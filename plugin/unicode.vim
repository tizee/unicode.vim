if exists('loaded_unicode_vim') || &cp || v:version < 700
  finish
endif
let g:loaded_unicode_vim = 1
let g:debug_unicode_vim = 0
let g:min_unicode=get(g:,'min_unicode',0x0)
let g:max_unicode=get(g:,'max_unicode',0x10ffff)

function! s:IsValidUnicodeValue(code) abort
 let result = matchlist(a:code,'\v(0x){0,1}(\x{1,6})')
 let result = filter(result,{ _,val -> len(val) >= 0 && len(matchstr(val,'0x')) == 0})
 let value=-1
 if len(result) > 0
   let code_str = result[0]
   if len(code_str) > 0
     let value = str2nr(code_str,16)
   else
     let value = -1
   endif
 endif
 " \u0000-\u10ffff
 return [value >= g:min_unicode && value <= g:max_unicode, code_str]
endfunction

function! s:ToUnicode(code, ...) abort range
  if a:firstline != a:lastline
    echoerr "Only support unicode in the same line"
    return
  endif
  let value = a:code
	let cursor_pos = getcurpos() " [0, lnum, col, off, curswant]
	let saved_pos = getpos('.')
	let saved_pos[0] = cursor_pos[0]
	let saved_pos[1] = cursor_pos[1]
	let saved_pos[2] = cursor_pos[4] - 1
	let saved_pos[3] = cursor_pos[3]
  if len(value) == 0
    " treat selected string as unicode
    " left column: trimmed if visual selection doesn't start on the first
    " column
    let leftCol = getpos("'<")[2]
    " right column: cut if visual selection doesn't end on the last column
    let rightCol = getpos("'>")[2]
    let value = getline(a:firstline)[leftCol - 1: rightCol - (&selection == 'inclusive' ? 1 : 2)]
		let saved_pos[2] = leftCol
  endif
  let [is_valid, code_str] = s:IsValidUnicodeValue(value)
  if is_valid
    " convert the unicode vlaue to the corresponding character
		" insert the character before the unicode value
    " based on help i_CTRL-V or i_CTRL-Q
		echoerr join(saved_pos," ")
    call setpos('.', saved_pos)
    call feedkeys("iU" . code_str . "\<esc>", 'n')
  endif
  call setpos('.', saved_pos)
	unlet saved_pos
	unlet cursor_pos
endfunction

" return substring of val
" val[left:right] inclusive
function! s:GetCharacterSubString(val, start, len)
	let str = a:val
	if type(str) == v:t_string
		return str[byteidx(str,a:start): byteidx(str,a:start+a:len) - 1]
	endif
endfunction

function! s:GetUnicode(val, ...) abort
  if a:firstline != a:lastline
    echoerr "Only support string in the same line"
    return
  endif
	let str = a:val
	" [buf, line, col, off, curswant]
	let cursor_pos = getcurpos() " [0, lnum, col, off, curswant]
	let saved_pos = getpos('.')
	let saved_pos[0] = cursor_pos[0]
	let saved_pos[1] = cursor_pos[1]
	let saved_pos[2] = cursor_pos[4] - 1
	let saved_pos[3] = cursor_pos[3]
	let l:codes = str2list(str)
	if len(str) == 0
		" [bufnum, lnum, col, off]
    let leftCol = getcharpos("'<")[2]
    let rightCol = getcharpos("'>")[2]
		let line = getline(saved_pos[1])[leftCol - 1:]
		let str = s:GetCharacterSubString(line, 0, rightCol - leftCol + 1)
		if g:debug_unicode_vim == 1
			echoerr "GetUnicode: leftCol " . leftCol . " rightCol " . rightCol
			echoerr "GetUnicode: substring " . str
			echoerr "GetUnicode: value ". str
		endif
		let l:codes = str2list(str)
		let saved_pos[2] = leftCol
	endif
	if len(l:codes) > 0
		let hex_strs = []
		for code in l:codes
			if g:debug_unicode_vim == 1
				echoerr "GetUnicode: code ". code
			endif
			let hex_str = '0x' . printf("%X", code)
			call add(hex_strs, hex_str)
		endfor
		let res = join(hex_strs, " ")
		if g:debug_unicode_vim == 1
			echoerr "GetUnicode: ". res
		endif
    call setpos('.', saved_pos)
		call feedkeys("i" . res . "\<esc>", 'n')
		call setpos('.', saved_pos)
	endif
endfunction

command! -range -nargs=* GetUnicode <line1>,<line2>call<SID>GetUnicode(<q-args>)
command! -range -nargs=* Unicode  <line1>,<line2>call<SID>ToUnicode(<q-args>)

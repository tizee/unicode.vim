if exists('loaded_unicode_vim') || &cp || v:version < 700
  finish
endif
let g:loaded_unicode_vim = 1
let g:min_unicode=get(g:,'min_unicode',0x0)
let g:max_unicode=get(g:,'max_unicode',0x10ffff)

function! s:IsValidUnicodeValue(code) abort
 let result = matchlist(a:code,'\v(0x){0,1}(\x{1,6})')
 let result = filter(result,{ _,val -> len(val) >= 0 && len(matchstr(val,'0x')) == 0})
 if len(result) > 0
   let code_str = result[0]
   if len(code_str) > 0
     let value = str2nr(code_str,16)
   else
     let value = -1
 endif
 " \u0000-\u10ffff
 return [value >= g:min_unicode && value <= g:max_unicode, code_str]
endfunction

function! s:ToUnicode(code, ...) abort range
  let range = a:firstline . "," . a:lastline
  let cursor_pos = getcurpos() " [0, lnum, col, off, curswant]
  let save_cursor = getpos('.') " [bufnum, lnum, col, off]
  let save_cursor[0] = bufnr()
  let save_cursor[2] = cursor_pos[4] " actual col
  let save_cursor[3] = cursor_pos[3] " off
  if a:firstline != a:lastline
    echoerr "Only support unicode in the same line"
    return
  endif 
  let value = a:code
  if len(value) == 0
    " treat selected string as unicode
    " left column: trimmed if visual selection doesn't start on the first
    " column
    let leftCol = getpos("'<")[2] 
    " right column: cut if visual selection doesn't end on the last column
    let rightCol = getpos("'>")[2]
    let value = getline(a:firstline)[leftCol - 1: rightCol - (&selection == 'inclusive' ? 1 : 2)]
  endif
  let [is_valid, code_str] = s:IsValidUnicodeValue(value)
  if is_valid
    " replace the unicode vlaue to the corresponding charactere
    " based on help i_CTRL-V or i_CTRL-Q
    let save_cursor[2] = cursor_pos[4]-1
    call setpos('.', save_cursor)
    call feedkeys("iU" . code_str . "\<esc>")
    " execute "normal! iU". code_str
  endif
  let save_cursor[2] = cursor_pos[4]
  call setpos('.', save_cursor)
  unlet save_cursor
endfunction

command! -range -nargs=* Unicode  <line1>,<line2>call<SID>ToUnicode(<q-args>)

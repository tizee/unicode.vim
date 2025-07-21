" ============================================================================
" File:         unicode.vim
" Description:  Unicode plugin for converting between Unicode characters and
"               their various string representations
" Author:       tizee <https://github.com/tizee>
" Version:      1.0.0
" License:      MIT License
" Homepage:     https://github.com/tizee/unicode.vim
" ============================================================================

if exists('loaded_unicode_vim') || &cp || v:version < 700
  finish
endif
let g:loaded_unicode_vim = 1
let g:unicode_vim_version = '1.0.0'
let g:debug_unicode_vim = 0
let g:min_unicode=get(g:,'min_unicode',0x0)
let g:max_unicode=get(g:,'max_unicode',0x10ffff)

" Core functions moved to autoload/unicode.vim for reusability

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
  " Try enhanced Unicode format parsing first
  let [is_enhanced_valid, enhanced_code] = unicode#parse_formats(value)
  if is_enhanced_valid
    let unicode_char = unicode#hex_to_char(enhanced_code)
    if len(unicode_char) > 0
      if g:debug_unicode_vim == 1
        echoerr "ToUnicode: " . value . " -> " . enhanced_code . " -> " . unicode_char
      endif
      call setpos('.', saved_pos)
      call feedkeys("i" . unicode_char . "\<esc>", 'n')
      call setpos('.', saved_pos)
      unlet saved_pos
      unlet cursor_pos
      return
    else
      echohl ErrorMsg
      echo "Unicode value out of range: " . enhanced_code
      echohl None
      call setpos('.', saved_pos)
      unlet saved_pos
      unlet cursor_pos
      return
    endif
  endif
  " Fall back to original validation method
  let [is_valid, code_str] = unicode#is_valid_value(value)
  if is_valid
    " convert the unicode vlaue to the corresponding character
  " insert the character before the unicode value
    " based on help i_CTRL-V or i_CTRL-Q
    if g:debug_unicode_vim == 1
      echoerr "ToUnicode (fallback): " . join(saved_pos," ")
    endif
    call setpos('.', saved_pos)
    call feedkeys("iU" . code_str . "\<esc>", 'n')
  else
    echohl ErrorMsg
    echo "Invalid Unicode format: " . value
    echohl None
  endif
  call setpos('.', saved_pos)
 unlet saved_pos
 unlet cursor_pos
endfunction

" GetCharacterSubString function moved to autoload/unicode.vim#get_substring

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
  let str = unicode#get_substring(line, 0, rightCol - leftCol + 1)
  if g:debug_unicode_vim == 1
   echoerr "GetUnicode: leftCol " . leftCol . " rightCol " . rightCol
   echoerr "GetUnicode: substring " . str
   echoerr "GetUnicode: value ". str
  endif
  let l:codes = str2list(str)
  let saved_pos[2] = leftCol
 endif
 if len(l:codes) > 0
  " Use autoload function for character to hex conversion
  let hex_codes = unicode#char_to_hex(str)
  let hex_strs = []
  for hex_code in hex_codes
   if g:debug_unicode_vim == 1
    echoerr "GetUnicode: hex_code ". hex_code
   endif
   let hex_str = '0x' . hex_code
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

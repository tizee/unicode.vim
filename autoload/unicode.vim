" ============================================================================
" File:         autoload/unicode.vim
" Description:  Unicode plugin autoload functions - core functionality for
"               converting between Unicode characters and string representations
" Author:       tizee <https://github.com/tizee>
" Version:      1.0.0
" License:      MIT License
" Homepage:     https://github.com/tizee/unicode.vim
" ============================================================================
"
" This file contains the core logic moved from plugin/unicode.vim for
" reusability and proper plugin architecture.

" Validate Unicode hex value (moved from s:IsValidUnicodeValue)
" Returns [is_valid, hex_code]
function! unicode#is_valid_value(code) abort
 let result = matchlist(a:code,'\v^(0x)?(\x{1,6})$')
 let value=-1
 let code_str = ""
 if len(result) > 0
   let code_str = result[2]  " Get hex part without 0x prefix
   if len(code_str) > 0
     let value = str2nr(code_str,16)
   else
     let value = -1
   endif
 endif
 " \u0000-\u10ffff
 let min_unicode = get(g:, 'min_unicode', 0x0)
 let max_unicode = get(g:, 'max_unicode', 0x10ffff)
 return [value >= min_unicode && value <= max_unicode, code_str]
endfunction

" Enhanced function to parse various Unicode string formats
" Returns [is_valid, hex_code]
function! unicode#parse_formats(text) abort
  let text = a:text
  let hex_code = ""
  
  " Remove common prefixes and suffixes to extract hex value
  " Format: \u1234 (JavaScript/JSON style) - supports 1-6 hex digits
  let match = matchlist(text, '\v\\u(\x{1,6})')
  if len(match) > 0
    let hex_code = match[1]
    return [1, hex_code]
  endif
  
  " Format: \U12345678 (8-digit Unicode)
  let match = matchlist(text, '\v\\U(\x{8})')
  if len(match) > 0
    let hex_code = match[1]
    return [1, hex_code]
  endif
  
  " Format: U+1234 (Unicode notation)
  let match = matchlist(text, '\vU\+(\x{1,6})')
  if len(match) > 0
    let hex_code = match[1]
    return [1, hex_code]
  endif
  
  " Format: &#x1234; (HTML entity)
  let match = matchlist(text, '\v&#x(\x{1,6});')
  if len(match) > 0
    let hex_code = match[1]
    return [1, hex_code]
  endif
  
  " Format: \x{1234} (Perl/regex style)
  let match = matchlist(text, '\v\\x\{(\x{1,6})\}')
  if len(match) > 0
    let hex_code = match[1]
    return [1, hex_code]
  endif
  
  " Format: 0x1234 or just hex digits (use existing validation)
  let [is_valid, code_str] = unicode#is_valid_value(text)
  if is_valid
    return [1, code_str]
  endif
  
  return [0, ""]
endfunction

" Convert hex code to Unicode character
" Returns the Unicode character or empty string if invalid
function! unicode#hex_to_char(hex_code) abort
  let decimal_value = str2nr(a:hex_code, 16)
  let min_unicode = get(g:, 'min_unicode', 0x0)
  let max_unicode = get(g:, 'max_unicode', 0x10ffff)
  
  if decimal_value >= min_unicode && decimal_value <= max_unicode
    return nr2char(decimal_value)
  else
    return ''
  endif
endfunction

" Convert Unicode character(s) to hex codes
" Returns list of hex codes (moved from s:GetUnicode logic)
function! unicode#char_to_hex(char) abort
  let codes = str2list(a:char)
  let hex_codes = []
  for code in codes
    let hex_str = printf("%X", code)
    call add(hex_codes, hex_str)
  endfor
  return hex_codes
endfunction

" Get character substring (moved from s:GetCharacterSubString)
" val[left:right] inclusive
function! unicode#get_substring(val, start, len) abort
  let str = a:val
  if type(str) == v:t_string
    return str[byteidx(str,a:start): byteidx(str,a:start+a:len) - 1]
  endif
  return ""
endfunction

" Get Unicode range settings
function! unicode#get_range() abort
  let min_unicode = get(g:, 'min_unicode', 0x0)
  let max_unicode = get(g:, 'max_unicode', 0x10ffff)
  return [min_unicode, max_unicode]
endfunction
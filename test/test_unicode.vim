" Unicode Plugin Command Line Unit Tests
" This file is designed for non-interactive command line execution

" Test Results Storage
let s:test_results = []
let s:total_tests = 0
let s:passed_tests = 0

" Test Framework Functions
function! s:Assert(condition, message) abort
  let s:total_tests += 1
  if a:condition
    let s:passed_tests += 1
    let result = "✓ PASS: " . a:message
    call add(s:test_results, result)
    echo result
  else
    let result = "✗ FAIL: " . a:message
    call add(s:test_results, result)
    echo result
  endif
endfunction

function! s:AssertEqual(expected, actual, message) abort
  let condition = a:expected ==# a:actual
  let full_message = a:message . " (expected: " . string(a:expected) . ", got: " . string(a:actual) . ")"
  call s:Assert(condition, full_message)
endfunction

" Same test functions as before, but with output suitable for CLI
function! s:TestParseUnicodeFormats() abort
  echo "=== Testing unicode#parse_formats function ==="
  
  " Test JavaScript/JSON style \u1234
  let [valid, code] = unicode#parse_formats('\u1F600')
  call s:Assert(valid, "Should parse \\u1F600 format")
  call s:AssertEqual('1F600', code, "Should extract 1F600 from \\u1F600")
  
  " Test 8-digit Unicode \U12345678
  let [valid, code] = unicode#parse_formats('\U0001F600')
  call s:Assert(valid, "Should parse \\U0001F600 format")
  call s:AssertEqual('0001F600', code, "Should extract 0001F600 from \\U0001F600")
  
  " Test Unicode notation U+1234
  let [valid, code] = unicode#parse_formats('U+1F600')
  call s:Assert(valid, "Should parse U+1F600 format")
  call s:AssertEqual('1F600', code, "Should extract 1F600 from U+1F600")
  
  " Test HTML entity &#x1234;
  let [valid, code] = unicode#parse_formats('&#x1F600;')
  call s:Assert(valid, "Should parse &#x1F600; format")
  call s:AssertEqual('1F600', code, "Should extract 1F600 from &#x1F600;")
  
  " Test Perl style \x{1234}
  let [valid, code] = unicode#parse_formats('\x{1F600}')
  call s:Assert(valid, "Should parse \\x{1F600} format")
  call s:AssertEqual('1F600', code, "Should extract 1F600 from \\x{1F600}")
  
  " Test traditional hex format 0x1234
  let [valid, code] = unicode#parse_formats('0x1F600')
  call s:Assert(valid, "Should parse 0x1F600 format")
  call s:AssertEqual('1F600', code, "Should extract 1F600 from 0x1F600")
  
  " Test plain hex format
  let [valid, code] = unicode#parse_formats('1F600')
  call s:Assert(valid, "Should parse plain 1F600 format")
  call s:AssertEqual('1F600', code, "Should extract 1F600 from plain 1F600")
  
  " Test invalid format
  let [valid, code] = unicode#parse_formats('invalid')
  call s:Assert(!valid, "Should reject invalid format")
  call s:AssertEqual('', code, "Should return empty string for invalid format")
  
  " Test empty string
  let [valid, code] = unicode#parse_formats('')
  call s:Assert(!valid, "Should reject empty string")
  
  " Test case sensitivity
  let [valid, code] = unicode#parse_formats('\u1f600')
  call s:Assert(valid, "Should parse lowercase hex \\u1f600")
  call s:AssertEqual('1f600', code, "Should preserve case for lowercase hex")
endfunction

function! s:TestIsValidUnicodeValue() abort
  echo "=== Testing unicode#is_valid_value function ==="
  
  " Test valid hex values
  let [valid, code] = unicode#is_valid_value('1F600')
  call s:Assert(valid, "Should validate plain hex 1F600")
  call s:AssertEqual('1F600', code, "Should return 1F600")
  
  let [valid, code] = unicode#is_valid_value('0x1F600')
  call s:Assert(valid, "Should validate 0x1F600")
  call s:AssertEqual('1F600', code, "Should return 1F600 without 0x prefix")
  
  " Test edge cases
  let [valid, code] = unicode#is_valid_value('0')
  call s:Assert(valid, "Should validate single digit 0")
  
  let [valid, code] = unicode#is_valid_value('10FFFF')
  call s:Assert(valid, "Should validate max Unicode value 10FFFF")
  
  " Test invalid values (beyond Unicode range)
  let [valid, code] = unicode#is_valid_value('110000')
  call s:Assert(!valid, "Should reject values beyond Unicode range")
  
  " Test invalid format
  let [valid, code] = unicode#is_valid_value('xyz')
  call s:Assert(!valid, "Should reject non-hex values")
endfunction

function! s:TestUnicodeConversion() abort
  echo "=== Testing Unicode Character Conversion ==="
  
  " Test conversion of various formats to expected decimal values
  let test_cases = [
    \ ['\u1F600', 0x1F600],
    \ ['U+1F600', 0x1F600],
    \ ['&#x1F600;', 0x1F600],
    \ ['\x{1F600}', 0x1F600],
    \ ['0x1F600', 0x1F600],
    \ ['\u0041', 0x41],
    \ ['U+0041', 0x41],
    \ ]
  
  for [input, expected_decimal] in test_cases
    let [valid, code] = unicode#parse_formats(input)
    if valid
      let actual_decimal = str2nr(code, 16)
      call s:AssertEqual(expected_decimal, actual_decimal, "Decimal conversion for " . input)
      
      " Test character conversion
      let char = unicode#hex_to_char(code)
      call s:Assert(len(char) > 0, "Should produce valid character for " . input)
    else
      call s:Assert(0, "Should parse " . input . " successfully")
    endif
  endfor
endfunction

function! s:TestEdgeCases() abort
  echo "=== Testing Edge Cases ==="
  
  " Test minimum Unicode value
  let [valid, code] = unicode#parse_formats('U+0000')
  call s:Assert(valid, "Should handle minimum Unicode U+0000")
  let decimal = str2nr(code, 16)
  let [min_unicode, max_unicode] = unicode#get_range()
  call s:Assert(decimal >= min_unicode, "Should be within min range")
  
  " Test maximum Unicode value
  let [valid, code] = unicode#parse_formats('U+10FFFF')
  call s:Assert(valid, "Should handle maximum Unicode U+10FFFF")
  let decimal = str2nr(code, 16)
  let [min_unicode, max_unicode] = unicode#get_range()
  call s:Assert(decimal <= max_unicode, "Should be within max range")
  
  " Test common emoji ranges
  let emoji_tests = ['1F600', '1F60A', '1F44D', '2764', '1F680']
  for emoji_hex in emoji_tests
    let [valid, code] = unicode#parse_formats('U+' . emoji_hex)
    call s:Assert(valid, "Should parse emoji U+" . emoji_hex)
    let char = unicode#hex_to_char(code)
    call s:Assert(len(char) > 0, "Should generate character for emoji " . emoji_hex)
  endfor
  
  " Test various lengths
  let [valid, code] = unicode#parse_formats('U+41')  " Short form
  call s:Assert(valid, "Should handle short Unicode U+41")
  
  let [valid, code] = unicode#parse_formats('U+0041')  " Padded form
  call s:Assert(valid, "Should handle padded Unicode U+0041")
endfunction

" No file saving needed - all results output directly to terminal

function! s:RunAllTestsCLI() abort
  echo "Starting Unicode Plugin Tests (CLI Mode)..."
  echo "============================================"
  
  try
    " Initialize test counters
    let s:test_results = []
    let s:total_tests = 0
    let s:passed_tests = 0
    
    " Run all test suites
    call s:TestParseUnicodeFormats()
    echo ""
    call s:TestIsValidUnicodeValue()
    echo ""
    call s:TestUnicodeConversion()
    echo ""
    call s:TestEdgeCases()
    echo ""
    
    " Display summary
    echo "============================================"
    echo "Test Summary:"
    echo "Total tests: " . s:total_tests
    echo "Passed: " . s:passed_tests
    echo "Failed: " . (s:total_tests - s:passed_tests)
    
    if s:passed_tests == s:total_tests
      echo "🎉 All tests passed!"
    else
      echo "❌ Some tests failed."
    endif
    
    " All results already output to terminal - no file saving needed"
    
  catch
    echo "Error during test execution: " . v:exception
  endtry
endfunction

" Main function called from command line
function! RunTestsAndExit() abort
  call s:RunAllTestsCLI()
  
  " Exit with appropriate code
  if s:passed_tests == s:total_tests && s:total_tests > 0
    quit!
  else
    " Exit with error code
    cquit!
  endif
endfunction

" Show that CLI test module is loaded
echo "Unicode Plugin CLI Test Module Loaded"
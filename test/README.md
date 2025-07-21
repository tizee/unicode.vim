# Unicode Plugin Testing Guide

This test suite validates the Unicode plugin functionality, including parsing and conversion of various Unicode formats.

## How to Run Tests

### 1. Command Line Execution (Recommended)

```bash
# Run from plugin root directory
./run_tests.sh
```

This method will:
- ✅ Use clean Vim environment (no user configuration loaded)
- ✅ Automatically run all 57 test cases
- ✅ Provide clear pass/fail reporting
- ✅ Return appropriate exit codes (suitable for CI/CD)
- ✅ Output results directly to terminal

### 2. Running Tests in Vim

```vim
" Load plugin and test file
:set runtimepath+=.
:source test/test_unicode.vim
:call RunTestsAndExit()
```

### 3. Manual Function Verification

Test various Unicode formats manually in Vim:
```vim
" Test conversion functionality
:Unicode \u1F600    " Should display 😀
:Unicode U+1F44D    " Should display 👍
:GetUnicode 😀      " Should display 0x1F600
```

## Test Architecture

### Test File Structure
```
test/
├── test_unicode.vim        # Main test suite (57 test cases)
└── README.md              # This documentation file
```

### Test Output
Command line tests output results directly to terminal, including:
- Detailed test execution progress
- Pass/fail status for each test case
- Final test summary statistics

### Exit Codes
- `0`: All 57 test cases passed
- `1`: Some tests failed or execution error occurred

### CI/CD Integration Examples

```yaml
# GitHub Actions example
- name: Run Unicode Plugin Tests
  run: |
    cd path/to/unicode.vim
    ./run_tests.sh
```

```bash
# Simple script integration
#!/bin/bash
if ./run_tests.sh; then
    echo "Tests passed, ready for release..."
else
    echo "Tests failed, check test output"
    exit 1
fi
```

## Test Case Examples

Here are some Unicode formats you can use for manual testing:

```
\u1F600    (grinning face emoji 😀)
U+1F44D    (thumbs up emoji 👍)  
&#x2764;   (red heart emoji ❤️)
\x{1F680}  (rocket emoji 🚀)
0x1F60A    (smiling face emoji 😊)
\U0001F600 (grinning face emoji 😀)
```

## Test Coverage

The test suite contains **57 test cases** covering the following functionality:

### 1. unicode#parse_formats() Function Tests (20 tests)
- ✅ JavaScript/JSON style: `\u1234`
- ✅ 8-digit Unicode: `\U12345678`  
- ✅ Unicode standard notation: `U+1234`
- ✅ HTML entities: `&#x1234;`
- ✅ Perl style: `\x{1234}`
- ✅ Hexadecimal with prefix: `0x1234`
- ✅ Plain hexadecimal: `1234`
- ✅ Mixed case testing
- ✅ Invalid format rejection

### 2. unicode#is_valid_value() Function Tests (8 tests)
- ✅ Valid hexadecimal value validation
- ✅ Unicode range checking (0x0 - 0x10FFFF)
- ✅ Boundary value testing
- ✅ Invalid format rejection

### 3. Unicode Character Conversion Tests (19 tests)
- ✅ Hexadecimal to Unicode character conversion
- ✅ Character to hexadecimal conversion
- ✅ Multi-character processing
- ✅ Emoji character support

### 4. Integration and Boundary Tests (10 tests)
- ✅ Minimum Unicode value (U+0000)
- ✅ Maximum Unicode value (U+10FFFF)
- ✅ Common emoji ranges (U+1F600, etc.)
- ✅ Error handling and exception cases

## Expected Output

When running `./run_tests.sh`, you should see output similar to:

```
[INFO] Starting Unicode Plugin Tests in Clean Environment
[INFO] Plugin directory: /path/to/unicode.vim
[INFO] Test directory: /path/to/unicode.vim/test
[INFO] Running tests with clean Vim configuration...

Unicode Plugin CLI Test Module Loaded
Starting Unicode Plugin Tests (CLI Mode)...
============================================
=== Testing unicode#parse_formats function ===
✓ PASS: Should parse \u1F600 format
✓ PASS: Should extract 1F600 from \u1F600 (expected: '1F600', got: '1F600')
✓ PASS: Should parse \U0001F600 format
...
=== Testing unicode#is_valid_value function ===
✓ PASS: Should validate plain hex 1F600
...
=== Testing Unicode Character Conversion ===
✓ PASS: Should convert hex 1F600 to emoji
...

Total tests: 57
Passed: 57
Failed: 0
🎉 All tests passed!

[INFO] Test execution completed with exit code: 0
[INFO] 🎉 All tests passed!
```

## Troubleshooting

If tests fail:

1. **Check if plugin loads correctly**
   ```vim
   :echo exists('g:loaded_unicode_vim')
   ```

2. **Enable debug mode**
   ```vim
   :let g:debug_unicode_vim = 1
   ```

3. **Check Unicode range settings**
   ```vim
   :echo g:min_unicode
   :echo g:max_unicode
   ```

4. **Review test output**
   All test information is displayed directly in the terminal

## Adding New Test Cases

To add new test cases, edit the `test/test_unicode.vim` file:

```vim
function! s:TestNewFeature() abort
    echo "=== Testing New Feature ==="
    
    " Add test assertions
    call s:AssertTrue(condition, "test description")
    call s:AssertEqual(expected, actual, "test description")
    call s:AssertFalse(condition, "negative test description")
endfunction

" Add the call in RunTestsAndExit function
call s:TestNewFeature()
```

### Available Assertion Functions

- `s:AssertTrue(condition, message)` - Assert condition is true
- `s:AssertFalse(condition, message)` - Assert condition is false  
- `s:AssertEqual(expected, actual, message)` - Assert values are equal
- `s:AssertNotEqual(expected, actual, message)` - Assert values are not equal

This makes it easy to extend the test suite!
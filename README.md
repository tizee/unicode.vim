# Unicode.vim

A comprehensive Vim plugin for converting between Unicode characters and their various string representations. Supports multiple Unicode formats including emoji conversion.

**Version:** 1.0.0  
**Author:** tizee  
**Homepage:** https://github.com/tizee/unicode.vim

## Features

- **Bidirectional conversion**: Unicode strings ↔ actual characters
- **Multiple Unicode formats**: `\u1F600`, `\U0001F600`, `U+1F600`, `&#x1F600;`, `\x{1F600}`, `0x1F600`
- **Emoji support**: Convert Unicode strings to actual emoji characters 😀👍❤️
- **Visual selection support**: Works with selected text
- **API functions**: Reusable autoload functions for other plugins
- **Comprehensive documentation**: Full Vim help system integration

![usage](https://user-images.githubusercontent.com/33030965/129754099-a8da88aa-c63d-4e15-b440-5f5e3528ffbc.gif)

## Installation

### Using vim-plug
```vim
Plug 'tizee/unicode.vim'
```

### Using Vundle
```vim
Plugin 'tizee/unicode.vim'
```

### Manual installation
```bash
git clone https://github.com/tizee/unicode.vim ~/.vim/bundle/unicode.vim
```

Add to your runtime path in `.vimrc`:
```vim
set runtimepath^=~/.vim/bundle/unicode.vim
```

After installation, generate help tags:
```vim
:helptags ~/.vim/doc
```

## Quick Start

### Convert Unicode strings to characters

```vim
" Place cursor on Unicode string and run:
:Unicode

" Or specify directly:
:Unicode \u1F600    " → 😀
:Unicode U+1F44D    " → 👍  
:Unicode &#x2764;   " → ❤️
```

### Convert characters to Unicode

```vim
" Place cursor on character and run:
:GetUnicode

" Examples:
:GetUnicode 😀      " → 0x1F600
:GetUnicode Hello   " → 0x48 0x65 0x6C 0x6C 0x6F
```

## Commands

| Command | Description | Example |
|---------|-------------|---------|
| `:Unicode [string]` | Convert Unicode string to character | `:Unicode \u1F600` → 😀 |
| `:GetUnicode [string]` | Convert character to hex representation | `:GetUnicode 😀` → 0x1F600 |

Both commands work with visual selections when no argument is provided.

## Supported Unicode Formats

| Format | Example | Description |
|--------|---------|-------------|
| `\u1234` | `\u1F600` | JavaScript/JSON style (4 hex digits) |
| `\U12345678` | `\U0001F600` | 8-digit Unicode |
| `U+1234` | `U+1F600` | Unicode standard notation |
| `&#x1234;` | `&#x1F600;` | HTML entity |
| `\x{1234}` | `\x{1F600}` | Perl/regex style |
| `0x1234` | `0x1F600` | Hexadecimal with prefix |
| `1234` | `1F600` | Plain hexadecimal |

## API Functions

The plugin provides autoload functions for use in other plugins:

```vim
" Parse Unicode format and extract hex code
let [valid, hex] = unicode#parse_formats('\u1F600')

" Convert hex to character  
let char = unicode#hex_to_char('1F600')

" Convert character to hex codes
let hex_list = unicode#char_to_hex('Hello')

" Validate Unicode value
let [valid, clean_hex] = unicode#is_valid_value('0x1F600')
```

See `:help unicode-functions` for complete API documentation.

## Configuration

```vim
" Enable debug output (default: 0)
let g:debug_unicode_vim = 1

" Set Unicode range (defaults shown)
let g:min_unicode = 0x0
let g:max_unicode = 0x10FFFF

" Disable plugin loading
let g:loaded_unicode_vim = 1

" Check plugin version (read-only, set automatically)
echo g:unicode_vim_version  " 1.0.0
```

## Documentation

Complete documentation is available through Vim's help system:

```vim
:help unicode           " Main help
:help :Unicode         " Unicode command
:help :GetUnicode      " GetUnicode command  
:help unicode-functions " API functions
:help unicode-examples  " Usage examples
```

## Development

### Project Structure

```
unicode.vim/
├── autoload/unicode.vim    # Core functionality (reusable API)
├── plugin/unicode.vim      # User commands and UI logic
├── doc/unicode.txt         # Vim help documentation
├── doc/tags               # Generated help tags
├── test/                  # Unit test suite
│   ├── test_unicode.vim
│   └── README.md
├── run_tests.sh           # Command-line test runner
├── update_doc.sh          # Documentation helper
├── release.sh             # Automated release script
├── version.sh             # Version information script
└── README.md
```

### Running Tests

Execute the comprehensive test suite:

```bash
# Run all unit tests (57 test cases)
./run_tests.sh

# Expected output:
# Total tests: 57
# Passed: 57
# Failed: 0
# 🎉 All tests passed!
```

The test suite runs in a clean Vim environment and covers:
- All supported Unicode formats
- Edge cases and boundary conditions  
- Error handling
- API function validation

### Updating Documentation

After modifying `doc/unicode.txt`:

```bash
# Regenerate help tags
./update_doc.sh

# Or manually:
vim -u NONE -c "helptags doc/" -c "quit"
```

### Development Workflow

1. **Make changes** to plugin code
2. **Run tests** with `./run_tests.sh` 
3. **Update documentation** if needed
4. **Regenerate tags** with `./update_doc.sh`
5. **Test manually** in Vim: `:help unicode`

### Release Workflow

For creating new releases:

```bash
# Check current version and status
./version.sh

# Create git tag with current commit message
./release.sh

# Preview what the release script would do (dry run)
./release.sh --dry-run
```

The release script will:
- Extract version from plugin file (`g:unicode_vim_version`)
- Use current git commit message as release notes
- Create annotated git tag (e.g., `v1.0.0`)
- Optionally push tag to remote repository

### Architecture

- **Plugin file** (`plugin/unicode.vim`): Defines user commands, handles UI interactions
- **Autoload file** (`autoload/unicode.vim`): Core functions, reusable API for other plugins  
- **Documentation** (`doc/unicode.txt`): Complete help system integration
- **Tests** (`test/`): Comprehensive unit test coverage

### Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run the test suite: `./run_tests.sh`
5. Update documentation if needed
6. Submit a pull request

### Testing Your Changes

```bash
# Test core functionality
./run_tests.sh

# Test documentation  
./update_doc.sh

# Check version and git status
./version.sh

# Manual testing in clean environment
vim -u NONE -c 'set runtimepath+=.' -c 'help unicode'
```

### Release Management

```bash
# Check current status before release
./version.sh

# Preview release without making changes
./release.sh --dry-run

# Create new release with current commit message
./release.sh

# The release script will:
# 1. Read version from plugin file
# 2. Check for uncommitted changes
# 3. Create annotated git tag using commit message
# 4. Optionally push to remote
```

## Examples

### Basic Usage
```vim
" Convert various Unicode formats
:Unicode \u1F600    " 😀
:Unicode U+1F44D    " 👍
:Unicode &#x2764;   " ❤️

" Get hex codes
:GetUnicode 🚀     " 0x1F680
```

### Batch Processing
```vim
" Replace all \u sequences in buffer with actual characters
:%s/\\u\(\x\{4\}\)/\=unicode#hex_to_char(submatch(1))/g
```

### Using in Scripts
```vim
function! ConvertUnicodeInLine()
    let line = getline('.')
    let [valid, hex] = unicode#parse_formats(line)
    if valid
        let char = unicode#hex_to_char(hex)
        call setline('.', char)
    endif
endfunction
```

## Requirements

- Vim 7.0 or higher
- Terminal with Unicode support for proper emoji display

## License

MIT License

---

**Completed Development Tasks:**
- ✅ Enhanced Unicode format support (`\u`, `\U`, `U+`, `&#x`, `\x{}`)
- ✅ Comprehensive unit test suite (57 tests)
- ✅ Command-line test runner with clean environment
- ✅ Refactored architecture (plugin + autoload)
- ✅ Complete Vim documentation system
- ✅ API functions for plugin reusability
- ✅ Error handling and user feedback
- ✅ Development tooling and automation
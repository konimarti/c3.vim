# C3.vim

Vim plugin for the [C3 Programming Language](https://c3-lang.org).

## Features

- **Syntax Highlighting**: Complete, up-to-date highlighting for C3 (version 0.8.x), including built-in types, compile-time directives (`$`), compiler intrinsics (`$$`), attributes and macros (`@`), doc contracts (`<* ... *>`), nested comments (`/* ... */`), raw/hex/base64 string literals, and numbers with separators and suffixes.
- **Robust Comment Synchronization**: Fixed scrolling glitches in long comments and doc contracts via accurate syntax synchronization.
- **Deprecated Features Section**: Old/deprecated syntax (`def`, `distinct`, `isz`, `attribute`, etc.) is isolated and highlighted as deprecated.
- **Smart Indentation**: C-style bracket and control-flow indentation with support for `case`, `default`, `nextcase`, and doc contracts `<* ... *>`.
- **Compiler Support (`:make`)**: Integrates with `c3c` and parses modern error/warning/note diagnostics into Vim's quickfix list (`file:line:col`).
- **Code Formatting (`:C3Format`)**: Seamless formatting using `c3f` with optional format-on-save.
- **Linting (`:C3Vet`)**: Runs [`c3vet`](https://github.com/konimarti/c3vet) and loads its findings into the quickfix list.
- **Update Check (`:C3Update`)**: Compares the installed `c3c`, `c3f` and `c3vet` with their latest GitHub releases.

## Installation

Clone into your Vim/Neovim runtime directory, or use your plugin manager of choice:

```vim
" Vundle
Plugin 'konimarti/c3.vim'

" vim-plug
Plug 'konimarti/c3.vim'
```

## Configuration

### Code Formatting

Format the current buffer with the `:C3Format` command.

By default, formatting uses `c3f` (`c3f --stdin-filename <file> -`). You can customize the formatter and enable format-on-save in your `.vimrc`:

```vim
" Enable format-on-save (default: 0)
let g:c3_fmt_autosave = 1

" Customize the formatting command (default: 'c3f')
let g:c3_fmt_command = 'c3f'

" Pass additional options to the formatter (default: '')
let g:c3_fmt_options = ''
```

Format-on-save can also be controlled per-buffer:

```vim
let b:c3_fmt_autosave = 1
```

### Linting

Lint the current project (or explicit paths) with the `:C3Vet` command, powered by [`c3vet`](https://github.com/konimarti/c3vet). Findings are loaded into the quickfix list.

```vim
" Lint the whole project (default)
:C3Vet

" Lint specific paths
:C3Vet src/main.c3
```

Customize the linter command and options in your `.vimrc`:

```vim
" Customize the linter command (default: 'c3vet')
let g:c3_vet_command = 'c3vet'

" Pass additional options to the linter (default: '')
let g:c3_vet_options = '--disable=float-equal'
```

### Update Check

Check whether newer releases of the C3 tools are available with the `:C3Update` command. It compares the installed version of each tool with the latest GitHub release:

- [`c3c`](https://github.com/c3lang/c3c) (compiler)
- [`c3f`](https://github.com/konimarti/c3f) (formatter)
- [`c3vet`](https://github.com/konimarti/c3vet) (linter)

```vim
" Check all three tools (default)
:C3Update

" Check only some of them
:C3Update c3f c3vet
```

Without `!`, `:C3Update` only reports. With `!`, it also replaces each outdated tool that is already installed with the latest release:

```vim
" Check, and install newer releases of outdated tools
:C3Update!
:C3Update! c3f
```

How the install works:
- It downloads the release build for your platform (Linux x86_64 and macOS arm64, see the release pages for the exact assets).
- It verifies the download against the release's `SHA256SUMS` when one is published. c3c does not publish checksums, so its download is not verified.
- It checks that the new binary reports the expected version before anything is replaced.
- The old binary is kept as `<path>.bak`.
- Symlinked binaries are never replaced, so a dev build linked from elsewhere is left alone.
- Tools that are not installed are not installed by `!`.

`:C3Update` needs `curl` and network access. Installing also needs `tar` (or `unzip` for c3c on macOS) and `sha256sum` or `shasum`. Tools whose binary is not on your `PATH` are reported as not installed. If you point `g:c3_fmt_command` or `g:c3_vet_command` at a binary with a different name, that tool is skipped.

### Key Mappings

Buffer-local mappings are enabled by default:

| Mapping           | Action                     |
| ----------------- | --------------------------- |
| `<LocalLeader>cf` | Run `:C3Format`             |
| `<LocalLeader>cv` | Run `:C3Vet`                 |

They are defined via `<Plug>` mappings, so you can rebind them in your `.vimrc`:

```vim
autocmd FileType c3 nmap <buffer> <F3> <Plug>(c3-format)
autocmd FileType c3 nmap <buffer> <F4> <Plug>(c3-vet)
```

If you map `<Plug>(c3-format)` or `<Plug>(c3-vet)` yourself, the corresponding default `<LocalLeader>` mapping is skipped automatically. To disable the default mappings entirely:

```vim
let g:c3_no_mappings = 1
```

### Compiler Settings (`:make`)

The compiler plugin is automatically set to `c3c`. Running `:make` builds `project.json` if present (`c3c build`), or compiles the current file (`c3c compile %`).

To override the `makeprg` command:

```vim
" Example: custom build or check command
let g:c3_makeprg = 'c3c check'
```

### Syntax Synchronization

Syntax synchronization uses `fromstart` by default to ensure 100% accurate parsing of nested block comments and `<* ... *>` doc contracts.

For extremely large generated files where performance may be a concern:

```vim
" Disable fromstart and use minlines/maxlines heuristic
let g:c3_sync_fromstart = 0
let g:c3_sync_minlines = 200
let g:c3_sync_maxlines = 500
```

## License

MIT

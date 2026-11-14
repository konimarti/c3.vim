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

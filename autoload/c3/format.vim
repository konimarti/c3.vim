" Vim autoload file for C3 formatting
" Language: C3
" Maintainer: Koni Marti <koni.marti@gmail.com>

if exists("g:autoloaded_c3_format")
  finish
endif
let g:autoloaded_c3_format = 1

function! c3#format#Format() abort
  let l:cmd = get(g:, 'c3_fmt_command', get(g:, 'c3_format_command', 'c3f'))
  let l:bin = split(l:cmd)[0]

  if !executable(l:bin)
    echohl WarningMsg
    echomsg 'c3.vim: formatter "' . l:bin . '" is not executable or not in PATH'
    echohl None
    return
  endif

  let l:options = get(g:, 'c3_fmt_options', '')
  let l:filename = expand('%')
  if empty(l:filename)
    let l:filename = 'stdin.c3'
  endif

  let l:bin_tail = fnamemodify(l:bin, ':t')
  if l:bin_tail =~? 'c3f'
    let l:full_cmd = l:cmd . (empty(l:options) ? '' : ' ' . l:options) . ' --stdin-filename ' . shellescape(l:filename) . ' -'
  else
    let l:full_cmd = l:cmd . (empty(l:options) ? '' : ' ' . l:options)
  endif

  let l:err = tempname()
  let l:lines = getline(1, '$')
  let l:out = systemlist(l:full_cmd . ' 2>' . shellescape(l:err), l:lines)

  if v:shell_error == 0 && l:out !=# l:lines
    let l:view = winsaveview()
    call setline(1, l:out)
    if len(l:out) < line('$')
      silent execute (len(l:out) + 1) . ',$delete _'
    endif
    call winrestview(l:view)
  endif

  if filereadable(l:err)
    for l:msg in readfile(l:err)
      echohl WarningMsg
      echomsg l:msg
      echohl None
    endfor
    call delete(l:err)
  endif
endfunction

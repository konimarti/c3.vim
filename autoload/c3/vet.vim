" Vim autoload file for C3 vetting (c3vet)
" Language: C3
" Maintainer: Koni Marti <koni.marti@gmail.com>

if exists("g:autoloaded_c3_vet")
  finish
endif
let g:autoloaded_c3_vet = 1

function! c3#vet#Vet(args) abort
  let l:cmd = get(g:, 'c3_vet_command', 'c3vet')
  let l:bin = split(l:cmd)[0]

  if !executable(l:bin)
    echohl WarningMsg
    echomsg 'c3.vim: vet tool "' . l:bin . '" is not executable or not in PATH'
    echohl None
    return
  endif

  let l:options = get(g:, 'c3_vet_options', '')
  let l:paths = a:args
  if empty(l:paths) && !empty(expand('%'))
    if &modified
      silent update
    endif
    let l:paths = shellescape(expand('%:p'))
  endif

  let l:full_cmd = l:cmd
        \ . (empty(l:options) ? '' : ' ' . l:options)
        \ . (empty(l:paths) ? '' : ' ' . l:paths)

  let l:out = systemlist(l:full_cmd)
  let l:exit = v:shell_error

  if l:exit == 2
    echohl ErrorMsg
    echomsg 'c3.vim: c3vet failed to run' . (empty(l:out) ? '' : ': ' . l:out[0])
    echohl None
    return
  endif

  call setqflist([], ' ', {
        \ 'title': l:full_cmd,
        \ 'lines': l:out,
        \ 'efm': '%f:%l:%c:\ %m',
        \ })

  if empty(l:out)
    echomsg 'c3.vim: c3vet found no issues'
  else
    botright copen
  endif
endfunction

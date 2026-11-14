" Vim filetype plugin
" Language: C3
" Maintainer: Koni Marti <koni.marti@gmail.com>

if exists("b:did_ftplugin")
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

" Comments
setlocal comments=s1:/*,mb:*,ex:*/,:///,://
setlocal commentstring=//\ %s

" Format options
setlocal formatoptions-=t formatoptions+=croql

" File extensions for gf command
setlocal suffixesadd=.c3,.c3i,.c3t

" Default compiler
if !exists("b:did_compiler")
  compiler c3c
endif

" Formatting command (:C3Format)
command! -buffer -bar C3Format call c3#format#Format()

" Linting command (:C3Vet), runs c3vet over the given paths (default: project)
command! -buffer -bar -nargs=* -complete=file C3Vet call c3#vet#Vet(<q-args>)

" Format on save (buffer-local b:c3_fmt_autosave overrides global g:c3_fmt_autosave)
let s:autosave = get(b:, 'c3_fmt_autosave', get(g:, 'c3_fmt_autosave', get(g:, 'c3_format_on_save', 0)))
if s:autosave
  augroup C3FormatOnSave
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> call c3#format#Format()
  augroup END
else
  silent! autocmd! C3FormatOnSave * <buffer>
endif

" Key mappings, remap via <Plug>(c3-format)/<Plug>(c3-vet) or disable defaults
" with let g:c3_no_mappings = 1
nnoremap <buffer> <silent> <Plug>(c3-format) :C3Format<CR>
nnoremap <buffer> <silent> <Plug>(c3-vet) :C3Vet<CR>

let s:mapundo = ''
if !get(g:, 'c3_no_mappings', 0)
  if !hasmapto('<Plug>(c3-format)', 'n')
    nmap <buffer> <silent> <LocalLeader>cf <Plug>(c3-format)
    let s:mapundo .= ' | silent! nunmap <buffer> <LocalLeader>cf'
  endif
  if !hasmapto('<Plug>(c3-vet)', 'n')
    nmap <buffer> <silent> <LocalLeader>cv <Plug>(c3-vet)
    let s:mapundo .= ' | silent! nunmap <buffer> <LocalLeader>cv'
  endif
endif

let b:undo_ftplugin = "setlocal comments< commentstring< formatoptions< suffixesadd< | silent! delcommand C3Format | silent! delcommand C3Vet | silent! autocmd! C3FormatOnSave * <buffer> | silent! nunmap <buffer> <Plug>(c3-format) | silent! nunmap <buffer> <Plug>(c3-vet)" . s:mapundo

let &cpo = s:cpo_save
unlet s:cpo_save

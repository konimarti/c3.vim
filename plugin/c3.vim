" Vim plugin for C3
" Language: C3

if exists("g:loaded_c3_vim")
  finish
endif
let g:loaded_c3_vim = 1

let s:cpo_save = &cpo
set cpo&vim

" Update check for c3c, c3f and c3vet (global, works without a C3 buffer).
" With !, outdated tools that are already installed are replaced.
command! -bar -bang -nargs=* -complete=customlist,c3#update#Complete C3Update call c3#update#Update(<q-args>, <bang>0)

let &cpo = s:cpo_save
unlet s:cpo_save

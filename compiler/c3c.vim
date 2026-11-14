" Vim compiler file
" Language: C3
" Compiler: c3c
" Maintainer: Koni Marti <koni.marti@gmail.com>

if exists("current_compiler")
  finish
endif
let current_compiler = "c3c"

if exists(":CompilerSet") != 2
  command -nargs=* CompilerSet setlocal <args>
endif

let s:cpo_save = &cpo
set cpo&vim

if exists("g:c3_makeprg")
  execute 'CompilerSet makeprg=' . escape(g:c3_makeprg, ' ')
elseif filereadable('project.json')
  CompilerSet makeprg=c3c\ build
else
  CompilerSet makeprg=c3c\ compile\ %
endif

" Diagnostic errorformat matching modern c3c diagnostics:
"   file:line:col: error: message
"   file:line:col: warning: message
"   file:line:col: note: message
"   (file:line:col) message (legacy format)
"   file:line: error: message
CompilerSet errorformat=
      \%f:%l:%c:\ %trror:\ %m,
      \%f:%l:%c:\ %tarning:\ %m,
      \%f:%l:%c:\ %tote:\ %m,
      \%f:%l:%c:\ %m,
      \(%f:%l:%c)\ %m,
      \%f:%l:\ %trror:\ %m,
      \%f:%l:\ %tarning:\ %m,
      \%f:%l:\ %m,
      \%-G%*[\ ]^,
      \%-G%*[\ ]^%*[~],
      \%-G%*[\ ]...

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: ft=vim

if exists("c3c")
  finish
endif
let current_compiler = "c3c"

if filereadable('project.json')
  CompilerSet makeprg=c3c\ run
else
  CompilerSet makeprg=c3c\ -C\ compile\ %
endif

let s:cpo_save = &cpo
set cpo&vim

setlocal errorformat=(%f:%l:%c)\ %m,
			\%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save

"vim: ft=vim

au BufNewFile,BufRead *.c3,*.c3i,*.c3t set filetype=c3
autocmd BufEnter *.c3 :syntax sync fromstart
autocmd FileType c3 setlocal commentstring=//\ %s

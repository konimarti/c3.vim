" Vim indent file
" Language: C3
" Maintainer: Koni Marti <koni.marti@gmail.com>

if exists("b:did_indent")
  finish
endif
let b:did_indent = 1

setlocal nosmartindent
setlocal nolisp
setlocal autoindent
setlocal indentexpr=GetC3Indent(v:lnum)
setlocal indentkeys=0{,0},0),0],0=case,0=default,0=nextcase,0=*,0=*>

if exists("*GetC3Indent")
  finish
endif

function! GetC3Indent(lnum)
  let prev = prevnonblank(a:lnum - 1)
  if prev == 0
    return 0
  endif

  let prevline = getline(prev)
  let line = getline(a:lnum)
  let ind = indent(prev)

  " Comment continuation
  if prevline =~ '^\s*/\*' && line =~ '^\s*\*'
    return ind + 1
  endif
  if prevline =~ '^\s*\*[^/]' && line =~ '^\s*\*/'
    return ind - 1
  endif

  " Increase indent after open brackets, contracts, or case labels
  if prevline =~ '^\s*<[*]'
    let ind += &sw
  elseif prevline =~ '[({[]\s*$'
    let ind += &sw
  elseif prevline =~ '^\s*\(case\>.*:\|default:\|nextcase\>.*:\)\s*$'
    let ind += &sw
  endif

  " Decrease indent before closing brackets, doc contract close, or case labels
  if line =~ '^\s*[*][>]'
    let ind -= &sw
  elseif line =~ '^\s*[)}\]]'
    let ind -= &sw
  elseif line =~ '^\s*\(case\>.*:\|default:\|nextcase\>.*:\)'
    if prevline !~ '^\s*\(case\>.*:\|default:\|nextcase\>.*:\)' && prevline !~ '{\s*$'
      let ind -= &sw
    endif
  endif

  return ind
endfunction

let b:undo_indent = "setlocal autoindent< smartindent< lisp< indentexpr< indentkeys<"

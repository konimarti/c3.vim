" Vim syntax file
" Language: C3
" Maintainer: Koni Marti <koni.marti@gmail.com>

if exists("b:current_syntax")
  finish
endif

" --- Operators & Delimiters (defined early so comment start markers take precedence) ---
syntax match c3Operator display "\%(+\{1,3\}=\?\|-\{1,2\}=\?\|\*=\?\|/=\?\|%=\?\|&\{1,3\}=\?\||\{1,3\}=\?\|\^=\?\|<<=\?\|>>=\?\|==\|!=\|<=\|>=\|=>\|->\|\.\{2,3\}\|::\|??\?\|!!\)"
syntax match c3VectorDelimiter display "\%(\[<\|>\]\)"
syntax match c3Delimiter display "[{}();,]"

" --- Keywords ---
syntax keyword c3Break break
syntax keyword c3Case case
syntax keyword c3Continue continue
syntax keyword c3Default default
syntax keyword c3Do do
syntax keyword c3Else else
syntax keyword c3For for
syntax keyword c3Foreach foreach
syntax keyword c3Foreachr foreach_r
syntax keyword c3If if
syntax keyword c3Nextcase nextcase
syntax keyword c3Return return
syntax keyword c3Switch switch
syntax keyword c3While while

syntax keyword c3Catch catch
syntax keyword c3Try try
syntax keyword c3Defer defer

syntax keyword c3Alias alias
syntax keyword c3Asm asm
syntax keyword c3Assert assert
syntax keyword c3Attrmacro attrmacro
syntax keyword c3Bitstruct bitstruct
syntax keyword c3Const const
syntax keyword c3Constdef constdef
syntax keyword c3Constset constset
syntax keyword c3Enum enum
syntax keyword c3Extern extern
syntax keyword c3Faultdef faultdef
syntax keyword c3Fn fn
syntax keyword c3Import import
syntax keyword c3Inline inline
syntax keyword c3Interface interface
syntax keyword c3Lengthof lengthof
syntax keyword c3Macro macro
syntax keyword c3Module module
syntax keyword c3Static static
syntax keyword c3Struct struct
syntax keyword c3Tlocal tlocal
syntax keyword c3TypeDef typedef
syntax keyword c3Union union
syntax keyword c3Var var

" --- Deprecated / Legacy language features ---
syntax keyword c3Deprecated attribute attrdef def define distinct local anyfault isz byte
syntax match c3Deprecated "\$\%(feature\|assignable\|evaltype\)\>" display

" --- Built-in Types ---
syntax keyword c3DataType void bool char ichar short ushort int uint long ulong int128 uint128
syntax keyword c3DataType float double float16 bfloat float128 iptr uptr sz usz any fault typeid untypedlist

" --- Literals & Constants ---
syntax keyword c3Bool true false
syntax keyword c3Null null

" --- Compile-Time Directives & Built-ins ($) ---
syntax match c3CompileTimeVar display "\$[a-zA-Z_][a-zA-Z0-9_]*\>"
syntax match c3CompileTime display "\$\%(if\|else\|endif\|switch\|case\|default\|endswitch\|for\|endfor\|foreach\|endforeach\)\>"
syntax match c3CompileTimeFunc display "\$\%(assert\|defined\|echo\|embed\|error\|eval\|exec\|expand\|feat\|include\|reflect\|stringify\|Typefrom\|Typeof\|vaarg\)\>"

" --- Compiler Intrinsics ($$) ---
syntax match c3Builtin "\$\$\w\+" display

" --- Attributes & Macro Calls (@) ---
syntax match c3Attribute "@\<[a-zA-Z_][a-zA-Z0-9_]*\>" display
syntax match c3MacroCall "@\<[a-zA-Z_][a-zA-Z0-9_]*\>\ze\s*(" display

" --- Identifiers & Types ---
" PascalCase user-defined types (structs, enums, unions, distinct types, typedefs)
syntax match c3UserType "\<[A-Z][a-zA-Z0-9_]*\>" display
" UPPER_CASE constants
syntax match c3Constant "\<[A-Z_][A-Z0-9_]*\>" display

" --- Functions ---
syntax match c3FunctionCall "\<[a-z_][0-9A-Z_a-z]*\>\ze\s*(" display

" --- Strings, Chars & Data Literals ---
syntax match c3Escape display contained /\\\([nrtabe0\\'"]\|x\x\{2}\|u\x\{4}\|U\x\{8}\)/
syntax region c3String start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=c3Escape oneline
syntax region c3RawString start=+`+ end=+`+
syntax region c3HexString start=+x"+ end=+"+ start=+x`+ end=+`+
syntax region c3Base64String start=+b64"+ end=+"+ start=+b64`+ end=+`+
syntax region c3Char start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=c3Escape oneline

" --- Numbers ---
syntax match c3Integer "\<[0-9][0-9_]*\%([uU]\|[uU]\=[lL]\{1,2\}\)\?\>" display
syntax match c3Hex "\<0[xX][0-9a-fA-F_]\+\%([uU]\|[uU]\=[lL]\{1,2\}\)\?\>" display
syntax match c3Oct "\<0[oO][0-7_]\+\%([uU]\|[uU]\=[lL]\{1,2\}\)\?\>" display
syntax match c3Bin "\<0[bB][01_]\+\%([uU]\|[uU]\=[lL]\{1,2\}\)\?\>" display
syntax match c3Float "\<[0-9][0-9_]*\%(\.[0-9][0-9_]*\)\%([eE][+-]\=[0-9_]\+\)\=\%([fFdD]\)\?\>" display
syntax match c3Float "\<0[xX][0-9a-fA-F][0-9a-fA-F_]*\%(\.[0-9a-fA-F_]*\)\%([pP][+-]\=[0-9_]\+\)\%([fFdD]\)\?\>" display

" --- Comments & Contracts ---
syntax match c3Shebang "\%^#!.*"
syntax keyword c3Todo contained TODO NOTE FIXME XXX HACK NB SAFETY NOCHECKIN
syntax region c3LineComment start=/\/\// end=/$/ contains=c3Todo,@Spell
syntax region c3BlockComment matchgroup=c3BlockComment start="/\*" end="\*/" contains=c3BlockCommentNest,c3Todo,@Spell
syntax region c3BlockCommentNest matchgroup=c3BlockComment start="/\*" end="\*/" contains=c3BlockCommentNest,c3Todo,@Spell contained transparent

" Contract text is prose, so quotes and backticks in it must not run past the line
" (an apostrophe in "don't" would otherwise swallow everything up to the next ').
syntax region c3ContractRawString start=+`+ end=+`+ oneline contained contains=NONE
syntax region c3Contract matchgroup=c3ContractBoundary start="<\*" end="\*>" contains=c3DocTag,c3String,c3Char,c3ContractRawString,c3Integer,c3Float,c3Hex,c3Bin,c3Oct,c3Todo,c3BlockCommentNest,c3BlockComment,@Spell
syntax match c3DocTag contained "@\<[a-zA-Z_][a-zA-Z0-9_]*\>" display

" --- Highlight Links ---
highlight link c3Break Keyword
highlight link c3Case Label
highlight link c3Continue Keyword
highlight link c3Default Label
highlight link c3Do Repeat
highlight link c3Else Conditional
highlight link c3For Repeat
highlight link c3Foreach Repeat
highlight link c3Foreachr Repeat
highlight link c3If Conditional
highlight link c3Nextcase Label
highlight link c3Return Keyword
highlight link c3Switch Conditional
highlight link c3While Repeat

highlight link c3Catch Exception
highlight link c3Try Exception
highlight link c3Defer Keyword

highlight link c3Alias Keyword
highlight link c3Asm Keyword
highlight link c3Assert Keyword
highlight link c3Attrmacro Structure
highlight link c3Bitstruct Structure
highlight link c3Const Keyword
highlight link c3Constdef Structure
highlight link c3Constset Structure
highlight link c3Enum Structure
highlight link c3Extern Keyword
highlight link c3Faultdef Structure
highlight link c3Fn Keyword
highlight link c3Import Include
highlight link c3Inline Keyword
highlight link c3Interface Structure
highlight link c3Lengthof Keyword
highlight link c3Macro Keyword
highlight link c3Module Include
highlight link c3Static Keyword
highlight link c3Struct Structure
highlight link c3Tlocal Keyword
highlight link c3TypeDef Structure
highlight link c3Union Structure
highlight link c3Var Keyword

highlight link c3Deprecated Error

highlight link c3DataType Type
highlight link c3UserType Type
highlight link c3Constant Constant
highlight link c3Bool Boolean
highlight link c3Null Special

highlight link c3CompileTime PreProc
highlight link c3CompileTimeFunc PreProc
highlight link c3CompileTimeVar Identifier

highlight link c3Builtin Function
highlight link c3Attribute PreProc
highlight link c3MacroCall Function
highlight link c3FunctionCall Function

highlight link c3Escape SpecialChar
highlight link c3String String
highlight link c3RawString String
highlight link c3HexString String
highlight link c3Base64String String
highlight link c3Char Character

highlight link c3Integer Number
highlight link c3Hex Number
highlight link c3Oct Number
highlight link c3Bin Number
highlight link c3Float Float

highlight link c3Shebang Comment
highlight link c3Todo Todo
highlight link c3LineComment Comment
highlight link c3BlockComment Comment
highlight link c3Contract Comment
highlight link c3ContractRawString Comment
highlight link c3ContractBoundary SpecialComment
highlight link c3DocTag SpecialComment

highlight link c3Operator Operator
highlight link c3VectorDelimiter Delimiter
highlight link c3Delimiter Delimiter

" --- Synchronization ---
" Synchronizes syntax highlighting reliably across buffer edits and scrolling.
" By default, 'fromstart' guarantees 100% accurate parsing of nested comments and doc contracts.
" For massive generated files, users can configure g:c3_sync_fromstart = 0.
if get(g:, 'c3_sync_fromstart', 1)
  syntax sync fromstart
else
  let s:minlines = get(g:, 'c3_sync_minlines', 200)
  let s:maxlines = get(g:, 'c3_sync_maxlines', 500)
  execute 'syntax sync minlines=' . s:minlines
  execute 'syntax sync maxlines=' . s:maxlines
  syntax sync match c3SyncBlockComment grouphere c3BlockComment "/\*"
  syntax sync match c3SyncBlockComment groupthere NONE "\*/"
  syntax sync match c3SyncContract grouphere c3Contract "<\*"
  syntax sync match c3SyncContract groupthere NONE "\*>"
endif

let b:current_syntax = "c3"

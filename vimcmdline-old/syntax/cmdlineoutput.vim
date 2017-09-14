if exists("b:current_syntax")
    finish
endif

" Normal text
syn match cmdlineNormal "."

" Strings
syn region cmdlineString start=/"/ skip=/\\\\\|\\"/ end=/"/ end=/$/

" integer
syn match cmdlineInteger "\<\d\+L"
syn match cmdlineInteger "\<0x\([0-9]\|[a-f]\|[A-F]\)\+L"
syn match cmdlineInteger "\<\d\+[Ee]+\=\d\+L"

" number with no fractional part or exponent
syn match cmdlineNumber "\<\d\+\>"
syn match cmdlineNegNum "-\<\d\+\>"
" hexadecimal number
syn match cmdlineNumber "\<0x\([0-9]\|[a-f]\|[A-F]\)\+"

" floating point number with integer and fractional parts and optional exponent
syn match cmdlineFloat "\<\d\+\.\d*\([Ee][-+]\=\d\+\)\="
syn match cmdlineNegFlt "-\<\d\+\.\d*\([Ee][-+]\=\d\+\)\="
" floating point number with no integer part and optional exponent
syn match cmdlineFloat "\<\.\d\+\([Ee][-+]\=\d\+\)\="
syn match cmdlineNegFlt "-\<\.\d\+\([Ee][-+]\=\d\+\)\="
" floating point number with no fractional part and optional exponent
syn match cmdlineFloat "\<\d\+[Ee][-+]\=\d\+"
syn match cmdlineNegFlt "-\<\d\+[Ee][-+]\=\d\+"

" complex number
syn match cmdlineComplex "\<\d\+i"
syn match cmdlineComplex "\<\d\++\d\+i"
syn match cmdlineComplex "\<0x\([0-9]\|[a-f]\|[A-F]\)\+i"
syn match cmdlineComplex "\<\d\+\.\d*\([Ee][-+]\=\d\+\)\=i"
syn match cmdlineComplex "\<\.\d\+\([Ee][-+]\=\d\+\)\=i"
syn match cmdlineComplex "\<\d\+[Ee][-+]\=\d\+i"

" dates and times
syn match cmdlineDate "[0-9][0-9][0-9][0-9][-/][0-9][0-9][-/][0-9][-0-9]"
syn match cmdlineDate "[0-9][0-9][-/][0-9][0-9][-/][0-9][0-9][0-9][-0-9]"
syn match cmdlineDate "[0-9][0-9]:[0-9][0-9]:[0-9][-0-9]"

" Input
if exists("b:cmdline_prompt")
    exe 'syn match cmdlineInput ' . b:cmdline_prompt
endif
if exists("b:cmdline_continue")
    exe 'syn match cmdlineInput ' . b:cmdline_continue
endif

" Errors and warnings
if exists("b:cmdline_error")
    exe 'syn match cmdlineError ' . b:cmdline_error
endif
if exists("b:cmdline_warn")
    exe 'syn match cmdlineWarn ' . b:cmdline_warn
endif

hi def link cmdlineInput	Comment
hi def link cmdlineNormal	Normal
hi def link cmdlineNumber	Number
hi def link cmdlineInteger	Number
hi def link cmdlineFloat	Float
hi def link cmdlineComplex	Number
hi def link cmdlineNegNum	Number
hi def link cmdlineNegFlt	Float
hi def link cmdlineDate	Number
hi def link cmdlineTrue	Boolean
hi def link cmdlineFalse	Boolean
hi def link cmdlineInf  	Number
hi def link cmdlineConst	Constant
hi def link cmdlineString	String
hi def link cmdlineIndex	Special
hi def link cmdlineError	ErrorMsg
hi def link cmdlineWarn	WarningMsg

let   b:current_syntax = "cmdline"

" vim: ts=8 sw=4

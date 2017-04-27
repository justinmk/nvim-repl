" Author: Alejandro "HiPhish" Sanchez
" License:  The MIT License (MIT) {{{
"    Copyright (c) 2017 HiPhish
" 
"    Permission is hereby granted, free of charge, to any person obtaining a
"    copy of this software and associated documentation files (the
"    "Software"), to deal in the Software without restriction, including
"    without limitation the rights to use, copy, modify, merge, publish,
"    distribute, sublicense, and/or sell copies of the Software, and to permit
"    persons to whom the Software is furnished to do so, subject to the
"    following conditions:
" 
"    The above copyright notice and this permission notice shall be included
"    in all copies or substantial portions of the Software.
" 
"    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
"    NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
"    DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
"    OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
"    USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}


" ----------------------------------------------------------------------------
"  Guess the file type based on a file type string.
"
"  Arguments:
"    a:ft  File type string, such as 'python' or 'scheme.guile'
"
"  Returns:
"    The guessed type
"
"  Throws:
"    'nomatch'  No matching type was found
" ----------------------------------------------------------------------------
function! repl#guess_type(ft)
	let l:fts = split(a:ft, '\v\.')
	let l:type = ''

	" Start with single types and gradually move to longer types, i.e.
	" 'a', 'b', 'c', 'a.b', 'b.c', 'a.b.c'
	for l:i in range(0, len(l:fts) - 1)
		for l:j in range(0, len(l:fts) - l:i -1)
			let l:ft = join(l:fts[l:j : l:j + l:i], '.')
			if has_key(g:repl, l:ft)
				let l:type = l:ft
			endif
		endfor
	endfor

	if empty(l:type)
		throw 'nomatch'
	endif

	return l:type
endfunction


" ----------------------------------------------------------------------------
"  Define a new REPL for a given type.
"
"  Arguments:
"    a:type   Type of the REPL to define
"    a:repl   Dictionary containing the repl information
"    a:force  Either "keep", "force" or "error"; see third arg of extend()
"
"  If the REPL does not exist it is added as a new REPL. If it does exists its
"  settings are merged with the new one according to 'a:force'.
" ----------------------------------------------------------------------------
function! repl#define_repl(type, repl, force)
	if !has_key(g:repl, a:type)
		let g:repl[a:type] = a:repl
		return
	endif

	call extend(g:repl[a:type], a:repl, a:force)
endf

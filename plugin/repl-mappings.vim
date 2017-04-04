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

if !has('nvim')
	finish
endif

nnoremap <silent> <Plug>(ReplSend)      :set opfunc=<SID>send_to_repl<CR>g@
nnoremap <silent> <Plug>(ReplSendLine)  :set opfunc=<SID>send_to_repl<CR>g@_
vnoremap <silent> <Plug>(ReplSend)      :<C-U>call <SID>send_to_repl(visualmode(), 1)<CR>

function! Send_to_repl(type, ...)
	if a:0
		call s:send_to_repl(a:type, a:0)
	else
		call s:send_to_repl(a:type)
	endif
endfunction

function! s:send_to_repl(type, ...) range
	if a:0
		let l:visualmode = visualmode()
		if l:visualmode == 'v'
			let l:text = s:range_selection( "`<",  "`>", 'v')
		elseif l:visualmode == 'V'
			let l:text = s:range_selection( "'<",  "'>", 'V')
		else
			let l:text = s:range_selection( "`<",  "`>", 'v')
		endif
	elseif a:type == 'line'
		let l:text = s:range_selection( "'[",  "']", 'V')
	elseif a:type == 'char'
		let l:text = s:range_selection( "`[",  "`]", 'v')
	endif

	if empty(g:repl[&ft].instances)
		Repl
	endif

	call jobsend(g:repl[&ft].instances[0].job_id, l:text)
	Repl
	startinsert
endfunction


function! s:range_selection(lower, upper, mod)
	let l:reg = getreg('"')
	let l:regtype = getregtype('"')

	silent execute "normal! ".a:lower.a:mod.a:upper.'y'

	let l:text = @"

	call setreg('"', l:reg, l:regtype)

	return l:text
endfunction

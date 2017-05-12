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
"    ft  File type string, such as 'python' or 'scheme.guile'
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


"  Define a new REPL for a given type.
"  It is merged with the "-" REPL type.
"  If the REPL does not exist it is added as a new REPL. If it does exists its
"  settings are merged with the new one according to 'a:force'.
"
"  Arguments:
"    type   Type of the REPL to define
"    repl   Dictionary containing the repl information
"    force  Either "keep", "force" or "error"; see third arg of extend()
"
"  Returns:
"    Handle to the REPL buffer
function! repl#define_repl(type, repl, force)
  " Merge with the "-" (default) type.
  let r = extend(deepcopy(g:repl['-']), a:repl, "force")

  if !has_key(g:repl, a:type)
    let g:repl[a:type] = r
    return
  endif

  call extend(g:repl[a:type], r, a:force)
endf


" ----------------------------------------------------------------------------
"  Open a new REPL buffer with the given options
"
"  Arguments:
"    mods  Modifiers like `:vert`
"    repl  Dictionary of REPL settings
"    type  Type of the REPL
"
"  Returns:
"    Handle to the REPL buffer
"
" This function is responsible for opening a new buffer, launching the REPL
" process and setting it up. It does not depend on state, but the opening of a
" new buffer is a side effect. It does not mutate the value of `g:repl`.
" ----------------------------------------------------------------------------
function! repl#spawn(mods, repl, type)
  " Open a new buffer and launch the terminal
  silent execute a:mods 'new'
  silent execute 'terminal' a:repl.bin join(a:repl.args, ' ')
  silent execute 'set syntax='.a:repl.syntax
  silent let b:term_title = a:repl.title

  let b:repl = {
    \ '-': {
      \ 'type'   : a:type,
      \ 'bin'    : a:repl.bin,
      \ 'args'   : a:repl.args,
      \ 'job_id' : b:terminal_job_id,
      \ 'buffer' : nvim_get_current_buf()
    \ }
  \ }

  return b:repl['-']
endfunction

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

if !has('nvim') || exists('g:loaded_repl')
  finish
endif
let g:loaded_repl = 1

" ----------------------------------------------------------------------------
" Called by the ':Repl' command
"
"   a:mods   Modifiers to the command like ':vert'
"   a:bang   Bang attribute to the command, will be empty of no bang
"   a:000    Arguments manually passed to the command
" ----------------------------------------------------------------------------
function! s:repl(mods, bang, ...)
  " First we need to determine the REPL type. If there were no arguments
  " passed or the first argument is '-' deduce the type from the current
  " file type. Otherwise the type is the first argument.
  let l:type = ''
  if a:0 > 0 && a:1 !=? '-'
    if has_key(g:repl, a:1)
      let l:type = a:1
    else
      echohl ErrorMsg
      echom 'No REPL of type '''.a:1.''' defined'
      echohl None
      return
    endif
  else
    try
      let l:type = repl#guess_type(&filetype)
    catch
      echohl ErrorMsg
      echom 'No REPL for current file type defined'
      echohl None
      return
    endtry
  endif

  " If the '!' was not supplied and there is already an instance running
  " jump to that instance.
  if empty(a:bang) && has_key(g:repl[l:type], 'instances') && len(g:repl[l:type].instances) > 0
    " Always use the youngest instance
    let l:buffer = g:repl[l:type].instances[0].buffer
    let l:windows = nvim_list_wins()
    let l:windows = filter(l:windows, {i, v -> nvim_win_get_buf(v) == l:buffer})

    if empty(l:windows)
      silent execute a:mods 'new'
      silent execute 'buffer' l:buffer
    else
      call nvim_set_current_win(l:windows[0])
    endif

    return
  endif

  " The actual option values to use are determined at runtime. Local
  " settings take precedence, so we loop over the local scope from lowest to
  " highest precedence.
  let l:repl = copy(g:repl[l:type])
  for l:scope in ['t', 'w', 'b']
    let l:local_settings = l:scope.':repl["'.l:type.'"]'
    if exists(l:local_settings)
      silent execute 'call extend(l:repl, '.l:local_settings.', "force")'
    endif
  endfor

  " Append the argument to the command to the argument list (but skip the
  " first argument, that is the file type)
  let l:repl.args = l:repl.args + a:000[1:]

  if has_key(l:repl, 'spawn')
    let l:instance = l:repl.spawn(a:mods, l:repl, l:type)
  else
    let l:instance = repl#spawn(a:mods, l:repl, l:type)
  endif

  call s:register_instance(l:instance)
endfunction


" ----------------------------------------------------------------------------
" Registers a REPL instance on the stack of instances
"
" Arguments:
"   instance  Dictionary containing information about the instance
" ----------------------------------------------------------------------------
function! s:register_instance(instance)
  " Add This instance to the top of the list of instances
  if has_key(g:repl[a:instance.type], 'instances')
    call insert(g:repl[a:instance.type].instances, a:instance)
  else
    let g:repl[a:instance.type].instances = [a:instance]
  endif

  " Hook up autocommand to clean up after the REPL terminates; the
  " autocommand is not guaranteed to have access to the instance variable,
  " that's why we instead use the literal job-id to identify this instance.
  let l:type = a:instance.type
  let l:job  = a:instance.job_id
  silent execute 'au BufDelete <buffer> call <SID>remove_instance('.job.', "'.type.'")'
endfunction

" ----------------------------------------------------------------------------
" Remove an instance from the global list of instances
"
" Arguments:
"   job_id   Job ID of the REPL process, used to find the REPL instance
"   type     The type of REPL
" ----------------------------------------------------------------------------
function! s:remove_instance(job_id, type)
  for i in range(len(g:repl[a:type].instances))
    if g:repl[a:type].instances[i].job_id == a:job_id
      call remove(g:repl[a:type].instances, i)
      break
    endif
  endfor
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
  call jobsend(g:repl[&ft].instances[0].job_id, g:repl[&ft]['enter'])
endfunction


function! s:range_selection(lower, upper, mod)
  let l:reg = getreg('"')
  let l:regtype = getregtype('"')

  silent execute "normal! ".a:lower.a:mod.a:upper.'y'

  let l:text = @"

  call setreg('"', l:reg, l:regtype)

  return l:text
endfunction

" ----------------------------------------------------------------------------
" Default settings
" ----------------------------------------------------------------------------
" bin    : Which REPL binary to execute
" args   : Arguments to pass to every execution, come before user arguments
" syntax : Syntax highlighting to use for the REPL buffer
" title  : Value of b:term_title
" ----------------------------------------------------------------------------
let s:repl = {
  \ 'guile': {
    \ 'bin': 'guile',
    \ 'args': ['-L', '.'],
    \ 'syntax': 'scheme',
    \ 'title': 'Guile REPL',
  \ },
  \ 'python': {
    \ 'bin': 'python',
    \ 'args': [],
    \ 'syntax': '',
    \ 'title': 'Python REPL',
  \ },
  \ 'r7rs-small': {
    \ 'bin': 'chibi-scheme',
    \ 'args': ['-I', '.'],
    \ 'syntax': '',
    \ 'title': 'Chibi Scheme',
  \ },
  \ 'sh': {
    \ 'bin': 'sh',
    \ 'args': [],
    \ 'syntax': '',
    \ 'title': 'Bourne Shell',
  \ },
\ }

" ----------------------------------------------------------------------------
let s:repl['r7rs'] = copy(s:repl['r7rs-small'])
let s:repl['scheme'] = copy(s:repl['r7rs-small'])
" ----------------------------------------------------------------------------

" Initialize g:repl.
let g:repl = get(g:, 'repl', {})

" Initialize the "-" (default) REPL type.
let s:repl_default = {
  \'enter': "\n",
  \}
let g:repl['-'] = extend(s:repl_default, get(g:repl, '-', {}), "force")

" Initialize REPL types.
for s:type in keys(s:repl)
  call repl#define_repl(s:type, s:repl[s:type], 'keep')
endfor

nnoremap <silent> <Plug>(ReplSend)      :set opfunc=<SID>send_to_repl<CR>g@
nnoremap <silent> <Plug>(ReplSendLine)  :set opfunc=<SID>send_to_repl<CR>g@_
vnoremap <silent> <Plug>(ReplSend)      :<C-U>call <SID>send_to_repl(visualmode(), 1)<CR>

command! -complete=file -bang -nargs=* Repl call <SID>repl(<q-mods>, '<bang>', <f-args>)

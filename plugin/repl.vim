if !has('nvim') || exists('g:loaded_repl')
  finish
endif
let g:loaded_repl = 1

let g:repl = get(g:, 'repl', {})
let s:repl_default = { 'enter': "\n" }
let g:repl['default'] = { 'enter': "\n" }

" Copies the a:repl map to g:repl[a:type].
function! s:extend_global_repl_map(type, repl)
  " Merge with the default settings.
  let r = extend(deepcopy(g:repl['default']), a:repl, 'force')

  if !has_key(g:repl, a:type)
    let g:repl[a:type] = r
    return
  endif

  call extend(g:repl[a:type], r)
endf

function! s:repl(mods, bang, ...)
  " Determine the REPL type. If there were no arguments passed or the first
  " argument is '-' deduce the type from the current file type. Otherwise the
  " type is the first argument.
  let type = &filetype
  if a:0 > 0 && a:1 !=? '-'
    if has_key(b:repl, a:1)
      let type = a:1
      " TODO: get b:repl settings for a:type ...
    else
      if !exists('b:repl')
        echohl ErrorMsg
        echom 'repl.vim: b:repl not defined for "'.&filetype.'" filetype'
        echohl None
        return
      endif
    endif
  endif

  call s:extend_global_repl_map(type, b:repl)

  " If the '!' was not supplied and there is already an instance running
  " jump to that instance.
  if empty(a:bang) && has_key(g:repl[l:type], 'instances') && len(g:repl[l:type].instances) > 0
    " Use the newest instance.
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

  " Local settings take precedence.
  let l:repl = b:repl
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

" Puts a REPL instance on the stack of instances
function! s:register_instance(repl)
  " Add this instance to the top of the list of instances
  if has_key(g:repl[a:repl.type], 'instances')
    call insert(g:repl[a:repl.type].instances, a:repl)
  else
    let g:repl[a:repl.type].instances = [a:repl]
  endif

  " Hook up autocommand to clean up after the REPL terminates; the autocommand
  " is not guaranteed to have access to the instance variable, that's why we
  " instead use the literal job-id to identify this instance.
  let l:type = a:repl.type
  let l:job  = a:repl.job_id
  silent execute 'autocmd BufDelete <buffer> call <SID>remove_instance('.job.', "'.type.'")'
endfunction

" Removes a REPL from the global list of instances
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

augroup repl
  autocmd!
  " -L adds the current directory to the module load path.
  autocmd FileType guile let b:repl = { 'bin': 'guile', 'args': [ '-L', '.' ] }
  autocmd FileType javascript let b:repl = { 'bin': 'node', 'args': [] }
  autocmd FileType python let b:repl = { 'bin': 'python3', 'args': [] }
  " -I prepends the current directory to the load-path list.
  autocmd FileType r7rs-small,r7rs,scheme let b:repl = { 'bin': 'chibi-scheme', 'args': [ '-I', '.' ] }
augroup END


nnoremap <silent> <Plug>(ReplSend)      :set opfunc=<SID>send_to_repl<CR>g@
nnoremap <silent> <Plug>(ReplSendLine)  :set opfunc=<SID>send_to_repl<CR>g@_
vnoremap <silent> <Plug>(ReplSend)      :<C-U>call <SID>send_to_repl(visualmode(), 1)<CR>

command! -complete=file -bang -nargs=* Repl call <SID>repl(<q-mods>, '<bang>', <f-args>)

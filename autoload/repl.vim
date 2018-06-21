" Opens a new buffer and launches the REPL.
"    mods  Modifiers like `:vert`
"    repl  Dictionary of REPL settings
"    type  Type of the REPL
function! repl#spawn(mods, repl, type)
  silent execute a:mods 'new'
  silent execute 'terminal' a:repl.bin join(a:repl.args, ' ')

  let b:repl = {
    \ 'type'   : a:type,
    \ 'bin'    : a:repl.bin,
    \ 'args'   : a:repl.args,
    \ 'job_id' : &channel,
    \ 'buffer' : nvim_get_current_buf()
  \ }

  return b:repl
endfunction

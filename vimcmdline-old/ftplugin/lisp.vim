" Ensure that plugin/vimcmdline.vim was sourced
if !exists("g:cmdline_job")
    runtime plugin/vimcmdline.vim
endif

function! s:source(lines)
    call writefile(a:lines, g:cmdline_tmp_dir . "/lines.lsp")
    call VimCmdLineSendCmd('(load "' . g:cmdline_tmp_dir . '/lines.lsp")')
endfunction

let b:cmdline_nl = "\n"
let b:repl['bin'] = "clisp"
let b:cmdline_source_fun = function("s:source")
let b:cmdline_send_empty = 0

" Ensure that plugin/vimcmdline.vim was sourced
if !exists("g:cmdline_job")
    runtime plugin/vimcmdline.vim
endif

function! s:source(lines)
    call writefile(a:lines, g:cmdline_tmp_dir . "/lines.js")
    call VimCmdLineSendCmd("require('" . g:cmdline_tmp_dir . "/lines.js')")
endfunction

let b:cmdline_nl = "\n"
let b:repl = "node"
let b:cmdline_source_fun = function("s:source")
let b:cmdline_send_empty = 0

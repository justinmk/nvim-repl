" Ensure that plugin/vimcmdline.vim was sourced
if !exists("g:cmdline_job")
    runtime plugin/vimcmdline.vim
endif

function s:source(lines)
    call writefile(a:lines, g:cmdline_tmp_dir . "/lines.jl")
    call VimCmdLineSendCmd('include("' . g:cmdline_tmp_dir . '/lines.jl")')
endfunction

let b:cmdline_nl = "\r\n"
let b:repl['bin'] = "julia"
let b:cmdline_source_fun = function("s:source")
let b:cmdline_send_empty = 0

" Ensure that plugin/vimcmdline.vim was sourced
if !exists("g:cmdline_job")
    runtime plugin/vimcmdline.vim
endif

if exists("g:cmdline_app")
    for key in keys(g:cmdline_app)
        if key == "python" && match(g:cmdline_app["python"], "ipython") != -1
            if has("nvim") && g:cmdline_in_buffer == 1
                echohl WarningMsg
                echomsg "vimcmdline does not support ipython in builtin terminal emulator"
                sleep 3
                echohl Normal
            else 
                let b:cmdline_ipython = 1
            endif
        endif
    endfor
endif

function! PythonSourceLines(lines)
    if exists("b:cmdline_ipython")
        call VimCmdLineSendCmd("%cpaste")
        call VimCmdLineSendCmd(join(add(a:lines, '--'), b:cmdline_nl))
    else
        call VimCmdLineSendCmd(join(add(a:lines, ''), b:cmdline_nl))
    endif
endfunction

let b:cmdline_nl = "\n"
let b:repl['bin'] = "python"
let b:cmdline_source_fun = function("PythonSourceLines")
let b:cmdline_send_empty = 1

if exists("g:repl")
    for key in keys(g:repl)
        if key == "python" && g:repl["python"]['bin'] == "ipython"
            echohl WarningMsg
            echomsg "vimcmdline does not support ipython"
            sleep 3
            echohl Normal
        endif
    endfor
endif

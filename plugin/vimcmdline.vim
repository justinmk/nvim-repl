"  This program is free software; you can redistribute it and/or modify
"  it under the terms of the GNU General Public License as published by
"  the Free Software Foundation; either version 2 of the License, or
"  (at your option) any later version.
"
"  This program is distributed in the hope that it will be useful,
"  but WITHOUT ANY WARRANTY; without even the implied warranty of
"  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"  GNU General Public License for more details.
"
"  A copy of the GNU General Public License is available at
"  http://www.r-project.org/Licenses/

"==========================================================================
" Author: Jakson Alves de Aquino <jalvesaq@gmail.com>
"==========================================================================

if exists("g:loaded_vimcmdline")
    finish
endif
let g:loaded_vimcmdline = 1

let g:cmdline_vsplit = get(g:, 'cmdline_vsplit', 0)
let g:cmdline_term_width = get(g:, 'cmdline_term_width', 40)
let g:cmdline_term_height = get(g:, 'cmdline_term_height', 15)
let g:cmdline_tmp_dir = get(g:,'cmdline_tmp_dir', expand('~').'/.local/share/nvim/repl')

" Internal variables
let g:cmdline_job = {"haskell": 0, "julia": 0, "lisp": 0, "matlab": 0,
            \ "prolog": 0, "python": 0, "ruby": 0, "sh": 0, "javascript": 0}
let g:cmdline_termbuf = {"haskell": "", "julia": "", "lisp": "", "matlab": "",
            \ "prolog": "", "python": "", "ruby": "", "sh": "", "javascript": ""}

" Skip empty lines
function s:GoLineDown()
    let i = line(".") + 1
    call cursor(i, 1)
    if b:cmdline_send_empty
        return
    endif
    let curline = substitute(getline("."), '^\s*', "", "")
    let fc = curline[0]
    let lastLine = line("$")
    while i < lastLine && strlen(curline) == 0
        let i = i + 1
        call cursor(i, 1)
        let curline = substitute(getline("."), '^\s*', "", "")
        let fc = curline[0]
    endwhile
endfunction

function VimCmdLineStart_Nvim(app)
    let edbuf = bufname("%")
    let thisft = &filetype
    if g:cmdline_job[&filetype]
        return
    endif
    set switchbuf=useopen
    if g:cmdline_vsplit
        if g:cmdline_term_width > 16 && g:cmdline_term_width < (winwidth(0) - 16)
            silent exe "belowright " . g:cmdline_term_width . "vnew"
        else
            silent belowright vnew
        endif
    else
        if g:cmdline_term_height > 6 && g:cmdline_term_height < (winheight(0) - 6)
            silent exe "belowright " . g:cmdline_term_height . "new"
        else
            silent belowright new
        endif
    endif
    let g:cmdline_job[thisft] = termopen(a:app, {'on_exit': function('s:VimCmdLineJobExit')})
    let g:cmdline_termbuf[thisft] = bufname("%")
    exe 'runtime syntax/cmdlineoutput_' . a:app . '.vim'
    exe "sbuffer " . edbuf
    stopinsert
endfunction

function VimCmdLineStartApp()
    if !exists("b:repl")
        echomsg 'Missing b:repl'
        return
    endif

    call mkdir(g:cmdline_tmp_dir, 'p')
    call VimCmdLineStart_Nvim(b:repl)
    call VimCmdLineSetApp(&filetype)
endfunction

" Send a single line to the REPL
function VimCmdLineSendCmd(...)
    if g:cmdline_job[&filetype]
        call jobsend(g:cmdline_job[&filetype], a:1 . b:cmdline_nl)
    endif
endfunction

" Send current line to the REPL and go down to the next non empty line
function VimCmdLineSendLine()
    let line = getline(".")
    if strlen(line) == 0 && b:cmdline_send_empty == 0
        call s:GoLineDown()
        return
    endif
    call VimCmdLineSendCmd(line)
    call s:GoLineDown()
endfunction

let s:all_marks = "abcdefghijklmnopqrstuvwxyz"

function VimCmdLineQuit()
  let bnr = bufnr(get(g:cmdline_termbuf, &filetype, v:null))
  if bnr && 'terminal' ==# getbufvar(bnr, '&buftype')
    exe 'bdelete! '.bnr
    let g:cmdline_termbuf[&filetype] = v:null
  endif
endfunction

" Register that the job no longer exists
function s:VimCmdLineJobExit(job_id, data, etype)
    for ft in keys(g:cmdline_job)
        if a:job_id == g:cmdline_job[ft]
            let g:cmdline_job[ft] = 0
        endif
    endfor
endfunction

" Replace default application with custom one
function VimCmdLineSetApp(ft)
    if exists("g:repl")
        for key in keys(g:repl)
            if key == a:ft
                let b:repl['bin'] = g:repl[a:ft]
            endif
        endfor
    endif
endfunction

nnoremap <silent> <Plug>(repl_start) :<C-U>call VimCmdLineStartApp()<CR>
nnoremap <silent> <Plug>(repl_quit) :call VimCmdLineQuit()<CR>
nnoremap <silent> <Plug>(repl_send) :call VimCmdLineSendLine()<CR>
xnoremap <silent> <Plug>(repl_send) <Esc>:call b:cmdline_source_fun(getline("'<", "'>"))<CR>

nmap !r <Plug>(repl_start)
nmap !q <Plug>(repl_quit)
nmap yxx <Plug>(repl_send)
xmap <Enter> <Plug>(repl_send)

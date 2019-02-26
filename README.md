# nvim-repl

This is a fork of [vimcmdline](https://github.com/jalvesaq/vimcmdline)
and https://gitlab.com/HiPhish/repl.nvim 

It's not usable yet.
The plan is to create a simplified/minimal REPL plugin using ideas/code from the two.

## Usage

  - `:Repl` to start the REPL.
  - `yx{motion}` to send text object to the REPL.
  - `yxx` to send the current line to the REPL.
  - `{Visual}<Enter>` to send the selection to the REPL.
  - `!q` to quit the REPL.

## Configuration

```vim
nmap <Plug>(repl_start) ?
nmap <Plug>(repl_send) ?
nmap <Plug>(repl_quit) ?

let cmdline_vsplit             = 1      " Split the window vertically
let cmdline_term_height        = 15     " Initial height of REPL window or pane
let cmdline_term_width         = 80     " Initial width of REPL window or pane
```

You can define what application will be run as REPL for each supported file
type. Create a dictionary `g:repl` with `filetype:{dict}` key-value pairs.

```vim
let g:repl {
  \ 'python': { 'bin': 'ptipython3' },
  \ 'ruby': { 'bin': 'pry' },
  \ 'sh': { 'bin': 'bash' }
  \ }
```

## Related

- [reply.vim](https://github.com/rhysd/reply.vim)
- [repl.nvim](https://gitlab.com/HiPhish/repl.nvim)
- [neoterm](https://github.com/kassio/neoterm)
- [vim-slime](https://github.com/jpalardy/vim-slime)

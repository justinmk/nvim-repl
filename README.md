# vimcmdline: Send lines to REPL

This is a fork of [vimcmdline](https://github.com/jalvesaq/vimcmdline).

This plugin sends lines from [Neovim](https://github.com/neovim/neovim) to
a command line interpreter (REPL) running in a `:terminal`. It includes support
for some filetypes; adding support for others is trivial. There is one instance
of the REPL for each filetype.

![nvim_running_octave](https://cloud.githubusercontent.com/assets/891655/7090493/5fba2426-df71-11e4-8eb8-f17668d9361a.png)

## Usage

  - `!r` to start the REPL.
  - `yxx` to send the current line to the REPL.
  - `!q` to quit the REPL.

For languages that can source chunks of code:

  - `{Visual}<Enter>` to send the selection to the REPL.
  - `yx{motion}` to send a range of lines to the REPL.

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

- [repl.nvim](https://gitlab.com/HiPhish/repl.nvim)
- [neoterm](https://github.com/kassio/neoterm)
- [vim-slime](https://github.com/jpalardy/vim-slime)

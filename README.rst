.. default-role:: code

####################################################################
 REPL.nvim - The universal, extendible and configurable REPL plugin
####################################################################

REPL.nvim bring REPL support to Nvim! Use the built-in REPLs, add your own, or
change the existing ones.Here are some of the highlights:

- Fully customisable: Change any aspect of any REPL you wish in your `init.vim`
  or in command mode
- Declarative and functional: options can be both values or functions which
  expand to values
- Expandable: Define all new REPLs from ground up
- API functions: Use functions in your own plugin or reroute existing ones

To put it simply, REPL.nvim adds a wrapper command that allows you to spawn a
REPL instance in a terminal buffer. What makes REPL.nvim stand out is the
amount of control it gives users. The plugin is designed to make configuration
as clean and simple as possible, to allow spawning any number of REPL instances
and add any type of REPL the user wishes with minimal effort.

Starting a REPL
===============

A new REPL window is created by running the `:Repl` command. You can use the
same arguments you can use with the binary. Example:

.. code-block:: vim

   " Load a given file at startup
   :Repl guile -l my-file.scm

   " Evaluate an expression and exit (escape the space after 'display')
   :Repl guile -c '(display\ "Hello from Guile")'

See below for how to set the default arguments. The `:Repl` command also
accepts the usual modifiers like `:vert`:

.. code-block:: vim

   " Open the REPL in a vertical split
   :vert Repl

If the `:Repl` command is executed without arguments it will guess the type of
REPL based on the current file type. If you want to guess the type *and* pass
arguments use `-` as the first argument.



Configuration
#############

REPL settings
=============

All REPL configuration is held within the `g:repl` dictionary. You can read the
documentation for details; here is what the default configuration for Python
looks like:

.. code-block:: vim

   let g:repl['python'] = {
       \ 'bin': 'python',
       \ 'args': [],
       \ 'syntax': '',
       \ 'title': 'Python REPL
   \ }

To override the defaults create a new `g:repl` in your `init.vim` file
containing *only* options you want to change. REPL.nvim is smart enough to fill
in the rest.

.. code-block:: vim

   " Add Python syntax highlighting
   let g:repl['python'] = {'syntax': 'python'}

You can also use function references or lambdas as option values if the
function reference does not take any arguments.

.. code-block:: vim

   " Add Python syntax highlighting as a lambda
   let g:repl['python'] = {'syntax': {-> 'python'}}

After Nvim has loaded you can change the dictionary entries. If you wanted to
turn syntax highlighting back off after starting up Nvim you would execute

.. code-block:: vim

   " Globally turn syntax highlighting back off
   :let g:repl['python']['syntax'] = ''

You can also specify settings local to the current tab/window/buffer by using a
local dictionary:

.. code-block:: vim

   " Turn on syntax highlighting for this tab only
   let t:repl['python'] = {'syntax': 'python'}

Local dictionaries can be created at any time.


Mappings
========

An operator is available for sending text from the current buffer to the
REPL. Define mappings to use it:

.. code-block:: vim

   " Send the text of a motion to the REPL
   nmap yx <Plug>(ReplSend)
   " Send the current line to the REPL
   nmap yxx <Plug>(ReplSendLine)
   " Send the selected text to the REPL
   xmap <Enter> <Plug>(ReplSend)

Inside a pair of parentheses, press `yxa)` and the expression will be sent to
the REPL.

License
#######

REPL.nvim is release under the terms of the MIT license. See the `COPYING.txt`_
file for details.

.. _COPYING.txt: COPYING.txt

.. default-role:: code

####################################################################
 REPL.nvim - The universal, extendible and configurable REPL plugin
####################################################################

REPL.nvim bring REPL support to Nvim! Use the built-in REPLs, add your own, or
change the existing ones. Change settings in your `init.vim` or on the fly,
make them global or local, use the existing ones or make your own.


What is REPL.nvim?
##################

To put it simply, REPL.nvim adds a wrapper command that allows you to spawn a
REPL instance in a terminal buffer. What makes REPL.nvim stand out is the
amount of control it gives users. The plugin is designed to make configuration
as clean and simple as possible, to allow spawning any number of REPL instances
and add any type of REPL the user wishes with minimal effort.

Let‘s say you are working on a Python script and you want to try a snippet out
in the REPL. Without REPL.nvim you would have to execute `:new` followed by
`:terminal python` to get a REPL instance. This is not a big deal for one
instance, but it adds up over time.

With REPL.nvim on the other hand you only execute `:Repl` to spawn a new Python
REPL instance. What if you are not actually a Python file at the moment? You
can specify the REPL type as the first argument: `:Repl python`.


Setup and quick start
#####################

Installation
============

Instal REPL.nvim like any other plugin. You will also need to have the REPLs
you want to use installed on your system.


Starting a REPL
===============

A new REPL window is created by running the `:Repl` command. You can use the
same arguments you can also use with your binary. Example:

.. code-block:: vim

   " Add the current working directory to the load path
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
       \'binary': 'python',
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

After Nvim has loaded you can the dictionary entries. If you wanted to turn
syntax highlighting back off after starting up Nvim you would execute

.. code-block:: vim

   " Globally turn syntax highlighting back off
   :let g:repl['python']['syntax'] = ''

You can also specify settings local to the current tab/window/buffer by using a
local dictionary:

.. code-block:: vim

   " Turn on syntax highlighting for this tab only
   let t:repl['python'] = {'syntax': 'python'}

Local dictionaries can be created at any time.


Key mappings
============

A new operator is available for sending text from the current buffer to the
REPL. You will have to remap the keys for the new operator:

.. code-block:: vim

   " Send the text of a motion to the REPL
   nmap <leader>rs  <Plug>(ReplSend)
   " Send the current line to the REPL
   nmap <leader>rss <Plug>(ReplSendLine)
   nmap <leader>rs_ <Plug>(ReplSendLine)
   " Send the selected text to the REPL
   vmap <leader>rs  <Plug>(ReplSend)

With these mappings you could position your cursor inside a pair of
parentheses, press `<leader>rsa)` and your expression would be sent over to the
REPL with its parentheses.



Shortcomings
############

Since REPL.nvim is implemented on top of Nvim's terminal emulator it is also
bound to the same interface. You cannot use Vim's commands to edit text, you
instead have to enter terminal mode (insert mode for the terminal) to modify
text.

Syntax highlighting uses Vim's Scheme highlighting, but this might not always
be adequate. Highlighting the prompt or the backtrace as if it was regular
Scheme code is wrong.



License
#######

REPL.nvim is release under the terms of the MIT license. See the `LICENSE.txt`_
file for details.

.. _LICENSE.txt: LICENSE.txt

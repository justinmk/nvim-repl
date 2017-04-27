.. default-role:: code

######################
 Working on REPL.nvim
######################


Code overview
#############

Here is the directory listing of important files::

   ├─ plugin
   │  ├─ repl.vim
   │  ├─ repl-settings.vim
   │  └─ repl-mappings.vim
   │
   └─ test
      └─ …

The `plugin/repl.vim` file contains all the important code. The `test`
directory is for testing_.



Building global REPL settings
#############################
:file: plugin/repl-settings.vim

REPL.nvim uses dictionaries for settings. All settings are in one dictionary
and the keys are the types of REPL. Here is an example:

.. code-block:: vim

   let g:repl = {'python': '…', 'ruby': '…'}

Of course the values of these keys are not strings, they are dictionaries
themselves. Each dictionary can define a number of settings for that kind of
REPL, such as the binary to execute or the arguments to pass. The default
settings describe the standard settings.

For the future we should consider the possibility of allowing function
references as setting values, those functions would then return the value. The
function could then access information dynamically from the buffer or so.

Users can define a global REPL settings dictionary, as well as dictionaries
local to the tab, window or buffer. When the REPL command is invoked to actual
settings for spawning the REPL are assembled on the spot. Here is a possible
setup:

.. code-block:: vim

   " Use GNU Guile as the Scheme interpreter every time
   let g:repl = {'scheme' : {'bin': 'guile'}}

   " Except for this buffer use Chibi-Scheme
   let b:repl = {'scheme' : {'bin': 'chibi-scheme'}}

This assembly is performed inside the `s:repl()` function. When the script is
loaded only the global settings are assembled. Here is how it is done:

#) The user‘s `init.vim` is read, which might contain a `g:repl` variable with
   some settings.
#) The plugin is read, which contain all default settings inside `s:repl`.
#) If no `g:repl` exists a new empty dictionary is created, otherwise the
   existing one (from `init.vim`) is used.
#) Loop over all the keys in `s:repl` and copy the values to `g:repl` if they
   do not exist.

The only restriction is that the user must not assign a value to `g:repl`
outside `init.vim`, otherwise the settings will be overwritten. Instead the
user must assign the values of the keys in question.


Defining a new REPL
===================

Defining a new REPL is the same as adding new settings: add a new key with the
name of the type to `s:repl` and fill in *all* the settings.



The inner workings of `plugin/repl.vim`
#######################################
:file: plugin/repl.vim

This is the file containing the bulk of the plugin logic. It defines the
`:Repl` command and sets up the instance management.


The `s:repl()` function
=======================

The function `s:repl()` is what is really behind the `:Repl` command, it
performs multiple steps, but its main responsibility is to handle spawning of
new REPL instances and hooking them up properly to the existing data
structures.

Determining the REPL type
-------------------------

If there is at least one argument passed the first argument is the type of the
REPL, except if the argument is `'-'`. If the first argument is `'-'` or there
are no arguments we have to guess the type based on the current file type.

We support the dotted file type syntax: first try all the dot-separated atomic
types from left to right. Later types override previous ones. Then keep trying
progressively more compound file types until the whole file type. This means
that if our file type is `scheme.guile` the types tried are `scheme`, `guile`
and `scheme.guile`, in that order.

The algorithm is as follows:

- Given a list `FTs` with length `l`

- For `i` in the range from `0` (inclusive) to `l` (exclusive)

  - For `j` in the range from `0` (inclusive) to `l - i` (inclusive)

    - The file type is `l[j: j + i]` (join items vial `.`)

This algorithm sorts file types by length and gives later types priority over
earlier ones.

If no type could be found an error is displayed and the function returns with
no value and no side effects.


Determining the options
-----------------------

As mentioned above, when the plugin was loaded the user‘s default options and
the plugin‘s default options had been combined into the global options. Now we
have to take local options into account as well.

We loop over the keys among the global options (for determined type of REPL)
and in each iteration we loop over the possible scopes. We create a copy of the
global option and if a local option exists we overwrite it.

.. code-block:: vim

   for l:key in keys(g:repl[l:type])
       silent execute 'let l:'.l:key.' = g:repl[l:type]["'.key.'"]'
       for l:scope in ['t', 'w', 'b']
           let l:entry = l:scope.':repl["'.l:type.'"]["'.l:key.'"]'
           if exists(l:entry)
               silent execute 'let l:'.l:key.' = '.l:entry
           endif
       endfor
   endfor


Hooking up and managing REPL instances
======================================

Each REPL buffer has a `b:repl` dictionary with a `'-'` filed, containing
information about this particular instance. This `b:repl` variable can also
contain buffer-local settings, but since `'-'` is a reserved “type” there is no
danger of name collision.

For every type of REPL we have to keep track of running instances. Every entry
in `g:repl` can have an `'instances'` field which contains a list of running
instances, sorted by range from youngest to oldest. When a new REPL instance is
spawned it is added to the front of the list. When a REPL buffer is deleted the
instance is removed from the list using an autocommand.



Testing
#######

We use `Vader.vim`_ as our testing framework.

.. _Vader.vim: https://github.com/junegunn/vader.vim

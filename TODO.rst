#############################
 Things that need to be done
#############################

:date: 2017-04-08

.. default-role:: code


When adding to or removing anything from this file please adjust the date at
the top.


Interface for new REPLs
   Defining a new REPL is already possible, but due to loading order users
   cannot change settings for it like they can for the built-in ones. What we
   need is some sort of `repl#define_repl()` function:

   .. code-block:: vim

      let s:ruby = {
          \ 'binary': 'irb',
          \ 'args': [],
          \ 'syntax': 'ruby',
          \ 'title': 'Ruby REPL',
      \ }

      call repl#define_repl('ruby', ruby)


Use a regular buffer
   At the moment we are using a terminal buffer, but this is subpar because the
   user cannot use regular Vim commands. A regular buffer that sends commands
   from the buffer to the REPL process and puts responses into the buffer would
   be a superior choice.


Have functions in addition to the command
   The `:Repl` command is a good interface for users, but other plugins could
   make use of `repl#...()`-style functions. A file type plugin could then use
   this plugin as a REPL framework.

   Ideas for functions:

   - `repl#determine_type()`: try to determine the type of the REPL based on
     the current buffer

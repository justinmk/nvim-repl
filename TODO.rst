#############################
 Things that need to be done
#############################
.. default-role:: code



Use a regular buffer
   At the moment we are using a terminal buffer, but this is subpar because the
   user cannot use regular Vim commands. A regular buffer that sends commands
   from the buffer to the REPL process and puts responses into the buffer would
   be a superior choice.


Have functions in addition to the command
   The `:Repl` command is a good interface for users, but other plugins could
   make use of `repl#...()`-style functions. A file type plugin could then use
   this plugin as a REPL framework.

###########################
 Contributing to REPL.nvim
###########################
.. default-role:: code


If you decide to contribute to the development of REPL.nvim please follow the
rules outlined in this file.


Project goals and non-goals
###########################

REPL.nvim aims to be a generic REPL plugin. We want to support as many REPL
types as possible, but we do not offer preferential treatment to any of them.
The main goal is to be a generic wrapper around Nvim‘s `:terminal` command.

Do:

- Add new REPL types

Do not:

- I don‘t know, this list will be filled out over time hopefully


Technical writing
#################

We use reStructuredText_ (reST) for documenting the project. Please follow these
guidelines:

- Use proper quotes:

  =====  ==================  =================================================
  Glyph  Unicode code point  Name
  =====  ==================  =================================================
  ``‘``  U+2018              Left single quotation mark
  ``’``  U+2019              Right single quotation mark
  ``“``  U+201C              Left double quotation mark
  ``”``  U+201D              Right double quotation mark
  =====  ==================  =================================================

  If you see wrong quotation marks (``'``, ``"``, ````` and ``´``) please fix
  them.

- Annotate the file in `HACKING.rst`_ using a field list:

  .. code-block:: rst

     About the `foo` function
     ########################
     :file: plugin/foo.vim

  This makes it easy for readers to jump directly to that file.


.. _reStructuredText: http://docutils.sourceforge.net/rst.html
.. _HACKING.rst: HACKING.rst

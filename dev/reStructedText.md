# ReStructedText

## Link

```rst
`Title <http://link>`_
```

## Hyperlink Targets

```rst
External hyperlinks, like Python_.

.. _Python: http://www.python.org/
```

## Table

```rst
.. csv-table::
   :header: h1, h2, h3

   c1l1, c2l1, c3l1
   c1l2, c2l2, c3l3
```

## Section Number

```rst
.. sectnum::
```

## Define

```rst
define::

   documents
```

## Footnotes

```rst
Autonumbered footnotes are
possible, like using [#]_ and [#]_.

.. [#] This is the first one.
.. [#] This is the second one.

They may be assigned 'autonumber
labels' - for instance,
[#fourth]_ and [#third]_.

.. [#third] a.k.a. third_

.. [#fourth] a.k.a. fourth_
```

## Refenrence

- [Quick reStructuredText](http://docutils.sourceforge.net/docs/user/rst/quickref.html)
- [reStructuredText Directives](http://docutils.sourceforge.net/docs/ref/rst/directives.html)

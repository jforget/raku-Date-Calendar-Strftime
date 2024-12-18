NAME
====

Date::Calendar::Strftime - formatting any Date object or any Date::Calendar::whatever object with 'strftime'

SYNOPSIS
========

Using the core class Date:

```
use Date::Calendar::Strftime;
my Date $last-day .= new(2019, 12, 31);
$last-day does Date::Calendar::Strftime;
say $last-day.strftime("%Y-%m-%d ('ISO' date %G-W%V-%u)");
# --> 2019-12-31 ('ISO' date 2020-W01-2)
```

Using a Date::Calendar::xxx class (here, the French Revolutionary one):

```
use Date::Calendar::FrenchRevolutionary;
my Date::Calendar::FrenchRevolutionary $Bonaparte's-coup-fr;
$Bonaparte's-coup-fr .= new(year => 8, month => 2, day => 18);

say $Bonaparte's-coup-fr.strftime("%Y-%m-%d");
# ---> "0008-02-18" for 18 Brumaire VIII

say $Bonaparte's-coup-fr.strftime("%A %e %B %EY");
# ---> "octidi 18 Brumaire VIII"
```

INSTALLATION
============

```shell
zef install Date::Calendar::Strftime
```

or

```shell
git clone https://github.com/jforget/raku-Date-Calendar-Strftime.git
cd raku-Date-Calendar-Strftime
zef install .
```

DESCRIPTION
===========

Date::Calendar::Strftime  is a  role  providing a  strftime method  to
format a string  representing the date. This method is  similar to the
strftime function in C.

The synopsis  above shows  examples with the  standard class  Date and
with     the     class    Date::Calendar::FrenchRevolutionary,     but
Date::Calendar::Strftime  can be  used  with any  Date::Calendar::xxxx
class which  implements the attributes  "year", "month" and  "day". It
can  be   used  with   a  little  more   effort  with   more  esoteric
Date::Calendar::xxxx classes.

AUTHOR
======

Jean Forget <J2N-FORGET at orange dot fr>

COPYRIGHT AND LICENSE
=====================

Copyright (c) 2019, 2020, 2024 Jean Forget, all rights reserved

This library is  free software; you can redistribute  it and/or modify
it under the Artistic License 2.0.


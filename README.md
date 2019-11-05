NAME
====

Date::Calendar::Strftime - formatting any Date::Calendar::whatever date with 'strftime'

SYNOPSIS
========

```perl6
use Date::Calendar::Strftime;
use Date::Calendar::FrenchRevolutionary;
my Date::Calendar::FrenchRevolutionary $Bonaparte's-coup-fr;
$Bonaparte's-coup-fr .= new(year => 8, month => 2, day => 18);

say $Bonaparte's-coup-fr.strftime("%Y-%m-%d");
# ---> "0008-02-18" for 18 Brumaire VIII

say $Bonaparte's-coup-fr.strftime("%A %e %B %EY");
# ---> "octidi 18 Brumaire VIII"
```

DESCRIPTION
===========

Date::Calendar::Strftime  is a  role  providing a  strftime method  to
format a string  representing the date. This method is  similar to the
strftime function in C.

The    synopsis   above    shows   an    example   with    the   class
Date::Calendar::FrenchRevolutionary, but  Date::Calendar::Strftime can
be  used  with any  Date::Calendar::xxxx  class  which implements  the
attributes "year",  "month" and "day".  It can  be used with  a little
more effort with more esoteric Date::Calendar::xxxx classes.

AUTHOR
======

Jean Forget <JFORGET@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright © 2019 Jean Forget, all rights reserved

This library is  free software; you can redistribute  it and/or modify
it under the Artistic License 2.0.


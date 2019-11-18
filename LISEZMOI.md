NOM
===

Date::Calendar::Strftime - formatter des dates Date::Calendar::quelque-chose avec 'strftime'

RÉSUMÉ
======

```perl6
use Date::Calendar::Strftime;
use Date::Calendar::FrenchRevolutionary;
my Date::Calendar::FrenchRevolutionary $coup-d'État-fr;
$coup-d'État-fr .= new(year => 8, month => 2, day => 18);

say $coup-d'État-fr.strftime("%Y-%m-%d");
# ---> "0008-02-18" correspondant au 18 Brumaire VIII

say $coup-d'État-fr.strftime("%A %e %B %EY");
# ---> "octidi 18 Brumaire VIII"
```

DESCRIPTION
===========

Date::Calendar::Strftime est un rôle  qui fournit une méthode strftime
pour construire une chaîne de  caractères représentant une date. Cette
méthode est semblable à la fonction strftime en C.

Le   résumé  ci-dessus   montre   un  exemple   utilisant  la   classe
Date::Calendar::FrenchRevolutionary    représentant   le    calendrier
républicain, mais il  est possible d'utiliser Date::Calendar::Strftime
avec  n'importe  quelle   classe  Date::Calendar::xxxx  possédant  des
attributs "year" (année), "month" (mois)  et "day" (jour). Avec un peu
d'effort,  il  est  possible  d'utiliser  le  rôle  avec  des  classes
Date::Calendar::xxxx moins conventionnelles.

AUTEUR
======

Jean Forget <JFORGET@cpan.org>

COPYRIGHT ET LICENCE
====================

Copyright © 2019 Jean Forget, tous droits réservés.

Ce code constitue du logiciel libre. Vous pouvez le redistribuer et le
modifier  en accord  avec  la  « licence  artistique  2.0 »  (Artistic
License 2.0).


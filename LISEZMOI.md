NOM
===

Date::Calendar::Strftime - formatter des objets de la classe Date ou d'une classe Date::Calendar::quelque-chose avec 'strftime'

RÉSUMÉ
======

Avec la classe standard Date :

```
use Date::Calendar::Strftime;
my Date $Saint-Sylvestre .= new(2019, 12, 31);
$Saint-Sylvestre does Date::Calendar::Strftime;
say $Saint-Sylvestre.strftime("%Y-%m-%d (date 'ISO' %G-W%V-%u)");
# --> 2019-12-31 (date 'ISO' 2020-W01-2)
```

Avec une classe Date::Calendar::xxx (ici le calendrier républicain) :

```
use Date::Calendar::FrenchRevolutionary;
my Date::Calendar::FrenchRevolutionary $coup-d'État-fr;
$coup-d'État-fr .= new(year => 8, month => 2, day => 18);

say $coup-d'État-fr.strftime("%Y-%m-%d");
# ---> "0008-02-18" correspondant au 18 Brumaire VIII

say $coup-d'État-fr.strftime("%A %e %B %EY");
# ---> "octidi 18 Brumaire VIII"
```

INSTALLATION
============

```shell
zef install Date::Calendar::Strftime
```

ou bien

```shell
git clone https://github.com/jforget/raku-Date-Calendar-Strftime.git
cd raku-Date-Calendar-Strftime
zef install .
```

DESCRIPTION
===========

Date::Calendar::Strftime est un rôle  qui fournit une méthode strftime
pour construire une chaîne de  caractères représentant une date. Cette
méthode est semblable à la fonction strftime en C.

Le résumé  ci-dessus montre  un exemple  utilisant la  classe standard
Date et  un autre  avec la  classe Date::Calendar::FrenchRevolutionary
représentant  le   calendrier  républicain,   mais  il   est  possible
d'utiliser  Date::Calendar::Strftime  avec   n'importe  quelle  classe
Date::Calendar::xxxx possédant  des attributs "year"  (année), "month"
(mois)  et  "day"  (jour).  Avec  un peu  d'effort,  il  est  possible
d'utiliser  le  rôle  avec   des  classes  Date::Calendar::xxxx  moins
conventionnelles.

AUTEUR
======

Jean Forget <J2N-FORGET at orange dot fr>

COPYRIGHT ET LICENCE
====================

Copyright (c) 2019, 2020, 2024, 2025 Jean Forget, tous droits réservés.

Ce code constitue du logiciel libre. Vous pouvez le redistribuer et le
modifier  en accord  avec  la  « licence  artistique  2.0 »  (Artistic
License 2.0).


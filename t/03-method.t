use v6.c;
use Test;
use Date::Calendar::Strftime;

class Date::Calendar::Check
 does Date::Calendar::Strftime {
  method day-name   { "monday" }
  method month-name { "january" }
}

plan 1;
my Date::Calendar::Check $d .= new;
is($d.strftime("whatever"), "placeholder");

done-testing;

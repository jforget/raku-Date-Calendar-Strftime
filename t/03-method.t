use v6.c;
use Test;
use Date::Calendar::Strftime;

class Date::Calendar::Check
 does Date::Calendar::Strftime {
  method day-name   { "monday" }
  method month-name { "january" }
}

my @tests = (   ("%3d whatever %-4d", "%3d whatever %-4d"       )
              , ("%A whatever %B"   , "monday whatever january" )
              , ("%% whatever %B"   , "% whatever january"      )
              , ("%%%A whatever %B" , "%monday whatever january")
            );
plan @tests.elems;
my Date::Calendar::Check $d .= new;
for @tests -> $elem {
  my ($fmt, $expected) = @$elem;
  is($d.strftime($fmt), $expected);
}

done-testing;

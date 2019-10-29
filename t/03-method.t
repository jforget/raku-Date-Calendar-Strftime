use v6.c;
use Test;
use Date::Calendar::Strftime;

class Date::Calendar::Check
 does Date::Calendar::Strftime {
  method year        { 2001 }
  method month       { 1 }
  method month-name  { "january" }
  method month-abbr  { "jan" }
  method day         { 1 }
  method day-name    { "monday" }
  method day-abbr    { "mon" }
  method day-of-year { 1 }
}

my @tests = (   ("%3z whatever %-4z"   , "%3z whatever %-4z"       )
              , ("%A whatever %B"      , "monday whatever january" )
              , ("%% whatever %B"      , "% whatever january"      )
              , ("%%%A whatever %B"    , "%monday whatever january")
              , ("%a %b %d %e %f %j %m", "mon jan 01  1  1 001 01")
              , ("%F %G %L %Y"         , "2001-01-01 2001 2001 2001")
              , ("|%2a| |%-2a| |%02a| |%-02a|", "|mon| |mon| |mon| |mon|")
              , ("|%3a| |%-3a| |%03a| |%-03a|", "|mon| |mon| |mon| |mon|")
              , ("|%4a| |%-4a| |%04a| |%-04a|", "|mon | | mon| |mon0| |0mon|")
              , ("|%5a| |%-5a| |%05a| |%-05a|", "|mon  | |  mon| |mon00| |00mon|")
            );
plan @tests.elems;
my Date::Calendar::Check $d .= new;
for @tests -> $elem {
  my ($fmt, $expected) = @$elem;
  is($d.strftime($fmt), $expected);
}

done-testing;

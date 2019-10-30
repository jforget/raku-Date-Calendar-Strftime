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
  method feast       { "New year's day" }
  method specific-format { %( Ej => { $.feast },
                             '*' => { $.feast },
                              a  => Nil,
                              b  => Nil ) }
}

my @tests = (   ("%F %*", "2001-01-01 New year's day")
              , ("%Ej %F", "New year's day 2001-01-01")
              , ("%2a %b"  , "%2a %b")
            );
plan @tests.elems;
my Date::Calendar::Check $d .= new;
for @tests -> $elem {
  my ($fmt, $expected) = @$elem;
  is($d.strftime($fmt), $expected);
}

done-testing;

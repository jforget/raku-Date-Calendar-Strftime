use v6.c;
use Test;
use Date::Calendar::Strftime;

class Date::Calendar::Check
 does Date::Calendar::Strftime {
  method year        { 2006 }
  method month       { 5 }
  method month-name  { "may" }
  method day         { 1 }
  method day-name    { "monday" }
  method day-of-year { 1 }
  method feast       { "Labor day" }
  method month-morse { "-- .- -.--" }
  method neg-attr    { -1 }
  method specific-format { %( Ej => { $.feast },
                             '*' => { $.feast },
                             '¯' => { $.neg-attr }, # negative sign for numeric constants in APL
                              OB => { $.month-morse },
                              a  => Nil,
                              b  => Nil ) }
}

my @tests = (   ("%F %*"           , "2006-05-01 Labor day")
              , ("%Ej %F"          , "Labor day 2006-05-01")
              , ("%2a %b"          , "%2a %b")                        # standard basic types have been inhibited
              , ("%OA %EB"         , "monday may")                    # alternate formats which fall back to basic
              , (">%12OA< >%-12EB<", ">      monday< >may         <") # same thing with padding
              , (">%05e<"          , ">000 1<")                       # bizarre zero-padding of a string
              , (">%5¯<"           , ">   -1<")                       # space padding of a negative number
              , (">%05¯<"          , ">-0001<")                       # zero padding of a negative number
              , (">%014OB<"        , ">-0000- .- -.--<")              # bizarre zero padding of a string with a dash
            );
plan @tests.elems;
my Date::Calendar::Check $d .= new;
for @tests -> $elem {
  my ($fmt, $expected) = @$elem;
  is($d.strftime($fmt), $expected);
}

done-testing;

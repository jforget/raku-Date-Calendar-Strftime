use v6.c;
unit role Date::Calendar::Strftime:ver<0.0.4>:auth<zef:jforget>:api<0>;

my grammar prt-format {
  token percent    { '%' }
  token except-pct { <-[%]> }
  token minus      { '-' }
  token zero       { '0' }
  token one-nine   { <[1..9]> }
  token echo-oscar { <[EO]> }
  token type       { <-[-0..9]> }
  regex zero-nine  { <zero> | <one-nine> }
  regex align      { <minus> ? }
  regex fill       { <zero> ? }
  regex number     { <one-nine> <zero-nine> * }
  regex length     { <number> ? }
  regex alternate  { <echo-oscar> ? }
  regex format     { <percent> <align> <fill> <length> <alternate> <type> }
  regex substring  { <except-pct> + }
  regex element    { <format> | <substring> }
  regex TOP        { <element> * }
}
my class re-format {
  method except-pct($/) { make $/.Str; }
  method minus     ($/) { make $/.Str; }
  method zero      ($/) { make $/.Str; }
  method one-nine  ($/) { make $/.Str; }
  method echo-oscar($/) { make $/.Str; }
  method type      ($/) { make $/.Str; }
  method zero-nine ($/) { make $/.values[0].made; }
  method align     ($/) { make $/.values[0].made // ''; }
  method fill      ($/) { make $/.values[0].made // ''; }
  method number    ($/) { make [~] $<one-nine>.made, |$<zero-nine>».made; }
  method length    ($/) { make $/.values[0].made // ''; }
  method alternate ($/) { make $/.values[0].made // ''; }
  method format($/) {
    my $fall-back = sprintf("%%%s%s%s%s%s", $<align>.made, $<fill>.made, $<length>.made, $<alternate>.made, $<type>.made);
    take %( :align(    $<align>    .made),
            :fill(     $<fill>     .made),
            :length(   $<length>   .made),
            :alternate($<alternate>.made),
            :type(     $<type>     .made),
            :fall-back($fall-back) );
  }
  method substring($/) {
    take %( :string([~] $<except-pct>».made) );
  }
}

sub reformat(Str $string, $fmt) {
  my Int $expected-length = $fmt<length>.Int;
  my Int $actual-length   = $string.chars;
  if $actual-length ≥ $expected-length {
    return $string;
  }
  my Str $fill;
  if $fmt<fill> eq '0' and $fmt<align> ne '-' {
    $fill = '0';
  }
  else {
    $fill = ' ';
  }
  $fill x= $expected-length - $actual-length;
  if $fmt<align> eq '-' {
    return $string ~ $fill;
  }
  else {
    if $string.substr(0, 1)eq '-' && $fmt<fill> eq '0' {
      # zero-padding of a negative number (with a good-looking result)
      # or zero-padding of a string beginning with a dash (with a funny result)
      return '-' ~ $fill ~ $string.substr(1);
    }
    return $fill ~ $string;
  }
}

method strftime($self: Str $format) {
  my %formatter = %(
                      # not a method
                      n => -> { "\n" },
                      t => -> { "\t" },
                      # raw or processed mandatory method
                      d => -> { sprintf("%02d", $.day) },
                      e => -> { sprintf("%2d",  $.day) },
                      f => -> { sprintf("%2d",  $.month) },
                      j => -> { sprintf("%03d", $.day-of-year) },
                      L => -> { warn("'%L' strftime specifier is deprecated"); sprintf("%04d", $.year) },
                      m => -> { sprintf("%02d", $.month) },
                      Y => -> { sprintf("%04d", $.year) },
                      # recursion on mandatory methods
                      F => -> { $.strftime("%Y-%m-%d") },
                      # raw optional method falling back to nil
                      a => -> { $self.?day-abbr   },
                      A => -> { $self.?day-name   },
                      b => -> { $self.?month-abbr },
                      B => -> { $self.?month-name },
                      # processed optional method falling back to nil
                      u => -> { if $.can('day-of-week') { sprintf("%d",   $.day-of-week) } else { Nil } },
                      V => -> { if $.can('week-number') { sprintf("%02d", $.week-number) } else { Nil } },
                      # processed optional method falling back to a mandatory method
                      G => { sprintf("%04d", ($self.?week-year // $self.year)) },
                   );
  %formatter<%> = -> { '%' };
  my @res = gather prt-format.parse($format, actions => re-format.new);
  @res ==> map -> $fmt { my Str $res; # Result string
                         my     $fnc; # Formatter function
                         my     %dispatch = %(); # empty specific dispatch table
                         if $.can('specific-format') {
                           # specific dispatch table with some stuff in it
                           %dispatch = $.specific-format;
                         }
                         if $fmt<string>:!exists {
                           my $key1 = $fmt<alternate> ~ $fmt<type>;
                           my $key2 = $fmt<type>;
                           if    %dispatch{$key1}:exists  { $fnc = &%dispatch{$key1 }; }
                           elsif %dispatch{$key2}:exists  { $fnc = &%dispatch{$key2 }; }
                           elsif %formatter{$key1}:exists { $fnc = &%formatter{$key1}; }
                           elsif %formatter{$key2}:exists { $fnc = &%formatter{$key2}; }
                         }
                         if $fmt<string>:exists { $res = $fmt<string> }
                         elsif $fnc             { my $res1 = $fnc();
                                                  if $res1.gist eq '(Any)' { $res = $fmt<fall-back> }
                                                  else                     { $res = reformat($res1.Str, $fmt); }
                                                }
                         else                   { $res = $fmt<fall-back> }
                         $res;
        } ==> my @val;
  return [~] @val;
}

=begin pod

=head1 NAME

Date::Calendar::Strftime - formatting any Date object or Date::Calendar::whatever object with 'strftime'

=head1 SYNOPSIS

This example uses the C<Date> core module

=begin code :lang<perl6>

use Date::Calendar::Strftime;
my Date $last-day .= new(2019, 12, 31);
$last-day does Date::Calendar::Strftime;
say $last-day.strftime("%Y-%m-%d %G-W%V-%u");
# --> 2019-12-31 2020-W01-2

=end code

Another example, with the French Revolutionary calendar

=begin code :lang<perl6>

use Date::Calendar::FrenchRevolutionary;
#------> no "use Date::Calendar::Strftime;" is necessary!
my Date::Calendar::FrenchRevolutionary $Bonaparte's-coup-fr;
$Bonaparte's-coup-fr .= new(year => 8, month => 2, day => 18);

say $Bonaparte's-coup-fr.strftime("%Y-%m-%d");
# ---> "0008-02-18" for 18 Brumaire VIII

say $Bonaparte's-coup-fr.strftime("%A %e %B %EY");
# ---> "octidi 18 Brumaire VIII"

=end code

=head1 DESCRIPTION

Date::Calendar::Strftime is  a role providing a  C<strftime> method to
format a string  representing the date. This method is  similar to the
C<strftime> function in C.

This role applies  to any C<Date::Calendar::>R<xxx> class,  as well as
the C<Date> core class.

=head2 Usage with the core class

Some code is  required to use this module wih  the core C<Date> class.
There  are two  variants. The  first  variant, shown  in the  synopsis
above,  assigns the  C<Date::Calendar::Srftime> role  to each  C<Date>
instance  separately. The  second  variant, shown  below, declares  an
empty   class  which   merges  the   core  C<Date>   class  with   the
C<Date::Calendar::Srftime> role.

=begin code :lang<perl6>

use Date::Calendar::Strftime;
class My::Date is Date
             does Date::Calendar::Strftime {}
my My::Date $last-day .= new(2019, 12, 31);
say $last-day.strftime("%Y-%m-%d %G-W%V-%u");
# --> 2019-12-31 2020-W01-2

=end code

Or  you  can use  the  C<Date::Calendar::Gregorian>  class instead  of
C<Date>. See below.

=head2 Usage with a C<Date::Calendar::>R<xxx> class

C<Date::Calendar::Strftime>  is  automatically and  implicitly  loaded
when using a C<Date::Calendar::>R<xxx> class.  There is no need to add
a C<use> statement.

Exceptions:  early versions  of C<Date::Calendar::FrenchRevolutionary>
and  C<Date::Calendar::Hebrew>  do not  include  the  loading of  this
module and are only partially compatible with it.

=head1 METHOD

There is only one method in the C<Date::Calendar::Strftime> role.

=head2 strftime

This method is  very similar to the homonymous functions  you can find
in several  languages (C, shell, etc).  It also takes some  ideas from
C<printf>-similar functions. For example

=begin code :lang<perl6>

$df.strftime("%04d blah blah blah %-25B")

=end code

will give  the day number  padded on  the left with  2 or 3  zeroes to
produce a 4-digit substring, plus the substring C<" blah blah blah ">,
plus the month name, padded on the right with enough spaces to produce
a 25-char substring.  Thus, the whole string will be at least 42 chars
long.

A C<strftime> specifier consists of:

=item A percent sign.

=item An  optional minus sign, to  indicate on which side  the padding
occurs. If the minus sign is present, the value is aligned to the left
and the padding spaces are added to the right. If it is not there, the
value is aligned to the right and the padding chars (spaces or zeroes)
are added to the left.

=item  An optional  zero  digit,  to choose  the  padding  char for  a
right-aligned left-padded value. If the  zero char is present, padding
is done with zeroes. Else, it is done wih spaces.

=item An  optional length, which  specifies the minimum length  of the
result substring.

=item  An optional  C<"E">  or  C<"O"> modifier.  On  some older  UNIX
systems,  these were  used  to give  the  I<extended> or  I<localized>
version  of  the date  attribute.  Here,  they rather  give  alternate
variants of the date attribute.

=item A mandatory  type code. A type code is  any character other than
the  characters used  in the  optional modifiers  above. That  is, any
character except a digit, a dash, a letter C<"E"> or a letter C<"O">.

The dot-digit optional modifier, used  in C<printf> for numbers with a
fractional  part,  is not  implemented.  Likewise,  the plus  optional
modifier, which displays  a plus sign for positive  numeric values, is
not implemented.

=head2 Standard C<strftime> codes

The C<Date::Calendar::Strftime> module implements  a few standard type
codes as  listed below.  Many others  are possible,  but they  must be
provided by the calling C<Date::Calendar::>R<xxx> module.

=defn C<%a>

The abbreviated name of the day of week.

If not  defined (as with  the C<Date>  core module), the  formatter is
returned as is.

=defn C<%A>

The full name of the day of week.

If not  defined (as with  the C<Date>  core module), the  formatter is
returned as is.

=defn C<%b>

The abbreviated month name.

If not  defined (as with  the C<Date>  core module), the  formatter is
returned as is.

=defn C<%B>

The full month name.

If not  defined (as with  the C<Date>  core module), the  formatter is
returned as is.

=defn C<%d>

The day of the month as a decimal number (usually range 01 to 31).

=defn C<%e>

Like C<%d>, the  day of the month  as a decimal number,  but a leading
zero is replaced by a space.

=defn C<%f>

The  month as  a decimal  number (usually  1 to  12). Unlike  C<%m>, a
leading zero is replaced by a space. This is still a 2-char string.

=defn C<%F>

Equivalent to  C<%Y-%m-%d> (similar  to the ISO  8601 date  format for
Gregorian dates)

=defn C<%G>

The year  as a decimal number.  By default, strictly similar  to C<%L>
and C<%Y>. If the calendar has a concept of week or similar and if the
week  is not  synchronised with  the  year, this  formatter gives  the
number of  the "quasi-year" as  defined by ISO-8601 for  the so-called
"ISO   date"   for   Gregorian  dates.   This   "quasi-year"   (method
C<week-year>) is synchronised with the week.

=defn C<%j>

The day of the year as a three-digit decimal number (usually range 001
to 366).

=defn C<%L>

The year  as a decimal number.  By default, strictly similar  to C<%G>
and C<%Y>.

=defn C<%m>

The month  as a  two-digit decimal  number (usually  range 01  to 12),
including a leading zero if necessary.

=defn C<%n>

A newline character.

=defn C<%t>

A tab character.

=defn C<%u>

If the calendar has  a notion of week, this formatter  give the day of
week as a 1..7 number (or some other range if the week-like concept is
not exactly a 7-day span).

If the calendar has no week-like notion, this formatter returns itself
C<"%u"> (or possibly with its  would-be length and padding codes, like
C<"%-3u">).

=defn C<%V>

If the calendar has a notion  of week or similar, this formatter gives
the week  number. If the week  and the year are  not synchronised, the
week number is defined in a fashion  similar to the week number in the
so-called "ISO  date" format  for Gregorian  dates.

For the Gregorian calendar, this number is within the 1..53 range. For
other calendars, the range may be different.

If the calendar has no week-like notion, this formatter returns itself
C<"%V"> (or possibly with its  would-be length and padding codes, like
C<"%05V">).

=defn C<%Y>

The year  as a decimal number.  By default, strictly similar  to C<%G>
and C<%L>.

=defn C<%%>

A literal `%' character.

=head3 C<Date::Calendar::>R<xxx> Requirements

The  C<Date::Calendar::>R<xxx>  module  must implement  at  least  the
following methods:

=item year
=item month
=item day
=item day-of-year

The  C<Date::Calendar::>R<xxx>   module  should  also   implement  the
following methods if possible:

=item month-name
=item month-abbr
=item day-name
=item day-abbr
=item day-of-week
=item week-number
=item week-year

=head2 Specific C<strftime> codes

A C<Date::Calendar::>R<xxx> module can  add its specific formats types
by specifying a  C<specific-format> method which returns  a hash where
the keys are the format types and the values are the callbacks used to
format the date attributes.

Example: a module defines a C<feast> method, which will be inserted in
string with the C<%Oj> or the C<%*> specifiers. This module defines:

=begin code :lang<perl6>

  method specific-format { %( Oj => { $.feast },
                             '*' => { $.feast } ); }

=end code

The same  C<specific-format> method  can also be  used to  override or
inhibit    existing    standard    specifiers.    For    example,    a
C<Date::Calendar::>R<xxx>  module  deactivates   the  C<%a>  specifier
(abbreviated  day) and  overrides  the C<month-abbr>  method with  the
C<abbreviated-month>  method  (C<%b>   specifier).  This  module  will
define:

=begin code :lang<perl6>

  method specific-format { %( a  => Nil,
                              b  => { $.abbreviated-month } ); }

=end code

Of course, these features can be combined with

=begin code :lang<perl6>

  method specific-format { %( Oj => { $.feast },
                             '*' => { $.feast },
                              a  => Nil,
                              b  => { $.abbreviated-month } ); }

=end code

So, the  sentence a few paragraphs  above was not completely  true. It
should actually read:

The  C<Date::Calendar::>R<xxx>  module  must implement  at  least  the
following methods: [...] except those  that are inhibited or overriden
with the C<specific-format> method.

=head2 Precedence

When encountering a C<%Ex> specifier,  the following entries are tried
and the first existing one is selected (let us ignore C<Nil> values in
the hashes):

=item 1 Entry C<Ex> from C<Date::Calendar::>R<xxx>C<.specific-format>.
=item 2 Entry C<x>  from C<Date::Calendar::>R<xxx>C<.specific-format>.
=item 3 Entry C<Ex> from C<%formatter> in C<Date::Calendar::Strftime>
=item 4 Entry C<x>  from C<%formatter> in C<Date::Calendar::Strftime>
=item 5 C<fall-back> attribute of the match object, which gives the C<"%Ex"> string.

And similarly for a C<%Ox> specifier.

For a specifier without alternate form, such as C<%x>, the precedence is:

=item 1 Entry C<x> from C<Date::Calendar::>R<xxx>C<.specific-format>.
=item 2 Entry C<x> from C<%formatter> in C<Date::Calendar::Strftime>
=item 3 C<fall-back> attribute of the match object, which gives the C<"%x"> string.

In the lists above,  if at any time a hash entry  exists with a C<Nil>
value,  the  C<fall-back>  attribute  is  immediately  chosen  without
examining the other possibilities.

=head2 Known Bugs, Silly Things and Security Concerns

Make sure the  C<strftime> format string comes from  a trusted origin.
Here are a few reasons.

You should not truncate a numeric value when formatting it. Especially
a  year. In  the 1950's  and  the 1960's,  when RAM  and storage  were
expensive, programmers had  a good reason to truncate  numbers and let
the users guess the missing parts.  But nowadays, kilobytes of RAM and
storage are several orders of magnitude  cheaper so there is no longer
any  reason  to truncate  numbers.  Twenty  years ago,  the  worldwide
endeavour to  fix the Y2K bug  was a really necessary  endeavour and a
mostly  successful  one, even  if  some  glitches happened  (and  were
hushed). This does  not mean that twenty years later  you can fallback
into the old dirty habits of butchering year numbers.

On the other  hand, using unambiguous abbreviations for  day names and
month names is OK. Be sure there is no ambiguity.

About the optional length, the module does not impose a maximum value.
A format such as C<"%123456789A"> is  valid and accepted. Yet, it will
drain your free RAM very fast. So  do not use such a ridiculous length
for a single string.

Zero-padding should apply only to  numbers. Yet, nothing in the module
prevents you from padding alphabetic strings with zeroes.

Numeric  values in  calendars are  rarely negative  and string  values
rarely begin with  a dash. When left-padding with  zeroes, the program
checks the first char of the value. If  this is a minus sign or a dash
char, the padding  zeroes are inserted between the minus  sign and the
rest  of the  value. Thus  negative numbers  look right  (C<"-000123">
instead of C<"000-123">). At the same  time, a string beginning with a
dash looks silly  when zero-padded. You cannot have your  cake and eat
it too. Anyhow,  you should not zero-pad strings,  only numbers should
be zero-padded.

=head3 Why three specifiers for the year?

The main  year specifier is  the C<%Y> specifier.  What is the  use of
C<%G> and C<%L>? First, let us examine C<%G>.

=head4 ISO Date and C<%G> Specifier

While C<%Y> is the year of the day, C<%G> is the "year of the week of
the day". Here is the explanation of this convoluted formula.

Between  the day  and  the  year, most  calendars  have two  different
intermediary time  units, the week  and the month.  In  all calendars,
the year is synchronised  with the month: a change from  a year to the
next always  occurs simultaneously with a  change from a month  to the
next.  On the other hand, the  year is not synchronised with the week:
a change from the year to the next may happen at the middle of a week.

Because the year and the month  are synchronised, the usual scheme for
designating  a date  is  the  year-month-day scheme.  Yet,  it may  be
convenient  to use  a  week-based scheme  sometimes.  So the  ISO-8601
standard defines the following scheme:

=item 1 Weeks span from Monday to Sunday.

=item 2 If a week is fully within a year, it is assigned to this year.

=item 3 If a week is across a  year change, it is assigned to the year
with which it shares at least 4 days.

=item  4 Once  all  weeks have  been  assigned to  a  year, the  weeks
belonging to a given year are numbered 1 to 52 (or 53).

The year  obtained with these  steps is the "year  of the week  of the
day".  From these steps, you can infer a few facts.

From 4th  January to 28th  December, the year of  the week of  the day
always coincides with the year of the  day. On the first three days of
the  year, 1st  Jan to  3rd  Jan, the  years  may differ  or they  may
coincide. Same thing for the last three days, 29th Dec to 31st Dec.

No matter how the year and the  week are unsynchronised, week 1 is the
week containing 4th Jan, week 2  is the week containing 11th Jan, week
3 is the week containing 18th Jan and so on.

No  matter how  the  year  and the  week  are  unsynchronised, on  any
Thursday, the year of the week of  the day is always equal to the year
of the day. Also, week 1 is  the week containing the first Thursday of
the year,  week 2 is  the week containing  the second Thursday  of the
year, and so on.

Other calendars  use unsynchronised  weeks, like the  Hebrew calendar,
the Coptic calendar  and the Ethiopic calendar. A  difference with the
Gregorian calendar is that in  threse three calendars weeks are Sunday
→ Saturday  spans. So  we can  define rules  similar to  the Gregorian
calendar's ISO date rules, but there, Wednesday / Yom Reviʻi / Peftoou
/ Hamus play a central role  (pun intended) instead of Thursday. Also,
for the Hebrew calendar, the number range for week numbers will not be
1..52 or 1..53, but 1..50, 1..51, 1..55 or 1..56 depending on the type
of the year.

A more remote case: the  French Revolutionary calendar use I<décades>,
not weeks.  I<Décades> are 10-day  long and are synchronised  with the
year, and even with the 30-day  months. The last I<décade> of the year
is shortened  to 5  or 6  days, to keep  the synchronisation  with the
year. So, what is told above  about the relations between the week and
the year may  not apply to this calendar. In  this calendar, the C<%G>
specifier always gives the same result as the C<%Y> specifier.

=head4 The C<%L> Specifier

Why a  C<%L> specifier  in C<Date::Calendar::Strftime>?  Because there
was    already    a   C<%L>    specifier    in    the   Perl    module
C<DateTime::Calendar::FrenchRevolutionary> (which I  wrote). And why a
C<%L>  specifier in  C<DT::C::FR>?  Because there  is  already one  in
Perl's C<Date::Convert::French_Rev>  (which I  wrote, too). And  why a
C<%L> specifier in C<D::C::F_R>? Well...

So  why did  I  include a  C<%L>  specifier in  the  first release  of
C<Date::Convert::French_Rev> in  early 2001? I cannot  remember. Maybe
there was  another week-based scheme,  that fell into disuse  and then
into oblivion.  Therefore this specifier is  deprecated, starting with
the release  of version C<0.0.4> in  2024. It will be  removed in 2026
(or a later release). You are advised  not to use it and to use either
C<%Y> or C<%G> depending on the context.

=head1 AUTHOR

Jean Forget <JFORGET at cpan dot org>

=head1 SUPPORT

You can  send me  a mail using  the address above.  Please be  sure to
include a subject  sufficiently clear and sufficiently  specific to be
green-flagged by my spam filter.

Or  you can  send a  pull request  to the  Github repository  for this
module.

=head1 COPYRIGHT AND LICENSE

Copyright © 2019, 2020, 2024 Jean Forget, all rights reserved

This library is  free software; you can redistribute  it and/or modify
it under the Artistic License 2.0.

=end pod

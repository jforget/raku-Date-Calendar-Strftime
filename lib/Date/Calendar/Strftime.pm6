use v6.c;
unit role Date::Calendar::Strftime:ver<0.0.1>:auth<cpan:JFORGET>;

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
  if $fmt<fill> eq '0' {
    $fill = '0';
  }
  else {
    $fill = ' ';
  }
  $fill x= $expected-length - $actual-length;
  if $fmt<align> eq '-' {
    return $fill ~ $string;
  }
  else {
    return $string ~ $fill;
  }
}

method strftime(Str $format) {
  my %formatter = %(  a => -> { $.day-abbr },
                      A => -> { $.day-name },
                      b => -> { $.month-abbr },
                      B => -> { $.month-name },
                      d => -> { sprintf("%02d", $.day) },
                      e => -> { sprintf("%2d",  $.day) },
                      f => -> { sprintf("%2d",  $.month) },
                      F => -> { $.strftime("%Y-%m-%d") },
                      G => -> { sprintf("%04d", $.year) },
                      j => -> { sprintf("%03d", $.day-of-year) },
                      L => -> { sprintf("%04d", $.year) },
                      m => -> { sprintf("%02d", $.month) },
                      n => -> { "\n" },
                      t => -> { "\t" },
                      Y => -> { sprintf("%04d", $.year) },
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
                           if %dispatch{$key1}:exists {
                             $fnc = &%dispatch{$key1};
                           }
                           elsif %dispatch{$key2}:exists {
                             $fnc = &%dispatch{$key2};
                           }
                           elsif %formatter{$key1}:exists {
                             $fnc = &%formatter{$key1};
                           }
                           elsif %formatter{$key2}:exists {
                             $fnc = &%formatter{$key2};
                           }
                         }
                         if $fmt<string>:exists { $res = $fmt<string> }
                         elsif $fnc             { $res = reformat($fnc(), $fmt); }
                         else                   { $res = $fmt<fall-back> }
                         $res;
        } ==> my @val;
  return [~] @val;
}

=begin pod

=head1 NAME

Date::Calendar::Strftime - formatting any Date::Calendar::whatever date with 'strftime'

=head1 SYNOPSIS

This example uses the French Revolutionary calendar

=begin code :lang<perl6>

use Date::Calendar::Strftime;
use Date::Calendar::FrenchRevolutionary;
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

=head1 METHOD

There is only one method in the C<Date::Calendar::Strftime> role.

=head2 strftime

Work in progress.

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
and the padding chars are added to  the right. If it is not there, the
value is aligned to  the right and the padding chars  are added to the
left.

=item An optional zero digit, to  choose the padding char. If the zero
char is  present, padding is  done with zeroes.  Else, it is  done wih
spaces.

=item An  optional length, which  specifies the minimum length  of the
result substring.

=item  An optional  C<"E">  or  C<"O"> modifier.  On  some older  UNIX
system,  these  were used  to  give  the I<extended>  or  I<localized>
version  of  the date  attribute.  Here,  they rather  give  alternate
variants of the date attribute.

=item A mandatory  type code. A type code is  any character other than
the  characters used  in the  optional modifiers  above. That  is, any
character except a digit, a dash, a letter C<"E"> or a letter C<"O">.

=head2 Standard C<strftime> codes

The C<Date::Calendar::Strftime> module implements  a few standard type
codes as  listed below.  Many others  are possible,  but they  must be
provided by the calling C<Date::Calendar::>R<xxx> module.

=defn C<%a>

The abbreviated name of the day of week.

=defn C<%A>

The full name of the day of week.

=defn C<%b>

The abbreviated month name.

=defn C<%B>

The full month name.

=defn C<%d>

The day of the month as a decimal number (usually range 01 to 31).

=defn C<%e>

Like C<%d>, the  day of the month  as a decimal number,  but a leading
zero is replaced by a space.

=defn C<%f>

The  month as  a decimal  number (usually  1 to  12). Unlike  C<%m>, a
leading zero is replaced by a space.

=defn C<%F>

Equivalent to %Y-%m-%d (the ISO 8601 date format)

=defn C<%G>

The year as a decimal number. Strictly similar to C<%L> and C<%Y>.

=defn C<%j>

The day of the year as a decimal number (usually range 001 to 366).

=defn C<%L>

The year as a decimal number. Strictly similar to C<%G> and C<%Y>.

=defn C<%m>

The month  as a  two-digit decimal  number (usually  range 01  to 12),
including a leading zero if necessary.

=defn C<%n>

A newline character.

=defn C<%t>

A tab character.

=defn C<%Y>

The year as a decimal number. Strictly similar to C<%G> and C<%L>.

=defn C<%%>

A literal `%' character.

=head3 C<Date::Calendar::>R<xxx> Requirements

The  C<Date::Calendar::>R<xxx>  module  must implement  at  least  the
following methods:

=item year
=item month
=item month-name
=item month-abbr
=item day
=item day-name
=item day-abbr
=item day-of-year

=head2 Specific C<strftime> codes

A C<Date::Calendar::>R<xxx> module can  add its specific formats types
by specifying a  C<specific-format> method which returns  a hash where
the keys are the format types and the values are the callbacks used to
format the date attributes.

Example: a module defines a C<feast> method, which will be inserted in
string with the C<%Oj> or the C<%*> specifiers. This module defines:

=begin code :lang<perl6>

  method specific-format { %( Oj => { $.feast },
                             '*' => { $.feast } );

=end code

The same  C<specific-format> method  can also be  used to  override or
inhibit    existing    standard    specifiers.    For    example,    a
C<Date::Calendar::>R<xxx>  module  deactivates   the  C<%a>  specifier
(abbreviated  day) and  overrides  the C<month-abbr>  method with  the
C<abbreviated-month>  method  (C<%b>   specifier).  This  module  will
define:

=begin code :lang<perl6>

  method specific-format { %( a  => Nil,
                              b  => { $.abbreviated-month } );

=end code

Of course, these features can be combined with

=begin code :lang<perl6>

  method specific-format { %( Oj => { $.feast },
                             '*' => { $.feast },
                              a  => Nil,
                              b  => { $.abbreviated-month } );

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
value, the C<fall-back> attribute is immediately chosen.

=head2 Silly Things and Security Concerns

Work in progress

=head1 AUTHOR

Jean Forget <JFORGET at cpan dot org>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 Jean Forget, all rights reserved

This library is  free software; you can redistribute  it and/or modify
it under the Artistic License 2.0.

=end pod

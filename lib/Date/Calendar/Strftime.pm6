use v6.c;
unit role Date::Calendar::Strftime:ver<0.0.1>:auth<cpan:JFORGET>;

my grammar prt-format {
  token percent    { '%' }
  token except-pct { <-[%]> }
  token minus      { '-' }
  token zero       { '0' }
  token one-nine   { <[1..9]> }
  token type       { <-[-0..9]> }
  regex zero-nine  { <zero> | <one-nine> }
  regex align      { <minus> ? }
  regex fill       { <zero> ? }
  regex number     { <one-nine> <zero-nine> * }
  regex length     { <number> ? }
  regex format     { <percent> <align> <fill> <length> <type> }
  regex substring  { <except-pct> + }
  regex element    { <format> | <substring> }
  regex TOP        { <element> * }
}
my class re-format {
  method except-pct($/) { make $/.Str; }
  method minus($/)      { make $/.Str; }
  method zero($/)       { make $/.Str; }
  method one-nine($/)   { make $/.Str; }
  method type($/)       { make $/.Str; }
  method zero-nine($/)  { make $/.values[0].made; }
  method align($/)      { make $/.values[0].made // ''; }
  method fill($/)       { make $/.values[0].made // ''; }
  method number($/)     { make [~] $<one-nine>.made, |$<zero-nine>».made; }
  method length($/) 	{ make $/.values[0].made // ''; }
  method format($/) {
    my $fall-back = sprintf("%%%s%s%s%s", $<align>.made, $<fill>.made, $<length>.made, $<type>.made);
    take %( :align($<align>.made), :fill($<fill>.made), :length($<length>.made), :type($<type>.made), :fall-back($fall-back) );
  }
  method substring($/) {
    take %( :string([~] $<except-pct>».made) );
  }
}

method strftime(Str $format) {
  my %formatter = %(  n => -> { "\n" },
                      A => -> { $.day-name },
                      B => -> { $.month-name },
                   );
  %formatter<%> = -> { '%' };
  my @res = gather prt-format.parse($format, actions => re-format.new);
  @res ==> map -> $fmt { my $res;
                         if $fmt<string>:exists              { $res = $fmt<string> }
                         elsif %formatter{$fmt<type>}:exists { $res = %formatter{$fmt<type>}(); }
                         else                                { $res = $fmt<fall-back> }
                         $res;
        } ==> my @val;
  return [~] @val;
}

=begin pod

=head1 NAME

Date::Calendar::Strftime - formatting any Date::Calendar::whatever date with 'strftime'

=head1 SYNOPSIS

=begin code :lang<perl6>

use Date::Calendar::Strftime;

=end code

=head1 DESCRIPTION

Date::Calendar::Strftime is  a role providing a  C<strftime> method to
format a string  representing the date. This method is  similar to the
C<strftime> function in C.

=head1 AUTHOR

 <>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 

This library is  free software; you can redistribute  it and/or modify
it under the Artistic License 2.0.

=end pod

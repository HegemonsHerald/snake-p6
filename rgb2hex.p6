#!/bin/perl6
use v6;

my $err-message = "One of your Values is out of the range from 0-255";

sub MAIN (IntStr $Red, IntStr $Green, IntStr $Blue, Bool :$lower-case?, Bool :$l?) {

	# check for 0-255 range boundaries
	subset InRange of Int where 0 <= * <= 255;
	my InRange $RedValid = $Red;
	my InRange $GreenValid = $Green;
	my InRange $BlueValid = $Blue;

	# throw an error, if args are out of bound
	CATCH { when * { say $err-message } }

	# do the conversion
	my Str $r = convert $RedValid;	# it seens you don't have to use the (), if there's no namespace overlap
	my Str $g = convert $GreenValid;
	my Str $b = convert( $BlueValid );

	# convert strings to lower case, if so desired
	if $lower-case | $l {
		$r.=lc;			# it seems you don't have to use the (), if there's no namespace overlap
		$g.=lc;
		$b.=lc();
	}	

	# output the final value
	say "#$r$g$b";
}

# convert them RGB Dec Ints to Hex Ints!
sub convert (InRange $n) returns Str {
	my $hex-value = $n.base(16);

	# if your hex-number is too short, make it longer!
	if $hex-value.chars() == 1 {
		$hex-value = "0$hex-value";
	}

	return $hex-value;
}

#!/bin/perl6
use v6;

my $err-message = "Your Hex Code is fricked!";

sub MAIN (Str $hex-value, Str :$delimiter=",", Str:$d?) {
        
        # get rid of whitespace
        my $hex-str = $hex-value.trim;

        # get rid of hash-signs
        $hex-str ~~ s/'#'//;

        # upper-case, cause the parse-base subroutine expects upper-case for Hex values
        $hex-str.=uc;

        # check length to be 3 or 6
        unless $hex-str.chars == 3 || $hex-str.chars == 6 {
                say $err-message;
                say "The length of the Code don't work!";
                exit;
        }

        # split in thirds
        my $num-of-chars = $hex-str.chars / 3;
        my $r = $hex-str.substr(0,               $num-of-chars);
        my $g = $hex-str.substr($num-of-chars,   $num-of-chars);
        my $b = $hex-str.substr($num-of-chars*2, $num-of-chars);

        # if length was 3 (shortened syntax) expand to 6
        if $hex-str.chars == 3 {
                $r = "$r$r";
                $g = "$g$g";
                $b = "$b$b";
        }

        # convert to dec
        $r = convert $r;
        $g = convert($g);
        $b = convert $b;

        # output rgb values
        if $d {
                say "$r$d$g$d$b";
        } else {
                say "$r$delimiter$g$delimiter$b";
        }

}

sub convert (Str $n) {
        $n.parse-base(16).base(10);
}

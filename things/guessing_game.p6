#/cygdrive/c/rakudo/bin/perl6.bat
use v6;

# This is a testing app, for practicing/learning/trying out perl6.
# Notice how I'm purposefully randomly adding and not adding type boundaries?

# HOISTING ====================================================================

# a bound secret number
constant $secret-number = 33;

# prompt the user for a thingy-bajingy
sub prompt-input {

  # get user input
  my Str $input = prompt "Ur guess: ";

  # convert input to number
  my Int $input-number = val($input, :val-or-fail);

  # catch conversion error
  CATCH {
    default {
      say "That wasn't an integer... douche!";
      prompt-input;
    }
  }

  # trigger comparison
  compare ($input-number);
}

# is $n over or under $m?
sub over-under(Int $n, Int $m) returns Str {
  if $n > $m {
    return "over";
  } else {
    return "under";
  }
}

# compare guess against secret number 
sub compare (Int $n) {
  if $n != $secret-number {
    my $over-under = over-under($n, $secret-number);
    say "You guessed wrong, mate! Your guess was $over-under.";
    prompt-input;
  } else {
    say "You guessed right, Well done!";
  }
}

# EXECUTION CODE ==============================================================

# explain what's happening
say "Hi, I've got a number, u guess it! (It's an integer, btw)";

# kick-off the game
prompt-input;

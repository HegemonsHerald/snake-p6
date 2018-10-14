use v6;

# make use of the local lib/ directory
use lib 'lib';

# explaaaaiiiiin: Each perl6 project is by default also a module, just
# without anything that would indicate that. By adding a lib/ dir you
# add the location for library code, with the lib pragma, you tell rakudo
# to go look for this project's library code. You could then go ahead and
# install this project, as if it were a properly done perl 6 module!

use snake-ui;
use snake-game;

# scoping is important
# By default everything in a module is lexically scoped, meaning private.
# To make it public, use the our keyword, which makes a thing globally scoped.
# Then you can access the module namespace and find the declared thing that way.
# If you use is export, the declared thing will be re-exported at the module's root.
# Basically just like rust, only worse keywords!
# Note that declaring something with is export doesn't make that thing globally scoped.


# Ok, what will I do?
#
# /bin/snake.p6
# /lib/snake-ui.p6
# /lib/snake-game.p6

sub MAIN(Int $height=0, Int $width=0) {

	# If $height and $width are equal to 0,
	# the Game Window will take up the entire screen

	# The minimum height for the game is 3
	if 0 < $height < 3 {
		die "The Game Window needs to be at least 3 units high!";
	}

	# The minimum width for the game is 5
	if 0 < $width < 5 {
		die "The Game Window needs to be at least 5 units wide!";
	}

	# The window size can't be negative
	if $width < 0 || $height < 0 {
		die "The Game Window can't be negative, dummy!";
	}

	# Adjust start length and growth rate of snake for tiny game boards
	my $start-length = 5;
	my $growth-rate  = 3;
	if 0 < $width < 10 { 
		$start-length = 1;
		$growth-rate  = 1;
	}

	# Do the game bit!
	start-up($height, $width, 0.5, 3, $start-length, 1, $growth-rate, Right)

}

# Potential Multi-Player:
# Put the Message-Generation Logic for High-Score and the Player-Score Displays in the players themselves, have the players have an ID or a name...
# Then you can go: player 3:  SCORE | player 2: SCORE etc

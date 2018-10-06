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
#
# from snake-game.p6 call snake-ui::render, which takes DYNAMICALLY scoped global player and food and size and settings vars...!

sub MAIN(Int $height=0, Int $width=0) {

	# If $height and $width are equal to 0,
	# the Game Window will take up the entire screen

	# The minimum width for the game is 5
	if 0 < $width < 5 {
		die "The Game Window needs to be at least 5 units wide!";
	}

	# The window size can't be negative
	if $width < 0 || $height < 0 {
		die "The Game Window can't be negative, dummy!";
	}

	# Adjust start length of snake for tiny game boards
	my $start-length = 5;
	if $width < 10 { $start-length = 1 }

	# Do the game bit!
	start-up($height, $width, 0.5, $start-length, 1, 3, Right)

}


# Potential Multi-Player:
# Put the Message-Generation Logic for High-Score and the Player-Score Displays in the players themselves, have the players have an ID or a name...
# Then you can go: player 3:  SCORE | player 2: SCORE etc

#
# 0. Put the welcome text messages in Package Wide variables
# 1. Make the welcome-screen thing print the SNAKE! and a please press any key message
# 2. Add a getch to wait for any key press
# 3. Make the text appear centered
# 4. Add a welcome text that's smaller, for if the window isn't quite so wide
# 5. Add another even smaller one
# 6. Add another, empty one

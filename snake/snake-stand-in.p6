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

sub MAIN(Int $height=80, Int $width=10) {

	start-up($height, $width, 0.5, 5, 1, 3, Right)

}

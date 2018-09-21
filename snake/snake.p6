#!/bin/perl6
use v6;

# Declare Global Variables (assignment in MAIN function)
our $HEIGHT;
our $WIDTH;
our $GAME-OVER;
our $settings;
our @PLAYERS;
our @FOODS;


# Class Definitions

# Points for the segments of the snake
class Point {
	has $.x;
	has $.y;
}

# Snake Movement Direction
enum Direction <Up Down Left Right>;

# Snake object
class Snake {
	has @.segments;
	has $.score is rw = 0;
	has $.direction is rw = Left;
	has $.game-over is rw = False;
	has $!growth is rw = 10;

	# Creation shorthand, takes settings for the width and height
	method create {

		# Put the Snake in the screen middle
		my $x = $WIDTH div 2;
		my $y = $HEIGHT div 2;
		my $start-point = Point.new(x => $x, y => $y);

		# Create the Snake!
		self.new(segments => ($start-point));
	}

	# Move in previous direction
	multi method move() {

		# Insert a segment in the front
		unless !self!insert-front() {
		# If the motion fails, there is no reason to pop from the tail

			# Unless you want to grow
			unless $!growth > 0 {
				# Remove a piece from the end of the snake, so it doesn't grow
				self!pop-tail();
				return;
			}

			# If you grew by a piece, you now have to grow less
			$!growth--;

			return;
		}

		# If the motion was unsuccessfull, this snake is DEAD!
		$GAME-OVER = True;
	}

	# Move in a specific direction
	multi method move( Direction $dir ) {

		# Set the direction
		$!direction = $dir;

		# Move
		self.move();
	}

	# Insert a new segment at the snake's head
	method !insert-front returns Bool {

		# Get the direction in which to move
		my $dir = self.direction;

		# Direction Control: the snake can only turn 90 degrees
		if !self!check-turn($dir) {
			say "Uh-oh, that was an illegal turn";

			# Illegal turns are no Game Over event, but just mean nothing happens, so return
			return True;
		}

		# Compute new position
		my $point = self!compute-new-point($dir);

		# Collision Detection: Is it even possible to insert?
		if self!collision($point) {
			say "Uh-oH, that was a collision!";

			# Self Collisions mean Game Over
			return False;
		}

		# Add new point to the beginning of the Snake
		self.segments.prepend: $point;

		# Check for an intersection with Food
		self!food-collision;

		# Moving was successfull!
		return True;
	}

	# Delete the last segment of the snake
	method !pop-tail {
		self.segments.pop;
	}

	# Compute a Point to insert in the front
	method !compute-new-point( Direction $dir ) returns Point {
		# If wrap-around the snake has hit a wall

		# Get the current head's position
		my $x = self.segments[0].x;
		my $y = self.segments[0].y;

		# Check in which direction to move
		given $dir {
			when Up {
				$y--;
				# TODO I don't know, whether ncurses screens are zero-indexed or one-indexed
				if $y == 0 {
					$y = $HEIGHT;
				}
			}
			when Down { $y++; if $y == $HEIGHT { $y=0 } }
			when Right { $x++; if $x == $WIDTH { $x=0 } }
			when Left { $x--; if $x == 0 { $x=$WIDTH } }
		}

		# Return the new head's point
		Point.new( x => $x, y => $y );
	}

	# 90 Degrees turning test, returns True if turn possible
	method !check-turn( Direction $dir ) {
		if $dir == Left && self.direction == Right { return False }
		if $dir == Right && self.direction == Left { return False }
		if $dir == Down && self.direction == Up { return False }
		if $dir == Up && self.direction == Down { return False }
		return True
	}

	# Collision Detection, if the target point is already in the snake this returns true
	method !collision( Point $point ) {
		for self.segments -> $segment {
			if $segment.x == $point.x && $segment.y == $point.y {
				return True;
			}
		}
		return False
	}

	# Collision Detection, but for Food Points
	method !food-collision {

		for @FOODS -> $food {
			# If you collided with Food
			if @.segments[0].x == $food.position.x && @.segments[0].y == $food.position.y {

				# More points
				$!score++;

				# More segments
				$!growth = 1;

				# New Food
				$food.next;
			}
		}
	}
}

# Food object
class Food {
	has $.position is rw;

	# Change the food point out for a new one
	method next {
		$.position = self!point;
	}

	# Make a new food poin
	method new {
		 my $position = self!point;
		return self.bless(:$position)
	}

	# Make a new point and make sure it is in the game field and not in the snake!
	method !point {
		my $px = $WIDTH.rand.floor;
		my $py = $HEIGHT.rand.floor;

		# say "$py	$px";
		# say "$HEIGHT	$WIDTH";

		for @PLAYERS -> $player {

			# Here's how you can destructure an Object, note that you have to use the field's actual names
			# and therefore can't also have other vars of the same names
			for $player.segments -> Point $P (:$x, :$y) {

				# If the point is already in the player's segments
				if $x == $px && $y == $py {

					# Try again
					return self!point
				}
			}

			# And you can use the precendence syntax for method calls whenever you don't have any method chaining going on
			return Point.new: x => $px, y => $py;
		}
	}
}

# Object to hold the settings
class Settings {
	has $.high-score;
	has $.speed;		# speed in moves-per-second

	method create ($speed) {
		self.new(high-score => 0);
	}
}


# Function Definitions

# Snake Motion Timer
sub timer($snake) {

	# A supplier to supply the interval supplies
	my $meta-supplier = Supplier.new;

	# For each thing (*) coming from $meta-supplier do: .say
	$meta-supplier.Supply.migrate.tap: *.say;
	# .say on a supply-block executes the code, so the supplies,
	# that are returned from this tap are executed

	# A function to change the speed of the movement interval
	sub change-interval($n) {

		# Emit a new interval supply
		$meta-supplier.emit( supply {
			whenever Supply.interval($n) -> $v {
				$snake.move;
				render;
			}

			# Note: You have to use whenever or .act here,
			# because if the handler isn't run single-threaded it
			# doesn't work for some reason...
			# Also, the supply handler has to be defined in
			# this supply-block, because outside it the handler
			# would only run on one of the supplies coming down
			# $meta-handler's tap!
		})
	}

	# Calculate new speed in seconds
	sub new-speed {
		return ( 1 - ( $snake.score div 5 / 10 ) )
	}

	# Kickoff a first interval, with the default speed
	change-interval(1);

	# Counter, that holds the score of the last speed change
	my $speed-counter = 0;

	# Change the speed concurrently
	Promise.start({

		# Only while the game is running
		while !$GAME-OVER {

			# If the score has increased by 5
			if $speed-counter <= ($snake.score - 5) {

				# Set a new interval speed
				change-interval(new-speed);

				# And update the counter
				$speed-counter = $snake.score
			}
		}

		# If the Game has ended
		if $GAME-OVER {

			# Quit the interval, just to be sure... the supply and supplier go out of scope here anyways
			$meta-supplier.done;
		}
	})
}

# Render Function
sub render {
	unless $GAME-OVER {
		say-snake
	}

	# Note: the GAME-OVER check here is necessary, cause the check
	# in the timer sub sometimes gets the timing wrong and makes a
	# recursive call, even though GAME-OVER over is set within a
	# millisecond or so. In that case another render is kicked off
	# that may interfere with the game-over() subroutine, unless I
	# check for GAME-OVER at every position a render update is
	# made!
}

# Function that draws the initial Screen
sub game-start {
	say "SNAKE! To play please press any button";
}

# Function that wraps up the Game upon Game Over Condition
sub game-over {
	say "Game Over";
}


# **** TEMP ****
# Function to output the current snake segments
sub say-snake {
	print "|";
	for @PLAYERS[0].segments -> $segment {
		my $x = $segment.x;
		my $y = $segment.y;
		print "$x, $y |";
	}
	print "\n";
}



# Run

# Get command line arguments and start the game
sub MAIN(Int $height=80, Int $width=10) {

	# Setup

	# Assign Global Variables
	our $HEIGHT = $height;
	our $WIDTH = $width;

	# Init settings object
	our $settings = Settings.create(0.25);
	
	# Init the Ncurses Buffers

	game-start;

	# Execution
	game;

	# Await game-over Input (Restart or Quit events)
	game-over;
}

sub game {

	# Init players
	our @PLAYERS = [ Snake.create() ];

	# Init foods
	our @FOODS = [ Food.new() ];

	# Kick off rendering
	render;

	# Init motion timer for player1
	timer(@PLAYERS[0]);

	# Start reading Keyboard Events for player1
	my $supplier = Supplier.new;
	my $supply = $supplier.Supply;
	$supply.tap( -> $v { say "$v" });

	sub key-listener(Supplier $sup) {
		my $async = Promise.start({
			loop {
				$sup.emit(get)
			}
		});
	}

	key-listener($supplier);

	# so here's the plan for the key-listener:
	# listen to all revant keys by default, depending on what context you're in,
	# change the behaviour of the the supplied... → you can just create the supplies for
	# the motion keys in the game functions and let them (and thereby the handling-behaviour)
	# go out of scope with the game's end!


	while !$GAME-OVER {}
}


# TODO
# Refactor so you could extend with multi-player and you aren't using specific vars in global context anymore!
#  → draw out the codes structure for that (print it first in like 8pt or sth, use 'highlight')

# WHEN I'M DONE WITH THIS
# I should draw out the structure of this program and see how spaghetti it really
# is... That would also teach me how to refactor it -- and how to modularize it!



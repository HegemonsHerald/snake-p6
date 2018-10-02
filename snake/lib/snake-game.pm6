unit module snake-game;

use snake-ui;
use NCurses;
use NativeCall;

our $HEIGHT;
our $WIDTH;
our $GAME-OVER;
our @PLAYERS;
our @FOODS;
our $SETTINGS;
our @WINDOWS;



# Class Definitions

# Points for the segments of the snake
class Point {
	has $.x;
	has $.y;
}

# Snake Movement Direction
enum Direction is export <Up Down Left Right>;

# Snake object
class Snake {
	has @.segments;
	has $.game-over is rw = False;
	has $.score is rw;
	has $.direction;
	has $.growth = 10;

	# Creation shorthand
	method create {

		# Put the Snake in the screen middle...
		my $x = $WIDTH div 2;
		my $y = $HEIGHT div 2;

		# ... by making its head be in the middle...
		my $start-point = Point.new(x => $x, y => $y);
		my @start-points = [ $start-point ];

		# ... then add all the rest of the body
		loop (my $i = 1; $i < $SETTINGS.start-length; $i++) {
			my $next-point = Point.new(x => (@start-points[$i - 1].x - 1), y => $y);
			@start-points.push: $next-point;
		}

		# Create the Snake!
		self.new(segments => @start-points, score => $SETTINGS.start-score, direction => $SETTINGS.start-direction);
	}

	# Motion Timer
	method timer {
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
					self.move;
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

			# for every 5 score points increase the speed by 0.1 seconds between ticks
			return ( 1 - ( ($.score / 5).floor / 10 ) )
		}

		# Kickoff a first interval, with the default speed
		change-interval($SETTINGS.start-speed);

		# Counter, that holds the score of the last speed change
		my $speed-counter = 0;

		# Change the speed concurrently
		Promise.start({

			# Only while the game is running
			while !$GAME-OVER {

				# If the score has increased by 5
				if $speed-counter <= ($.score - 5) {

					# Set a new interval speed
					change-interval(new-speed);

					# And update the counter
					$speed-counter = $.score
				}
			}

			# If the Game has ended
			if $GAME-OVER {

				# Quit the interval, just to be sure... the supply and supplier go out of scope here anyways
				$meta-supplier.done;
			}
		})
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

	# 0 to 90 Degrees turning test, returns True if turn possible (90 degrees or less)
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

		# If the game board isn't completely full of Snakes
		# Note: If the board is full of Snakes the call to $food.next can't decide
		# on a new Food point and won't return, which means the Game will crash instead
		# of ending with a Game Over on the next motion by a Snake.
		unless board-filled() {

			# Check for collisions with food objects
			for @FOODS -> $food {
				# If you collided with Food
				if $.segments[0].x == $food.position.x && $.segments[0].y == $food.position.y {

					# More points
					$!score += $SETTINGS.points-worth;

					# More segments
					$!growth += $SETTINGS.growth-rate;

					# New Food
					$food.next;
				}
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

# Settings object
class Settings {
	has $.high-score;
	has $.start-speed;	# How fast a snake is at the start, in delta seconds between ticks
	has $.start-score;	# How many points a snake has at the start
	has $.start-length;	# How long a snake is at the start
	has $.start-direction;	# Which direction a snake starts in
	has $.points-worth;	# How much a food point is worth in score
	has $.growth-rate;	# How many segments a snake grows per food point

	method create ($start-speed, $start-length, $points-worth, $growth-rate, $start-direction) {
		self.bless(high-score => 0, start-score => 0, :$start-speed, :$start-length, :$points-worth, :$growth-rate, :$start-direction)
	}
}


# Function Definitions

# Make the Snake(s) move
sub init-timers {
	for @PLAYERS -> $player {
		$player.timer
	}
}

# Function that checks how many fields of the game board are filled with Snake segments
# and returns true, if all are filled
sub board-filled {
	my $area = $HEIGHT * $WIDTH;

	my $snake-area = 0;
	for @PLAYERS -> $player {
		$snake-area += $player.segments.elems;
	}

	if $snake-area >= $area {
		return True
	}

	return False
}

# Function to output the current snake segments
sub say-snake {
	print "|";
	for @PLAYERS[0].segments -> $segment {
		my $x = $segment.x;
		my $y = $segment.y;
		print "$x, $y |";
	}
	print "		@PLAYERS[0].score()	@PLAYERS[0].growth()\n";
}


# *****************************************************************************
# Render Function Wrappers

# Render Function
#sub render {
#	unless $GAME-OVER {
#		say-snake
#	}
#
#	# Note: the *GAME-OVER check here is necessary, cause the check
#	# in the timer sub sometimes gets the timing wrong and makes a
#	# recursive call, even though *GAME-OVER over is set within a
#	# millisecond or so. In that case another render is kicked off
#	# that may interfere with the game-over() subroutine, unless I
#	# check for *GAME-OVER at every position a render update is
#	# made!
#}



# *****************************************************************************
# API Functions

sub game-start is export {

	welcome-screen(@WINDOWS);

}

sub game is export {

	# game...
	our @PLAYERS.push: Snake.create();

	our @FOODS.push: Food.new();

	init-timers;

	while !$GAME-OVER {}
}

sub game-over is export {
	say "Game Over";

	# render the game over screen over the active screen...
}

sub start-up (Int $height, Int $width, $speed, $length, $worth, $growth, $start-direction) is export {

	# init thingies
	our $HEIGHT	= $height;
	our $WIDTH	= $width;
	our @PLAYERS	= [];
	our @FOODS	= [];
	our @WINDOWS	= [];

	our $SETTINGS	= Settings.create($speed, $length, $worth, $growth, $start-direction);


	# Basic Settings and init stdscr
	@WINDOWS.push: ui-init;

	# These have to be globally scoped for the execution of the entire game...
	start_color;
	use_default_colors;
	init_pair(COLOR_PAIR_1, COLOR_BLUE, COLOR_YELLOW);
	init_pair(COLOR_PAIR_2, COLOR_GREEN, COLOR_WHITE);

	# Let's make some windows...		height		width	y		x
	@WINDOWS.push: snake-ui::create-window( 1,		$WIDTH, 0, 		0);	# ... top bar
	@WINDOWS.push: snake-ui::create-window( $HEIGHT - 2,	$WIDTH, 1, 		0);	# ... game board
	@WINDOWS.push: snake-ui::create-window( 1,		$WIDTH, $HEIGHT - 1,	0);	# ... bottom bar
	

	# run the game!
	game-start;
	game;
	game-over;
}

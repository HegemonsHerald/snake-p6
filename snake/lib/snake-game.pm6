unit module snake-game;

use snake-ui;
use NCurses;
use NativeCall;

our $HEIGHT;
our $WIDTH;
our $GAME-OVER;
our $SETTINGS;
our @PLAYERS;
our @FOODS;
our @WINDOWS;


# *****************************************************************************
# GAME LOGIC

# Class Definitions

# Points for the segments of the snake
class Point {
	has $.x is rw;
	has $.y is rw;
}

# Snake Movement Direction
enum Direction is export <Up Down Left Right>;

# A Timer that moves a Snake
class Timer {

	# A timer holds a reference to its player, so it can call its .move method.
	#
	# Explanation of the Speed Change System:
	# The Settings object holds a field: speed-change-interval.
	# The timer holds a field: speed-counter.
	# Whenever the speed-counter lacks behind the timer's player's score by the value in speed-change-interval, (player.score - settings.speed-change-interval == timer.speed-counter)
	# the timer will increase the player's speed.
	# ... so, whenever a player has made speed-change-interval many points, the speed will increase by 0.1 seconds/tick

	has $.parent-player;
	has $.meta-supplier;
	has $.speed-counter is rw = -1;
	has $.current-speed is rw = $SETTINGS.start-speed;
	has $.promise is rw = 0;

	method new ($parent-player) {

		# A supplier to supply the interval supplies
		my $meta-supplier = Supplier.new;

		self.bless(:$parent-player, :$meta-supplier);
	}

	# Start the timer
	method start {

		# For each thing (*) coming from $meta-supplier do: .say
		$.meta-supplier.Supply.migrate.tap: *.say;
		# .say on a supply-block executes the code, so the supplies,
		# that are returned from this tap are executed

		$.promise = Promise.start({

			while !$GAME-OVER {

				# If speed-counter is in initial state, kick off the intervall
				if $.speed-counter == -1 {
					self.change-interval;
					$.speed-counter = 0;

				# If the score has increased by 5 && this is at max the fourth speed increase (Supply.interval only goes down to 0.1, we start at 0.5 with .1 speed increases...)
				} elsif $.speed-counter == ( $.parent-player.score - $SETTINGS.speed-change-interval ) && $.parent-player.score <= $SETTINGS.speed-change-interval * 4 {

					# Set a new interval speed
					$.current-speed = self.new-speed;

					# Update the interval
					self.change-interval;

					# And update the counter
					$.speed-counter = $.parent-player.score
				}

			}

			# If game over, make the interval stop!
			self.clear-interval;

			# Close the Supply
			$.meta-supplier.done;
			return
		});
	}

	# A function to set the interval Supply to not be an interval Supply
	method clear-interval {
		$.meta-supplier.emit: supply { }
	}

	# A function to change the speed of the movement interval
	method change-interval {

		# Emit a new interval supply
		$.meta-supplier.emit( supply {
			whenever Supply.interval($.current-speed) -> $v {
				unless $GAME-OVER {
					$.parent-player.move;
					render;
				}
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

	# Calculate speed in seconds
	method new-speed {
		return ( $.current-speed - 0.1 )
	}

}

# Snake object
class Snake {
	has @.segments is rw;
	has $.score is rw;
	has $.direction is rw;
	has $.growth is rw = 0;
	has $.timer is rw = 0;

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

	method start-timer {
		$.timer = Timer.new(self);
		$.timer.start;
	}

	method kill-timer {
		$.timer.kill;
	}


	# Move in previous direction
	multi method move() {

		# Insert a segment in the front
		unless !self!insert-front() {
		# If the motion fails, there is no reason to pop from the tail

			# Unless you want to grow
			unless $.growth > 0 {
				# Remove a piece from the end of the snake, so it doesn't grow
				self!pop-tail();
				return;
			}

			# If you grew by a piece, you now have to grow less
			$.growth--;

			return;
		}

		# If the motion was unsuccessfull, this snake is DEAD!
		$GAME-OVER = True;
	}

	# Move in a specific direction
	multi method move( Direction $dir ) {

		# Direction Control: the snake can only turn 90 degrees
		if !self!check-turn($dir) {
			# say "Uh-oh, that was an illegal turn";

			# Illegal turns are no Game Over event, but just mean nothing happens, so return
			return
		}

		# If the new direction isn't illegal, set the direction
		$.direction = $dir;

		# Move
		self.move();
	}

	# Insert a new segment at the snake's head
	method !insert-front returns Bool {

		# Compute new position
		my $point = self!compute-new-point($.direction);

		# Collision Detection: Is it even possible to insert?
		if self!collision($point) {
			# say "Uh-oH, that was a collision!";

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
			when Up {	$y--; if $y == -1	{ $y = $HEIGHT -1 } }	# $HEIGHT -1 because $HEIGHT is the number of lines, not the index of the last line (ncurses windows are 0-indexed, but $HEIGHT counts the number of lines, which makes it 1-indexed)
			when Down {	$y++; if $y == $HEIGHT	{ $y = 0 } }		#										    ($HEIGHT = lines.elems, we want to move to lines[$HEIGHT -1], cause $HEIGHT -1 == lines.elems -1)
			when Right {	$x++; if $x == $WIDTH	{ $x = 0 } }
			when Left {	$x--; if $x == -1	{ $x = $WIDTH -1 } }	# $WIDTH -1 for same reason as above with $HEIGHT
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
					$.score += $SETTINGS.points-worth;

					# More segments
					$.growth += $SETTINGS.growth-rate;

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
	has $.start-speed;		# How fast a snake is at the start, in delta seconds between ticks
	has $.speed-change-interval;	# How many points a player has to make, til he gets a speed increase
	has $.start-score;		# How many points a snake has at the start
	has $.start-length;		# How long a snake is at the start
	has $.start-direction;		# Which direction a snake starts in
	has $.points-worth;		# How much a food point is worth in score
	has $.growth-rate;		# How many segments a snake grows per food point

	method create ($start-speed, $speed-change-interval, $start-length, $points-worth, $growth-rate, $start-direction) {
		self.bless(high-score => 0, start-score => 0, :$start-speed, :$speed-change-interval, :$start-length, :$points-worth, :$growth-rate, :$start-direction)
	}
}


# *****************************************************************************
# Function Definitions

# Make the Snake(s) move
sub init-timers {
	for @PLAYERS -> $player {
		$player.move;
		$player.start-timer
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

# Function to calculate the maximally possible score
sub max-score {
	return ( $HEIGHT * $WIDTH - $SETTINGS.start-length ) * $SETTINGS.points-worth
}

# *****************************************************************************
# Game State Functions and API Functions


# Render Function Wrapper
sub render {
	unless $GAME-OVER {
		snake-ui::render-game(@WINDOWS, @PLAYERS, @FOODS);
	}

	# Note: the $GAME-OVER check here is necessary, cause the check
	# in the timer sub sometimes gets the timing wrong and makes a
	# recursive call, even though $GAME-OVER over is set within a
	# millisecond or so. In that case another render is kicked off
	# that may interfere with the game-over() subroutine, unless I
	# check for $GAME-OVER at every position a render update is
	# made!
}

# Start the Game
sub game-start {

	# Render the initial screen
	welcome-screen(@WINDOWS, $SETTINGS.high-score);

}

# Run the Game
sub game {

	# Make absolutely sure, that the game can begin!
	our $GAME-OVER = False;

	# Setup Game Logic things...
	our @PLAYERS.push: Snake.create();
	our @FOODS.push: Food.new();

	# Start the motions!
	init-timers;

	# While the Game's running
	while !$GAME-OVER {

		# Wait for input
		my $input = getch;

		given $input {
			# 104 = h, 260 = left_arrow
			when 104 | KEY_LEFT {	@PLAYERS[0].move(Left); render }

			# 106 = j, 258 = down_arrow
			when 106 | KEY_DOWN {	@PLAYERS[0].move(Down); render }

			# 107 = k, 259 = up_arrow
			when 107 | KEY_UP {	@PLAYERS[0].move(Up); render }

			# 108 = l, 261 = right_arrow
			when 108 | KEY_RIGHT {	@PLAYERS[0].move(Right); render }

			# 115 = s
			# when 115 { game-over }

			default { say $input }
		}

	}

	game-over;
}

# Emtpy the game state global vars
sub purge {
	$GAME-OVER = True;

	until @PLAYERS.elems == 0 {
		@PLAYERS.pop;
	}

	until @FOODS.elems == 0 {
		@FOODS.pop;
	}
}

# On Game Over
sub game-over {

	# Reset the game state
	purge;

	# Render the game over screen
	game-over-screen(@WINDOWS, $SETTINGS.high-score);

	# Decide, whether to restart or not...
	my $restart = False;

	# Wait for user interaction
	while 1 {
		my $input = getch;
		given $input {
			# 114 = r
			when 114 { $restart = True; last }

			# 113 = q
			when 113 { last }

			# If anything else, loop
			default { next }
		}
	}

	# Either restart or power down NCurses and quit
	if $restart { game } else { endwin; exit }
}

# Kickoff!
sub start-up ($height, $width, $speed, $interval, $length, $worth, $growth, $start-direction) is export {

	# Init NCurses
	our @WINDOWS	= [];
	@WINDOWS.push: ui-init;

	# These have to be globally scoped for the execution of the entire game...
	curs_set(0);
	start_color;
	use_default_colors;
	init_pair(COLOR_PAIR_1, COLOR_BLUE, COLOR_YELLOW);
	init_pair(COLOR_PAIR_2, COLOR_BLUE, -1);

	# Make window size decisions
	my ($h, $w) = $height, $width;
	my $y = getmaxy(@WINDOWS[0]);
	my $x = getmaxx(@WINDOWS[0]);
	
	if $height == 0 {
		$h = $y;
	}

	if $width == 0 {
		$w = $x;
	}

	# Make sure the width is evenly divisible (cause game logic runs at half-width of render-logic)
	if $w % 2 == 1 {
		$w--
	}


	# Init thingies
	our $ABS-HEIGHT	= $h;				# absolute height
	our $ABS-WIDTH	= $w;				# absolute width
	our $HEIGHT	= $ABS-HEIGHT - 2;		# height of the game board for the game logic; -2 for the top and bottom status lines
	our $WIDTH	= $ABS-WIDTH div 2;		# width of the game board for the game logic... div 2 cause of a renderer peculiarity
	our $H-OFFSET	= 1;				# offset for the renderer: add this to all game element's Y-position-values to offset against the borders...
	our $W-OFFSET	= 0;				# offset for the renderer: add this to all game element's X-position-values to offset against the borders...
	our @PLAYERS	= [];
	our @FOODS	= [];

	our $SETTINGS	= Settings.create($speed, $interval, $length, $worth, $growth, $start-direction);


	# Let's make some windows...
	# ...			  	height	   		width       	y			x
	@WINDOWS.push: Top.new(		1,			$ABS-WIDTH,	0,			0,	"SNAKE!!!",	max-score);	# ... top bar
	@WINDOWS.push: Middle.new(	$ABS-HEIGHT - 2,	$ABS-WIDTH,	1,			0);					# ... game board
	@WINDOWS.push: Bottom.new(	1,			$ABS-WIDTH,	$ABS-HEIGHT - 1,	0,	max-score);			# ... bottom bar



	# run the game!
	game-start;		# note: game-start is a one-time function that wraps the render welcome screen call
	game;
}

# On leave, restore regular terminal behaviour
LEAVE {
	endwin
}

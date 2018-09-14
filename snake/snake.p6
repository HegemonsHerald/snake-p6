#!/bin/perl6
use v6;

# Declare Global Variables (assignment in MAIN function)
our $HEIGHT;
our $WIDTH;


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
	has $.score = 0;
	has $.direction is rw = Left;

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
	method move( Bool $grow=False ) {

		# Insert a segment in the front
		unless !self!insert-front() {
		# If the motion fails, there is no reason to pop from the tail

			# Unless you want to grow
			unless $grow {
				# Remove a piece from the end of the snake, so it doesn't grow
				self!pop-tail();
			}

			# Return Successfully, cause the movement was executed collision-less
			return True;
		}

		# If the movement failed, that means Game Over
		return False;
	}

	# Move in a specific direction
	method moveDir( Direction $dir, Bool $grow=False ) {

		# Insert a segment in the specified direction
		unless !self!insert-front($dir) {
		# If the motion fails, there is no reason to pop from the tail

			# Unless you want to grow
			unless $grow {
				# Remove a piece from the tail of the snake, so it doesn't grow
				self!pop-tail();
			}

			# Return Successfully, cause the movement was executed collision-less
			return True;
		}

		return False;
	}

	# Insert a new segment at the snake's head
	method !insert-front( Direction $dir=self.direction ) returns Bool {

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

		# Change previous direction to current direction
		self.direction = $dir;

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

# Async timer that runs specified lambda after n seconds
sub timer(Int $seconds, $lambda) {
	my $sleeper = Promise.in($seconds);

	$sleeper.then({
		$lambda();
		timer( $seconds, $lambda );
	});
}

# Function that wraps up the Game upon Self-Collision
sub game-over {
	say "Game Over";
}

# Run

# Get command line arguments and start the game
sub MAIN(Int $height=80, Int $width=10) {

	# Assign Global Variables
	our $HEIGHT = $height;
	our $WIDTH = $width;

	# init settings object
	my $settings = Settings.create(0.25);
	
	# init snake object
	my $player1 = Snake.create();


	# **** TEMP ****
	# function to output the current snake segments
	sub say-snake {
		print "|";
		for $player1.segments -> $segment {
			my $x = $segment.x;
			my $y = $segment.y;
			print "$x, $y |";
		}
		print "\n";
	}

	say-snake;


	# move up
	$player1.moveDir(Up);
	say-snake;

	# move up and grow
	$player1.moveDir(Left, True);
	say-snake;

	# init motion timer
	timer(1, -> {
		if !$player1.move(True) {
			return False
		}
		say-snake
	});

	sleep 100;
}


# WHEN I'M DONE WITH THIS
# I should draw out the structure of this program and see how spaghetti it really
# is... That would also teach me how to refactor it -- and how to modularize it!
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
	has $.direction = Left;

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
		self!insert-front();

		# Unless you want to grow
		unless $grow {
			# Remove a piece from the end of the snake, so it doesn't grow
			self!pop-tail();
		}
	}

	# Move in a specific direction
	method moveDir( Direction $dir, Bool $grow=False ) {

		# Insert a segment in the specified direction
		self!insert-front($dir);

		# Unless you want to grow
		unless $grow {
			# Remove a piece from the tail of the snake, so it doesn't grow
			self!pop-tail();
		}
	}

	# Insert a new segment at the snake's head
	method !insert-front( Direction $dir=self.direction ) {

		# run collision detection: Is it even possible to insert?

		# Compute new position
		my $point = self!compute-new-point($dir);

		# Add new point to the beginning of the Snake
		self.segments.prepend: $point;
	}

	# Delete the last segment of the snake
	method !pop-tail {
		self.segments.pop;
	}

	# Compute a Point to insert in the front
	method !compute-new-point( Direction $dir, Bool $wrap-around=False ) returns Point {
		# If wrap-around the snake has hit a wall

		# Get the current head's position
		my $x = self.segments[0].x;
		my $y = self.segments[0].y;

		# Check in which direction to move
		given $dir {
			when Up { $y++ }
			when Down { $y-- }
			when Right { $x++ }
			when Left { $x-- }
		}

		# Return the new head's point
		Point.new( x => $x, y => $y );
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


# Run

# Get command line arguments and start the game
sub MAIN(Int $height=20, Int $width=80) {

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
	$player1.moveDir(Up, True);
	say-snake;

	# init motion timer
	timer(1, -> { $player1.move(); say-snake });

	sleep 100;
}


# WHEN I'M DONE WITH THIS
# I should draw out the structure of this program and see how spaghetti it really
# is... That would also teach me how to refactor it -- and how to modularize it!

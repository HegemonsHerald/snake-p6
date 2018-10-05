use v6;
use NCurses;
use NativeCall;

unit module snake-ui;

# setlocale from libc, sets the locale for the native Strings, that are passed to NCurses and makes NCurses use wide/unicode chars
sub setlocale(int32, Str) returns Str is native(Str) {*};

# wprintw isn't a part of the NCurses NativeCall version... for some reason
sub wprintw(WINDOW, Str) returns int32 is native(&library) {*};

# Init Function
sub ui-init is export {

        # set locale to en_US.UTF-8 for Unicode Char support
        setlocale(0, "");

        cbreak;
        noecho;

        our $window = initscr() or die "Failed to initialize ncurses\n";
        nc_refresh;

        return $window
}

# Run a method on all the windows
sub infix:<all>(@w, $m) {
	for @w[1..^@w.elems] { $_."$m"() }
	# Note: this makes use of the quoted method call syntax, which allows you to substitute the method name from inside a variable!
	# This is friggin' brilliant [perl 5 can do that, too!]
}

# Fields in the top bar and the bottom bar
# This is just a convenient way of storing, where the printw has to start to overwrite status info, like the player's High Score...
class Field {
	has $.x-anchor;
	has $.y-anchor;

	method new ($y-anchor, $x-anchor) {
		self.bless(:$y-anchor, :$x-anchor)
	}
}

class Score-Field is Field {
	method new ($y-anchor, $parent-width, $max-score, $message-length) {

		# Calculate the x-anchor position:
		# 		window width - ( ... the width of the field ... )
		my $x-anchor = $parent-width - ($max-score.base(10).chars + $message-length + 1);
		# Note: the -1 adds padding for aesthetic reasons

		self.bless(:$y-anchor, :$x-anchor);
	}
}

# Window objects hold meta data about the windows, so you can remember e.g. the width
class Window is export {
	has $.width;
	has $.height;
	has $.x;
	has $.y;
	has $.window;

	# Make a new NCurses Window
	method create-window ($height, $width, $y, $x) {
		# Create the window
		my $window = newwin($height, $width, $y, $x);

		# Render it
		wrefresh($window);
		nc_refresh;

		return $window
	}


	# Make a new window
	method new ($height, $width, $y, $x) {

		my $window = self.create-window($height, $width, $y, $x);

		# Return the window object
		return self.bless(:$height, :$width, :$y, :$x, :$window)
	}

	# Fill the window with spaces to set the background color!
	multi method bkgd {
		for 0..$.height -> $index {
			mvwhline($.window, $index, $.x, 32, $.width)
		}
	}

	multi method bkgd ($color-pair) {
		wcolor_set($.window, $color-pair, 0);
		$.bkgd;
	}

	# Delete the window
	method delwin {
		delwin($.window);
		nc_refresh;
	}

	method wprintw ($str) {
		wprintw($.window, $str);
	}

	method mvprintw ($y, $x, $str) {
		mvwprintw($.window, $y, $x, $str)
	}

	method color ($color-pair) {
		wcolor_set($.window, $color-pair, 0);
	}

	method attron ($attr) {
		wattron($.window, $attr)
	}

	method refresh {
		wrefresh($.window)
	}

	method move ($y, $x) {
		wmove($.window, $y, $x)
	}
}

# Top Window
class Top is Window is export {
	has Field $.snake-field;
	has $.snake-message;
	has Field $.hi-score-field;

	# This code also works: it slurps up the parameters...
	# method new (*%params) {
	# 	# ... and transforms them into a list with '|'
	# 	return self.bless(|%params);
	# }

	method new ($height, $width, $y, $x, $snake-message, $max-score) {

		# Create the window
		my $window = self.create-window($height, $width, $y, $x);

		# Make a field as left as they come
		my $snake-field = Field.new(0,0);

		# Now for the right side, bright side!
		my $message = "Hi:";
		my $hi-score-field = Score-Field.new(0, $width, $max-score, $message.chars);

		# Maaaake Snaaaake Tooooop Windoooooooow
		return self.bless(:$height, :$width, :$y, :$x, :$window, :$snake-message, :$snake-field, :$hi-score-field)
	}

	# Print the Message on the Left Side of the Top Window
	method print-snake-field {
		self.move($.snake-field.y-anchor, $.snake-field.x-anchor);
		self.wprintw(self.snake-message);
	}

	# Print the Message on the Right Side of the Top Window... that's the High Score
	method print-hi-score-field ($high-score) {

		# Compute the string for the field

		my $message = "HI:";
		my $number-of-spaces = self.width - self.hi-score-field.x-anchor - $message.chars - $high-score.base(10).chars;

		for 1..$number-of-spaces { $message = $message ~ " " }

		$message = $message ~ $high-score.base(10);

		# Print the field

		self.move($.hi-score-field.y-anchor, $.hi-score-field.x-anchor);
		self.wprintw($message);
	}
}

# Bottom Window
class Bottom is Window {
	has Field $.score-field;

	method new ($height, $width, $y, $x, $max-score) {

		# Create the window
		my $window = self.create-window($height, $width, $y, $x);

		# Player's wanna know, how their game does go!
		my $message = "Score:";
		my $score-field = Score-Field.new(0, $width, $max-score, $message.chars);

		# Maaaake Snaaaake Bottooooom Windoooooooow
		return self.bless(:$height, :$width, :$y, :$x, :$window, :$score-field)
	}

	method print-score-field ($score) {
	}
}


# Render Initial Welcome Screen
sub welcome-screen (@windows, $high-score) is export {

	# Shortcuts
	my ($top, $mid, $bot) = @windows[1..3];

	# Set the color palette...
	$top.color(COLOR_PAIR_1);
	$mid.color(COLOR_PAIR_2);
	$bot.color(COLOR_PAIR_1);

	# ... and styles
	$top.attron(A_BOLD);
	$bot.attron(A_BOLD);

	# Make the windows visible
	@windows all "bkgd";

	# Add some Text
	#$top.mvprintw(0, 0, "SNAKE!");
	$mid.mvprintw(5, 5, "wheee ƣ");
	$bot.mvprintw(0, 0, "sldkfjsdlfkj");

	# Print the Top Bar
	$top.print-snake-field;
	$top.print-hi-score-field($high-score);

	# Print the Startup Screen

	# Nothing to do for the Bottom Bar

	# Refresh
	@windows all "refresh";

	move(0,0);

	# Wait for Input
	loop {}
}

# General Render Function
our sub render (@windows) {

	# Render Game
	# ...

}

# Render Game Over Screen
sub game-over-screen (@windows, $high-score) is export {

	# Shortcuts
	my ($top, $mid, $bot) = @windows[1..3];

	# Render Game Over Screen
	# ...

	$top.print-hi-score-field($high-score);


	# Wait for input

}

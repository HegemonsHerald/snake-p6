use v6;
use NCurses;
use NativeCall;

unit module snake-ui;

sub setlocale(int32, Str) returns Str is native(Str) {*};

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
class Field {
	has $.x-anchor;
	has $.y-anchor;

	method new ($y-anchor, $x-anchor) {
		self.bless(:$y-anchor, :$x-anchor)
	}

	method move-to {
		move($.y-anchor, $.x-anchor);
	}
}

# Window objects hold meta data about the windows, so you can remember e.g. the width
class Window is export {
	has $.width;
	has $.height;
	has $.x;
	has $.y;
	has $.window;

	# Make a new window
	method new ($height, $width, $y, $x) {

		# Create the window
		my $window = newwin($height, $width, $y, $x);

		# Render it
		wrefresh($window);
		nc_refresh;

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
}

# Top Window
class Top is Window is export {
	#has Field $.l-field;
	#has Field $.r-field;
	has $.snake-field;
	has $.snake-message;
	has $.hi-score-field;

	# This code also works: it slurps up the parameters...
	# method new (*%params) {
	# 	# ... and transforms them into a list with '|'
	# 	return self.bless(|%params);
	# }

	method new ($height, $width, $y, $x, $snake-message, $max-score) {


		# Create the window
		my $window = newwin($height, $width, $y, $x);

		# Render it
		wrefresh($window);
		nc_refresh;

		my $snake-field = Field.new(0,0);

		my $hi-score-field = Field.new(0, $max-score.elems);

		return self.bless(:$height, :$width, :$y, :$x, :$window, :$snake-message, :$snake-field, :$hi-score-field)
	}
}



# Render Initial Welcome Screen
sub welcome-screen (@windows) is export {

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
	$top.mvprintw(0, 0, "SNAKE!");
	$mid.mvprintw(5, 5, "wheee ƣ");
	$bot.mvprintw(0, 0, "sldkfjsdlfkj");

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
sub game-over-screen (@windows) is export {

	# Render Game Over Screen
	# ...

	# Wait for input

}

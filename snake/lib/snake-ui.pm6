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

# Run bkgd() on all the relevant windows
sub postfix:<.bkgd>(@w) {
	for @w[1..^@w] { $_.bkgd }
}

# Run refresh on all the relevant windows
sub postfix:<.refresh>(@w) {
	for @w[1..^@w] { $_.refresh }
	nc_refresh
}

# Render Initial Welcome Screen
sub welcome-screen (@windows) is export {

	# Shortcuts
        my $top = @windows[1];
        my $mid = @windows[2];
        my $bot = @windows[3];


	# Set the color palette...
	$top.color(COLOR_PAIR_1);
	$mid.color(COLOR_PAIR_2);
	$bot.color(COLOR_PAIR_1);

	# ... and styles
	$top.attron(A_BOLD);
	$bot.attron(A_BOLD);

	# Make the windows visible
	@windows.bkgd;

	# Add some Text
	$top.mvprintw(0, 0, "SNAKE!");
	$mid.mvprintw(5, 5, "wheee ƣ");
	$bot.mvprintw(0, 0, "Hahahahahahahahahahaha");

	# Refresh
	@windows.refresh;

	move(0,0);

	loop {}
}

# General Render Function
sub render is export {}

# Render Game Over Screen
#sub game-over is export {}

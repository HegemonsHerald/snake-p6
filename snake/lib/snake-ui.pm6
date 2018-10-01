use v6;
use NCurses;
use NativeCall;

unit module snake-ui;

sub setlocale(int32, Str) returns Str is native(Str) {*};

our $window;

# Init Function
sub ui-init is export {

	# set locale to en_US.UTF-8 for Unicode Char support
	setlocale(0, "");

	cbreak;
	noecho;
	start_color;
	use_default_colors;

	init-colors;

	our $window = initscr() or die "Failed to initialize ncurses\n";
	nc_refresh;
}

# Set my Color Palette
sub init-colors {
	init_pair( COLOR_PAIR_1, COLOR_BLUE, -1 );
}

# Create Window
sub create-window (Int $height, Int $width, Int $pos-y, Int $pos-x) {
	my $win = newwin($height, $width, $pos-y, $pos-x);
	box($win, 0,0);
	wrefresh($win);
	nc_refresh;
	return $win
}

# Delete Window
sub delete-window ($window) {
	delwin($window);
	nc_refresh;
}

sub start-top-win {
	my $top-win = create-window(1, $*WIDTH, 0, 0);
	return $top-win
}
sub start-game-win   {};
sub start-bottom-win {};

# Render Initial Welcome Screen
sub welcome-screen {

	# create the top status bar
	my $top-win = start-top-win;

	# create the main game window
	start-game-win;

	# create the bottom status bar
	start-bottom-win;

}

# General Render Function
sub render {}

# Render Game Over Screen
sub game-over {}

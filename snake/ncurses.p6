use v6;
use NCurses;
use NativeCall;

# FUNCTION DEFINITIONS

# Creates and draws a standard window
sub create-window(Int $height, Int $width, Int $StartY, Int $StartX) {
	my $win = newwin($height, $width, $StartY, $StartX);
	box($win, 0, 0);
	
	# Using nativecast and encoding to generate the ascii codes on the fly
	# Make sure a Unicode compatible TERM is set (like xterm-16color)
	# my int32 $a = nativecast(int32, '|'.encode("ascii"));
	# my int32 $a = 124;
	# wborder($win, $a, $a, $b, $b, $c, $c, $c, $c);

	wrefresh($win);
	return $win
}

# Cleans up and deletes a window
sub delete-window($window) {
	my int32 $space = 32;
	wborder($window, $space,$space,$space,$space,$space,$space,$space,$space);
	wrefresh($window);
	delwin($window);
}


# SET THE LOCALE so that ncurses can use utf8
# This needs to be done before initscr() is called
# import the setlocale function from libc (for some reason Str calls up libc here)
sub setlocale(int32, Str) returns Str is native(Str) {*};

# use it to set en_US.UTF-8
setlocale(0, "");

# after this you can use printw ("print wide") to print wide unicode characters (if the emulator supports it)


# Initialize curses window
my $win = initscr() or die "Failed to initialize ncurses\n";
nc_refresh;

# Initialize status bar window
my $st-y = 7;
my $st-x = 7;
my $status-bar = create-window(12, 24, $st-y, $st-x);

cbreak;		# disable the line buffer (get raw-ish characters)
noecho;		# don't render input
# keypad;		# read special keys

start_color;

# make the terminal emulator's own colors available
use_default_colors;

init_pair(1, COLOR_RED, -1);
init_pair(2, COLOR_GREEN, -1);

# add the Color Pair to the attributes available in the current window
attrset(COLOR_PAIR_2);
wattrset($status-bar, COLOR_PAIR_1);

# set the Color Pair disregarding the attributes
# color_set(2, 0);

my int32 $row = 1;
my $col = 1;


loop {
	unless $row == 11 {
		my $ch = getch;
		mvwprintw($status-bar, $row, $col, "ㄩ");
		move(0, 0);
		wrefresh($status-bar);
		$row++;
		nc_refresh;
		next;
	}


	$col++;
	$row = 1;
#		delete-window($status-bar);
#		last;
};

# Cleanup
LEAVE {
    delwin($win) if $win;
        endwin;
}


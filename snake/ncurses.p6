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

	# Unicode makes problems
	# For some reason nativecast produces a number of different output integers, non of which correspond to the looked-for value
	# my int32 $a = nativecast(int32, 'आ'.encode("utf8"));
	# my int32 $a = 2309;

	# my int32 $a = nativecast(int32, '|'.encode("ascii"));
	# my int32 $b = nativecast(int32, '-'.encode("ascii"));
	# #my int32 $c = nativecast(int32, '+'.encode("ascii"));
	# my int32 $c = 2309;

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

# Initialize curses window
my $win = initscr() or die "Failed to initialize ncurses\n";
nc_refresh;

# Initialize status bar window
my $status-bar = create-window(12, 24, 7, 7);

cbreak;		# disable the line buffer (get raw-ish characters)
noecho;		# don't render input
# keypad;		# read special keys

start_color;

# make the terminal emulator's own colors available
use_default_colors;

init_pair(1, COLOR_RED, -1);
init_pair(2, COLOR_GREEN, COLOR_BLACK);

# add the Color Pair to the attributes available in the current window
attrset(COLOR_PAIR_1);

# turn the attribute on!
attron(COLOR_PAIR_1);

# set the Color Pair disregarding the attributes
# color_set(2, 0);

my int32 $row = 0;
my $col = 0;
loop {
	my $ch = getch;
	mvwaddch($status-bar, $row, $col, $ch);
	wrefresh($status-bar);
	$row++;
	nc_refresh;

	if $row > 50 {
		$col++;
		$row = 0;
#		delete-window($status-bar);
#		last;
	}
};

# Cleanup
LEAVE {
    delwin($win) if $win;
        endwin;
}


# Alright!
# Windows function like cutouts that look into buffers, that are stacked on top of each other.
# They are literally a window into a buffer. The buffers the windows look onto all have the size and coordinates of the physical screen. 

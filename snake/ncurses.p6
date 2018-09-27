use v6;
use NCurses;
use NativeCall;

# FUNCTION DEFINITIONS

# Creates and draws a standard window
sub create-window(Int $height, Int $width, Int $StartY, Int $StartX) {
	my $win = newwin($height, $width, $StartY, $StartX);
	# box($win, 0, 0);
	
	# Using nativecast and encoding to generate the ascii codes on the fly
	# Make sure a Unicode compatible TERM is set (like xterm-16color)
	# my int32 $a = nativecast(int32, '|'.encode("ascii"));
	# my int32 $a = 124;

	# Unicode makes problems
	# For some reason nativecast produces a number of different output integers, non of which correspond to the looked-for value
	# my int32 $a = nativecast(int32, 'आ'.encode("utf8"));
	# my int32 $a = 2309;

	my int32 $a = nativecast(int32, '|'.encode("ascii"));
	my int32 $b = nativecast(int32, '-'.encode("ascii"));
	my int32 $c = nativecast(int32, '+'.encode("ascii"));

	wborder($win, $a, $a, $b, $b, $c, $c, $c, $c);
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

# Wait for a keypress
# getch;

my $row = 0;
loop {
	my $ch = getch;
	mvaddch($row, 0, $ch);
	$row++;
	nc_refresh;

	if $row > 25 {
		delete-window($status-bar);
		last;
	}
};

# Cleanup
LEAVE {
    delwin($win) if $win;
        endwin;
   }

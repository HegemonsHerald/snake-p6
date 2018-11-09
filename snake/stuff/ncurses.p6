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
my $status-bar = create-window(12, 25, $st-y, $st-x);

cbreak;		# disable the line buffer (get raw-ish characters)
noecho;		# don't render input
# keypad;		# read special keys

start_color;

# make the terminal emulator's own colors available
use_default_colors;


# Let's make some custom colors, shall we!

#constant COLOR-BG = -1;
#constant COLOR-BLACK	= 10;
#constant COLOR-RED	= 11;
#constant COLOR-GREEN	= 12;
#constant COLOR-YELLOW	= 13;
#constant COLOR-BLUE	= 14;
#
#init_color( COLOR-BLACK,	0, 	0, 	0 );
#init_color( COLOR-RED,		1000, 	0, 	0 );
#init_color( COLOR-GREEN, 	0, 	1000, 	0 );
#init_color( COLOR-YELLOW, 	1000, 	1000, 	0 );
#init_color( COLOR-BLUE, 	0, 	0, 	1000 );
#
#init_pair( 1, COLOR-BLUE,	COLOR-BG);
#init_pair( 2, COLOR-YELLOW,	COLOR-BLACK);
#init_pair( 3, COLOR-GREEN,	COLOR-BLACK);

sub init_extended_pair (int32, int32, int32) returns int32 is native(&library) {*};
sub init_extended_color (int32, int32, int32, int32) returns int32 is native(&library) {*};

my $i = init_extended_color( COLOR_RED,	0,	0,	1000 );
my $j = init_extended_pair( 1,	COLOR_RED,	-1 );
wcolor_set($status-bar, A_BOLD+|COLOR_RED, 0);
#wattr_set( $status-bar, 0, 1, 0);
#wattr_on( $status-bar, A_BOLD, 0);


# Ok you can have extended colors, but you can't also have bold, because the attr_set functions'
# in this ncurses impl don't support long integers, and extended pairs need long integers!


# I have been doing it right! It just doesn't work under Konsole, which is a shame!
# Direct-Color / Truecolor support works, if the rgb flag is set in termcap, which it is under xterm-256color compliant terminal emulators

# On some terminal emulators under some circumstances this now works!
# xterm-256color and xterm-termite work, but not necessarily with tmux...?

# add the Color Pair to the attributes available in the current window
# To chain Attributes use the bitwise OR operator '+|'
#wattrset($status-bar, COLOR_PAIR_1 +| A_BOLD);
#wattrset($status-bar, COLOR_PAIR_1);
#wattron($status-bar, A_BOLD +| COLOR_PAIR_1);

# set the Color Pair disregarding the attributes
# color_set(2, 0);

my int32 $row = 1;
my $col = 1;


loop {
	unless $row == 11 {
		my $ch = getch;
		mvwprintw($status-bar, $row, $col, "☻ ");
		mvwaddch($status-bar, $row, $col+2, $ch);
		move(0, 0);
		wrefresh($status-bar);
		$row++;
		nc_refresh;
		next;
	}


	$col+=4;
	$row = 1;

#	if $col >= 5 {
#		wattrset($status-bar, A_BLINK +| COLOR_PAIR_2);
#	}
#
#	if $col >= 9 {
#		wattrset($status-bar, A_ITALIC +| COLOR_PAIR_3);
#	}
#
#	if $col >= 13 {
#		wattrset($status-bar, A_REVERSE +| COLOR_PAIR_1);
#	}
#
#	if $col >= 17 {
#		wattrset($status-bar, A_UNDERLINE +| COLOR_PAIR_2);
#	}
#
#	if $col >= 21 {
#		wattrset($status-bar, COLOR_PAIR_3);
#	}
#
	if $col >= 25 {
		delete-window($status-bar);
		sleep 2;
		nc_refresh;
		last;
	}
};

# Cleanup
LEAVE {
    delwin($win) if $win;
        endwin;
}


use v6;
use NCurses;

# Initialize curses window
my $win = initscr() or die "Failed to initialize ncurses\n";

cbreak;		# disable the line buffer (get raw-ish characters)
noecho;		# don't render input
# keypad;		# read special keys

# Refresh (this is needed)
nc_refresh;

# Wait for a keypress
# getch;

my $row = 0;
loop {
	my $ch = getch;
	mvaddch($row, 0, $ch);
	$row++;
	nc_refresh;
};

# Cleanup
LEAVE {
    delwin($win) if $win;
        endwin;
   }

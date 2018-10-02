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

# Set my Color Palette
sub init-colors {
        start_color;
        use_default_colors;
        init_pair( COLOR_PAIR_1, COLOR_BLUE, -1 );
}

class Window {
	has $.width;
	has $.height;
	has $.x;
	has $.y;
	has $.window;

	method new ($height, $width, $y, $x, $window) {
		return self.bless(:$height, :$width, :$y, :$x, :$window)
	}
}

# Create Window
our sub create-window (Int $height, Int $width, Int $pos-y, Int $pos-x) {
        my $win = newwin($height, $width, $pos-y, $pos-x);

        wrefresh($win);
	nc_refresh;

	my $window-container = Window.new($height, $width, $pos-y, $pos-x, $win);
        return $window-container
}

# Delete Window
sub delete-window ($window) {
        delwin($window);
        nc_refresh;
}


# Fill window with spaces to draw the background color!
sub draw-bg ($window) {
	my $win = $window.window;
	for 0..$window.height -> $index {
		mvwhline($win, $index, $window.x, 32, $window.width)
	}
}


# Render Initial Welcome Screen
sub welcome-screen (@windows) is export {
        my $top = @windows[1];
        my $mid = @windows[2];
        my $bot = @windows[3];
	my $tw = $top.window;
	my $mw = $mid.window;
	my $bm = $bot.window;

	# make the windows visible...

	wcolor_set(	$tw, COLOR_PAIR_2, 0);
	wcolor_set(	$mw, COLOR_PAIR_1, 0);
	wcolor_set(	$bm, COLOR_PAIR_2, 0);
	wattron(	$tw, A_REVERSE);
	wattron(	$bm, A_REVERSE);
	draw-bg($top);
	draw-bg($mid);
	draw-bg($bot);
	mvwprintw(	$mw, 5, 5, "wheee ƣ");

	my $top-str = "SNAKE!";
	mvwprintw(	$tw, 0, 0, $top-str);
	mvwprintw(	$bm, 0, 0, "asdfghjkl;asdfghjkl;asdfghjkl;asdfgh");
	wrefresh($mw);
	wrefresh($tw);
	wrefresh($bm);
	move(0,0);
	nc_refresh;

	loop {}
}

# General Render Function
sub render is export {}

# Render Game Over Screen
#sub game-over is export {}

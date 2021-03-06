use v6;
use NCurses;
use NativeCall;

unit module snake-ui;


# Welcome, Pause and Game Over Screen messages

# WELCOME SCREEN
# Small-ish
our $WELCOME-SCREEN-PROMPT_1 = 'Please press';
our $WELCOME-SCREEN-PROMPT_2 = '  Any Key';
our $WELCOME-SCREEN-PROMPT_3 = '  to start';
our $WELCOME-SCREEN-PROMPT_4 = '  the Game!';
our @WELCOME-SCREEN-MESSAGE = ['   SNAKE!   ',
'',
$WELCOME-SCREEN-PROMPT_1,
$WELCOME-SCREEN-PROMPT_2,
$WELCOME-SCREEN-PROMPT_3,
$WELCOME-SCREEN-PROMPT_4,
];

# Not small but not too big
our $WELCOME-SCREEN-PROMPT-L_1 =  '       Please press Any Key';
our $WELCOME-SCREEN-PROMPT-L_2 =  '     to start the game SNAKE!';
our @WELCOME-SCREEN-MESSAGE-L = [ ' ____  _   _    _    _  _______ _ ',
				  '/ ___|| \ | |  / \  | |/ / ____| |',
				  '\___ \|  \| | / _ \ | \' /|  _| | |',
				  ' ___) | |\  |/ ___ \| . \| |___|_|',
				  '|____/|_| \_/_/   \_\_|\_\_____(_)',
				  '',
				  "$WELCOME-SCREEN-PROMPT-L_1",
				  "$WELCOME-SCREEN-PROMPT-L_2", ];

# Friggin humongous
our $WELCOME-SCREEN-PROMPT-XL =    "           Please press Any Key to start the game SNAKE!";
our @WELCOME-SCREEN-MESSAGE-XL = [ ' ╔═════╗   ╔══╗  ╔══╗        ╔══╗        ╔══╗ ╔══╗  ╔════════╗  ╔══╗',
				   '╔╝█████╚╗  ║██╚╗ ║██║       ╔╝██╚╗       ║██║╔╝██║  ║████████║  ║██║',
				   '║██╔═╗██║  ║███╚╗║██║      ╔╝████╚╗      ║██╠╝██╔╝  ║██╔═════╝  ║██║',
				   '║██║ ╚══╝  ║████╚╣██║     ╔╝██╔╗██╚╗     ║██║██╔╝   ║██║        ║██║',
				   '║██╚════╗  ║██║██║██║    ╔╝██═╩╩═██╚╗    ║█████║    ║██╚═════╗  ║██║',
				   '╚╗██████║  ║██╠╗████║   ╔╝██████████╚╗   ║██║██╚╗   ║████████║  ╚══╝',
				   '╔╩════██║  ║██║╚╗███║  ╔╝██╔══════╗██╚╗  ║██╠╗██╚╗  ║██══════╣  ╔══╗',
				   '║██████╔╝  ║██║ ╚╗██║  ║██╔╝      ╚╗██║  ║██║╚╗██║  ║████████║  ║██║',
				   '╚══════╝   ╚══╝  ╚══╝  ╚══╝        ╚══╝  ╚══╝ ╚══╝  ╚════════╝  ╚══╝',
				   '',
				   "$WELCOME-SCREEN-PROMPT-XL" ];

# Collection of possible messages
our @WELCOME-SCREEN-MESSAGE-OPTIONS = [
	@WELCOME-SCREEN-MESSAGE-XL,
	@WELCOME-SCREEN-MESSAGE-L,
	@WELCOME-SCREEN-MESSAGE,
];


# GAME OVER
# Small-ish
our $GAME-OVER-SCREEN-PROMPT_1 = ' Press R';
our $GAME-OVER-SCREEN-PROMPT_2 = 'to restart';
our $GAME-OVER-SCREEN-PROMPT_3 = 'the Game!';
our @GAME-OVER-SCREEN-MESSAGE = ['GAME OVER!',
'',
$GAME-OVER-SCREEN-PROMPT_1,
$GAME-OVER-SCREEN-PROMPT_2,
$GAME-OVER-SCREEN-PROMPT_3,
];

# Not small but not too big
our $GAME-OVER-SCREEN-PROMPT-L_1 =  '                     Please press R',
our $GAME-OVER-SCREEN-PROMPT-L_2 =  '               to restart the game SNAKE!',
our @GAME-OVER-SCREEN-MESSAGE-L = [ '  ____    _    __  __ _____    _____     _______ ____  _ ',
				    ' / ___|  / \  |  \/  | ____|  / _ \ \   / / ____|  _ \| |',
				    '| |  _  / _ \ | |\/| |  _|   | | | \ \ / /|  _| | |_) | |',
				    '| |_| |/ ___ \| |  | | |___  | |_| |\ V / | |___|  _ <|_|',
				    ' \____/_/   \_\_|  |_|_____|  \___/  \_/  |_____|_| \_(_)',
				    '',
				    "$GAME-OVER-SCREEN-PROMPT-L_1",
				    "$GAME-OVER-SCREEN-PROMPT-L_2", ];

# Friggin humongous
our $GAME-OVER-SCREEN-PROMPT-XL =    "           Please press R to restart the game SNAKE!";
our @GAME-OVER-SCREEN-MESSAGE-XL = [ '     ╔═══════╗          ╔══╗        ╔══╗     ╔══╗  ╔════════╗',
				     '    ╔╝███████╚╗        ╔╝██╚╗       ║██╚╗   ╔╝██║  ║████████║',
				     '   ╔╝██╔═══╗██║       ╔╝████╚╗      ║███╚╗ ╔╝███║  ║██╔═════╝',
				     '   ║██╔╝   ╚══╝      ╔╝██╔╗██╚╗     ║████╚╦╝████║  ║██║      ',
				     '   ║██║╔═══════╗    ╔╝██═╩╩═██╚╗    ║██║██║██║██║  ║██╚═════╗',
				     '   ║██╚╣███████║   ╔╝██████████╚╗   ║██╠╗███╔╣██║  ║████████║',
				     '   ╚╗██╚═══╝██╔╝  ╔╝██╔══════╗██╚╗  ║██║╚═══╝║██║  ║██══════╣',
				     '    ╚╗███████╔╝   ║██╔╝      ╚╗██║  ║██║     ║██║  ║████████║',
				     '     ╚═══════╝    ╚══╝        ╚══╝  ╚══╝     ╚══╝  ╚════════╝',
				     '  ╔═══════╗    ╔══╗         ╔══╗  ╔════════╗  ╔════════╗    ╔══╗ ',
				     ' ╔╝███████╚╗   ║██╚╗       ╔╝██║  ║████████║  ║████████╚╗   ║██║ ',
				     '╔╝██╔═══╗██╚╗  ╚╗██╚╗     ╔╝██╔╝  ║██╔═════╝  ║██╔═══╗██║   ║██║ ',
				     '║██╔╝   ╚╗██║   ╚╗██╚╗   ╔╝██╔╝   ║██║        ║██║   ║██║   ║██║ ',
				     '║██║     ║██║    ╚╗██╚╗ ╔╝██╔╝    ║██╚═════╗  ║██╚═══╝██║   ║██║ ',
				     '║██╚╗   ╔╝██║     ╚╗██╚╦╝██╔╝     ║████████║  ║████████═╣   ╚══╝ ',
				     '╚╗██╚═══╝██╔╝      ╚╗██║██╔╝      ║██══════╣  ║██╔═══╗██╚╗  ╔══╗ ',
				     ' ╚╗███████╔╝        ╚╗███╔╝       ║████████║  ║██║   ╚╗██║  ║██║ ',
				     '  ╚═══════╝          ╚═══╝        ╚════════╝  ╚══╝    ╚══╝  ╚══╝ ',
				     '',
				     "$GAME-OVER-SCREEN-PROMPT-XL" ];

# Collection of possible messages
our @GAME-OVER-SCREEN-MESSAGE-OPTIONS = [
	@GAME-OVER-SCREEN-MESSAGE-XL,
	@GAME-OVER-SCREEN-MESSAGE-L,
	@GAME-OVER-SCREEN-MESSAGE,
];


# PAUSE
# Small-ish
our $PAUSE-SCREEN-PROMPT_1 = 'Please press';
our $PAUSE-SCREEN-PROMPT_2 = '  Any Key';
our $PAUSE-SCREEN-PROMPT_3 = ' to resume';
our $PAUSE-SCREEN-PROMPT_4 = '  the Game!';
our @PAUSE-SCREEN-MESSAGE = ['   SNAKE!   ',
'',
$PAUSE-SCREEN-PROMPT_1,
$PAUSE-SCREEN-PROMPT_2,
$PAUSE-SCREEN-PROMPT_3,
];

# Not small but not too big
our $PAUSE-SCREEN-PROMPT-L_1 =  '      Please press Any Key';
our $PAUSE-SCREEN-PROMPT-L_2 =  '   to resume the game SNAKE!';
our @PAUSE-SCREEN-MESSAGE-L = [ ' ____   _   _   _ ____  _____ _ ',
				'|  _ \ / \ | | | / ___|| ____| |',
				'| |_) / _ \| | | \___ \|  _| | |',
				'|  __/ ___ \ |_| |___) | |___|_|',
				'|_| /_/   \_\___/|____/|_____(_)',
				"$PAUSE-SCREEN-PROMPT-L_1",
				"$PAUSE-SCREEN-PROMPT-L_2", ];

# Friggin humongous
our $PAUSE-SCREEN-PROMPT-XL =    '             Please press Any Key to resume the game SNAKE!';
our @PAUSE-SCREEN-MESSAGE-XL = [ '╔════════╗         ╔══╗        ╔══╗     ╔══╗   ╔═════╗   ╔════════╗  ╔══╗',
				 '║████████╚╗       ╔╝██╚╗       ║██║     ║██║  ╔╝█████╚╗  ║████████║  ║██║',
				 '║██╔═══╗██║      ╔╝████╚╗      ║██║     ║██║  ║██╔═╗██║  ║██╔═════╝  ║██║',
				 '║██║   ║██║     ╔╝██╔╗██╚╗     ║██║     ║██║  ║██║ ╚══╝  ║██║        ║██║',
				 '║██╚═══╝██║    ╔╝██═╩╩═██╚╗    ║██║     ║██║  ║██╚════╗  ║██╚═════╗  ║██║',
				 '║████████╔╝   ╔╝██████████╚╗   ║██╚╗   ╔╝██║  ╚╗██████║  ║████████║  ╚══╝',
				 '║██╔═════╝   ╔╝██╔══════╗██╚╗  ╚╗██╚═══╝██╔╝   ╠════██║  ║██══════╣  ╔══╗',
				 '║██║         ║██╔╝      ╚╗██║   ╚╗███████╔╝    ║█████╔╝  ║████████║  ║██║',
				 '╚══╝         ╚══╝        ╚══╝    ╚═══════╝     ╚═════╝   ╚════════╝  ╚══╝',
				 '',
				 "$PAUSE-SCREEN-PROMPT-XL" ];

# Collection of possible messages
our @PAUSE-SCREEN-MESSAGE-OPTIONS = [
	@PAUSE-SCREEN-MESSAGE-XL,
	@PAUSE-SCREEN-MESSAGE-L,
	@PAUSE-SCREEN-MESSAGE,
];



# NativeCall and Subroutine declarations

# setlocale from libc, sets the locale for the native Strings, that are passed to NCurses and makes NCurses use wide/unicode chars
sub setlocale(int32, Str) returns Str is native(Str) {*};

# wprintw isn't a part of the NCurses NativeCall version... for some reason
sub wprintw(WINDOW, Str) returns int32 is native(&library) {*};

# Init Function
sub ui-init is export {

        # set locale to en_US.UTF-8 for Unicode Char support
        setlocale(0, "");

	# init screen
        our $window = initscr() or die "Failed to initialize ncurses\n";

	# get support for special keys (like arrows!)
	keypad($window, TRUE);

	# don't wait for EOLs when getting input
        cbreak;

	# don't print, what's input
        noecho;

	# update to make it all real
        nc_refresh;

        return $window
}

# Run a method on all the windows
sub infix:<all>(@w, $m) {
	for @w[1..^@w.elems] { $_."$m"() }
	# Note: this makes use of the quoted method call syntax, which allows you to substitute the method name from inside a variable!
	# This is friggin' brilliant [perl 5 can do that, too!]
}



# Class definitions

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

	# Method to calculate a message string
	method make-string ($parent-width, $message, $score) {

		# Compute the string for the field
		my $string = $message;

		my $number-of-spaces = $parent-width - self.x-anchor - $message.chars - $score.base(10).chars;

		for 1..$number-of-spaces { $string = $string ~ " " }

		$string = $string ~ $score.base(10);

		return $string
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

	# Fill the window with spaces to set the background color (to whatever has been set before)!
	multi method bkgd {
		for 0..$.height -> $index {
			mvwhline($.window, $index, $.x, 32, $.width)
		}
	}

	method delwin {
		delwin($.window);
		nc_refresh;
	}

	method wprintw ($str) {
		wprintw($.window, $str);
	}

	method mvprintw ($y, $x, $str) {
		wmove($.window, $y, $x);
		self.wprintw($str);
	}

	method color ($color-pair) {
		wcolor_set($.window, $color-pair, 0);
	}

	method attron ($attr) {
		wattron($.window, $attr)
	}

	method attroff ($attr) {
		wattroff($.window, $attr)
	}

	method refresh {
		wrefresh($.window)
	}

	method move ($y, $x) {
		wmove($.window, $y, $x)
	}

	method clear {
		wclear($.window);
		self.refresh;
	}
}

# Top Window
class Top is Window is export {
	has Field $.snake-field;
	has $.snake-message;
	has Field $.high-score-field;
	has $.message;

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
		my $high-score-field = Score-Field.new(0, $width, $max-score, $message.chars);

		# Maaaake Snaaaake Tooooop Windoooooooow
		return self.bless(:$height, :$width, :$y, :$x, :$window, :$snake-message, :$snake-field, :$high-score-field, :$message)
	}

	# Print the Message on the Left Side of the Top Window
	method print-snake-field {

		# Print the field
		self.move($.snake-field.y-anchor, $.snake-field.x-anchor);
		self.wprintw(self.snake-message);

		# Refresh
		self.refresh;
	}

	# Print the Message on the Right Side of the Top Window... that's the High Score
	method print-high-score-field ($high-score) {

		# Make the Field's contents
		my $string = self.high-score-field.make-string(self.width, $.message, $high-score);

		# Print the field
		self.move($.high-score-field.y-anchor, $.high-score-field.x-anchor);
		self.wprintw($string);

		# Refresh
		self.refresh;
	}
}

# Middle Window
class Middle is Window is export {

	# Method, that prints the largest fitting message from the @options
	# Take a look at the hard-coded messages at the beginning of this file, for an example...
	method !print-message(@options) {
		my @message;

		# Choose the right size message from the options
		for @options -> @m {
			unless @m[0].chars >= $.width || @m.elems >= $.height {
				@message = @m;
				last;
			}

			# If none of the message options works, use empty
			@message = [ "" ]
		}

		# Find the starting position for drawing the message's parts
		my $message-start-y = $.height div 2 - @message.elems div 2;
		my $message-start-x = $.width div 2 - @message[0].chars div 2;

		# Print the message
		for @message.kv -> $ind, $line {
			self.mvprintw($message-start-y + $ind, $message-start-x, $line);
		}

		# Refresh
		self.refresh;
	}

	method print-welcome-message {
		self!print-message: @WELCOME-SCREEN-MESSAGE-OPTIONS
	}

	method print-game-over-message {
		self!print-message: @GAME-OVER-SCREEN-MESSAGE-OPTIONS
	}

	method print-pause-screen-message {
		self!print-message: @PAUSE-SCREEN-MESSAGE-OPTIONS
	}
}


# Bottom Window
class Bottom is Window is export {
	has Score-Field $.score-field;
	has $.message;

	method new ($height, $width, $y, $x, $max-score) {

		# Create the window
		my $window = self.create-window($height, $width, $y, $x);

		# Player's wanna know, how their game does go!
		my $message = "Score:";
		my $score-field = Score-Field.new(0, $width, $max-score, $message.chars);

		# Maaaake Snaaaake Bottooooom Windoooooooow
		return self.bless(:$height, :$width, :$y, :$x, :$window, :$score-field, :$message)
	}

	method print-score-field ($score) {

		# Make the Field's contents
		my $string = self.score-field.make-string(self.width, $.message, $score);

		# Print the field
		self.move($.score-field.y-anchor, $.score-field.x-anchor);
		self.wprintw($string);

		# Refresh
		self.refresh;
	}
}



# State Overlays

# Render Initial Welcome Screen
sub welcome-screen (@windows, $high-score) is export {

	# Shortcuts
	my ($top, $mid, $bot) = @windows[1..3];
	

	# GENERAL SETUP

	# Set the color palette...
	$top.color(COLOR_PAIR_1);
	$mid.color(COLOR_PAIR_2);
	$bot.color(COLOR_PAIR_1);

	# ... and styles
	$top.attron(A_BOLD);
	$bot.attron(A_BOLD);

	# Make the windows visible
	@windows all "bkgd";


	# RENDER WELCOME SCREEN

	# Print the Top Bar
	$top.print-snake-field;
	$top.print-high-score-field($high-score);

	# Print the Startup Screen aka Welcome Message
	$mid.print-welcome-message;

	# Nothing to do for the Bottom Bar
	# ...

	# Refresh
	@windows all "refresh";
	nc_refresh;

	move(0,0);

	# Wait for Input
	noecho();
	getch();

}

# General Render Function
our sub render-game (@windows, @players, @foods) {

	my $mid = @windows[2];
	my $bot = @windows[3];

	# Clear the game window
	$mid.clear;
	$mid.move(0,0);

	# Render Foods
	for @foods -> $food {
		$mid.mvprintw($food.position.y, $food.position.x * 2, " ●");
		$mid.move(0,0);
	}

	# Render Snake
	for @players -> $player {
		for $player.segments.kv -> $ind, $segment {

			# If you are rendering the head of the Snake...
			if $ind == 0 {
				# Alright, bit of a hack cause I can't import the Direction enum due to circular dependancy (I really can't be bothered to refactor the class code into separate files...)
				given $player.direction.perl {
					when "Direction::Left"  { $mid.mvprintw($segment.y, $segment.x * 2, " ◀") }
					when "Direction::Right" { $mid.mvprintw($segment.y, $segment.x * 2, " ▶") }
					when "Direction::Up"    { $mid.mvprintw($segment.y, $segment.x * 2, " ▲") }
					when "Direction::Down"  { $mid.mvprintw($segment.y, $segment.x * 2, " ▼") }
				}

				next;
			}

			# Render all the other segments
			$mid.mvprintw($segment.y, $segment.x * 2, " ○");
			$mid.move(0,0);
		}
	}

	# ... I said render before, I lied.
	$mid.refresh;

	# Render Score Board (bottom bar)
	$bot.print-score-field(@players[0].score);
	# NOTE: this would have to be done differently for a multiplayer
	# Maybe have a score-fields Array in the bottom bar, where each field has a reference to its player...?
	# Then you could also sort however you please!

	nc_refresh;
}

# Render Pause Screen
sub pause-screen(@windows) is export {

	# Shortcuts
	my $mid = @windows[2];
	
	# RENDER PAUSE SCREEN

	# Print the Pause Screen Message
	$mid.print-pause-screen-message;

	nc_refresh;

}

# Render Game Over Screen
sub game-over-screen (@windows, $high-score) is export {

	# Shortcuts
	my ($top, $mid, $bot) = @windows[1..3];

	# RENDER GAME OVER SCREEN

	# Update the Top Bar
	$top.print-high-score-field($high-score);

	# Print the Game Over Message
	$mid.print-game-over-message;

	# Refresh
	@windows all "refresh";
	nc_refresh;

	move(0,0);
}

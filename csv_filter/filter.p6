use v6;

our $SECTION-FILE;
our $DATA-FILE;

# Get Input Arguments
sub MAIN($sections, $data-file) {
	$SECTION-FILE = $sections;
	$DATA-FILE = $data-file;

	run;
}

sub run {

	# Get Sections Data
	my @sections = "$SECTION-FILE".IO.lines;

	# Get rid of empty lines
	@sections.=grep(none /^\s*$/);

	# Get Input Data
	my @data = "$DATA-FILE".IO.lines;

	# Init Data Structures

	# Each Sort Target is a Section Header in the INI file, with its corresponding patterns
	# This array contains lists, each of which has the Header in its 0th position and the Header's patterns in the following positions
	my @sort-targets = ();


	# Get Section-Headers and their corresponding patterns

	# Get the section-header's indices in @sections
	my @section-header-positions = @sections.grep({/\[.*\]/}, :k);

	# For each section-header found, add the header and its patterns to @sort-targets
	for @section-header-positions.kv -> $header-index, $header-position {

		my @section-and-patterns = ();
		my $next-header-index = $header-index + 1;
		my $end = @section-header-positions.elems - 1;
		

		# If the for-loop hasn't reached the end of the header positions array
		unless $next-header-index > $end {

			# Get the slice from the current header up until, but excluding the next header from the sections array
			@section-and-patterns = @sections[$header-position..@section-header-positions[$next-header-index]-1];
		}

		# If the for-loop has reached the end
		if $next-header-index > $end {

			# Get the slice from the current header to the end of the sections array
			@section-and-patterns = @sections[$header-position..@sections.elems-1];
		}

		@sort-targets.push: @section-and-patterns;
	}

	say @sort-targets;

	# Get Sections and Patterns

	# Sort with Grammars!
}

# I mean, just saying:
# There's definitely a better way to do this, even the linearly looping method
# we used in perl 5 is more sensible than this absolute mess, but this is fun...
# So I'm fine with it!

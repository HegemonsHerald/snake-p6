use v6;

say "Hello World, Baby!";

print "And what's the difference between say and print?\n";
say "Well, it seems in print you have to add the \\n explicitely…";

my $this-is-a-valid-variable-name = "wut?";

say "This var is in kebab-case: $this-is-a-valid-variable-name";

my %hash-a-di-doodle = (
	'0 key'		=> 'value',
	'1 knee'	=> 'all goo',
	'2 gee'		=> 'ooOOooh'
);

for %hash-a-di-doodle.keys -> $key {
	say "Here come's Hash-a-di-Doodle: $key	%hash-a-di-doodle{$key}"
}

say %hash-a-di-doodle;

say "Now the only question is: what's with all the fancy :=s and {}s and all that?";

# Oh my there is some real syntax learning to do here...
# And apparently the syntax is a bit more strict here...
# I can't just leave my semicolons out? What? Wut? mmmh.

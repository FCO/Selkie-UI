unit class Selkie::UI::ReactiveArray does Positional does Iterable;

has $.store is required;
has Str $.name is required;
has Str $.event is required;

method !get {
	.push: ($!name,) with @*UI-PATHS;
	self!get-only
}

method !get-only { $!store.get-in($!name).list }

method list { self!get }

method List              { $.list }
method Array(-->Array()) { $.list }

method STORE(Array() $value) {
	$!store.dispatch: $!event, :$value;
	$value[]
}

method AT-POS(UInt $pos) {
	self!get.AT-POS: $pos
}

method ASSIGN-POS(UInt $pos, $value) {
	my @current    = self!get-only;
	@current[$pos] = $value;
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
	$value
}

method EXISTS-POS(Int $pos) {
	self!get.EXISTS-POS($pos)
}

method DELETE-POS(Int $pos) {
	my @current = self!get-only;
	my $val = @current.DELETE-POS: $pos;
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
	$val
}

method elems   { self!get.elems }
method Numeric { $.elems }
method Rat     { $.Numeric.Rat }
method Real    { $.Numeric.Real }
method Int     { $.Numeric.Int }
method Bool    { $.elems != 0 }

method push(\values) {
	my @current = self!get-only;
	@current.push: values;
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
	@current
}

method pop {
	my @current = self!get-only;
	my $v = @current.pop;
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
	$v
}

method shift {
	my @current = self!get-only;
	my $v = @current.shift;
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
	$v
}

method unshift(*@values) {
	my @current = self!get-only;
	@current.unshift: |@values;
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
	@current
}

method splice(|c) {
	my @current = self!get-only;
	my @r = @current.splice: |c;
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
	@r
}

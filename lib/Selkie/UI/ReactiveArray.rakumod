unit class Selkie::UI::ReactiveArray does Positional does Iterable;

has $.store is required;
has Str $.name is required;
has Str $.event is required;

method AT-POS(Int $pos) {
	.{$!name} = True with %*UI-PATHS;
	my @current = $!store.get-in: $!name;
	@current[$pos]
}

method ASSIGN-POS(Int $pos, $value) {
	my @current = $!store.get-in: $!name;
	@current[$pos] = $value;
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
	$value
}

method EXISTS-POS(Int $pos) {
	my @current = $!store.get-in: $!name;
	@current.EXISTS-POS($pos)
}

method DELETE-POS(Int $pos) {
	my @current := $!store.get-in: $!name;
	@current.DELETE-POS($pos);
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
}

method elems {
	.{$!name} = True with %*UI-PATHS;
	my @current = $!store.get-in: $!name;
	@current.elems
}

method push(|values) {
	my @current = $!store.get-in: $!name;
	@current.push: |values;
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
}

method pop {
	my @current = $!store.get-in: $!name;
	my $v = @current.pop;
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
	$v
}

method shift {
	my @current = $!store.get-in: $!name;
	my $v = @current.shift;
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
	$v
}

method unshift(|values) {
	my @current = $!store.get-in: $!name;
	@current.unshift(|values);
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
}

method splice(|c) {
	my @current = $!store.get-in: $!name;
	my @r = @current.splice(|c);
	$!store.dispatch: $!event, value => @current;
	$!store.tick;
	@r
}

method list {
	.{$!name} = True with %*UI-PATHS;
	my @current = $!store.get-in: $!name;
	@current.list
}

method set(@values) {
	$!store.dispatch: $!event, value => @values;
	self
}

method STORE($values) {
	my @next = $values ~~ Positional ?? $values.list !! ($values.defined ?? [$values] !! []);
	$!store.dispatch: $!event, value => @next;
	@next
}

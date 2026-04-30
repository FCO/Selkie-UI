unit class Selkie::UI::ReactiveHash does Associative does Iterable;

has $.store is required;
has Str $.name is required;
has Str $.event is required;

method AT-KEY($key) {
	.{$!name} = True with %*UI-PATHS;
	my %current = $!store.get-in: $!name;
	%current{$key}
}

method ASSIGN-KEY($key, $value) {
	my %current = $!store.get-in: $!name;
	%current{$key} = $value;
	$!store.dispatch: $!event, value => %current;
	$value
}

method EXISTS-KEY($key) {
	my %current = $!store.get-in: $!name;
	%current.EXISTS-KEY($key)
}

method DELETE-KEY($key) {
	my %current = $!store.get-in: $!name;
	%current.DELETE-KEY($key);
	$!store.dispatch: $!event, value => %current
}

method keys {
	.{$!name} = True with %*UI-PATHS;
	my %current = $!store.get-in: $!name;
	%current.keys
}

method values {
	.{$!name} = True with %*UI-PATHS;
	my %current = $!store.get-in: $!name;
	%current.values
}

method kv {
	.{$!name} = True with %*UI-PATHS;
	my %current = $!store.get-in: $!name;
	%current.kv
}

method pairs {
	.{$!name} = True with %*UI-PATHS;
	my %current = $!store.get-in: $!name;
	%current.pairs
}

method list {
	.{$!name} = True with %*UI-PATHS;
	my %current = $!store.get-in: $!name;
	%current.list
}

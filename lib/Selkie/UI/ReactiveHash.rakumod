unit class Selkie::UI::ReactiveHash does Associative does Iterable;

has $.store is required;
has Str $.name is required;

method sink { .push: ($!name,) with @*UI-PATHS }

method !get-val               {
	$.sink;
	self!get-val-only;
}

method !get-val-only          {
	$!store.get-in: $!name;
}

method !set-val($key, $value) {
	$!store.assoc-in: $!name, $key, :$value;
	$!store.tick;
	self
}

method keys   { self!get-val.keys   }
method values { self!get-val.values }
method kv     { self!get-val.kv     }
method pairs  { self!get-val.pairs  }

multi method AT-KEY($key) is rw {
	# $.sink;
	Proxy.new(
		FETCH => -> $ {
			.push: ($!name, $key) with @*UI-PATHS;
			my $resp-AT-KEY = $!store.get-in: $!name, $key;
			$resp-AT-KEY
		},
		STORE => -> $, $value {
			self.ASSIGN-KEY: $key, $value
		}
	)
}

multi method AT-KEY(@keys --> List()) is rw {
	# $.sink;
	@keys.map: -> $key {
		.push: ($!name, $key) with @*UI-PATHS;
		$!store.get-in: $!name, $key
	}
}

method EXISTS-KEY($key) { self!get-val.EXISTS-KEY: $key }

method STORE(Hash() $values) {
	$!store.assoc-in: $!name, value => $values;
	$!store.tick;
	self
}

method ASSIGN-KEY($key, $value) { self!set-val: $key, $value }

method DELETE-KEY($key) {
	my %hash = self!get-val-only;
	my $v = %hash{$key}:delete // return Nil;
	$!store.assoc-in: $!name, value => %hash;
	$!store.tick;
	$v
}

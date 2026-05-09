use Selkie::UI::Base;
use Selkie::Widget::ListView;
use Selkie::UI::Helpers;

unit class Selkie::UI::ListViewBuilder is Selkie::UI::Base;

has &.block;
has @.items;
has $.select-first;
has $.select-last;
has Selkie::Widget::ListView $.obj .= new;

submethod TWEAK(:&block, :@items, :$select-first, :$select-last, |) {
	self.set-items:    $_ with @items;
	self.set-items:    $_ with &block;
	self.select-first: $_ with $select-first;
	self.select-last:  $_ with $select-last;
}

multi method set-items(@items) {
	$!obj.set-items: @items;
	self
}

multi method set-items(&block) {
	$.auto-subscribe: "set-items", with-ui-context {
		self.set-items: block self
	}
}

multi method on-select(&block) is idempotent {
	$!obj.on-select.tap: with-ui-context -> $idx {
		block self, $idx
	}
	self
}

multi method on-activate(&block) is idempotent {
	$!obj.on-activate.tap: with-ui-context -> $idx {
		block self, $idx
	}
	self
}

multi method select-first(Bool() $select = True) {
	$!obj.select-index: 0 if $select;
	self
}

multi method select-first(&block) {
	$.auto-subscribe: "select-first", with-ui-context { $.select-first: block self }
}

multi method select-last(Bool() $select = True) {
	$!obj.select-last: $!obj.items.end if $select;
	self
}

multi method select-last(&block) {
	$.auto-subscribe: "select-last", with-ui-context { $.select-last: block self }
}

method cursor {
	$!obj.cursor
}

method on-key(Str $key, &block) is idempotent {
	return self unless $.should-add: "on-key-$key";
	$!obj.on-key: $key, with-ui-context { block self, $ }
	self
}

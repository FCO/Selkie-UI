use Selkie::UI::Base;
use Selkie::Widget::ListView;
use Selkie::UI::Helpers;

unit class Selkie::UI::ListViewBuilder is Selkie::UI::Base;

has &.block;
has Selkie::Widget::ListView $.obj .= new;

submethod TWEAK(:&block, |) {
	self.set-items: $_ with &block
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

method select-last {
	$!obj.select-last;
	self
}

method cursor {
	$!obj.cursor
}

method on-key(Str $key, &block) is idempotent {
	return self unless $.should-add: "on-key-$key";
	$!obj.on-key: $key, with-ui-context { block self, $ }
	self
}

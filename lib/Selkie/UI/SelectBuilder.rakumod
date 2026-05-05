use Selkie::UI::Base;
use Selkie::Widget::Select;
use Selkie::UI::Helpers;

unit class Selkie::UI::SelectBuilder is Selkie::UI::Base;

has Selkie::Widget::Select $.obj .= new;

multi method set-items(@items) {
	$!obj.set-items(@items);
	self
}

multi method set-items(&block) {
	$.auto-subscribe: "set-items", with-ui-context { self.set-items(block self) }
}

method placeholder(Str $placeholder) {
	$!obj.placeholder = $placeholder;
	self
}

multi method select-index(UInt $idx) {
	$!obj.select-index: $_ with $idx;
	self
}

multi method select-index(&block) {
	$.auto-subscribe: "select-index", with-ui-context { self.select-index: block self }
}

multi method on-change(&block) is idempotent {
	$!obj.on-change.tap: with-ui-context -> $idx { block self, $idx }
	self
}

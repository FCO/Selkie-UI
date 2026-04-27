use Selkie::UI::Base;
use Selkie::Widget::Select;

unit class Selkie::UI::SelectBuilder is Selkie::UI::Base;

has Selkie::Widget::Select $.obj .= new;

multi method set-items(@items) {
	$!obj.set-items(@items);
	self
}

multi method set-items(&block) {
	my %*UI-PATHS := SetHash.new;
	self.set-items(block self);
	$.auto-subscribe: "set-items", { self.set-items(block self) }
	self
}

method placeholder(Str $placeholder) {
	$!obj.placeholder = $placeholder;
	self
}

multi method on-change(&block) {
	$!obj.on-change.tap: -> $idx { block self, $idx };
	self
}

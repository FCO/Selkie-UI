use Selkie::UI::Base;
use Selkie::Widget::ListView;

unit class Selkie::UI::ListViewBuilder is Selkie::UI::Base;

has Selkie::Widget::ListView $.obj .= new;


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

multi method on-select(&block) {
	$!obj.on-select.tap: -> $idx { block self, $idx };
	self
}

multi method on-activate(&block) {
	$!obj.on-activate.tap: -> $idx { block self, $idx };
	self
}

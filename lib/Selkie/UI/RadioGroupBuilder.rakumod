use Selkie::UI::Base;
use Selkie::Widget::RadioGroup;
use Selkie::UI::Helpers;

unit class Selkie::UI::RadioGroupBuilder is Selkie::UI::Base;

has Selkie::Widget::RadioGroup $.obj .= new;

multi method set-items(@items) {
	$!obj.set-items(@items);
	self
}

multi method set-items(&block) {
	$.auto-subscribe: "set-items", with-ui-context $*UI-APP, $*UI-PARENT, { self.set-items: block self }
}

multi method select(UInt $idx) {
	$!obj.select-index: $_ with $idx;
	self
}

multi method select(&block) {
	$.auto-subscribe: "select", with-ui-context $*UI-APP, $*UI-PARENT, { self.select: block self }
}

multi method on-change(&block) {
	$!obj.on-change.tap: with-ui-context $*UI-APP, $*UI-PARENT, -> $idx { block self, $idx };
	self
}

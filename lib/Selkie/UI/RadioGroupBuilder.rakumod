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
	my %*UI-PATHS := SetHash.new;
	self.set-items(block self);
	$.auto-subscribe: "set-items", { self.set-items(block self) }
	self
}

multi method selected(UInt $idx) {
	$!obj.set-selected($idx);
	self
}

multi method selected(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "selected", { self.selected: block self }
	self
}

multi method on-change(&block) {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-change.tap: -> $idx { with-ui-context($app, $parent, &block)(self, $idx) };
	self
}

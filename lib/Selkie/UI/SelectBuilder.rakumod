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
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-change.tap: -> $idx { with-ui-context($app, $parent, &block)(self, $idx) };
	self
}

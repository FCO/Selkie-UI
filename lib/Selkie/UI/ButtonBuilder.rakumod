use Selkie::UI::Base;
use Selkie::Widget::Button;

unit class Selkie::UI::ButtonBuilder is Selkie::UI::Base;

has Str                    $.label = "";
has Selkie::Widget::Button $.obj  .= new: :$!label;

multi method label(Str $label) {
	$!obj.set-label: $label;
	self
}

multi method label(&label) {
	my %*UI-PATHS := SetHash.new;
	$ = label self;
	$.auto-subscribe: "label", { self.label: label self }
	self
}

method on-press(&block) {
	$!obj.on-press.tap: { block self }
	self
}

use Selkie::UI::Base;
use Selkie::Widget::Button;
use Selkie::UI::Helpers;

unit class Selkie::UI::ButtonBuilder is Selkie::UI::Base;

has Str                    $.label = "";
has Selkie::Widget::Button $.obj  .= new: :$!label;
has                        $.on-press;

submethod TWEAK(:$on-press, |) {
	self.on-press: $_ with $on-press
}

multi method label(Str $label) {
	$!obj.set-label: $label;
	self
}

multi method label(&label) {
	$.auto-subscribe: "label", with-ui-context { self.label: label self }
}

method on-press(&block) is idempotent {
	$!obj.on-press.tap: with-ui-context { block self }
	self
}

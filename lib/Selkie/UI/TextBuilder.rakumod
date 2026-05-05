use Selkie::UI::Base;
use Selkie::Widget::Text;
use Selkie::UI::Helpers;

unit class Selkie::UI::TextBuilder is Selkie::UI::Base;

has Str $.text = "";
has Selkie::Widget::Text $.obj .= new: |(:$!text with $!text);
has &!block;

method TWEAK(:&block) {
	self.text: $_ with &block
}

multi method text(Empty) {
	$.text: "";
	self
}

multi method text(Str $text) {
	$!obj.set-text: $text;
	self
}

multi method text(&block) {
	$.auto-subscribe: "text", with-ui-context { self.text: block self }
}

multi method text-silent(Str $text) {
	$!obj.set-text-silent: $text;
	self
}

multi method text-silent(&block) {
	$.auto-subscribe: "text-silent", with-ui-context { self.text-silent: block self }
}

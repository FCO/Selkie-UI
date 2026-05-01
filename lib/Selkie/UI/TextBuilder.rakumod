use Selkie::UI::Base;
use Selkie::Widget::Text;

unit class Selkie::UI::TextBuilder is Selkie::UI::Base;

has Str $.text = "";
has Selkie::Widget::Text $.obj .= new: |(:$!text with $!text);
has &!block;

method TWEAK(:&block) {
	self.text: $_ with &block
}

multi method text(Str $text) {
	$!obj.set-text: $text;
	self
}

multi method text(&block) {
	my %*UI-PATHS := SetHash.new;
	$!obj.set-text: block self;
	$.auto-subscribe: "text", { self.text: block self }
	self
}

method text-silent(Str $text) {
	$!obj.set-text-silent($text);
	self
}

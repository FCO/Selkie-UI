use Selkie::UI::Base;
use Selkie::Widget::Text;

unit class Selkie::UI::TextBuilder is Selkie::UI::Base;

has Str $.text = "";
has Selkie::Widget::Text $.obj .= new: :$!text;

multi method text(Str $text) {
	$!obj.set-text: $text;
	self
}

multi method text(&text-block) {
	my %*UI-PATHS := SetHash.new;
	$ = text-block self;
	$.auto-subscribe: "text", { self.text: text-block self }
	self
}
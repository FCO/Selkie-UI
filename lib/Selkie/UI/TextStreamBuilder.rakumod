use Selkie::UI::Base;
use Selkie::Widget::TextStream;

unit class Selkie::UI::TextStreamBuilder is Selkie::UI::Base;

has Selkie::Widget::TextStream $.obj .= new;

multi method append(&text) {
	my %*UI-PATHS := SetHash.new;
	$ = text self;
	$.auto-subscribe: "append", { self.append: text self }
	self
}

multi method append(Str() $text) {
	$!obj.append: $text with $text;
	self
}

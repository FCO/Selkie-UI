use Selkie::UI::Base;
use Selkie::Widget::MultiLineInput;

unit class Selkie::UI::MultiLineInputBuilder is Selkie::UI::Base;

has Str  $.placeholder;
has UInt $.max-lines;
has Selkie::Widget::MultiLineInput $.obj .= new:
	|(:$!placeholder with $!placeholder),
	|(:$!max-lines with $!max-lines);

multi method text(Str $text) {
	$!obj.set-text($text);
	self
}

multi method text(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "text", { self.text: block self }
	self
}

method text-silent(Str $text) {
	$!obj.set-text-silent($text);
	self
}

multi method placeholder(Str $placeholder) {
	$!obj.placeholder = $placeholder;
	self
}

multi method placeholder(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "placeholder", { self.placeholder: block self }
	self
}

method clear { $!obj.clear }

method on-submit(&block) {
	$!obj.on-submit.tap: -> $text { block self, $text };
	self
}

method on-change(&block) {
	$!obj.on-change.tap: -> $text { block self, $text };
	self
}

use Selkie::UI::Base;
use Selkie::Widget::MultiLineInput;
use Selkie::UI::Helpers;

unit class Selkie::UI::MultiLineInputBuilder is Selkie::UI::Base;

has Str  $.placeholder;
has UInt $.max-lines;
has Selkie::Widget::MultiLineInput $.obj .= new:
	|(:$!placeholder with $!placeholder),
	|(:$!max-lines with $!max-lines);

method cursor(UInt :$row, UInt :$col) {
	my $attr-row = $!obj.^attributes.first: *.name eq '$!cursor-row';
	my $attr-col = $!obj.^attributes.first: *.name eq '$!cursor-col';

	$attr-row.set_value: $!obj, $($_) with $row;
	$attr-col.set_value: $!obj, $($_) with $col;
	self
}

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
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-submit.tap: -> $text { with-ui-context($app, $parent, &block)(self, $text) };
	self
}

method on-change(&block) {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-change.tap: -> $text { with-ui-context($app, $parent, &block)(self, $text) };
	self
}

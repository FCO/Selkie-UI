use Selkie::UI::Base;
use Selkie::Widget::MultiLineInput;
use Selkie::UI::Helpers;

unit class Selkie::UI::MultiLineInputBuilder is Selkie::UI::Base;

has Str  $.placeholder;
has UInt $.max-lines;
has Selkie::Widget::MultiLineInput $.obj .= new: |(:$!placeholder with $!placeholder), |(:$!max-lines with $!max-lines);

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
	$.auto-subscribe: "text", with-ui-context $*UI-APP, $*UI-PARENT, { self.text: block self }
}

multi method text-silent(Any:U) {}

multi method text-silent(Str $text) {
	$!obj.set-text-silent($text);
	self
}

multi method text-silent(&block) {
	$.auto-subscribe: "text-silent", with-ui-context $*UI-APP, $*UI-PARENT, { self.text-silent: block self }
}

multi method placeholder(Any:U) {}

multi method placeholder(Str $placeholder) {
	$!obj.placeholder = $placeholder;
	self
}

multi method placeholder(&block) {
	$.auto-subscribe: "placeholder", with-ui-context $*UI-APP, $*UI-PARENT, { self.placeholder: block self }
}

multi method clear(Bool() $clear = True) { $!obj.clear if $clear }

multi method clear(&block) {
	$.auto-subscribe: "clear", with-ui-context $*UI-APP, $*UI-PARENT, { self.text-silent: "" if block self }
}

method on-submit(&block) {
	$!obj.on-submit.tap: with-ui-context $*UI-APP, $*UI-PARENT, -> $text { block self, $text };
	self
}

method on-change(&block) {
	$!obj.on-change.tap: with-ui-context $*UI-APP, $*UI-PARENT, -> $text {
		block self, $text
	}
	self
}

use Selkie::UI::Base;
use Selkie::Widget::TextStream;
use Selkie::UI::Helpers;

unit class Selkie::UI::TextStreamBuilder is Selkie::UI::Base;

has Selkie::Widget::TextStream $.obj .= new;

method max-lines(UInt $lines) {
	$!obj.^attributes.first(*.name eq '$!max-lines').set_value: $!obj, $lines;
	self
}

multi method append(&text) {
	$.auto-subscribe: "append", with-ui-context $*UI-APP, $*UI-PARENT, { self.append: text self }
}

multi method append(Str() $text) {
	$!obj.append: $text with $text;
	self
}

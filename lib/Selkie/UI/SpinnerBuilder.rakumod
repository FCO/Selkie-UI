use Selkie::UI::Base;
use Selkie::Widget::Spinner;
use Selkie::Style;

unit class Selkie::UI::SpinnerBuilder is Selkie::UI::Base;

has                         @.frames;
has Real                    $.interval;
has Selkie::Style           $.style;
has Selkie::Widget::Spinner $.obj .= new: |(:@!frames if @!frames), |(:$!interval with $!interval), |(:$!style with $!style);

method tick {
	$!obj.tick;
	self
}

method reset {
	$!obj.reset;
	self
}

method interval($interval) {
	$!obj.^attributes.first(*.name eq '$!interval').set_value: $!obj, $interval;
	self
}

method frames(@frames) {
	$!obj.^attributes.first(*.name eq '@!frames').set_value: $!obj, @frames;
	self
}

method braille {
	$.frames: Selkie::Widget::Spinner::BRAILLE;
}

method dots {
	$.frames: Selkie::Widget::Spinner::DOTS;
}

method line {
	$.frames: Selkie::Widget::Spinner::LINE;
}

method circle {
	$.frames: Selkie::Widget::Spinner::CIRCLE;
}

method arrow {
	$.frames: Selkie::Widget::Spinner::ARROW;
}

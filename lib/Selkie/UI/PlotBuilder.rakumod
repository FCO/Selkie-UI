use Selkie::UI::Base;
use Selkie::Widget::Plot;

unit class Selkie::UI::PlotBuilder is Selkie::UI::Base;

has Str  $.type;
has Real $.min-y;
has Real $.max-y;
has Str  $.title;
has Int  $.gridtype;
has UInt $.rangex;
has Str @.store-path;
has Str $.empty-message;
has Selkie::Widget::Plot $.obj .= new:
	|(:$!type with $!type),
	|(:$!min-y with $!min-y),
	|(:$!max-y with $!max-y),
	|(:$!title with $!title),
	|(:$!gridtype with $!gridtype),
	|(:$!rangex with $!rangex),
	|(:@!store-path with @!store-path),
	|(:$!empty-message with $!empty-message);

method push-sample(Int $x, Real $y) {
	$!obj.push-sample($x, $y);
	self
}

method set-sample(Int $x, Real $y) {
	$!obj.set-sample($x, $y);
	self
}

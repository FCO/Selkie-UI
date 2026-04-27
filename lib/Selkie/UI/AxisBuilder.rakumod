use Selkie::UI::Base;
use Selkie::Widget::Axis;

unit class Selkie::UI::AxisBuilder is Selkie::UI::Base;

has Real $.min is required;
has Real $.max is required;
has Str  $.edge;
has UInt $.tick-count;
has Bool $.show-line;
has Selkie::Widget::Axis $.obj;

submethod TWEAK() {
	$!obj = Selkie::Widget::Axis.new(
		:$!min,
		:$!max,
		|(:$!edge with $!edge),
		|(:$!tick-count with $!tick-count),
		|(:$!show-line with $!show-line),
	);
	self
}

method reserved-rows(--> UInt) { $!obj.reserved-rows }

method reserved-cols(--> UInt) { $!obj.reserved-cols }

use Selkie::UI::Base;
use Selkie::Widget::BarChart;
use Selkie::UI::Helpers;

unit class Selkie::UI::BarChartBuilder is Selkie::UI::Base;

has @.data;
has Str @.store-path;
has Str $.orientation;
has Str $.palette;
has Bool $.show-axis;
has Bool $.show-labels;
has Real $.min;
has Real $.max;
has UInt $.tick-count;
has Str $.empty-message;
has Selkie::Widget::BarChart $.obj .= new:
	|(:@!data with @!data),
	|(:@!store-path with @!store-path),
	|(:$!orientation with $!orientation),
	|(:$!palette with $!palette),
	|(:$!show-axis with $!show-axis),
	|(:$!show-labels with $!show-labels),
	|(:$!min with $!min),
	|(:$!max with $!max),
	|(:$!tick-count with $!tick-count),
	|(:$!empty-message with $!empty-message);

multi method data(@data) {
	$!obj.set-data(@data);
	self
}

multi method data(&block) {
	$.auto-subscribe: "data", with-ui-context $*UI-APP, $*UI-PARENT, { self.data: block self }
}

use Selkie::UI::Base;
use Selkie::Widget::LineChart;

unit class Selkie::UI::LineChartBuilder is Selkie::UI::Base;

has @.series;
has &.store-path-fn;
has Str $.palette;
has Bool $.show-axis;
has Bool $.show-legend;
has Bool $.fill-below;
has Str $.overlap;
has Real $.y-min;
has Real $.y-max;
has UInt $.tick-count;
has Str $.empty-message;
has Selkie::Widget::LineChart $.obj .= new:
	|(:@!series with @!series),
	|(:&!store-path-fn with &!store-path-fn),
	|(:$!palette with $!palette),
	|(:$!show-axis with $!show-axis),
	|(:$!show-legend with $!show-legend),
	|(:$!fill-below with $!fill-below),
	|(:$!overlap with $!overlap),
	|(:$!y-min with $!y-min),
	|(:$!y-max with $!y-max),
	|(:$!tick-count with $!tick-count),
	|(:$!empty-message with $!empty-message);

multi method series(@series) {
	$!obj.set-series(@series);
	self
}

multi method series(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "series", { self.series: block self }
	self
}

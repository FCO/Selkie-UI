use Selkie::UI::Base;
use Selkie::Widget::ScatterPlot;

unit class Selkie::UI::ScatterPlotBuilder is Selkie::UI::Base;

has @.series;
has Str @.store-path;
has Str $.palette;
has Real $.x-min;
has Real $.x-max;
has Real $.y-min;
has Real $.y-max;
has Str $.overlap;
has Str $.empty-message;
has Selkie::Widget::ScatterPlot $.obj .= new:
	|(:@!series with @!series),
	|(:@!store-path with @!store-path),
	|(:$!palette with $!palette),
	|(:$!x-min with $!x-min),
	|(:$!x-max with $!x-max),
	|(:$!y-min with $!y-min),
	|(:$!y-max with $!y-max),
	|(:$!overlap with $!overlap),
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

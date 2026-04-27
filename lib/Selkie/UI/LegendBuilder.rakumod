use Selkie::UI::Base;
use Selkie::Widget::Legend;

unit class Selkie::UI::LegendBuilder is Selkie::UI::Base;

has @.series;
has Str $.orientation;
has Str $.swatch;
has Selkie::Widget::Legend $.obj .= new:
	|(:@!series with @!series),
	|(:$!orientation with $!orientation),
	|(:$!swatch with $!swatch);

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

use Selkie::UI::Base;
use Selkie::Widget::Histogram;

unit class Selkie::UI::HistogramBuilder is Selkie::UI::Base;

has Real @.values;
has UInt $.bins;
has Real @.bin-edges;
has Str $.orientation;
has Str $.palette;
has Bool $.show-axis;
has Bool $.show-labels;
has Real $.min;
has Real $.max;
has UInt $.tick-count;
has Str $.empty-message;
has Selkie::Widget::Histogram $.obj .= new:
	|(:@!values with @!values),
	|(:$!bins with $!bins),
	|(:@!bin-edges with @!bin-edges),
	|(:$!orientation with $!orientation),
	|(:$!palette with $!palette),
	|(:$!show-axis with $!show-axis),
	|(:$!show-labels with $!show-labels),
	|(:$!min with $!min),
	|(:$!max with $!max),
	|(:$!tick-count with $!tick-count),
	|(:$!empty-message with $!empty-message);

multi method values(@values) {
	$!obj.set-values(@values);
	self
}

multi method values(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "values", { self.values: block self }
	self
}

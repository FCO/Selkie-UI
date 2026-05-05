use Selkie::UI::Base;
use Selkie::Widget::Heatmap;
use Selkie::UI::Helpers;

unit class Selkie::UI::HeatmapBuilder is Selkie::UI::Base;

has @.data;
has Str @.store-path;
has Str $.ramp;
has Real $.min;
has Real $.max;
has Str $.empty-message;
has Selkie::Widget::Heatmap $.obj .= new:
	|(:@!data with @!data),
	|(:@!store-path with @!store-path),
	|(:$!ramp with $!ramp),
	|(:$!min with $!min),
	|(:$!max with $!max),
	|(:$!empty-message with $!empty-message);

multi method data(@data) {
	$!obj.set-data(@data);
	self
}

multi method data(&block) {
	$.auto-subscribe: "data", with-ui-context { self.data: block self }
}

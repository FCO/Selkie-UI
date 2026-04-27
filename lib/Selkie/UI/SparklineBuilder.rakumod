use Selkie::UI::Base;
use Selkie::Widget::Sparkline;

unit class Selkie::UI::SparklineBuilder is Selkie::UI::Base;

has Real @.data;
has Str @.store-path;
has Real $.min;
has Real $.max;
has Str $.empty-message;
has Selkie::Widget::Sparkline $.obj .= new:
	|(:@!data with @!data),
	|(:@!store-path with @!store-path),
	|(:$!min with $!min),
	|(:$!max with $!max),
	|(:$!empty-message with $!empty-message);

method push-sample(Real $value) {
	$!obj.push-sample($value);
	self
}

multi method data(@data) {
	$!obj.set-data(@data);
	self
}

multi method data(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "data", { self.data: block self }
	self
}

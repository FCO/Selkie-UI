use Selkie::UI::Base;
use Selkie::Widget::Toast;

unit class Selkie::UI::ToastBuilder is Selkie::UI::Base;

has Selkie::Widget::Toast $.obj .= new;

multi method show(Str $message, :$duration, :$style) {
	$!obj.show($message, |(:$duration with $duration), |(:$style with $style));
	self
}

multi method show(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "show", { self.show: block self }
	self
}

method tick(--> Bool) { $!obj.tick }

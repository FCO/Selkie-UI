use Selkie::UI::Base;
use Selkie::Widget::Toast;
use Selkie::UI::Helpers;

unit class Selkie::UI::ToastBuilder is Selkie::UI::Base;

has Selkie::Widget::Toast $.obj .= new;

multi method show(Str $message, :$duration, :$style) {
	$!obj.show($message, |(:$duration with $duration), |(:$style with $style));
	self
}

multi method show(&block) {
	$.auto-subscribe: "show", with-ui-context { self.show: block self }
}

method tick(--> Bool) { $!obj.tick }

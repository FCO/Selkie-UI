use Selkie::UI::Base;
use Selkie::Widget::ProgressBar;
use Selkie::UI::Helpers;

unit class Selkie::UI::ProgressBarBuilder is Selkie::UI::Base;

has Selkie::Widget::ProgressBar $.obj .= new;

multi method progress(Numeric $value) {
	$!obj.set-value($value);
	self
}

multi method progress(&block) {
	$.auto-subscribe: "progress", with-ui-context { self.progress: block self }
}

multi method indeterminate(Bool $indet = True) {
	$!obj.indeterminate = $indet;
	self
}

multi method indeterminate(&block) {
	$.auto-subscribe: "indeterminate", with-ui-context { self.indeterminate: block self }
}

multi method show-percentage(Bool $show = True) {
	$!obj.^attributes.first(*.name eq '$!show-percentage').set_value: $!obj, $show;
	self
}

multi method show-percentage(&block) {
	$.auto-subscribe: "show-percentage", with-ui-context { self.show-percentage: block self }
}

method tick {
	$!obj.tick;
	self
}

method frames-per-step(Int $frames) {
	$!obj.^attributes.first(*.name eq '$!frames-per-step').set_value: $!obj, $frames;
	self
}

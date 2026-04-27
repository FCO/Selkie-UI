use Selkie::UI::Base;
use Selkie::Widget::Spinner;
use Selkie::Style;

unit class Selkie::UI::SpinnerBuilder is Selkie::UI::Base;

has @.frames;
has Real $.interval;
has Selkie::Style $.style;
has Selkie::Widget::Spinner $.obj;

submethod TWEAK() {
	my %args;
	%args<frames> = @!frames if @!frames.elems;
	%args<interval> = $!interval if $!interval.defined;
	%args<style> = $!style if $!style.defined;
	$!obj = Selkie::Widget::Spinner.new(|%args);
	self
}

method tick {
	$!obj.tick;
	self
}

method reset {
	$!obj.reset;
	self
}

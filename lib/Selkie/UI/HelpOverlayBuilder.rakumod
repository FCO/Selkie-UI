use Selkie::UI::Base;
use Selkie::Widget::HelpOverlay;
use Selkie::Widget;

unit class Selkie::UI::HelpOverlayBuilder is Selkie::UI::Base;

has $.app is required;
has Selkie::Widget $.focused-widget;
has Selkie::Widget::HelpOverlay $.obj;

submethod TWEAK() {
	$!obj = Selkie::Widget::HelpOverlay.new(
		app => $!app,
		|(:$!focused-widget with $!focused-widget),
	);
	self
}

method build { $!obj.build }

method modal { $!obj.modal }

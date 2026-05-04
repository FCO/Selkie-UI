use Selkie::UI::Base;
use Selkie::Widget::ConfirmModal;
use Selkie::UI::Helpers;

unit class Selkie::UI::ConfirmModalBuilder is Selkie::UI::Base;

has Str   $.title;
has Str   $.message;
has Str   $.yes-label = "yes";
has Str   $.no-label  = "no";
has Rat() $.width-ratio;
has Rat() $.height-ratio;
has Selkie::Widget::ConfirmModal $.obj .= new;

submethod TWEAK(
	:$title,
	:$message,
	:$yes-label,
	:$no-label,
	:$width-ratio,
	:$height-ratio
) {
	self.build:
	:$title,
	:$message,
	:$yes-label,
	:$no-label,
	:$width-ratio,
	:$height-ratio
}

method build(
	:$title,
	:$message,
	:$yes-label,
	:$no-label,
	:$width-ratio,
	:$height-ratio
) {
	$!obj.build(
		|(:$title with $title),
		|(:$message with $message),
		|(:$yes-label with $yes-label),
		|(:$no-label with $no-label),
		|(:$width-ratio with $width-ratio),
		|(:$height-ratio with $height-ratio),
	);
	self
}

method on-result(&block) {
	$!obj.on-result.tap: with-ui-context $*UI-APP, $*UI-PARENT, -> $result { block self, $result }
	self
}

method modal { $!obj.modal }

method yes-button { $!obj.yes-button }

method no-button { $!obj.no-button }

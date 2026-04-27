use Selkie::UI::Base;
use Selkie::Widget::ConfirmModal;

unit class Selkie::UI::ConfirmModalBuilder is Selkie::UI::Base;

has Selkie::Widget::ConfirmModal $.obj .= new;

method build(:$title, :$message, :$yes-label, :$no-label,
		:$width-ratio, :$height-ratio) {
	$!obj.build(
		|(:$title with $title),
		|(:$message with $message),
		|(:$yes-label with $yes-label),
		|(:$no-label with $no-label),
		|(:$width-ratio with $width-ratio),
		|(:$height-ratio with $height-ratio),
	);
}

method on-result(&block) {
	$!obj.on-result.tap: -> $result { block self, $result };
	self
}

method modal { $!obj.modal }

method yes-button { $!obj.yes-button }

method no-button { $!obj.no-button }

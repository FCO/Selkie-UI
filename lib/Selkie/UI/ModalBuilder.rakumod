use Selkie::UI::Base;
use Selkie::Widget::Modal;

unit class Selkie::UI::ModalBuilder is Selkie::UI::Base;

has Rat  $.width-ratio;
has Rat  $.height-ratio;
has Bool $.dim-background;
has Selkie::Widget::Modal $.obj .= new:
	|(:$!width-ratio with $!width-ratio),
	|(:$!height-ratio with $!height-ratio),
	|(:$!dim-background with $!dim-background);

method content($widget, Bool :$destroy = True) {
	$!obj.set-content($widget.obj, :$destroy);
	self
}

method on-close(&block) {
	$!obj.on-close.tap: -> $ { block self };
	self
}

method close { $!obj.close }

submethod TWEAK(:&block) {
	return unless &block.defined;
	my $*UI-PARENT = self;
	my @*UI-NODES;
	block self;
	with @*UI-NODES.head -> $node {
		$!obj.set-content($node.obj);
	}
	self
}

use Selkie::UI::Base;
use Selkie::Widget::Modal;
use Selkie::UI::Helpers;

unit class Selkie::UI::ModalBuilder is Selkie::UI::Base;

has Rat  $.width-ratio;
has Rat  $.height-ratio;
has Bool $.dim-background;
has Selkie::Widget::Modal $.obj .= new:
|(:$!width-ratio with $!width-ratio),
|(:$!height-ratio with $!height-ratio),
|(:$!dim-background with $!dim-background);

submethod TWEAK(:&block) {
	return unless &block.defined;
	my $*UI-PARENT = self;
	my @*UI-NODES;
	block self;
	with @*UI-NODES.head -> $node {
		self.content: $node
	}
	self
}

method content($widget, Bool :$destroy = True) {
	$!obj.set-content: $widget.&selkie-obj, :$destroy;
	self
}

method on-close(&block) is idempotent {
	$!obj.on-close.tap: with-ui-context -> $received { block self, $received }
	self
}

method close { $!obj.close }

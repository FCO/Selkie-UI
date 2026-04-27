use Selkie::UI::Base;
use Selkie::Layout::HBox;

unit class Selkie::UI::HBoxBuilder is Selkie::UI::Base;

has Selkie::Layout::HBox $.obj .= new;
has                      &.block;

submethod TWEAK(:&block) {
	my $*UI-PARENT = self;
	my @*UI-NODES;
	block self;
	for @*UI-NODES -> $node {
		$!obj.add: $node.obj
	}
	self
}
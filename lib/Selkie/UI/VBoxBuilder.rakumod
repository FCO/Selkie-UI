use Selkie::UI::Base;
use Selkie::Layout::VBox;

unit class Selkie::UI::VBoxBuilder is Selkie::UI::Base;

has Selkie::Layout::VBox $.obj .= new;
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

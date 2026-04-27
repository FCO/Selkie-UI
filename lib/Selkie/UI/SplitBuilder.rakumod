use Selkie::UI::Base;
use Selkie::Layout::Split;

unit class Selkie::UI::SplitBuilder is Selkie::UI::Base;

has Selkie::Layout::Split $.obj .= new;
has                      &.block;

multi method orientation(Str $orientation!) {
	$!obj.orientation = $orientation;
	self
}

multi method orientation(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "orientation", { self.orientation: block self }
	self
}

multi method ratio(Numeric $ratio!) {
	$!obj.ratio = $ratio;
	self
}

multi method ratio(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "ratio", { self.ratio: block self }
	self
}

method first($widget) {
	$!obj.set-first: $widget.obj;
	self
}

method second($widget) {
	$!obj.set-second: $widget.obj;
	self
}

submethod TWEAK(:&block) {
	my $*UI-PARENT = self;
	my @*UI-NODES;
	block self;
	for @*UI-NODES -> $node {
		$!obj.add: $node.obj
	}
	self
}
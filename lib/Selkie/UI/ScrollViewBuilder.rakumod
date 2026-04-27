use Selkie::UI::Base;
use Selkie::Widget::ScrollView;

unit class Selkie::UI::ScrollViewBuilder is Selkie::UI::Base;

has Bool $.show-scrollbar;
has Selkie::Widget::ScrollView $.obj .= new:
	|(:$!show-scrollbar with $!show-scrollbar);
has &.block;

method add($widget) {
	$!obj.add: $widget.obj;
	self
}

method scroll-to(UInt $row) {
	$!obj.scroll-to($row);
	self
}

method scroll-by(Int $delta) {
	$!obj.scroll-by($delta);
	self
}

method scroll-to-start {
	$!obj.scroll-to-start;
	self
}

method scroll-to-end {
	$!obj.scroll-to-end;
	self
}

submethod TWEAK(:&block) {
	return unless &block.defined;
	my $*UI-PARENT = self;
	my @*UI-NODES;
	block self;
	for @*UI-NODES -> $node {
		$!obj.add: $node.obj
	}
	self
}

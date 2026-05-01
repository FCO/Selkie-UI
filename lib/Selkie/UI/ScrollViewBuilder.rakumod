use Selkie::UI::Base;
use Selkie::Widget::ScrollView;

unit class Selkie::UI::ScrollViewBuilder is Selkie::UI::Base;

has Bool $.show-scrollbar;
has Selkie::Widget::ScrollView $.obj .= new: |(:$!show-scrollbar with $!show-scrollbar);
has &.block;

submethod TWEAK(:&block) {
	self.content: $_ with &block;
	self
}

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

multi method content($widget) {
	$!obj.add: $widget.obj;
	self
}

multi method content(&block) {
	my $*UI-PARENT = self;
	my @*UI-NODES;
	$ = block self;
	for @*UI-NODES -> $node {
		$!obj.add: $node.obj
	}
	$.auto-subscribe: "content", { self.content: &block }
	self
}

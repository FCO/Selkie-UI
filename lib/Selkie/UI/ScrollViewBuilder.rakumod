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

multi method scroll-to-start(Bool $scroll = True) {
	$!obj.scroll-to-start if $scroll;
	self
}

multi method scroll-to-start(&block) {
	$.scroll-to-start: block self;
	$.auto-subscribe: "scroll-to-start", { self.scroll-to-start: block self }
	self
}

multi method scroll-to-end(Bool $scroll = True) {
	$!obj.scroll-to-end if $scroll;
	self
}

multi method scroll-to-end(&block) {
	$.scroll-to-end: block self;
	$.auto-subscribe: "scroll-to-end", { self.scroll-to-end: block self }
	self
}

method clear { $!obj.clear }

multi method content($widget) {
	$.clear;
	$!obj.add: $widget.obj;
	self
}

multi method content(@widgets) {
	$.clear;
	$.add: $_ for @widgets;
	self
}

multi method content(&block) {
	my %*UI-PATHS;
	my $*UI-PARENT = self;
	my @*UI-NODES;
	$ = block self;
	$.content: @*UI-NODES;
	$.auto-subscribe: "content", {
		my @*UI-NODES;
		$ = block self;
		self.content: @*UI-NODES
	}
	self
}

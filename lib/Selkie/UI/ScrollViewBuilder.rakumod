use Selkie::UI::Base;
use Selkie::Widget::ScrollView;
use Selkie::UI::Helpers;

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
	$.auto-subscribe: "scroll-to-start", with-ui-context { self.scroll-to-start: block self }
}

multi method scroll-to-end(Bool $scroll = True) {
	$!obj.scroll-to-end if $scroll;
	self
}

multi method scroll-to-end(&block) {
	$.auto-subscribe: "scroll-to-end", with-ui-context { self.scroll-to-end: block self }
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
	$.auto-subscribe: "content", with-ui-context {
		$ = block self;
		self.content: @*UI-NODES
	}
}

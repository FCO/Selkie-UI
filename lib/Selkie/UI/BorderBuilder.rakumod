use Selkie::UI::Base;
use Selkie::Widget::Border;
use Selkie::UI::Helpers;

unit class Selkie::UI::BorderBuilder is Selkie::UI::Base;

has Str  $.title;
has Bool $.hide-top-border;
has Bool $.hide-bottom-border;
has Selkie::Widget::Border $.obj .= new:
|(:$!title with $!title),
|(:$!hide-top-border with $!hide-top-border),
|(:$!hide-bottom-border with $!hide-bottom-border);
has &.block;
has $!content;

submethod TWEAK(:&block) {
	self.content: $_ with &block;
}

multi method title(Str $title) {
	$!obj.set-title: $title;
	self
}

multi method title(&title-block) {
	$.auto-subscribe: "title", with-ui-context { self.title: title-block self }
}

multi method hide-top-border(Bool $hide = True) {
	$!obj.hide-top-border = $hide;
	self
}

multi method hide-top-border(&block) {
	$.auto-subscribe: "hide-top-border", with-ui-context { self.hide-top-border: block self }
}

multi method hide-bottom-border(Bool $hide = True) {
	$!obj.hide-bottom-border = $hide;
	self
}

multi method hide-bottom-border(&block) {
	$.auto-subscribe: "hide-bottom-border", with-ui-context { self.hide-bottom-border: block self }
}

multi method get-content { $!content }

multi method content($widget, Bool :$destroy = True) {
	$!content = $widget;
	$!obj.set-content: $widget.&selkie-obj, :$destroy;
	self
}

multi method content(&block) {
	$.auto-subscribe: "content", with-ui-context { self!set-content-from-block(&block) }
}

method !set-content-from-block(&block) {
	my $*UI-PARENT = self;
	my @*UI-NODES;
	block self;
	with @*UI-NODES.head -> $node {
		$.content: $_ with $node;
	}
}

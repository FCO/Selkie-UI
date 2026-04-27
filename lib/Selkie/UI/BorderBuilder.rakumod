use Selkie::UI::Base;
use Selkie::Widget::Border;

unit class Selkie::UI::BorderBuilder is Selkie::UI::Base;

has Str  $.title;
has Bool $.hide-top-border;
has Bool $.hide-bottom-border;
has Selkie::Widget::Border $.obj .= new:
	|(:$!title with $!title),
	|(:$!hide-top-border with $!hide-top-border),
	|(:$!hide-bottom-border with $!hide-bottom-border);

multi method title(Str $title) {
	$!obj.set-title: $title;
	self
}

multi method title(&title-block) {
	my %*UI-PATHS := SetHash.new;
	$ = title-block self;
	$.auto-subscribe: "title", { self.title: title-block self }
	self
}

multi method hide-top-border(Bool $hide = True) {
	$!obj.hide-top-border = $hide;
	self
}

multi method hide-top-border(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "hide-top-border", { self.hide-top-border: block self }
	self
}

multi method hide-bottom-border(Bool $hide = True) {
	$!obj.hide-bottom-border = $hide;
	self
}

multi method hide-bottom-border(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "hide-bottom-border", { self.hide-bottom-border: block self }
	self
}

multi method content($widget, Bool :$destroy = True) {
	$!obj.set-content($widget.obj, :$destroy);
	self
}

multi method content(&block) {
	my %*UI-PATHS := SetHash.new;
	self!set-content-from-block(&block);
	$.auto-subscribe: "content", { self!set-content-from-block(&block) }
	self
}

method !set-content-from-block(&block) {
	my $*UI-PARENT = self;
	my @*UI-NODES;
	block self;
	with @*UI-NODES.head -> $node {
		$!obj.set-content($node.obj);
	}
}

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

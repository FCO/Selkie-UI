use Selkie::UI::Base;
use Selkie::Widget;
use Selkie::Widget::CardList;

unit class Selkie::UI::CardListBuilder is Selkie::UI::Base;

has Selkie::Widget::CardList $.obj .= new;
has &.block;


multi method add-item($widget, :$root = $*UI-PARENT, :$height!, :$border) {
	my $root-widget = $root ~~ Selkie::Widget ?? $root !! $root.obj;
	my $item-widget = $widget ~~ Selkie::Widget ?? $widget !! $widget.obj;
	my $border-widget = $border.defined
		?? ($border ~~ Selkie::Widget ?? $border !! $border.obj)
		!! Nil;
	$!obj.add-item($item-widget, :root($root-widget), :$height,
		|(:$border-widget with $border-widget));
	self
}

multi method add-item(&block, :$root, :$height!, :$border) {
	my $caller-parent = CALLERS::<$*UI-PARENT> // $*UI-PARENT;
	my $local-root = $root // $caller-parent;
	my @*UI-NODES;
	block self;
	for @*UI-NODES -> $node {
		self.add-item($node, :root($local-root), :$height, |(:$border with $border));
	}
	self
}

multi method set-items(@items) {
	self.clear-items;
	for @items -> $item {
		next unless $item ~~ Associative;
		my $widget = $item<widget>;
		next unless $widget.defined;
		my $root = $item<root> // $*UI-PARENT;
		my $height = $item<height>;
		my $border = $item<border>;
		self.add-item($widget, :$root, :$height, |(:$border with $border));
	}
	self
}

multi method set-items(&block) {
	my %*UI-PATHS := SetHash.new;
	self.set-items(block self);
	$.auto-subscribe: "set-items", { self.set-items(block self) }
	self
}

method clear-items {
	$!obj.clear-items;
	self
}

multi method set-item-height(Int :$idx!, Int :$height!) {
	$!obj.set-item-height($idx, $height);
	self
}

multi method set-item-height(Int $idx, Int $height) {
	self.set-item-height(:$idx, :$height)
}

multi method set-item-height(&block) {
	my %*UI-PATHS := SetHash.new;
	my %values = block self;
	self.set-item-height(|%values);
	$.auto-subscribe: "set-item-height", {
		my %next = block self;
		self.set-item-height(|%next)
	}
	self
}

multi method select-index(Int $idx) {
	$!obj.select-index($idx);
	self
}

multi method select-index(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "select-index", { self.select-index: block self }
	self
}

method select-first {
	$!obj.select-first;
	self
}

method select-last {
	$!obj.select-last;
	self
}

method scroll-up {
	$!obj.scroll-up;
	self
}

method scroll-down {
	$!obj.scroll-down;
	self
}

method on-select(&block) {
	$!obj.on-select.tap: -> $idx { block self, $idx };
	self
}

submethod TWEAK(:&block) {
	return unless &block.defined;
	my $*UI-PARENT = self;
	my @*UI-NODES;
	block self;
	self
}

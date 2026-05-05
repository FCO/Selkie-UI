use Selkie::UI::Base;
use Selkie::Widget;
use Selkie::Widget::CardList;
use Selkie::UI::Helpers;

unit class Selkie::UI::CardListBuilder is Selkie::UI::Base;

has Selkie::Widget::CardList $.obj .= new;
has &.block;
has $.select-first;
has $.select-last;

submethod TWEAK(:&block, :$select-first, :$select-last, |) {
	return unless &block.defined;
	my $*UI-PARENT = self;
	my @*UI-NODES;
	self.set-items: $_ with with-ui-context &block;

	$!select-first = with-ui-context $select-first if $select-first ~~ Callable;
	$!select-last  = with-ui-context $select-last  if $select-last  ~~ Callable;

	self.select-first: $!select-first;
	self.select-last:  $!select-last;

	self
}

multi method add-item($widget, :$height!, :$root = $*UI-PARENT, :$border) {
	$!obj.add-item(
		$widget.&selkie-obj,
		:root($root.&selkie-obj),
		:$height,
		|(:border(.&selkie-obj) with $border));

	unless $*UI-MULTIPLE-ADD-ITEMS {
		my @*UI-PATHS;
		$.select-first: $_ with $!select-first;
		$.select-last:  $_ with $!select-last;
	}
	self
}

multi method add-item(&block, :$height!, :$root = $*UI-PARENT, :$border) {
	my $caller-parent = CALLERS::<$*UI-PARENT> // $*UI-PARENT;
	my $local-root = $root // $caller-parent;
	$.auto-subscribe: "add-items", with-ui-context {
		my @values = block self;
		for @values -> $node {
			self.add-item: $node, :root($local-root), :$height, |(:$border with $border);
		}
	}
	self
}

multi method set-items(@items) {
	my $*UI-MULTIPLE-ADD-ITEMS = True;
	self.clear-items;
	for @items -> % (:$widget, :$root, :$height, :$border) {
		self.add-item(
			$widget,
			:$root,
			:$height,
			|(:$border with $border),
		);
	}
	{
		my @*UI-PATHS;
		$.select-first: $_ with $!select-first;
		$.select-last:  $_ with $!select-last;
	}
	self
}

multi method set-items(&block) {
	$.auto-subscribe: "set-items", with-ui-context {
		self.set-items: block self
	}
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
	$.auto-subscribe: "set-item-height", with-ui-context {
		self.set-item-height: |block self;
	}
}

multi method select-index(Int() $idx) {
	$!obj.select-index($idx);
	self
}

multi method select-index(&block) {
	$.auto-subscribe: "select-index", with-ui-context {
		self.select-index: block self
	}
}

multi method select-first(&block) {
	self.select-first: block self
}

multi method select-first(Bool() $select-first = True) {
	$!obj.select-first if $select-first;
	self
}

multi method select-last(&block) {
	self.select-last: block self
}

multi method select-last(Bool() $select-last = True) {
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

method on-select(&block) is idempotent {
	$!obj.on-select.tap: with-ui-context -> $idx {
		block self, $idx
	}
	self
}

=begin pod

=head1 Selkie::UI::CardListBuilder

Builder for a card list widget — a vertically scrollable list of items
with configurable heights and optional borders.

=head2 Methods

=head3 C<add-item($widget, :$height!, :$root, :$border)>

Adds a widget as a card item. C<:$height> is required (in rows).
C<:$root> defaults to C<$*UI-PARENT>. C<:$border> adds an optional border.

=head3 C<add-item(&block, :$height!, :$root, :$border)>

Reactive variant — block is re-evaluated when subscribed state changes.

=head3 C<set-items(@items)> / C<set-items(&block)>

Replaces all items. Each item is a hash with C<:widget>, C<:root>, C<:height>,
and optional C<:border>. The block variant supports reactive subscriptions.

=head3 C<clear-items>

Removes all items.

=head3 C<set-item-height(Int $idx, Int $height)> / C<set-item-height(&block)>

Changes the height of the item at C<$idx>. Block variant supports reactive
subscriptions and receives C<($builder)> returning C<(:$idx, :$height)>.

=head3 C<select-index(Int $idx)> / C<select-index(&block)>

Selects the item at C<$idx> (0-based). The block variant supports reactive
subscriptions.

=head3 C<select-first(Bool $select-first = True)> / C<select-first(&block)>

Selects the first item when C<True>. Block variant supports reactive
subscriptions.

=head3 C<select-last(Bool $select-last = True)> / C<select-last(&block)>

Selects the last item when C<True>. Block variant supports reactive
subscriptions.

=head3 C<scroll-up> / C<scroll-down>

Scrolls the card list by one item.

=head3 C<on-select(&block)> (idempotent)

Registers a callback for selection changes. Receives C<($builder, $idx)>.

=end pod

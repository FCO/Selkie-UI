use Selkie::UI::Base;
use Selkie::Layout::Split;
use Selkie::UI::Helpers;

unit class Selkie::UI::SplitBuilder is Selkie::UI::Base;

has Str()                 $.orientation;
has Rat                   $.ratio;
has Selkie::Layout::Split $.obj .= new:
|(:$!orientation with $!orientation),
|(:$!ratio with $!ratio);
has                       &.block;


submethod TWEAK(:&block) {
	self.set: $_ with &block
}

multi method set($first?, $second?) {
	$.first:  $_ with $first;
	$.second: $_ with $second;
	self
}

multi method set(&block) {
	self.auto-subscribe: "add", with-ui-context $*UI-APP, $*UI-PARENT, {
		$ = block self;
		self.set: |@*UI-NODES
	}
}

multi method add($node) {
	$!obj.add: $node.obj;
	self
}

multi method add(&block) {
	self.auto-subscribe: "add", with-ui-context $*UI-APP, $*UI-PARENT, {
		$ = block self;
		for @*UI-NODES -> $node {
			self.add: $node
		}
	}
	self
}

multi method orientation(Str $orientation!) {
	$!obj.orientation = $orientation;
	self
}

multi method orientation(&block) {
	$.auto-subscribe: "orientation", with-ui-context $*UI-APP, $*UI-PARENT, { self.orientation: block self }
}

multi method ratio(Numeric $ratio!) {
	$!obj.ratio = $ratio;
	self
}

multi method ratio(&block) {
	$.auto-subscribe: "ratio", with-ui-context $*UI-APP, $*UI-PARENT, { self.ratio: block self }
}

multi method first($widget) {
	$!obj.set-first: $widget.obj;
	self
}

multi method first(&block) {
	self.auto-subscribe: "first", with-ui-context $*UI-APP, $*UI-PARENT, {
		$ = block self;
		self.first: @*UI-NODES.head
	}
}

multi method second($widget) {
	$!obj.set-second: $widget.obj;
	self
}

multi method second(&block) {
	self.auto-subscribe: "second", with-ui-context $*UI-APP, $*UI-PARENT, {
		$ = block self;
		self.second: @*UI-NODES.head
	}
}

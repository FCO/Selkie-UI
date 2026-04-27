use Selkie::UI::Base;
use Selkie::Widget::TabBar;

unit class Selkie::UI::TabBarBuilder is Selkie::UI::Base;

has Selkie::Widget::TabBar $.obj .= new;

method add-tab(Str :$name!, Str :$label!) {
	$!obj.add-tab(:$name, :$label);
	self
}

method remove-tab(Str $name) {
	$!obj.remove-tab($name);
	self
}

method clear-tabs {
	$!obj.clear-tabs;
	self
}

multi method select-by-name(Str $name) {
	$!obj.select-by-name($name);
	self
}

multi method select-by-name(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "select-by-name", { self.select-by-name: block self }
	self
}

multi method select-index(UInt $idx) {
	$!obj.select-index($idx);
	self
}

multi method select-index(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "select-index", { self.select-index: block self }
	self
}

method set-active-name-silent(Str $name) {
	$!obj.set-active-name-silent($name);
	self
}

method on-tab-selected(&block) {
	$!obj.on-tab-selected.tap: -> $name { block self, $name };
	self
}

method sync-to-app($app) {
	$!obj.sync-to-app($app);
	self
}

method set-focused(Bool $focused = True) {
	$!obj.set-focused($focused);
	self
}

method focus(Bool $focused = True) {
	$!obj.set-focused($focused);
	self
}

use Selkie::UI::Base;
use Selkie::Widget::Table;
use Selkie::Sizing;

unit class Selkie::UI::TableBuilder is Selkie::UI::Base;

has Bool $.show-scrollbar;
has Selkie::Widget::Table $.obj .= new:
	|(:$!show-scrollbar with $!show-scrollbar);

method add-column(Str :$name!, Str :$label!, Sizing :$sizing = Sizing.flex,
		Bool :$sortable = False, :&render, :&sort-key) {
	$!obj.add-column(:$name, :$label, :$sizing, :$sortable, :&render, :&sort-key);
	self
}

multi method rows(@rows) {
	$!obj.set-rows(@rows);
	self
}

multi method rows(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "rows", { self.rows: block self }
	self
}

method clear-columns {
	$!obj.clear-columns;
	self
}

method sort-by(Str $name, Str :$direction) {
	$!obj.sort-by($name, |(:$direction with $direction));
	self
}

method clear-sort {
	$!obj.clear-sort;
	self
}

method select-index(UInt $idx) {
	$!obj.select-index($idx);
	self
}

method on-select(&block) {
	$!obj.on-select.tap: -> $idx { block self, $idx };
	self
}

method on-activate(&block) {
	$!obj.on-activate.tap: -> $idx { block self, $idx };
	self
}

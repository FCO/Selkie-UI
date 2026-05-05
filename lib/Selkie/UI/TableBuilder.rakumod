use Selkie::UI::Base;
use Selkie::Widget::Table;
use Selkie::UI::Helpers;
use Selkie::Sizing;

unit class Selkie::UI::TableBuilder is Selkie::UI::Base;

has @.columns;
has &.block;
has Bool $.show-scrollbar;
has Selkie::Widget::Table $.obj .= new:
	|(:$!show-scrollbar with $!show-scrollbar);

submethod TWEAK(:&block, |) {
	for @!columns -> %column {
		self.add-column: |%column
	}
	self.rows: $_ with &block;
}

method add-column(
	Str :$name!,
	Str :$label!,
	Sizing :$sizing is copy,
	:$size is copy,
	:$flex,
	:$fixed,
	Bool :$sortable = False,
	:&render,
	:&sort-key
) {
	my %size = %(
		|(:$flex  with $flex             ),
		|(:$fixed with $fixed            ),
		|(fixed => $size if $size ~~ Int ),
		|(|%$size if $size ~~ Associative),
	);
	$sizing //= Sizing."{ .key }"(.value) with %size.pairs.head;
	$sizing //= Sizing.flex;
	$!obj.add-column: :$name, :$label, :$sizing, :$sortable, :&render, :&sort-key;
	self
}

multi method rows(@rows) {
	$!obj.set-rows(@rows.list);
	self
}

multi method rows(&block) {
	$.auto-subscribe: "rows", with-ui-context { self.rows: block self }
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

method on-select(&block) is idempotent {
	$!obj.on-select.tap: with-ui-context -> $idx { block self, $idx }
	self
}

method on-activate(&block) is idempotent {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-activate.tap: with-ui-context -> $idx { block self, $idx }
	self
}

method columns {
	$!obj.columns
}

method row-at(UInt $idx) {
	$!obj.row-at($idx)
}

method sort-column {
	$!obj.sort-column
}

method on-key(Str $key, &block) {
	return self unless $.should-add: "on-key-$key";
	$!obj.on-key($key, with-ui-context { block self, $ });
	self
}

use Selkie::UI::Base;
use Selkie::Widget::ListView;
use Selkie::UI::Helpers;

unit class Selkie::UI::ListViewBuilder is Selkie::UI::Base;

has &.block;
has Selkie::Widget::ListView $.obj .= new;

submethod TWEAK(:&block, |) {
	self.set-items: $_ with &block
}

multi method set-items(@items) {
	$!obj.set-items: @items;
	self
}

multi method set-items(&block) {
	$.auto-subscribe: "set-items", with-ui-context $*UI-APP, $*UI-PARENT, {
		self.set-items: block self
	}
}

multi method on-select(&block) {
	$!obj.on-select.tap: with-ui-context $*UI-APP, $*UI-PARENT, -> $idx {
		block self, $idx
	}
	self
}

multi method on-activate(&block) {
	$!obj.on-activate.tap: with-ui-context $*UI-APP, $*UI-PARENT, -> $idx {
		block self, $idx
	}
	self
}

method select-last {
	$!obj.select-last;
	self
}

method cursor {
	$!obj.cursor
}

method on-key(Str $key, &block) {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-key($key, -> $ { with-ui-context($app, $parent, &block)(self, $) });
	self
}

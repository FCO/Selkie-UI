use Selkie::UI::Base;
use Selkie::Widget::ListView;
use Selkie::UI::Helpers;

unit class Selkie::UI::ListViewBuilder is Selkie::UI::Base;

has Selkie::Widget::ListView $.obj .= new;


multi method set-items(@items) {
	$!obj.set-items: @items;
	self
}

multi method set-items(&block) {
	my $app = $*UI-APP;
	my %*UI-PATHS := SetHash.new;
	self.set-items: block self;
	$.auto-subscribe: "set-items", {
		my $*UI-APP = $app;
		self.set-items: block self
	}
	self
}

multi method on-select(&block) {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-select.tap: -> $idx {
		with-ui-context($app, $parent, &block)(self, $idx)
	}
	self
}

multi method on-activate(&block) {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-activate.tap: -> $idx {
		with-ui-context($app, $parent, &block)(self, $idx)
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

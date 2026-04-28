use Selkie::UI::Base;
use Selkie::Widget::ListView;

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
	$!obj.on-select.tap: -> $idx {
		my $*UI-APP = $app;
		block self, $idx
	}
	self
}

multi method on-activate(&block) {
	my $app = $*UI-APP;
	$!obj.on-activate.tap: -> $idx {
		my $*UI-APP = $app;
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

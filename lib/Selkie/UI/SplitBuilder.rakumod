use Selkie::UI::Base;
use Selkie::Layout::Split;

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
	my $app = $*UI-APP;
	my %*UI-PATHS := SetHash.new;
	my $*UI-PARENT = self;
	my @*UI-NODES;
	$ = block self;
	self.set: |$_ with @*UI-NODES;
	self.auto-subscribe: "add", {
		my $*UI-APP = $app;
		my @*UI-NODES;
		$ = block self;
		self.set: |@*UI-NODES
	}
	self
}

multi method add($node) {
	$!obj.add: $node.obj;
	self
}

multi method add(&block) {
	my $app = $*UI-APP;
	my %*UI-PATHS := SetHash.new;
	my $*UI-PARENT = self;
	my @*UI-NODES;
	$ = block self;
	for @*UI-NODES -> $node {
		self.add: $node
	}
	self.auto-subscribe: "add", {
		my $*UI-APP = $app;
		my @*UI-NODES;
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
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "orientation", { self.orientation: block self }
	self
}

multi method ratio(Numeric $ratio!) {
	$!obj.ratio = $ratio;
	self
}

multi method ratio(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "ratio", { self.ratio: block self }
	self
}

multi method first($widget) {
	$!obj.set-first: $widget.obj;
	self
}

multi method first(&block) {
	my $app = $*UI-APP;
	my %*UI-PATHS := SetHash.new;
	my $*UI-PARENT = self;
	my @*UI-NODES;
	$ = block self;
	self.first: @*UI-NODES.head;
	self.auto-subscribe: "first", {
		my $*UI-APP = $app;
		my @*UI-NODES;
		$ = block self;
		self.first: @*UI-NODES.head
	}
	self
}

multi method second($widget) {
	$!obj.set-second: $widget.obj;
	self
}

multi method second(&block) {
	my $app = $*UI-APP;
	my %*UI-PATHS := SetHash.new;
	my $*UI-PARENT = self;
	my @*UI-NODES;
	$ = block self;
	self.second: @*UI-NODES.head;
	self.auto-subscribe: "second", {
		my $*UI-APP = $app;
		my @*UI-NODES;
		$ = block self;
		self.second: @*UI-NODES.head
	}
	self
}

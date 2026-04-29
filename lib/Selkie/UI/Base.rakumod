use Selkie::Sizing;
use Selkie::Widget;
use Selkie::Style;
use Selkie::UI::Helpers;

unit class Selkie::UI::Base;

submethod TWEAK(|) {
	.push: self with @*UI-NODES
}

method auto-subscribe($method, &block) {
	with $*UI-APP.obj.store {
		my $app = $*UI-APP;
		my $parent = $*UI-PARENT;
		for %*UI-PATHS.keys -> $path {
			.subscribe-path-callback(
				"{ $.obj.WHERE }-{ self.^name }-{ $method }-{ $path }",
				[ $path ],
				with-ui-context($app, $parent, &block),
				$.obj ~~ Selkie::Widget ?? $.obj !! Selkie::Widget
			)
		}
	}
	block self
}

method style(|c) {
	my $style = Selkie::Style.new: |c.hash;
	if $.obj.^can('set-style') {
		$.obj.set-style($style);
	} elsif $.obj.^can('style') {
		try { $.obj.style = $style };
	}
	self
}

multi method size(UInt $fixed!) {
	$.obj.update-sizing: Sizing.fixed($fixed);
	self
}

multi method size(Numeric :$percent!) {
	$.obj.update-sizing: Sizing.percent($percent);
	self
}

multi method size(:$flex is copy) {
	my $value = $flex ~~ UInt ?? $flex.Int !! 1;
	$.obj.update-sizing: Sizing.flex($value);
	self
}

multi method size(&sizing-block) {
	my %*UI-PATHS := SetHash.new;
	$ = sizing-block self;
	$.auto-subscribe: "size", { self.size: sizing-block self }
	self
}

method focus {
	$*UI-APP.obj.focus: $.obj;
	self
}

use Selkie::UI::Base;
use Selkie::UI::ScreenBuilder;
use Selkie::App;

unit class Selkie::UI::AppBuilder is Selkie::UI::Base;

has Selkie::App $.obj   .= new;
has             &.block;

submethod TWEAK(:&block) {
	my $*UI-APP = self;
	my @*UI-NODES;
	block self;
	my Str $default;
	die "No screens to show" unless @*UI-NODES;
	for @*UI-NODES -> $node {
		given $node {
			when Selkie::UI::ScreenBuilder {
				$default //= .name;
				$!obj.add-screen: .name, .screen.obj;
			}
			default {
				die "More than one unnamed screen..." with $default;
				$default = "main";
				$!obj.add-screen: $default, .obj;
			}
		}
	}
	$!obj.switch-screen: $default;
	self
}

multi method theme(Selkie::Theme $theme) { $!obj.set-theme: $theme; self }

multi method theme(*%theme) { $!obj.theme: Selkie::Theme.new: |%theme; self }

multi method theme(&theme) {
	my %*UI-PATHS := SetHash.new;
	$ = theme self;
	$.auto-subscribe: "theme", { self.theme: theme self }
	self
}


method run { $!obj.run }

use Selkie::UI::Base;
use Selkie::UI::ScreenBuilder;
use Selkie::App;
use Selkie::Container;
use Selkie::UI::Helpers;

unit class Selkie::UI::AppBuilder is Selkie::UI::Base;

has $.start-screen;
has Selkie::App $.obj   .= new;
has             &.block;

submethod TWEAK(:&block) {
	my $*UI-APP = self;
	my @*UI-NODES;
	block self;
	die "No screens to show" unless @*UI-NODES;
	my Str $default;
	for @*UI-NODES -> $node {
		given $node {
			when Selkie::UI::ScreenBuilder {
				$default //= .name;
				self.add-screen: .name, .screen.obj;
			}
			default {
				die "More than one unnamed screen..." if $++;
				$default = "main";
				self.add-screen: $default, .obj;
			}
		}
	}
	with $!start-screen {
		$!obj.switch-screen: .Str;
	} else {
		$!obj.switch-screen: $default;
	}
	self
}

multi method add-screen($name, Selkie::Container $screen) {
	$!obj.add-screen: $name, $screen
}

multi method add-screen($name, $) {
	die "Error trying to add a non container as a screen called '$name'";
}

multi method theme(Selkie::Theme $theme) { $!obj.set-theme: $theme; self }

multi method theme(*%theme) { $!obj.theme: Selkie::Theme.new: |%theme; self }

multi method theme(&theme) {
	$.auto-subscribe: "theme", with-ui-context { self.theme: theme self }
}

method run { $!obj.run }

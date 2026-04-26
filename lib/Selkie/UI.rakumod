unit class Selkie::UI;

use Selkie::App;
use Selkie::Layout::VBox;
use Selkie::Widget::Button;
use Selkie::Widget::TextStream;
use Selkie::Widget::TextInput;
use Selkie::Sizing;
use UUID;

my %states;
sub new-state(
	$default?,
	:$name  = UUID.new.Str,
	:$event = "ui/automatic/{ $name }/update",
) is rw is export {
	die "State $name already exists" if %states{$name}++;

	my $store = $*UI-APP.obj.store;

	$store.register-handler: $event, -> $, %ev {
		:db{ $name => %ev<value> }
	}

	with $default -> $value {
		$store.dispatch: $event, :$value;
		$store.tick;
	}

	Proxy.new(
		FETCH => sub ($) {
			.{$name} = True with %*UI-PATHS;
			$store.get-in: $name
		},
		STORE => sub ($, $value) {
			$store.dispatch: $event, :$value;
			$value
		}
	)
}

class UI {
	submethod TWEAK(|) {
		.push: self with @*UI-NODES
	}

	method auto-subscribe($method, &block) {
		with $*UI-APP.obj.store {
			for %*UI-PATHS.keys -> $path {
				.subscribe-path-callback(
					"{ $.obj.WHERE }-{ self.^name }-{ $method }-{ $path }",
					[ $path ],
					&block,
					$.obj
				)
			}
		}
		block self
	}
}

class ScreenBuilder is UI {
	has Str $.name;
	has     $.screen;
}

multi Screen(&block, Str :$name = "main") is export {
	my @*UI-NODES;
	block $*UI-APP;
	ScreenBuilder.new: :$name, :screen(@*UI-NODES.head)
}

multi Screen($node, Str :$name = "main") is export {
	ScreenBuilder.new: :$name, :screen($node)
}

class AppBuilder is UI {
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
				when ScreenBuilder {
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

	method run { $!obj.run }
}

sub App(&block) is export { AppBuilder.new(:&block).run }

class VBoxBuilder is UI {
	has Selkie::Layout::VBox $.obj .= new;
	has                      &.block;

	submethod TWEAK(:&block) {
		my $*UI-PARENT = self;
		my @*UI-NODES;
		block self;
		for @*UI-NODES -> $node {
			$!obj.add: $node.obj
		}
		self
	}
}

sub VBox(&block) is export { VBoxBuilder.new: :&block }

class ButtonBuilder is UI {
	has Str                    $.label = "";
	has Selkie::Widget::Button $.obj  .= new: :$!label;

	multi method label(Str $label) {
		$!obj.set-label: $label;
		self
	}

	multi method label(&label) {
		my %*UI-PATHS := SetHash.new;
		my Str() $label = label self;
		$.auto-subscribe: "label", { self.label: label self }
		self
	}

	method on-press(&block) {
		$!obj.on-press.tap: { block self }
		self
	}
}

sub Button(:$label) is export { ButtonBuilder.new: |(:$label with $label) }

class TextStreamBuilder is UI {
	has Selkie::Widget::TextStream $.obj .= new;

	multi method append(Str() $text) {
		$!obj.append: $text;
		self
	}

	multi method append(&text) {
		$.auto-subscribe: "label", { self.append: text self }
		self
	}
}

sub TextStream(:$placeholder) is export { TextStreamBuilder.new: |(:$placeholder with $placeholder) }

class TextInputBuilder is UI {
	has Str                       $.placeholder;
	has Sizing                    $.sizing;
	has Selkie::Widget::TextInput $.obj .= new: |(:$!placeholder with $!placeholder), |(:$!sizing with $!sizing);

	method size(UInt $fixed = 1) {
		$!obj.update-sizing: Sizing.fixed($fixed);
		self
	}

	method on-submit(&block) {
		$!obj.on-submit.tap: -> $text { block self, $text }
		self
	}

	method clear { $!obj.clear }
}

sub TextInput(:$placeholder) is export { TextInputBuilder.new: :$placeholder }



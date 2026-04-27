unit class Selkie::UI;

=begin pod

=NAME Selkie::UI
=TITLE UI Builder Abstractions for Selkie

=NOTE This module is under active development. API may change.

=SYNOPSIS

=begin code :lang<raku>

use Selkie::UI;

App {
    Screen :name<main>, {
        VBox {
            Button.label: "Click me"
        }
    }
}

=end code

=DESCRIPTION

Selkie::UI provides a Raku-native DSL for building terminal user interfaces using the Selkie framework. Unlike traditional imperative UI code where you manually manage rendering and event loops, this module offers a declarative approach—your code describes B<what> the UI should look like and do, not B<how> to achieve it step-by-step.

Widgets are declared hierarchically using block syntax, with properties and handlers specified via chained method calls. This makes UI definitions intuitive, compositional, and easy to reason about—whether you're building simple tools or complex applications.

The DSL handles the glue between your declarative definitions and Selkie's imperative runtime, including state management with automatic UI updates when reactive variables change.

=head2 State Management

C<new-state> creates reactive state variables that automatically dispatch updates and re-render affected UI elements:

=begin code :lang<raku>

my $counter := new-state 0;
$counter = $counter + 1;  # Triggers UI update

=end code

=head2 Builders

The module exports builder functions for all major Selkie primitives:

=item C<App> — Application entry point that initializes the UI and starts the event loop
=item C<Screen> — Named screens that can be switched between
=item C<VBox> — Vertical layout container for stacking widgets
=item C<Button> — Clickable button with label and press handler
=item C<TextStream> — Text display widget that updates reactively
=item C<TextInput> — Text input field with submit handling

Each builder uses a block syntax where widget properties are configured via chained method calls.

=head2 Examples

=head3 Text input with reactive display

This example creates a text input field that echoes user input to a text stream above it. Type in the input box and press Enter to see the text appear:

=begin code :lang<raku>

use Selkie::UI;
App {
	my $next-msg := new-state Str;        # Reactive variable, starts empty
	VBox {                                 # Vertical layout container
		TextStream.append: { $next-msg };  # Displays $next-msg, auto-updates when it changes
		TextInput(:placeholder('Type here...')).size(1).on-submit: -> $input, $text {
			$next-msg = $text;              # Update state with submitted text
			$input.clear                    # Clear the input field for next entry
		}
	}
}

=end code

![](./text.gif)

=head3 Button with reactive state

This example shows a button whose label changes based on a numeric state variable. Each button press increments the counter, automatically updating the label:

=begin code :lang<raku>

use Selkie::UI;

App {
	my UInt $val := new-state 0;                                   # Reactive counter, starts at 0
	VBox {
		Button.label({ $val ?? "BLE $val" !! "BLA $val" })        # Label shows "BLA 0" then "BLE 1", etc.
			.on-press: { ++$val }                                  # Increment counter when clicked
	}
}

=end code

![](./test.gif)

=end pod

use Selkie::App;
use Selkie::Layout::VBox;
use Selkie::Widget::Button;
use Selkie::Widget::TextStream;
use Selkie::Widget::TextInput;
use Selkie::Sizing;
use UUID;

my %states;
sub new-state(
	$default,
	:$name  = UUID.new.Str,
	:$event = "ui/automatic/{ $name }/update",
) is rw is export {
	die "State $name already exists" if %states{$name}++;

	my $store = $*UI-APP.obj.store;

	$store.register-handler: $event, -> $, %ev {
		:db{ $name => %ev<value> }
	}

	given $default -> $value {
		$store.dispatch: $event, :$value;
		$store.tick;
	}

	return-rw Proxy.new(
		FETCH => sub ($) {
			.{$name} = True with %*UI-PATHS;
			try $store.get-in: $name
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
		$ = label self;
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

	multi method append(&text) {
		my %*UI-PATHS := SetHash.new;
		$ = text self;
		$.auto-subscribe: "append", { self.append: text self }
		self
	}

	multi method append(Str() $text) {
		$!obj.append: $text with $text;
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



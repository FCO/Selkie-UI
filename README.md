[![Actions Status](https://github.com/FCO/Selkie-UI/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/Selkie-UI/actions)

NAME
====

Selkie::UI

TITLE
=====

UI Builder Abstractions for Selkie

NOTE
====

This module is under active development. API may change.

SYNOPSIS
========



```raku
use Selkie::UI;

App {
    Screen :name<main>, {
        VBox {
            Button.label: "Click me"
        }
    }
}
```

DESCRIPTION
===========



Selkie::UI provides a Raku-native DSL for building terminal user interfaces using the Selkie framework. Unlike traditional imperative UI code where you manually manage rendering and event loops, this module offers a declarative approach—your code describes **what** the UI should look like and do, not **how** to achieve it step-by-step.

Widgets are declared hierarchically using block syntax, with properties and handlers specified via chained method calls. This makes UI definitions intuitive, compositional, and easy to reason about—whether you're building simple tools or complex applications.

The DSL handles the glue between your declarative definitions and Selkie's imperative runtime, including state management with automatic UI updates when reactive variables change.

State Management
----------------

`new-state` creates reactive state variables that automatically dispatch updates and re-render affected UI elements:

```raku
my $counter := new-state 0;
$counter = $counter + 1;  # Triggers UI update
```

Builders
--------

The module exports builder functions for all major Selkie primitives:

  * `App` — Application entry point that initializes the UI and starts the event loop

  * `Screen` — Named screens that can be switched between

  * `VBox` — Vertical layout container for stacking widgets

  * `Button` — Clickable button with label and press handler

  * `TextStream` — Text display widget that updates reactively

  * `TextInput` — Text input field with submit handling

Each builder uses a block syntax where widget properties are configured via chained method calls.

Examples
--------

### Text input with reactive display

This example creates a text input field that echoes user input to a text stream above it. Type in the input box and press Enter to see the text appear:

```raku
use Selkie::UI;
App {
	my $next-msg := new-state Str;             # Reactive variable, starts empty
	VBox {                                     # Vertical layout container
		TextStream.append: { $next-msg };  # Displays $next-msg, auto-updates when it changes
		TextInput(:placeholder('Type here...')).size(1).on-submit: -> $input, $text {
			$next-msg = $text;         # Update state with submitted text
			$input.clear               # Clear the input field for next entry
		}
	}
}
```

![](./text.gif)

### Button with reactive state

This example shows a button whose label changes based on a numeric state variable. Each button press increments the counter, automatically updating the label:

```raku
use Selkie::UI;

App {
	my UInt $val := new-state 0;                               # Reactive counter, starts at 0
	VBox {
		Button.label({ $val ?? "BLE $val" !! "BLA $val" }) # Label shows "BLA 0" then "BLE 1", etc.
			.on-press: { ++$val }                      # Increment counter when clicked
	}
}
```

![](./test.gif)


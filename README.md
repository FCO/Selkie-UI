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

`new-state` creates reactive state variables that automatically dispatch updates and re-render affected UI elements.

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

This example creates a text input field that echoes user input to a text stream above it.

The program creates a reactive string variable with `new-state`, places a vertical box layout on screen, adds a text stream widget to display messages, and adds a text input widget. When the user types and presses Enter, the input text is stored in the reactive variable, which automatically updates the text stream, and the input field is cleared for the next entry.

```raku
use Selkie::UI;

App {
    my $next-msg := new-state Str;
    VBox {
        TextStream.append: { $next-msg };
        TextInput(:placeholder('Type here...')).size(1).on-submit: -> $input, $text {
            $next-msg = $text;
            $input.clear
        }
    }
}
```

The `App` block is the entry point that initializes the application.

The `new-state` function creates a reactive state variable bound with `:=`, initialized as an empty string.

The `VBox` widget arranges its children vertically from top to bottom.

`TextStream.append` with a block argument reactively displays the value of `$next-msg` and updates whenever it changes.

`TextInput` creates a single-line text input with a placeholder hint.

`.size(1)` constrains the input to a fixed height of one row.

`.on-submit` registers a handler that runs when the user presses Enter. The handler receives the input widget and the submitted text, stores the text in the reactive variable, and clears the input for the next entry.

![](./text.gif)

### Button with reactive state

This example shows a button whose label changes based on a numeric state variable.

The program creates a reactive integer counter, places it in a vertical box, and displays a button. The button label is computed from the counter value using a block—when the counter changes, the label automatically re-renders. Each button press increments the counter, updating both the counter value and the button label.

```raku
use Selkie::UI;

App {
    my UInt $val := new-state 0;
    VBox {
        Button.label({ $val ?? "BLE $val" !! "BLA $val" })
            .on-press: { ++$val }
    }
}
```

The `App` block is the entry point that initializes the application.

The `new-state` function creates a reactive state variable bound with `:=`, initialized as zero.

The `VBox` widget arranges its children vertically.

`Button.label` with a block argument computes the label text. The ternary operator shows "BLA 0" when the value is zero, otherwise "BLE $val".

`.on-press` registers a handler that runs when the user clicks the button. The handler increments the counter with `++$val`, triggering a UI update.

![](./test.gif)


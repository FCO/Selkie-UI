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

For compound values (arrays, hashes), assign a new value to trigger updates. In-place mutations do not dispatch.

```raku
my $items := new-state [];
$items = [ |$items, 'new' ];
```

Block-Based Setters
-------------------

Many builder methods accept a block instead of a value. The block is evaluated once and the builder auto-subscribes to any state read inside it, re-running the setter when those states change. These reactive setters require an active `App` because auto-subscribe uses `$*UI-APP` and the store.

Builders
--------

The module exports builder functions for Selkie primitives. Each builder returns a chainable builder object that wraps the underlying widget.

### Layout and Containers

  * `App` — Application entry point that initializes the UI and starts the event loop

  * `Screen` — Named screens that can be switched between

  * `VBox`, `HBox`, `Split` — Layout containers for stacking or splitting widgets

  * `Border`, `Modal`, `ScrollView` — Container and decorator widgets

  * `CardList` — Scrollable list of variable-height widgets

### Inputs and Selection

  * `Button` — Clickable button with label and press handler

  * `TextInput`, `MultiLineInput` — Text input fields with submit handling

  * `Checkbox`, `RadioGroup`, `Select` — Selection controls

  * `ProgressBar` — Progress indicator

### Text and Lists

  * `Text`, `TextStream`, `RichText` — Text display widgets

  * `ListView`, `Table`, `TabBar` — List and table widgets

  * `Image`, `Spinner`, `Toast` — Media and status widgets

### Overlays and Helpers

  * `ConfirmModal` — Confirmation modal builder

  * `CommandPalette` — Fuzzy command launcher

  * `FileBrowser` — File picker modal

  * `HelpOverlay` — Contextual keybind help

  * `PasswordStrength` — Password strength meter

### Charts

  * `Plot`, `BarChart`, `LineChart`, `ScatterPlot` — Chart widgets

  * `Sparkline`, `Heatmap`, `Histogram` — Inline and grid charts

  * `Axis`, `Legend` — Chart adornments

Helpers
-------

App helpers that interact with the runtime:

  * `OnKey` — Register global key handlers

  * `OnFrame` — Register a per-frame callback

  * `Dispatch` — Dispatch events to the store

  * `Tick` — Tick the store immediately

  * `Quit` — Quit the application

  * `Toast` — Show a transient toast message

Playground
----------

There is a built-in playground to live-edit/test Selkie::UI code:

    raku -I lib bin/selkie-ui-playground.raku

![](./playground.gif)

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

The `App` block is the entry point that initializes the application. The `new-state` function creates a reactive state variable bound with `:=`, initialized as an empty string. The `VBox` widget arranges its children vertically from top to bottom. `TextStream.append` with a block argument reactively displays the value of `$next-msg` and updates whenever it changes. `TextInput` creates a single-line text input with a placeholder hint. `.size(1)` constrains the input to a fixed height of one row. `.on-submit` registers a handler that runs when the user presses Enter. The handler receives the input widget and the submitted text, stores the text in the reactive variable, and clears the input for the next entry.

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

The `App` block is the entry point that initializes the application. The `new-state` function creates a reactive state variable bound with `:=`, initialized as zero. The `VBox` widget arranges its children vertically. `Button.label` with a block argument computes the label text. The ternary operator shows "BLA 0" when the value is zero, otherwise "BLE $val". `.on-press` registers a handler that runs when the user clicks the button. The handler increments the counter with `++$val`, triggering a UI update.

![](./test.gif)

### ListView with reactive items

This example binds a list view to a reactive array. When the array changes, the list updates automatically.

```raku
use Selkie::UI;

App {
    my $items := new-state <One Two Three>;
    VBox {
        ListView.set-items: { $items };
        Button.label('Refresh').on-press: {
            $items = <One Two Three Four>
        }
    }
}
```


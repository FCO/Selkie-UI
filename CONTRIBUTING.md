# Contributing to Selkie::UI

## Getting Started

```bash
# Clone the repository
git clone https://github.com/FCO/Selkie-UI.git
cd Selkie-UI

# Install dependencies
zef install --/test --deps-only .

# Run tests
zef test .

# Install for development
zef install .
```

## Project Structure

```
lib/Selkie/UI.rakumod        # Main entry point — exports all builders and helpers
lib/Selkie/UI/                # Builder modules (one per widget type)
lib/Selkie/UI/Base.rakumod    # Base class for all builders
lib/Selkie/UI/Helpers.rakumod # Dynamic variable context helpers
t/                            # Test files (01-*.rakutest to 05-*.rakutest)
examples/                     # Runnable example scripts
dist.ini                      # Dist::Ini build configuration
META6.json                    # Raku distribution metadata
```

## Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `zef test .` to verify nothing is broken
5. Submit a pull request

## Code Conventions

### Builder Pattern

Every widget gets a builder class that extends `Selkie::UI::Base`. Builders wrap an
underlying Selkie widget object (accessible via `.obj`) and expose chainable setters:

```raku
method label(Str $label) {
    $.obj.label = $label;
    self
}
```

### Method Chaining

All builder methods return `self` to enable fluent chaining:

```raku
Button.label("Click").on-press({ ... }).size(10)
```

### Reactive Setters

Builder methods use `multi` dispatch to support both direct values and reactive blocks:

```raku
multi method label(Str $label) { $.obj.label = $label; self }
multi method label(&label) {
    %*UI-PATHS := SetHash.new;
    with &label.() -> $value {
        $.obj.label = $value;
        $.auto-subscribe("label", &label);
    }
    self
}
```

### Dynamic Variables

Context is passed through dynamic variables that only exist within builder scopes:
- `$*UI-APP` — The running application
- `$*UI-PARENT` — The parent builder
- `%*UI-PATHS` — Tracks state paths read during block evaluation
- `@*UI-NODES` — Nodes created by child builders

### Naming

- Builder classes: `Selkie::UI::<WidgetName>Builder`
- Exported subs: PascalCase matching the widget name (e.g., `Button`, `VBox`)
- Test files: numbered `01-category.rakutest` to `05-category.rakutest`

## Testing

Tests use Raku's built-in `Test` module along with `Selkie::Test::Keys` and
`Selkie::Test::Focus` helper modules from the Selkie framework:

```raku
use Test;
use Selkie::UI;
use Selkie::Test::Keys;
use Selkie::Test::Focus;

subtest 'Button builder with string label' => {
    my $btn = Button.label: 'Click Me';
    ok $btn ~~ Selkie::UI::ButtonBuilder, 'Button builder works';
    is $btn.obj.label, 'Click Me', 'Label set correctly';
}
```

Test files are organized by widget category:
- `01-button-textinput.rakutest` — Button and TextInput builders
- `02-layout-structure.rakutest` — Layout containers and Screen
- `03-text-stream-collection.rakutest` — Text, lists, and overlays
- `04-data-visualization.rakutest` — Chart builders
- `05-system-helpers.rakutest` — Helpers, state, and advanced widgets

## Documentation

- **POD**: Use Raku Pod6 (`=begin pod` / `=end pod`) in `.rakumod` files for
  inline API documentation
- **Rakudoc**: The `dist.ini` uses `ReadmeFromPod` to generate the README from
  `lib/Selkie/UI.rakudoc`
- **AGENTS.md**: Documents project commands, structure, and patterns for AI agents
- Keep documentation concise and focused on usage, not implementation details

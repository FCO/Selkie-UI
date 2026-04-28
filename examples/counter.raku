#!/usr/bin/env raku
use Selkie::UI;

App {
	my $counter := new-state 0;
	VBox {
		Text.text: { "Count: $counter" };
		HBox {
			Button.label('−').on-press: { --$counter };
			Button.label('Reset').on-press: { $counter = 0 };
			Button.label('+').on-press: { ++$counter };
		};
	};
	OnKey('ctrl+q', { Quit });
}

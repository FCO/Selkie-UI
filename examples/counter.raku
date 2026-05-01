#!/usr/bin/env raku
#
# counter.raku — Selkie::UI version of the counter demo
# Run with: raku -I lib examples/counter.raku
# Quit with: Ctrl+Q
use Selkie::UI;
use Selkie::Style;
use Selkie::Sizing;

App {
	my $counter := new-state 0;

	VBox {
		Text(:text('  Selkie Counter  —  Tab switches focus, Ctrl+Q quits'),
			:1size,
			:style(:fg(0x7AA2F7), :bold));

		Text.text('') :size(:flex);

		Text.text: { "       Count: $counter" }
			.size(3)
			.style(:fg(0xFFFFFF), :bold);

		HBox :1size, {
			Button.label('  −  ').on-press: { --$counter };
			Button.label('Reset').on-press: { $counter = 0 };
			Button.label('  +  ').on-press: { ++$counter };
		};

		Text.text('') :size(:flex);
	};

	OnKey('ctrl+q', { Quit });
}

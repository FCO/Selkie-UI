#!/usr/bin/env raku
#
# settings.raku — Selkie::UI version of the upstream settings demo
# Run with: raku -I lib examples/settings.raku
use Selkie::UI;
use Selkie::Style;
use Selkie::Sizing;

$*OUT = $*ERR = open "log.log", :w;
App {
	.obj.store.enable-debug: log => $*OUT;
	my %form  := new-hash-state %( dirty => False );

	sub save(|) {
		if %form<name> {
			%form<dirty> = False;
			Toast 'Settings saved';
		}
	}

	VBox {
		Text(
			:text('  Settings  —  Tab cycles focus, Ctrl+S save, Ctrl+H about, Ctrl+Q quit'),
			:1size,
			:style{ :fg(0x7AA2F7), :bold }
		);

		Border :4size, {
			VBox {
				Text :text<Name>, :1size, :style{ :fg(0x999999) };
				given TextInput :placeholder('Your display name') {
					.on-change: -> $, $v {
						%form<name>    = $v;
						%form<dirty> ||= True
					}
					.text-silent:  { %form<name> // '' }
					.focus: { !%form<dirty> }
				}
			}
		}

		Border :6size, {
			VBox {
				Text :text<Bio>, :1size, :style{ :fg(0x999999) };
				given MultiLineInput(
					:placeholder('A short bio... (Ctrl+Enter to insert newline, field submits on blur)'),
					:3max-lines,
					:3size
				) {
					.text-silent: { %form<bio> // '' }
					.on-change: -> $, $v {
						%form<bio>     = $v;
						%form<dirty> ||= True;
					}
				}
			}
		}

		Border :4size, {
			VBox {
				Text :text<Preferences>, :1size, :style{ :fg(0x999999) };
				given Checkbox :label('Enable notifications') {
					.check: { %form<notifications> // True }
					.on-change: -> $, $v {
						%form<notifications> = $v;
						%form<dirty> ||= True;
					}
				}
			}
		}

		Border :6size, {
			VBox {
				Text :text<Density>, :1size, :style{ :fg(0x999999) };
				given RadioGroup() {
					.set-items: <Compact Comfortable Spacious>;
					.select: { +%form<density> // 0 }
					.on-change: -> $, $v {
						%form<density>   = $v;
						%form<dirty>   ||= True;
					}
				}
			}
		}

		Border :4size, {
			VBox {
				Text :text<Theme>, :1size, :style{ :fg(0x999999) };
				given Select(:placeholder('Choose a theme')) {
					.set-items: <Auto Light Dark>;
					.select-index: { +%form<theme> // 0 }
					.on-change: -> $, $v {
						%form<theme>   = $v;
						%form<dirty> ||= True;
					}
				}
			}
		}

		HBox :1size, {
			Button.label('Save').on-press: &save;

			Button.label('Reset').on-press: {
				if %form<dirty> {
					ShowModal ConfirmModal(
						:title('Reset form'),
						:message('Discard unsaved changes?'),
						:yes-label('Reset'),
						:no-label('Cancel'),
					).on-result: -> $, $confirmed {
						CloseModal;
						%form = () if $confirmed;
						Tick
					}
				} else {
					%form = ();
					Tick
				}
			}
		}

		Text :style{ :fg(0x888888), :italic }, {
			my ($name, $dirty) = %form<name dirty>;

			do if !$name {
				'  ⚠  Enter a name to enable Save'
			} elsif $dirty {
				"  ● Unsaved changes for '$name' — Ctrl+S to save"
			} else {
				"  ✓ '$name' saved";
			}
		}
	};

	OnKey 'ctrl+s', &save;

	OnKey 'ctrl+h', {
		ShowModal Modal :width-ratio(0.5), :height-ratio(0.3), {
			VBox {
				Text :size(:1fixed), :text('  About this example'), :style{:fg(0x7AA2F7), :bold};
				Text :size(:1fixed), :text('');
				Text :size(:1fixed), :text('  A settings form demonstrating every input widget.');
				Text :size(:1fixed), :text('  Press Esc to close.'), :style{:fg(0x888888), :italic};
				Text :size(:flex),   :text('');
				Button.size(:1fixed).label('OK').on-press: { CloseModal };
			}
		}
	}

	OnKey 'ctrl+q', { Quit }
}

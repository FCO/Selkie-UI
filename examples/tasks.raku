#!/usr/bin/env raku
#
# tasks.raku — Selkie::UI version of the upstream tasks demo
# Run with: raku -I lib examples/tasks.raku
use Selkie::UI;
use Selkie::Style;

$*ERR = open "log.log", :w;
App :start-screen<list>, :run{ $*TEST.not }, {
	my @tasks := new-array-state [
		{ :1id, text => 'Read the Selkie docs',      :done  },
		{ :2id, text => 'Build a tiny TUI',          :!done },
		{ :3id, text => 'Brag about it on Mastodon', :!done },
	];
	my $next-id       := new-state 4;
	my $show-complete := new-state True;
	my @visible-ids   := new-array-state [];
	my $active-screen := new-state 'list';

	sub current-task-id($cursor) {
		@visible-ids[$cursor] // Int
	}

	Screen :name<list>, {
		VBox {
			Text(
				:text('  Tasks  —  Tab focus list, ↑↓ navigate, Enter toggle, d delete, Ctrl+T stats, Ctrl+Q quit'),
				:1size,
				:style{ :fg(0x7AA2F7), :bold }
			);

			Checkbox(:1size, :label('Show completed')).check.on-change: -> $, $v { $show-complete = $v };

			Border :title('Tasks'), {
				given ListView {
					my @filtered = $show-complete
					?? @tasks
					!! @tasks.grep: { !$_<done> }
					@visible-ids = @filtered.map: *<id>;
					@filtered.map: -> %t {
						my $marker = %t<done> ?? '[x]' !! '[ ]';
						"$marker {%t<text>}"
					}
				} {
					.on-activate: -> $list, $ {
						with current-task-id($list.cursor) -> $id {
							my $idx = @tasks.first(*<id> == $id, :k);
							if $idx.defined {
								my %t = @tasks[$idx];
								%t<done> = !%t<done>;
								@tasks[$idx] = %t;
							}
						}
					}
					.on-key: 'd', -> $list, $ {
						with current-task-id($list.cursor) -> $id {
							my $idx = @tasks.first(*<id> == $id, :k);
							with $idx.defined ?? @tasks[$idx] !! Nil -> $task {
								ShowModal ConfirmModal
								title => 'Delete task',
								message => "Delete '{$task<text>}'?",
								yes-label => 'Delete',
								no-label => 'Cancel',
								on-result => -> $, $confirmed {
									CloseModal;
									if $confirmed {
										@tasks = @tasks.grep(*<id> != $id).Array;
										Toast 'Task deleted';
									}
								}
							}
						}
					}
				}
			}

			Border :title<New>, :3size, {
				TextInput(
					:1size,
					:placeholder('Add a task — press Enter to submit'),
				).focus.on-submit: -> $input, $text {
					my $trim = $text.trim;
					if $trim.chars {
						@tasks.push: { id => $next-id++, text => $trim, done => False };
						$input.clear;
					}
				}
			}
		}

	}

	Screen :name<stats>, {
		VBox {
			Text
			:text('  Stats  —  Ctrl+T returns to list, Ctrl+Q quits'),
			:1size,
			:style{ :fg(0x7AA2F7), :bold }

			Text :text(''), :size(:flex);

			Text :5size, :style{ :fg(0xEEEEEE) }, {
				my Int() $total = @tasks;
				my Int() $done  = @tasks.grep: *<done>;
				my Int() $pct   = $total && (100 * $done / $total).round;

				qq:to/END/
				  Total tasks: $total
				  Completed:   $done
				  Remaining:   {$total - $done}
				  Progress:    $pct%
				END
			}

			Text :text(''), :size(:flex);
		}
	}

	OnKey('ctrl+t', {
			if $active-screen eq 'list' {
				$active-screen = 'stats';
				SwitchScreen('stats');
			} else {
				$active-screen = 'list';
				SwitchScreen('list');
			}
	});

	OnKey('ctrl+q', { Quit });
}

#!/usr/bin/env raku
#
# dashboard.raku — Selkie::UI version of the upstream dashboard demo
# Run with: raku -I lib examples/dashboard.raku
use Selkie::UI;
use Selkie::Sizing;
use Selkie::Style;

$*ERR = $*OUT = open "log.log", :w;

sub seed-servers(Bool :$jitter) {
	my @rows = (
		{
			:host<api-1.example.com>, :status<up>, uptime => 87_200, :12latency,
			:history[12, 11, 13, 12, 14, 13, 12, 15, 13, 12, 14, 12, 13, 14, 13, 12, 13, 12, 14, 12]
		},
		{
			:host<api-2.example.com>, :status<up>, uptime => 12_350, :18latency,
			:history[15, 17, 19, 20, 22, 19, 18, 20, 18, 17, 19, 18, 16, 17, 18, 19, 20, 18, 19, 18]
		},
		{
			:host<db-primary>, :status<up>, uptime => 432_100, :3latency,
			:history[3, 2, 3, 3, 4, 3, 2, 3, 3, 4, 3, 3, 2, 3, 3, 4, 3, 3, 2, 3]
		},
		{
			:host<db-replica-1>, :status<up>, uptime => 418_900, :4latency,
			:history[4, 3, 4, 5, 4, 3, 4, 4, 3, 4, 5, 4, 3, 4, 4, 5, 4, 3, 4, 4]
		},
		{
			:host<cache-1>, :status<down>, uptime => 0, :0latency,
			:history[8, 9, 7, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
		},
		{
			:host<queue-worker-1>, :status<up>, uptime => 56_700, :8latency,
			:history[7, 8, 9, 8, 7, 8, 9, 10, 8, 7, 8, 9, 8, 7, 8, 9, 8, 7, 8, 8]
		},
		{
			:host<queue-worker-2>, :status<warn>, uptime => 56_700, :142latency,
			:history[12, 15, 20, 35, 55, 78, 92, 115, 138, 142, 150, 145, 140, 142, 139, 144, 142, 141, 143, 142]
		},
		{
			:host<batch-runner>, :status<up>, uptime => 201_400, :22latency,
			:history[20, 22, 25, 22, 20, 22, 24, 22, 23, 22, 21, 22, 24, 22, 23, 22, 22, 21, 23, 22]
		},
	);
	if $jitter {
		@rows = @rows.map({
				my $l = .<latency>;
				my $new-l = $l == 0 ?? 0 !! $l + ((-1, 0, 1).pick);
				my @h = .<history>.list;
				my @shifted = @h.tail(@h.elems - 1).Array;
				@shifted.push: $new-l;
				%(|$_, latency => $new-l, history => @shifted);
		}).Array;
	}
	@rows;
}

sub sparkline-str(@values --> Str) {
	return '' unless @values;
	my @levels = '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█';
	my @clean = @values.grep: { .defined && $_ !=== NaN };
	return ' ' x @values.elems unless @clean;
	my $lo = @clean.min;
	my $hi = @clean.max;
	if $lo == $hi {
		return '▄' x @values.elems;
	}
	@values.map(-> $v {
			if !$v.defined || $v === NaN {
				' ';
			} else {
				my $t = ($v - $lo) / ($hi - $lo);
				my $idx = ($t * 7).round.Int;
				$idx = 0 if $idx < 0;
				$idx = 7 if $idx > 7;
				@levels[$idx];
			}
	}).join;
}

sub seed-tasks() {
	[
		{ title => 'Upgrade Rakudo to 2026.03', done => True  },
		{ title => 'Publish Selkie 0.2.0',       done => False },
		{ title => 'Write dashboard example',    done => False },
		{ title => 'Record demo GIF',            done => False },
		{ title => 'Update website landing',     done => False },
	];
}

sub human-uptime(Int $s --> Str) {
	given $s {
		when 0          { '—' }
		when * < 60     { "{$s}s" }
		when * < 3600   { "{($s / 60).floor}m" }
		when * < 86_400 { "{($s / 3600).floor}h" }
		default         { "{($s / 86_400).floor}d" }
	}
}

sub status-cell(Str $s --> Str) {
	given $s {
		when 'up'   { '✓ up' }
		when 'down' { '✗ down' }
		when 'warn' { '⚠ warn' }
		default     { $s }
	}
}

App {
	my $active-tab := new-state 'servers';
	my @servers    := new-array-state seed-servers();
	my @tasks      := new-array-state seed-tasks();
	my $polling    := new-state True;
	my @log-lines  := new-array-state ['--- dashboard started ---'];

	my $spinner;

	VBox {
		Text(
			:text('  Selkie Dashboard  —  Tab cycles focus, Ctrl+P palette, Ctrl+Q quit'),
			:1size,
			:style{ :fg(0x7AA2F7), :bold }
		);

		TabBar :active-tab{ $active-tab }, :1size, {
			.focus;
			Tab :name<servers>, :label<Servers>, {
				Table :size(:flex), :columns[
					%(
						:name<host>,
						:label<Host>,
						:2flex,
						:sortable
					),
					%(
						:name<status>,
						:label<Status>,
						:8size,
						:sortable,
						:render(&status-cell)
					),
					%(
						:name<uptime>,
						:label<Uptime>,
						:8size,
						:sortable,
						:render(-> $s { human-uptime($s) }),
						:sort-key(-> $s { $s })
					),
					%(
						:name<latency>,
						:label<Latency>,
						:10size,
						:sortable,
						:render(-> $ms { $ms == 0 ?? '—' !! "{$ms}ms" }),
						:sort-key(-> $ms { $ms })
					),
					%(
						:name<history>,
						:label<History>,
						:20size,
						:render(-> @h { sparkline-str(@h) })
					),
				], {
					.on-activate: -> $_, $idx {
						my $row = .row-at: $idx;
						Toast "Host: {$row<host>} — {$row<status>}" if $row;
					}

					.on-key: 's', -> $_, $ {
						my @sortable = .columns.grep: *.sortable;
						if @sortable {
							my $current = .sort-column;
							my $idx = $current.defined
							?? (@sortable.first(*.name eq $current, :k) // -1)
							!! -1;
							my $next = @sortable[($idx + 1) mod @sortable.elems];
								.sort-by: $next.name;
						}
					}

					@servers
				}
			}
			Tab :name<tasks>, :label<Tasks>,   {
				ListView :size(:flex), {
					.on-activate: -> $_, $ {
						if @tasks {
							with .cursor -> $idx {
								my %task = @tasks[$idx];
								%task<done> = !%task<done>;
								@tasks[$idx] = %task;
							}
						}
					}
					@tasks.map: -> %t {
						my $mark = %t<done> ?? '[x]' !! '[ ]';
						"$mark {%t<title>}";
					}
				}
			}
			Tab :name<logs>,    :label<Logs>,    {
				TextStream.size(:flex).max-lines(1000).append: {
					state Int() $last-size //= @log-lines;
					.clear if $last-size >= @log-lines;
					$last-size = @log-lines;
					@log-lines.elems ?? @log-lines[* - 1] !! ''
				}
			}

			Border :title<Servers>, :size(:flex);
		}

		HBox :1size, {
			$spinner = Spinner.braille.interval(0.15).size(1);
			Text {
				my $indicator = $polling ?? 'polling' !! 'paused';
				my $n-servers = @servers.elems;
				"  $indicator  —  monitoring $n-servers servers";
			}
		}
	}

	sub refresh-servers(Bool :$toast = False) {
		@servers = seed-servers(:jitter).Array;
		Toast 'Servers refreshed' if $toast;
	}

	OnKey 'ctrl+p', {
		unless $*UI-APP.obj.has-modal {
			ShowModal Modal CommandPalette :build, {
				.on-command: -> $, $_ {
					CloseModal;
					.action.() if .defined;
				}

				(
					'Go to Servers'   => -> { $active-tab = 'servers' },
					'Go to Tasks'     => -> { $active-tab = 'tasks'   },
					'Go to Logs'      => -> { $active-tab = 'logs'    },
					'Refresh servers' => -> { refresh-servers(:toast) },
					'Toggle polling'  => -> { $polling = !$polling    },
					'Quit'            => -> { Quit                    },
				)
			}
		}
	}

	OnKey 'ctrl+q', { Quit }
	OnKey 'ctrl+r', { refresh-servers :toast }
	OnKey 'ctrl+l', {
		@log-lines = ['--- logs cleared ---'];
		Toast 'Logs cleared';
	}
	OnKey 'ctrl+space', { $polling = !$polling }

	OnFrame {
		state $frame //= 0;
		$frame++;
		if $polling {
			$spinner.tick;
			if $frame %% 180 {
				@log-lines.push: sprintf '[%s]  polled %d servers', DateTime.now.hh-mm-ss, @servers.elems;
				refresh-servers;
			}
		}
	}

}

#!/usr/bin/env raku
#
# dashboard.raku — Selkie::UI version of the upstream dashboard demo
# Run with: raku -I lib examples/dashboard.raku
use Selkie::UI;
use Selkie::Sizing;
use Selkie::Style;

sub seed-servers(Bool :$jitter) {
	my @rows = (
		{ host => 'api-1.example.com',  status => 'up',   uptime => 87_200,  latency => 12,  history => [12, 11, 13, 12, 14, 13, 12, 15, 13, 12, 14, 12, 13, 14, 13, 12, 13, 12, 14, 12] },
		{ host => 'api-2.example.com',  status => 'up',   uptime => 12_350,  latency => 18,  history => [15, 17, 19, 20, 22, 19, 18, 20, 18, 17, 19, 18, 16, 17, 18, 19, 20, 18, 19, 18] },
		{ host => 'db-primary',         status => 'up',   uptime => 432_100, latency => 3,   history => [3, 2, 3, 3, 4, 3, 2, 3, 3, 4, 3, 3, 2, 3, 3, 4, 3, 3, 2, 3] },
		{ host => 'db-replica-1',       status => 'up',   uptime => 418_900, latency => 4,   history => [4, 3, 4, 5, 4, 3, 4, 4, 3, 4, 5, 4, 3, 4, 4, 5, 4, 3, 4, 4] },
		{ host => 'cache-1',            status => 'down', uptime => 0,       latency => 0,   history => [8, 9, 7, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0] },
		{ host => 'queue-worker-1',     status => 'up',   uptime => 56_700,  latency => 8,   history => [7, 8, 9, 8, 7, 8, 9, 10, 8, 7, 8, 9, 8, 7, 8, 9, 8, 7, 8, 8] },
		{ host => 'queue-worker-2',     status => 'warn', uptime => 56_700,  latency => 142, history => [12, 15, 20, 35, 55, 78, 92, 115, 138, 142, 150, 145, 140, 142, 139, 144, 142, 141, 143, 142] },
		{ host => 'batch-runner',       status => 'up',   uptime => 201_400, latency => 22,  history => [20, 22, 25, 22, 20, 22, 24, 22, 23, 22, 21, 22, 24, 22, 23, 22, 22, 21, 23, 22] },
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

	my $servers-table = Detached { Table.size(:flex) };
	$servers-table.add-column(:name<host>, :label('Host'), :sizing(Sizing.flex(2)), :sortable);
	$servers-table.add-column(:name<status>, :label('Status'), :sizing(Sizing.fixed(8)), :sortable,
		:render(&status-cell));
	$servers-table.add-column(:name<uptime>, :label('Uptime'), :sizing(Sizing.fixed(8)), :sortable,
		:render(-> $s { human-uptime($s) }), :sort-key(-> $s { $s }));
	$servers-table.add-column(:name<latency>, :label('Latency'), :sizing(Sizing.fixed(10)), :sortable,
		:render(-> $ms { $ms == 0 ?? '—' !! "{$ms}ms" }), :sort-key(-> $ms { $ms }));
	$servers-table.add-column(:name<history>, :label('History'), :sizing(Sizing.fixed(20)),
		:render(-> @h { sparkline-str(@h) }));
	$servers-table.rows: { @servers.list };

	my $tasks-list = Detached { ListView.size(:flex) };
	$tasks-list.set-items: {
		@tasks.map(-> %t {
			my $mark = %t<done> ?? '[x]' !! '[ ]';
			"$mark {%t<title>}";
		}).Array;
	};

	my $logs-stream = Detached { TextStream.max-lines(1000) };
	$logs-stream.append: { @log-lines.elems ?? @log-lines[* - 1] !! '' };
	$logs-stream.size(:flex);

	my $tabs;
	my $content;
	my $spinner;
	my $status;

	VBox {
		Text(:text('  Selkie Dashboard  —  Tab cycles focus, Ctrl+P palette, Ctrl+Q quit'),
			:1size,
			:style(:fg(0x7AA2F7), :bold));

		$tabs = TabBar;
		$tabs.add-tab(:name<servers>, :label('Servers'))
			.add-tab(:name<tasks>, :label('Tasks'))
			.add-tab(:name<logs>, :label('Logs'));

		$content = Border :title<Servers>, :size(:flex);

		HBox :1size, {
			$spinner = Spinner.braille.interval(0.15).size(1);
			$status = Text.text: {
				my $indicator = $polling ?? 'polling' !! 'paused';
				my $n-servers = @servers.elems;
				"  $indicator  —  monitoring $n-servers servers";
			};
		};
	};

	$content.content: $servers-table, :!destroy;

	sub set-active-tab(Str $name) {
		$active-tab = $name;
		$tabs.set-active-name-silent($name);
		given $name {
			when 'servers' {
				$content.title: 'Servers';
				$content.content: $servers-table, :!destroy;
			}
			when 'tasks' {
				$content.title: 'Tasks';
				$content.content: $tasks-list, :!destroy;
			}
			when 'logs' {
				$content.title: 'Logs';
				$content.content: $logs-stream, :!destroy;
			}
		}
	}

	$tabs.on-tab-selected: -> $_, $name { set-active-tab $name };
	set-active-tab($active-tab);

	$servers-table.on-activate: -> $_, $idx {
		my $row = $servers-table.row-at: $idx;
		Toast "Host: {$row<host>} — {$row<status>}" if $row;
	};

	$servers-table.on-key('s', -> $_, $ {
		my @sortable = $servers-table.columns.grep: *.sortable;
		if @sortable {
			my $current = $servers-table.sort-column;
			my $idx = $current.defined
				?? (@sortable.first(*.name eq $current, :k) // -1)
				!! -1;
			my $next = @sortable[($idx + 1) mod @sortable.elems];
			$servers-table.sort-by: $next.name;
		}
	});

	$tasks-list.on-activate: -> $_, $ {
		my $idx = $tasks-list.cursor;
		return unless $idx.defined;
		my %task = @tasks[$idx];
		%task<done> = !%task<done>;
		@tasks[$idx] = %task;
	};

	sub refresh-servers(Bool :$toast = False) {
		@servers = seed-servers(:jitter).Array;
		Toast 'Servers refreshed' if $toast;
	}

	sub append-log(Str $line) {
		@log-lines.push($line);
	}

	sub build-palette() {
		my $palette = Detached { CommandPalette };
		$palette.add-command(-> { set-active-tab('servers') }, :label('Go to Servers'))
			.add-command(-> { set-active-tab('tasks') }, :label('Go to Tasks'))
			.add-command(-> { set-active-tab('logs') }, :label('Go to Logs'))
			.add-command(-> { refresh-servers(:toast) }, :label('Refresh servers'))
			.add-command(-> { $polling = !$polling }, :label('Toggle polling'))
			.add-command(-> { Quit }, :label('Quit'));
		$palette.on-command: -> $_, $cmd {
			CloseModal;
			$cmd.action.() if $cmd.defined;
		};
		$palette
	}

	OnKey('ctrl+p', {
		unless $*UI-APP.obj.has-modal {
			my $palette = build-palette();
			ShowModal $palette.modal;
			Focus $palette.focusable-widget;
		}
	});

	OnKey('ctrl+q', { Quit });
	OnKey('ctrl+r', {
		refresh-servers(:toast);
	});
	OnKey('ctrl+l', {
		@log-lines = ['--- logs cleared ---'];
		Toast 'Logs cleared';
	});
	OnKey('ctrl+space', { $polling = !$polling });

	my UInt $frame = 0;
	OnFrame {
		$frame++;
		if $polling {
			$spinner.tick;
			if $frame %% 180 {
				append-log sprintf '[%s]  polled %d servers', DateTime.now.hh-mm-ss, @servers.elems;
				refresh-servers;
			}
		}
	};

	Focus($tabs);
}

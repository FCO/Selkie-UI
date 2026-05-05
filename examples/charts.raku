#!/usr/bin/env raku
#
# charts.raku — Selkie::UI version of the upstream charts demo
# Run with: raku -I lib examples/charts.raku
# Quit with: Ctrl+Q
use Selkie::UI;
use Selkie::Sizing;
use Selkie::Style;

unless $*IN.t && $*OUT.t {
	note 'charts.raku requires a TTY. Run it in a terminal.';
	exit 1;
}

constant WINDOW-SIZE = 60;
sub seed-samples(&fn --> List) {
	(^WINDOW-SIZE).map({ fn($_) }).list;
}

my @heatmap-data = (^8).map: -> $r {
	(^16).map: -> $c {
		sin($r * 0.5) + cos($c * 0.4);
	}
}

my @scatter-points;
for ^200 {
	my $cluster = rand < 0.5;
	my $cx = $cluster ?? 25 !! 75;
	my $cy = $cluster ?? 25 !! 75;
	my $x = $cx + (rand * 20 - 10);
	my $y = $cy + (rand * 20 - 10);
	@scatter-points.push: $x => $y;
}

App {
	sub shift-append(@buf, Int $v --> List) {
		|@buf.tail(WINDOW-SIZE - 1), $v
	}

	my $tick := new-state 0;
	my @load := new-array-state seed-samples -> $i { (sin($i * 0.3) * 30 + 50).Int }
	my @p50  := new-array-state (^WINDOW-SIZE).map: { (sin($_ * 0.2 + 1) * 20 + 30).Int }
	my @p99  := new-array-state (^WINDOW-SIZE).map: {
		my $gap = (cos($_ * 0.11) * 15 + 25).Int.abs;
		(@p50[$_] + $gap) min 95;
	}
	my $plot;

	VBox {
		Text(
			:text('  Selkie charts showcase  —  Ctrl+Q quits'),
			:1size,
			:style{ :fg(0x7AA2F7), :bold },
		);

		HBox :1size, {
			Text :text('load: '), :6size, :style{ :fg(0x808080) }
			Sparkline(:0min, :100max).data({ @load }).size(:flex);
		}

		Border :title('LineChart — latency percentiles (live)'), {
			LineChart(
				:series[
					{ :label<p50>, :values[], :color(0x4477AA) },
					{ :label<p99>, :values[], :color(0xEE6677) },
				],
				:0y-min,
				:100y-max,
				:!fill-below,
			).series: {
				[
					{ :label<p50>, values => @p50.list, :color(0x4477AA) },
					{ :label<p99>, values => @p99.list, :color(0xEE6677) },
				]
			}
		}

		HBox :14size, {
			Border :title('BarChart — quarterly sales'), {
				BarChart :data[
					{ label => 'Q1', value =>  50 },
					{ label => 'Q2', value =>  80 },
					{ label => 'Q3', value =>  65 },
					{ label => 'Q4', value => 100 },
				]
			}
			Border :title('Histogram — gaussian samples'), {
				Histogram(
					:values((^1000).map({ 5 + 5 * sqrt(-2 * log(rand)) * cos(2 * pi * rand) })),
					:bins(12),
				);
			}
			Border :title('Heatmap — sin(r) + cos(c)'), {
				Heatmap :data(@heatmap-data), :ramp<viridis>
			}
		}

		HBox :size(:flex), {
			Border :title('Plot — streaming ncuplot'), {
				$plot = Plot(:type<uint>, :0min-y, :100max-y, :title<cpu%>);
			}
			Border :title('ScatterPlot — two clusters'), {
				ScatterPlot
				:series[{ :label<clusters>, points => @scatter-points }],
				:0x-min, :100x-max,
				:0y-min, :100y-max,
			}
		}
	}

	my UInt $frame = 0;
	OnFrame {
		$frame++;
		if $frame %% 4 {
			my $t = $tick + 1;
			my $load-sample = (sin($t * 0.3) * 30 + 50).Int;
			my $p50-sample  = (sin($t * 0.2 + 1) * 20 + 30).Int;
			my $gap         = (cos($t * 0.11) * 15 + 25).Int.abs;
			my $p99-sample  = ($p50-sample + $gap) min 95;
			$tick           = $t;
			@load           = shift-append(@load, $load-sample);
			@p50            = shift-append(@p50, $p50-sample);
			@p99            = shift-append(@p99, $p99-sample);
			my $y           = (sin($t * 0.15) * 40 + 50).Int;
			$plot.push-sample($t, $y);
		}
	}

	OnKey 'ctrl+q', -> $ { Quit };
	Tick;
}

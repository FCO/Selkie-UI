#!/usr/bin/env raku
#
# charts.raku — Selkie::UI version of charts demo
# Run with: raku -I lib examples/charts.raku
# Quit with: Ctrl+Q
use Selkie::UI;

unless $*IN.t && $*OUT.t {
    note 'charts.raku requires a TTY. Run it in a terminal.';
    exit 1;
}

constant WINDOW-SIZE = 60;
sub seed-samples(&fn --> List) {
    (^WINDOW-SIZE).map({ fn($_) }).list;
}
# Precompute heatmap + scatter data
my @heatmap-data = (^8).map(-> $r {
    (^16).map(-> $c {
        sin($r * 0.5) + cos($c * 0.4);
    }).list;
}).list;
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
    $*ERR = open "log.log", :w;
    sub shift-append(@buf, Int $v --> List) {
        (|@buf.tail(WINDOW-SIZE - 1), $v).list;
    }
    my @p50 = (^WINDOW-SIZE).map({ (sin($_ * 0.2 + 1) * 20 + 30).Int });
    my @p99 = (^WINDOW-SIZE).map({
        my $gap = (cos($_ * 0.11) * 15 + 25).Int.abs;
        (@p50[$_] + $gap) min 95;
    });
    my $tick := new-state 0;
    my $load := new-state seed-samples(-> $i { (sin($i * 0.3) * 30 + 50).Int });
    my $latency := new-state [@p50, @p99];
    my $plot;
    VBox {
        Text(:text('  Selkie charts showcase  —  Ctrl+Q quits'),
            :1size,
            :style(:fg(0x7AA2F7), :bold));
            HBox :1size, {
            Text(:text('load: '), :6size, :style(:fg(0x808080)));
            Sparkline(:0min, :100max)
                .data(-> $ { $load })
                .size(:flex);
        }
        Border(:title('LineChart — latency percentiles (live)')).content: {
            LineChart(
                :series([
                    { label => 'p50', values => [], color => 0x4477AA },
                    { label => 'p99', values => [], color => 0xEE6677 },
                ]),
                :0y-min,
                :100y-max,
                :!fill-below,
            ).series(-> $ {
                [
                    { label => 'p50', values => $latency[0], color => 0x4477AA },
                    { label => 'p99', values => $latency[1], color => 0xEE6677 },
                ]
            });
        }
        HBox({
            Border(:title('BarChart — quarterly sales')).content: {
                BarChart(:data([
                    { label => 'Q1', value =>  50 },
                    { label => 'Q2', value =>  80 },
                    { label => 'Q3', value =>  65 },
                    { label => 'Q4', value => 100 },
                ]));
            }
            Border(:title('Histogram — gaussian samples')).content: {
                Histogram(
                    :values((^1000).map({ 5 + 5 * sqrt(-2 * log(rand)) * cos(2 * pi * rand) })),
                    :bins(12),
                );
            }
            Border(:title('Heatmap — sin(r) + cos(c)')).content: {
                Heatmap(:data(@heatmap-data), :ramp('viridis'));
            }
        }, :size(14));
        HBox :size(:flex), {
            Border(:title('Plot — streaming ncuplot')).content: {
                $plot = Plot(:type<uint>, :0min-y, :100max-y, :title<cpu%>);
            }
            Border(:title('ScatterPlot — two clusters')).content: {
                ScatterPlot(
                    :series[{ :label<clusters>, points => @scatter-points }],
                    :0x-min, :100x-max,
                    :0y-min, :100y-max,
                );
            }
        }
    }
    # --- Frame loop --------------------------------------------------------
    my UInt $frame = 0;
    OnFrame {
        $frame++;
        if $frame %% 4 {
            my $t           = $tick + 1;
            my $load-sample = (sin($t * 0.3) * 30 + 50).Int;
            my $p50-sample  = (sin($t * 0.2 + 1) * 20 + 30).Int;
            my $gap         = (cos($t * 0.11) * 15 + 25).Int.abs;
            my $p99-sample  = ($p50-sample + $gap) min 95;
            my @next-p50    = shift-append($latency[0], $p50-sample);
            my @next-p99    = shift-append($latency[1], $p99-sample);
            $tick           = $t;
            $load           = shift-append($load, $load-sample);
            $latency        = [@next-p50, @next-p99];
            my $y           = (sin($t * 0.15) * 40 + 50).Int;
            $plot.push-sample($t, $y);
        }
    };
    # --- Keybinds ----------------------------------------------------------
    OnKey 'ctrl+q', -> $ { Quit };
    Tick;
}

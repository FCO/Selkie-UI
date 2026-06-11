#!/usr/bin/env raku
#
# job-runner.raku — Selkie::UI version of the upstream job runner demo
# Run with: raku -I lib examples/job-runner.raku
use Selkie::UI;
use Selkie::Style;
use Selkie::Sizing;

$*OUT = $*ERR = open "log.log", :w;
App :run{ $*TEST.not }, {
	constant TOTAL-STEPS = 8;

	my $running     := new-state False;
	my $step        := new-state 0;
	my $log-message := new-state Str;

	my $spinner;

	VBox {
		given Text(:text('  Job Runner  —  s: start, Ctrl+Q: quit')) {
			.size: 1;
			.style: :fg(0x7AA2F7), :bold;
		}

		Border :title<Progress>, :6size, {
			VBox :4size, {
				given $spinner = ProgressBar() {
					.size: 1;
					.show-percentage: False;
					.frames-per-step: 4;
					.indeterminate: { $running }
				}
				ProgressBar(:1size).show-percentage.progress: { $step / TOTAL-STEPS };
			}
		}

		Border :title<Log>, :size(:flex), {
			given TextStream() {
				.max-lines: 1000;
				.append: 'Press s (or focus and Enter on the button) to start.';
				.append: { $log-message };
			}
		};

		HBox :1size, {
			Button.label('Start job').on-press: {
				$log-message = '--- starting job ---';
				$running = True;
				$step = 0;
			};
		};
	};

	OnKey('s', {
			$log-message = '--- starting job ---';
			$running = True;
			$step = 0;
	});

	my UInt $frame = 0;
	OnFrame {
		$frame++;
		if $running {
			$spinner.tick;
			if $frame %% 24 {
				$step++;
				$log-message = "  step $step / {TOTAL-STEPS} complete";
				if $step >= TOTAL-STEPS {
					$log-message = '--- job done ---';
					$running = False;
				}
			}
		}
	}

	OnKey('ctrl+q', { Quit });
}

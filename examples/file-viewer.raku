#!/usr/bin/env raku
#
# file-viewer.raku — Selkie::UI version of the upstream file viewer demo
# Run with: raku -I lib examples/file-viewer.raku
use Selkie::UI;
use Selkie::Style;
use Selkie::Sizing;

$*OUT = $*ERR = open "log.log", :w;
App :run{ $*TEST.not }, {
	my $current-path         := new-state '';
	my $kind                 := new-state 'none';
	my $text                 := new-state '';
	my $error                := new-state '';
	my $needs-preview-update := new-state True;

	sub open-path(Str $path) {
		$current-path = $path;
		my $ext = $path.IO.extension.lc;
		if $ext eq any(<png jpg jpeg gif bmp>) {
			$kind = 'image';
			$text = '';
			$error = '';
		} else {
			my $content = try { $path.IO.slurp };
			if $content {
				$kind = 'text';
				$text = $content;
				$error = '';
			} else {
				$kind = 'error';
				$text = '';
				$error = "Could not read $path";
			}
		}
		$needs-preview-update = True;
	}

	my $scroll;

	sub open-browser(|) {
		FileBrowser
		:show-modal,
		:focus,
		on-select => -> $, $path {
			CloseModal;
			open-path $path;
			Focus $scroll;
		},
		{
			%(
				extensions => <txt md rakudoc raku rakumod rakutest json png jpg jpeg gif>,
				show-dotfiles => False,
				width-ratio => 0.7,
				height-ratio => 0.7,
			)
		}
	}

	VBox :size(:flex), {
		Text :text('  File Viewer  —  o: open, Ctrl+Q: quit'), :1size, :style(:fg(0x7AA2F7), :bold);

		Split :orientation<vertical>, :ratio(0.15), :size(:flex), {
			Border :size(:flex), :title<Current>, {
				VBox :size(:flex), {
					Text :1size, {
						$current-path.chars
						?? "  $current-path"
						!! '  (no file — press o to open)'
					}
					Button(
						:label('Open file...'),
						:1size,
						:style{:fg(0x888888), :italic}
					).on-press: &open-browser
				}
			}
			Border :size(:flex), :title<Preview>, {
				VBox :size(:flex), {
					Image      :size{ $kind eq "image" ?? :flex !! 0 }, { $current-path }
					ScrollView(:size{ $kind eq "text"  ?? :flex !! 0 }, {
							$scroll = $_;
							Text { $text }
					});
					Text       :size{ $kind eq "error" ?? :flex !! 0 }, { "  {$error}" };
					Text       :size{ $kind eq "none"  ?? :flex !! 0 }, :text('  No file loaded.');
				}
			}
		}
	}

	OnKey 'o', { open-browser }

	OnKey 'ctrl+q', { Quit }
}

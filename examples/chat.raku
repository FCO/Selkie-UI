#!/usr/bin/env raku
use Selkie::UI;
use Selkie::Style;
use Selkie::Theme;

sub dark-theme(--> Selkie::Theme) {
    Selkie::Theme.new(
        base              => Selkie::Style.new(fg => 0xEEEEEE, bg => 0x16162E),
        text              => Selkie::Style.new(fg => 0xEEEEEE),
        text-dim          => Selkie::Style.new(fg => 0x888899),
        text-highlight    => Selkie::Style.new(fg => 0xFFFFFF, bold => True),
        border            => Selkie::Style.new(fg => 0x444466),
        border-focused    => Selkie::Style.new(fg => 0x7AA2F7, bold => True),
        input             => Selkie::Style.new(fg => 0xEEEEEE, bg => 0x1A1A2E),
        input-focused     => Selkie::Style.new(fg => 0xFFFFFF, bg => 0x2A2A3E),
        input-placeholder => Selkie::Style.new(fg => 0x606080, italic => True),
        scrollbar-track   => Selkie::Style.new(fg => 0x333344),
        scrollbar-thumb   => Selkie::Style.new(fg => 0x7AA2F7),
        divider           => Selkie::Style.new(fg => 0x444466),
        tab-active        => Selkie::Style.new(fg => 0xFFFFFF, bg => 0x7AA2F7, bold => True),
        tab-inactive      => Selkie::Style.new(fg => 0x8888A0, bg => 0x16162E),
    );
}

sub light-theme(--> Selkie::Theme) {
    Selkie::Theme.new(
        base              => Selkie::Style.new(fg => 0x222222, bg => 0xF5F5F0),
        text              => Selkie::Style.new(fg => 0x222222),
        text-dim          => Selkie::Style.new(fg => 0x666666),
        text-highlight    => Selkie::Style.new(fg => 0x000000, bold => True),
        border            => Selkie::Style.new(fg => 0xCCCCCC),
        border-focused    => Selkie::Style.new(fg => 0x3366CC, bold => True),
        input             => Selkie::Style.new(fg => 0x222222, bg => 0xFFFFFF),
        input-focused     => Selkie::Style.new(fg => 0x000000, bg => 0xEEEEFF),
        input-placeholder => Selkie::Style.new(fg => 0x999999, italic => True),
        scrollbar-track   => Selkie::Style.new(fg => 0xDDDDDD),
        scrollbar-thumb   => Selkie::Style.new(fg => 0x3366CC),
        divider           => Selkie::Style.new(fg => 0xCCCCCC),
        tab-active        => Selkie::Style.new(fg => 0xFFFFFF, bg => 0x3366CC, bold => True),
        tab-inactive      => Selkie::Style.new(fg => 0x666688, bg => 0xF5F5F0),
    );
}

App {
	my $messages := new-state [
		{
			speaker => 'bot',
			text => 'Hello! Type something and I will echo it back, transformed.'
		},
	];
	my $dark := new-state True;
	.theme: { $dark ?? dark-theme() !! light-theme() }

	VBox {
		Border :title<Chat>, {
			CardList.set-items: {
				$messages.map: -> %message {
					my $speaker = (%message<speaker> // 'unknown').Str;
					my $text = (%message<text> // '').Str;
					my $is-bot = $speaker eq 'bot';
					my $name-style = Selkie::Style.new(
						fg => $is-bot ?? 0x9ECE6A !! 0x7AA2F7,
						:bold,
					);
					my $body-style = Selkie::Style.new(fg => 0xEEEEEE);
					my $rich = RichText.content([
						{ text => "$speaker: ", style => $name-style },
						{ text => $text,        style => $body-style },
					]);
					my $card = Border;
					$card.content($rich);
					{
						widget => $rich,
						root => $card,
						border => $card,
						height => 3,
					}
				}
			};
		}
		Border :title<Compose>, {
			MultiLineInput.placeholder('Type a message — Ctrl+Enter to send')
				.on-submit: -> $input, $text {
					if $text.trim {
						my $trim = $text.trim;
						my $reply = $trim.flip;
						$messages = [
							|$messages,
							{ speaker => 'you', text => $trim },
							{ speaker => 'bot', text => "Reversed: $reply" },
						];
						$input.clear;
					}
				};
		}
	}
	OnKey 'ctrl+l', {
		$messages = [];
		Toast 'Cleared';
	};
	OnKey 'ctrl+t', {
		$dark = !$dark;
		Toast 'Theme toggled';
	};
	OnKey 'ctrl+q', { Quit };
}

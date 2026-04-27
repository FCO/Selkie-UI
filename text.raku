use Selkie::UI;
App {
	VBox {
		my $stream = TextStream;
		TextInput(:placeholder('Type here...')).size.on-submit: -> $_, $text {
			$stream.append: $text;
			.clear
		}
	}
}

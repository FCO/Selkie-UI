use Selkie::UI;
App {
	my $next-msg := new-state Str;
	VBox {
		TextStream.append: { $next-msg };
		TextInput(:placeholder('Type here...')).size(1).on-submit: -> $input, $text {
			$next-msg = $text;
			$input.clear
		}
	}
}

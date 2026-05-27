use Selkie::UI;
App :run{ $*TEST.not }, {
	my $next-msg := new-state Str;
	VBox {
		TextStream.append: { $next-msg };
		TextInput(:placeholder('Type here...')).size(1).on-submit: -> $input, $text {
			$next-msg = $text;
			$input.clear
		}
	}
}

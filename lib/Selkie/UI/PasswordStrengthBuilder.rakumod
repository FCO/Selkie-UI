use Selkie::UI::Base;
use Selkie::Widget::PasswordStrength;
use Selkie::Widget::TextInput;

unit class Selkie::UI::PasswordStrengthBuilder is Selkie::UI::Base;

has Selkie::Widget::TextInput $.input is required;
has Bool $.show-label;
has Selkie::Widget::PasswordStrength $.obj;

submethod TWEAK() {
	$!obj = Selkie::Widget::PasswordStrength.new(
		input => $!input,
		|(:$!show-label with $!show-label),
	);
	self
}

method score(--> UInt) { $!obj.score }

method label(--> Str) { $!obj.label }

use Selkie::UI::Base;
use Selkie::Widget::TextStream;
use Selkie::UI::Helpers;

unit class Selkie::UI::TextStreamBuilder is Selkie::UI::Base;

has Selkie::Widget::TextStream $.obj .= new;
has &.block;

submethod TWEAK(:&block, |) {
	self.append: $_ with &block
}

method max-lines(UInt $lines) {
	$!obj.^attributes.first(*.name eq '$!max-lines').set_value: $!obj, $lines;
	self
}

multi method append(&text) {
	$.auto-subscribe: "append", with-ui-context { self.append: text self }
}

multi method append(Str() $text) {
	$!obj.append: $text with $text;
	self
}

multi method clear(&block) {
	$.auto-subscribe: "clear", with-ui-context { self.clear: block self }
}

multi method clear(Bool() $clear = True) {
	$!obj.clear if $clear;
	self
}

=begin pod

=head1 Selkie::UI::TextStreamBuilder

Builder for a streaming text output widget. Displays text lines with an
optional maximum line count.

=head2 Methods

=head3 C<max-lines(UInt $lines)>

Limits the number of visible lines. Older lines are trimmed when exceeded.

=head3 C<append(Str $text)> / C<append(&text)>

Appends text to the stream. The block variant supports reactive subscriptions:
C<append { "Count: $counter" }>.

=head3 C<clear(Bool $clear = True)> / C<clear(&block)>

Clears all text from the stream. The block variant supports reactive subscriptions.

=end pod

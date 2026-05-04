use Selkie::UI::Base;
use Selkie::Widget::RichText;
use Selkie::Style;
use Selkie::UI::Helpers;

unit class Selkie::UI::RichTextBuilder is Selkie::UI::Base;

has Bool $.truncated-top;
has Bool $.truncated-bottom;
has Selkie::Widget::RichText $.obj .= new:
	|(:$!truncated-top with $!truncated-top),
	|(:$!truncated-bottom with $!truncated-bottom);

	multi method content(@spans) {
		my @converted = @spans.map: -> $s {
			given $s {
				when Selkie::Widget::RichText::Span { $s }
				when Hash|Map {
					my $text = $s<text> // '';
					my $style = $s<style> // Selkie::Style.new;
					$style = Selkie::Style.new(|$style) if $style ~~ Hash|Map;
					Selkie::Widget::RichText::Span.new(:$text, :$style)
				}
				default { $s }
			}
		};
	$!obj.set-content(@converted);
	self
}

multi method content(&block) {
	$.auto-subscribe: "content", with-ui-context $*UI-APP, $*UI-PARENT, { self.content: block self }
}

method truncated-top(Bool $value = True) {
	$!obj.truncated-top = $value;
	self
}

method truncated-bottom(Bool $value = True) {
	$!obj.truncated-bottom = $value;
	self
}

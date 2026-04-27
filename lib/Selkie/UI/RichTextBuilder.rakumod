use Selkie::UI::Base;
use Selkie::Widget::RichText;

unit class Selkie::UI::RichTextBuilder is Selkie::UI::Base;

has Bool $.truncated-top;
has Bool $.truncated-bottom;
has Selkie::Widget::RichText $.obj .= new:
	|(:$!truncated-top with $!truncated-top),
	|(:$!truncated-bottom with $!truncated-bottom);

multi method content(@spans) {
	$!obj.set-content(@spans);
	self
}

multi method content(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "content", { self.content: block self }
	self
}

method truncated-top(Bool $value = True) {
	$!obj.truncated-top = $value;
	self
}

method truncated-bottom(Bool $value = True) {
	$!obj.truncated-bottom = $value;
	self
}

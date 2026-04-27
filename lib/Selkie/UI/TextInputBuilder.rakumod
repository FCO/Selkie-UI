use Selkie::UI::Base;
use Selkie::Widget::TextInput;
use Selkie::Sizing;

unit class Selkie::UI::TextInputBuilder is Selkie::UI::Base;

has Str                       $.placeholder;
has Sizing                    $.sizing;
has Selkie::Widget::TextInput $.obj .= new: |(:$!placeholder with $!placeholder), |(:$!sizing with $!sizing);

method size(UInt $fixed = 1) {
	$!obj.update-sizing: Sizing.fixed($fixed);
	self
}

method on-submit(&block) {
	$!obj.on-submit.tap: -> $text { block self, $text }
	self
}

method clear { $!obj.clear }

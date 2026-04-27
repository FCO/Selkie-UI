use Selkie::UI::Base;
use Selkie::Widget::Checkbox;

unit class Selkie::UI::CheckboxBuilder is Selkie::UI::Base;

has Str $.label = "";
has Selkie::Widget::Checkbox $.obj .= new: :$!label;

multi method label(Str $label) {
	$!obj.label = $label;
	self
}

multi method label(&label-block) {
	my %*UI-PATHS := SetHash.new;
	$ = label-block self;
	$.auto-subscribe: "label", { self.label: label-block self }
	self
}

multi method check(Bool $checked = True) {
	$!obj.set-checked($checked);
	self
}

multi method check(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "check", { self.check: block self }
	self
}

multi method on-change(&block) {
	$!obj.on-change.tap: -> $checked { block self, $checked };
	self
}

method toggle {
	$!obj.toggle;
	self
}

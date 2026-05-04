use Selkie::UI::Base;
use Selkie::Widget::Checkbox;
use Selkie::UI::Helpers;

unit class Selkie::UI::CheckboxBuilder is Selkie::UI::Base;

has Str $.label = "";
has Selkie::Widget::Checkbox $.obj .= new: :$!label;

multi method label(Str $label) {
	$!obj.label = $label;
	self
}

multi method label(&label-block) {
	$.auto-subscribe: "label", with-ui-context $*UI-APP, $*UI-PARENT, { self.label: label-block self }
}

multi method check(Bool() $checked = True) {
	$!obj.set-checked: $_ with $checked;
	self
}

multi method check(&block) {
	$.auto-subscribe: "check", with-ui-context $*UI-APP, $*UI-PARENT, { self.check: block self }
}

multi method on-change(&block) {
	$!obj.on-change.tap: with-ui-context $*UI-APP, $*UI-PARENT, -> $checked { block self, $checked }
	self
}

method toggle {
	$!obj.toggle;
	self
}

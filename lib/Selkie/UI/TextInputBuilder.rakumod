use Selkie::UI::Base;
use Selkie::Widget::TextInput;
use Selkie::Sizing;
use Selkie::UI::Helpers;

unit class Selkie::UI::TextInputBuilder is Selkie::UI::Base;

has Str                       $.placeholder;
has Sizing                    $.sizing;
has Str                       $.mask-char;
has Selkie::Widget::TextInput $.obj .= new:
|(:$!placeholder with $!placeholder),
|(:$!sizing      with $!sizing     ),
|(:$!mask-char   with $!mask-char  );

multi method mask(Str :$char!) {
	$!obj .= new: |(:$!placeholder with $!placeholder), |(:$!sizing with $!sizing), |(:$char with $char);
	self
}

multi method mask(&mask-block) {
	$.auto-subscribe: "mask", with-ui-context $*UI-APP, $*UI-PARENT, {
		self.mask: mask-block self
	}
}

method on-submit(&block) {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-submit.tap: with-ui-context $*UI-APP, $*UI-PARENT, -> $text {
		block self, $text
	}
	self
}

method on-change(&block) {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-change.tap: with-ui-context $*UI-APP, $*UI-PARENT, -> $text {
		block self, $text
	}
	self
}

multi method clear(Bool() $clear = True) { $!obj.clear if $clear }

multi method clear(&block) {
	$.auto-subscribe: "clear", with-ui-context $*UI-APP, $*UI-PARENT, { self.text-silent: "" if block self }
}

multi method text(--> Str) { $!obj.text }

multi method text(Any:U) { }

multi method text(Str $value) {
	$!obj.set-text($value);
	self
}

multi method text(&block) {
	$.auto-subscribe: "text", with-ui-context $*UI-APP, $*UI-PARENT, {
		self.text: block self
	}
}

multi method text-silent(Any:U) { }

multi method text-silent(Str() $text) {
	$!obj.set-text-silent: $text;
	self
}

multi method text-silent(&block) {
	$.auto-subscribe: "text-silent", with-ui-context $*UI-APP, $*UI-PARENT, {
		self.text-silent: block self
	}
}

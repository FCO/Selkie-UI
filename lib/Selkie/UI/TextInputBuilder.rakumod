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
	my $app = $*UI-APP;
	my %*UI-PATHS := SetHash.new;
	$ = mask-block self;
	$.auto-subscribe: "mask", {
		my $*UI-APP = $app;
		self.mask: mask-block self
	}
	self
}

method on-submit(&block) {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-submit.tap: -> $text {
		with-ui-context($app, $parent, &block)(self, $text)
	}
	self
}

method on-change(&block) {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-change.tap: -> $text {
		with-ui-context($app, $parent, &block)(self, $text)
	}
	self
}

method clear { $!obj.clear }

multi method text(--> Str) { $!obj.text }

multi method text(Str $value) {
	$!obj.set-text($value);
	self
}

multi method text(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "text", { self.text: block self }
	self
}

method set-text-silent(Str $text) {
	$!obj.set-text-silent($text);
	self
}

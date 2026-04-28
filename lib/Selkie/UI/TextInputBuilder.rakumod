use Selkie::UI::Base;
use Selkie::Widget::TextInput;
use Selkie::Sizing;

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
	$!obj.on-submit.tap: -> $text {
		my $*UI-APP = $app;
		block self, $text
	}
	self
}

method on-change(&block) {
	my $app = $*UI-APP;
	$!obj.on-change.tap: -> $text {
		my $*UI-APP = $app;
		block self, $text
	}
	self
}

method clear { $!obj.clear }

use Selkie::UI::Base;
use Selkie::Widget::Image;

unit class Selkie::UI::ImageBuilder is Selkie::UI::Base;

has Str $.file;
has Selkie::Widget::Image $.obj .= new: |(:$!file with $!file);
has &.block;

submethod TWEAK(:&block) {
	self.file: $_ with &block
}

multi method file(Str $file) {
	$!obj.set-file($file);
	self
}

multi method set-file(Str $file) {
	$!obj.set-file($file);
	self
}

multi method file(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "file", { self.file: block self }
	self
}

method clear-image {
	$!obj.clear-image;
	self
}

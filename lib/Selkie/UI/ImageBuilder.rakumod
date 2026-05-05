use Selkie::UI::Base;
use Selkie::Widget::Image;
use Selkie::UI::Helpers;

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
	$.auto-subscribe: "file", with-ui-context { self.file: block self }
}

method clear-image {
	$!obj.clear-image;
	self
}

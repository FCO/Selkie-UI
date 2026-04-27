use Selkie::UI::Base;
use Selkie::Widget::FileBrowser;

unit class Selkie::UI::FileBrowserBuilder is Selkie::UI::Base;

has Selkie::Widget::FileBrowser $.obj .= new;

method build(:$start-dir, :@extensions, :$show-dotfiles,
		:$width-ratio, :$height-ratio) {
	$!obj.build(
		|(:$start-dir with $start-dir),
		|(:@extensions with @extensions),
		|(:$show-dotfiles with $show-dotfiles),
		|(:$width-ratio with $width-ratio),
		|(:$height-ratio with $height-ratio),
	);
}

method on-select(&block) {
	$!obj.on-select.tap: -> $path { block self, $path };
	self
}

method focusable-widget { $!obj.focusable-widget }

method modal { $!obj.modal }

method list { $!obj.list }

method path-input { $!obj.path-input }

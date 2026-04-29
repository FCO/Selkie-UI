use Selkie::UI::Base;
use Selkie::Widget::FileBrowser;
use Selkie::UI::Helpers;

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
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-select.tap: -> $path { with-ui-context($app, $parent, &block)(self, $path) };
	self
}

method focusable-widget { $!obj.focusable-widget }

method modal { $!obj.modal }

method list { $!obj.list }

method path-input { $!obj.path-input }

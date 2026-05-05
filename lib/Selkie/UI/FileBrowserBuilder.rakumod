use Selkie::UI::Base;
use Selkie::Widget::FileBrowser;
use Selkie::UI::Helpers;

unit class Selkie::UI::FileBrowserBuilder is Selkie::UI::Base;

has Selkie::Widget::FileBrowser $.obj .= new;
has &.block;

submethod TWEAK(:&block) {
	self.build: |.() with &block
}

method build(
	:$start-dir,
	:@extensions,
	:$show-dotfiles,
	:$width-ratio,
	:$height-ratio
) {
	$!obj.build(
		|(:$start-dir     with $start-dir),
		|(:@extensions    with @extensions),
		|(:$show-dotfiles with $show-dotfiles),
		|(:$width-ratio   with $width-ratio),
		|(:$height-ratio  with $height-ratio),
	);
}

method on-select(&block) is idempotent {
	$!obj.on-select.tap: with-ui-context -> $path {
		block self, $path
	}
	self
}

method focusable-widget { $!obj.focusable-widget }

method focus { $*UI-APP.&selkie-obj.focus: $.focusable-widget }

method modal { $!obj.modal }

method show-modal { $*UI-APP.&selkie-obj.show-modal: $.modal }

method list { $!obj.list }

method path-input { $!obj.path-input }

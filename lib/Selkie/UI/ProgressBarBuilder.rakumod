use Selkie::UI::Base;
use Selkie::Widget::ProgressBar;

unit class Selkie::UI::ProgressBarBuilder is Selkie::UI::Base;

has Selkie::Widget::ProgressBar $.obj .= new;

multi method progress(Numeric $value) {
	$!obj.set-value($value);
	self
}

multi method progress(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "progress", { self.progress: block self }
	self
}

multi method indeterminate(Bool $indet = True) {
	$!obj.indeterminate = $indet;
	self
}

multi method indeterminate(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "indeterminate", { self.indeterminate: block self }
	self
}

multi method show-percentage(Bool $show = True) {
	$!obj.show-percentage = $show;
	self
}

multi method show-percentage(&block) {
	my %*UI-PATHS := SetHash.new;
	$ = block self;
	$.auto-subscribe: "show-percentage", { self.show-percentage: block self }
	self
}

method tick {
	$!obj.tick;
	self
}

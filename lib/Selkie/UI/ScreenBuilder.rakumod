use Selkie::UI::Base;

unit class Selkie::UI::ScreenBuilder is Selkie::UI::Base;

has     &.block;
has Str $.name;
has     $.screen;
has Str $.label;

submethod TWEAK(:&!block, |) {
	my @*UI-NODES;
	$!screen = &!block.(self) with &!block
}

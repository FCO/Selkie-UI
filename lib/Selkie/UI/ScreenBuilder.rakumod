use Selkie::UI::Base;

unit class Selkie::UI::ScreenBuilder is Selkie::UI::Base;

has     &.block;
has Str $.name;
has     $.screen;

submethod TWEAK(:&!block, |) {
	$!screen = &!block.(self) with &!block
}

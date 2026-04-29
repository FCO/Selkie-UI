unit module Selkie::UI::Helpers;

sub with-ui-context($app, $parent, &block) is export {
	-> |c {
		my $*UI-APP = $app;
		my $*UI-PARENT = $parent;
		block |c
	}
}

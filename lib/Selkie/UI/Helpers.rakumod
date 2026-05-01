unit module Selkie::UI::Helpers;

sub with-ui-context($app, $parent, &block) is export {
	-> |c {
		my $*UI-APP = $app;
		my $*UI-PARENT = $parent;
		block |c
	}
}

multi selkie-obj($widget where *.^can: "obj") is export { $widget.obj }
multi selkie-obj($widget)                     is export { $widget     }

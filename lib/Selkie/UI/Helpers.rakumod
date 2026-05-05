unit module Selkie::UI::Helpers;

sub with-ui-context(&block) is export {
	my $app    = $*UI-APP;
	my $parent = $*UI-PARENT;
	my $id     = $*UI-ID // &block.WHICH;
	-> |c {
		my $*UI-APP    = $app;
		my $*UI-PARENT = $parent;
		my $*UI-ID     = $id;
		my @*UI-NODES;
		block |c
	}
}

multi selkie-obj($widget where *.^can: "obj") is export { $widget.obj }
multi selkie-obj($widget)                     is export { $widget     }

multi trait_mod:<is>(Method $m, Bool :$idempotent! where *.so) is export {
	$m.wrap: my method (|c) {
		return unless $.should-add: join "-", $m.name;
		nextsame
	}
}

=begin pod

=head1 Selkie::UI::Helpers

Helper routines for Selkie UI builders.

=head2 C<with-ui-context(&block)>

Wraps a block to preserve dynamic variables across async boundaries. Captures
C<$*UI-APP>, C<$*UI-PARENT>, and C<$*UI-ID> from the call site and restores
them when the returned closure is invoked. Also sets up a fresh C<@*UI-NODES>
for the callback.

=head2 C<selkie-obj($widget)>

Returns the underlying widget object. If C<$widget> has an C<.obj> method
(builder pattern), calls it. Otherwise returns C<$widget> directly.

=head2 C<is idempotent> trait

Method trait that prevents duplicate event handler registration. Wraps the
method to call C<$.should-add> with the method name, returning early if the
handler was already registered for the current C<$*UI-ID> context.

=end pod


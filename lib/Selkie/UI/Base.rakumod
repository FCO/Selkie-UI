use Selkie::Sizing;
use Selkie::Widget;
use Selkie::Style;
use Selkie::UI::Helpers;

unit class Selkie::UI::Base;

has %.already-added;

submethod TWEAK(:$size, :$style, |) {
	.push: self with @*UI-NODES
}

my %count;
method auto-subscribe($method, &block) {
	with $*UI-APP.?obj.store {
		my @*UI-PATHS := my @paths;
		my $*UI-ID = my $id = join "-", $method, ++$;
		block;
		@paths .= unique: :with(&[eqv]);
		for @paths -> @path {
			my @*UI-PATHS;
			my $base = "{ $.obj.WHERE }-{ self.^name }-{ $method }-{ @path.join: "-" }";
			.subscribe-path-callback(
				"{ $base }-{ ++%count{$base} }",
				@path,
				with-ui-context(&block),
				$.obj ~~ Selkie::Widget ?? $.obj !! Selkie::Widget
			);
		}
	} else { block }
	self
}

method should-add(Str $event --> Bool()) {
	!%!already-added{join "-", $*UI-ID // "none", $event}++
}

method modal($ where { .obj.^can: "modal" }:) {
	self.&selkie-obj.modal
}

multi method theme(Selkie::Theme $theme) { $.obj.set-theme: $theme; self }

multi method theme(*%theme) { $.theme: $.obj.theme.clone: |%theme; self }

multi method theme(&theme) {
	$.auto-subscribe: "theme", with-ui-context { self.theme: theme self }
}

multi method style(&block) {
	$.auto-subscribe: "style", with-ui-context { self.style: |block self }
}

multi method style(|c) {
	my $style = Selkie::Style.new: |c.hash;
	try $.obj.set-style: $style;
	self
}

multi method fixed(UInt $fixed)  { $.size: :$fixed }
multi method fixed(&block)       { $.size: -> $ { fixed => block self } }
multi method flex($flex)         { $.size: :$flex }
multi method flex(&block)        { $.size: -> $ { flex => block self } }
multi method size(Pair $pair)    { $.size: |$pair }
multi method size(UInt $fixed)   { $.size: :$fixed }
multi method size(UInt :$fixed!) {
	$.obj.update-sizing: Sizing.fixed($fixed);
	self
}

multi method size(Numeric :$percent!) {
	$.obj.update-sizing: Sizing.percent($percent);
	self
}

multi method size(:$flex is copy) {
	my $value = $flex ~~ UInt ?? $flex.Int !! 1;
	$.obj.update-sizing: Sizing.flex($value);
	self
}

multi method size(&block) {
	$.auto-subscribe: "size", with-ui-context { self.size: |block self }
}

method fixed-size-value {
	return unless $.obj.sizing.mode === SizingMode::SizeFixed;
	$.obj.sizing.value
}

multi method focus(Bool() $focus = True) {
	$*UI-APP.obj.focus: $.obj if $focus;
	self
}

multi method focus(&block) {
	$.auto-subscribe: "focus", with-ui-context { self.focus: block self }
}

method mark-dirty {
	self.&selkie-obj.mark-dirty
}

=begin pod

=head1 Selkie::UI::Base

Base class for all Selkie::UI widget builders. Provides core builder functionality:
auto-registration into the node tree, reactive subscription management, sizing, and
styling.

=head2 Dynamic Variables

Builders operate within a context established by C<App> and C<Screen>. The following
dynamic variables are available:

=over 4

=item C<$*UI-APP> — The running Selkie application object

=item C<$*UI-PARENT> — The parent builder (if any)

=item C<@*UI-PATHS> — C<Array> tracking state paths read during block evaluation

=item C<@*UI-NODES> — Stack of child widgets being constructed

=item C<$*UI-ID> — Unique string per auto-subscribe chain, used for event deduplication

=back

=head2 Methods

=head3 C<TWEAK>

Called during object construction. Automatically pushes C<self> onto C<@*UI-NODES>,
registering the builder with its parent container.

=head3 C<auto-subscribe(Str $method, &block)>

Sets up store subscriptions for reactive value blocks. For each path in C<@*UI-PATHS>,
registers a callback that re-invokes C<&block> when that state path changes. Uses
C<with-ui-context> to preserve C<$*UI-APP> and C<$*UI-PARENT> across async boundaries.
Also sets C<$*UI-ID> for event deduplication.

=head3 C<%!already-added>

Internal hash attribute tracking event handler registrations. Keys are
C<"$*UI-ID-$event-name"> strings. Used by C<should-add> for deduplication.

=head3 C<should-add(Str $event --> Bool)>

Checks whether an event handler has already been registered for the current
C<$*UI-ID> context. Returns C<False> for duplicates, preventing handler
proliferation when builders are reconfigured. Used by the C<is idempotent>
trait defined in C<Selkie::UI::Helpers>.

=head3 C<modal()>

Extracts the underlying widget's C<.modal> attribute, if available. Used by
C<Modal($builder)> and C<ShowModal>.

=head3 C<style(|c)>

Delegates styling to the underlying widget. Supports C<set-style> and C<style>
protocols on the widget object.

=head3 C<size>

Four C<multi> variants for widget sizing:

=over 4

=item C<size(UInt $fixed)> — Fixed-size in cells

=item C<size(Numeric :$percent)> — Percentage of available space

=item C<size(:$flex)> — Flex sizing with optional weight (default 1)

=item C<size(&sizing-block)> — Reactive sizing block that auto-subscribes to state changes

=back

=head3 C<fixed> / C<flex>

Convenience methods that delegate to C<size>:

=over 4

=item C<fixed(UInt $cells)> — Sets fixed size in cells

=item C<fixed(&block)> — Reactive fixed size

=item C<flex($weight)> — Sets flex size with optional weight

=item C<flex(&block)> — Reactive flex size

=back

=head3 C<focus>

Proxies focus to the application: C<$*UI-APP.obj.focus($.obj)>.

=head3 C<mark-dirty>

Marks the underlying widget for re-render on the next frame.

=end pod

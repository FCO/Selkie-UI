use Selkie::Sizing;
use Selkie::Widget;
use Selkie::Style;
use Selkie::UI::Helpers;

unit class Selkie::UI::Base;

submethod TWEAK(:$size, :$style, |) {
	.push: self with @*UI-NODES
}

my %count;
method auto-subscribe($method, &block) {
	with $*UI-APP.?obj.store {
		my $app = $*UI-APP;
		my $parent = $*UI-PARENT;
		my @*UI-PATHS := my @paths;
		block;
		@paths .= unique: :with(&[eqv]);
		for @paths -> @path {
			my @*UI-PATHS;
			my $base = "{ $.obj.WHERE }-{ self.^name }-{ $method }-{ @path.join: "-" }";
			.subscribe-path-callback(
				"{ $base }-{ ++%count{$base} }",
				@path,
				with-ui-context($app, $parent, &block),
				$.obj ~~ Selkie::Widget ?? $.obj !! Selkie::Widget
			);
		}
	} else {
		block;
	}
	self
}

multi method style(&block) {
	$.auto-subscribe: "style", with-ui-context $*UI-APP, $*UI-PARENT, { self.style: |block self }
}

multi method style(|c) {
	my $style = Selkie::Style.new: |c.hash;
	try $.obj.set-style: $style;
	self
}

multi method size(Pair $pair) {
	$.size: |$pair
}

multi method fixed(UInt $fixed) { $.size: :$fixed }

multi method fixed(&block) { $.size: -> $ { fixed => block self } }

multi method size(UInt $fixed) {
	$.size: :$fixed
}

multi method size(UInt :$fixed!) {
	$.obj.update-sizing: Sizing.fixed($fixed);
	self
}

multi method size(Numeric :$percent!) {
	$.obj.update-sizing: Sizing.percent($percent);
	self
}

multi method flex($flex) { $.size: :$flex }

multi method flex(&block) { $.size: -> $ { flex => block self } }

multi method size(:$flex is copy) {
	my $value = $flex ~~ UInt ?? $flex.Int !! 1;
	$.obj.update-sizing: Sizing.flex($value);
	self
}

multi method size(&block) {
	$.auto-subscribe: "size", with-ui-context $*UI-APP, $*UI-PARENT, { self.size: |block self }
}

multi method focus(Bool() $focus = True) {
	$*UI-APP.obj.focus: $.obj if $focus;
	self
}

multi method focus(&block) {
	$.auto-subscribe: "focus", with-ui-context $*UI-APP, $*UI-PARENT, { self.focus: block self }
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

=back

=head2 Methods

=head3 C<TWEAK>

Called during object construction. Automatically pushes C<self> onto C<@*UI-NODES>,
registering the builder with its parent container.

=head3 C<auto-subscribe(Str $method, &block)>

Sets up store subscriptions for reactive value blocks. For each path in C<@*UI-PATHS>,
registers a callback that re-invokes C<&block> when that state path changes. Uses
C<with-ui-context> to preserve C<$*UI-APP> and C<$*UI-PARENT> across async boundaries.

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

=head3 C<focus>

Proxies focus to the application: C<$*UI-APP.obj.focus($.obj)>.

=end pod

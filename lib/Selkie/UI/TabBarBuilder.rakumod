use Selkie::UI::Base;
use Selkie::Widget::TabBar;
use Selkie::UI::Helpers;
use Selkie::UI::ScreenBuilder;

unit class Selkie::UI::TabBarBuilder is Selkie::UI::Base;

has                        @.tabs;
has                        %.tab-screens;
has                        $.content;
has                        $.active-tab;
has Selkie::Widget::TabBar $.obj .= new;
has                        &.set-content = -> $_, $content, (:$label, :$screen, |) {
	$content.title: $label;
	$content.content: $screen, :!destroy;
}

submethod TWEAK(:&block, |) {
	my @nodes := @*UI-NODES;
	{
		my @*UI-NODES;
		$!content = block self;
		@nodes.push: $_ with $!content;
		die "No tabs to show" unless @*UI-NODES;
		my Str $default;
		for @*UI-NODES.grep: Selkie::UI::ScreenBuilder -> $_ {
			$default = .name;
			self.add-tab: .name, .label;
			%!tab-screens{.name} = $_;
		}

		self.on-tab-selected: with-ui-context -> $_, $name {
			&!set-content.(self, $!content, %!tab-screens{$name});
		}

		$!active-tab //= $default;
		with $!active-tab -> $name is copy {
			self.set-active-name-silent: $name;
			$name = $name.(self) if $name ~~ Callable;
			&!set-content.(self, $!content, %!tab-screens{$name});
		}
	}
}

multi method add-tab(Str $name, Str $label) {
	$.add-tab: :$name, :$label;
	self
}

multi method add-tab(Str :$name!, Str :$label!) {
	$!obj.add-tab: :$name, :$label;
	self
}

method remove-tab(Str $name) {
	$!obj.remove-tab($name);
	self
}

method clear-tabs {
	$!obj.clear-tabs;
	self
}

multi method select-by-name(Str $name) {
	$!obj.select-by-name($name);
	self
}

multi method select-by-name(&block) {
	$.auto-subscribe: "select-by-name", with-ui-context { self.select-by-name: block self }
}

multi method select-index(UInt $idx) {
	$!obj.select-index($idx);
	self
}

multi method select-index(&block) {
	$.auto-subscribe: "select-index", with-ui-context { self.select-index: block self }
}

multi method set-active-name-silent(Str $name) {
	$!obj.set-active-name-silent($name);
	self
}

multi method set-active-name-silent(&block) {
	$.auto-subscribe: "set-active-name-silent", with-ui-context {
		self.set-active-name-silent: block self
	}
}

method on-tab-selected(&block) is idempotent {
	$!obj.on-tab-selected.tap: with-ui-context -> $name { block self, $name }
	self
}

method sync-to-app($app) {
	$!obj.sync-to-app($app);
	self
}

method set-focused(Bool $focused = True) {
	$!obj.set-focused($focused);
	self
}

method focus(Bool $focused = True) {
	$!obj.set-focused($focused);
	self
}

=begin pod

=head1 Selkie::UI::TabBarBuilder

Builder for a tabbed container widget. Provides tab management with reactive
content switching.

=head2 Usage

TabBar uses a declarative block-based API. The block receives the TabBarBuilder
as C<$_> and should return a content container (e.g., Border):

    TabBar {
        my $content = Border;
        Tab { Text(:text('Dashboard')) }: :name<dash>, :label('Dashboard');
        Tab { Text(:text('Settings')) }:  :name<set>,  :label('Settings');
        $content
    }

=head2 Attributes

=over 4

=item C<@.tabs> — Array of registered tab names

=item C<$.active-tab> — Currently active tab name (can be a C<Callable> for reactive binding)

=item C<$.content> — The content container returned by the block

=item C<&.set-content> — Callback invoked when switching tabs: receives
C<($_, $content, :$label, :$screen)>

=back

=head2 Methods

=head3 C<add-tab(Str $name, Str $label)> / C<add-tab(:$name!, :$label!)>

Registers a new tab with the given name and display label.

=head3 C<remove-tab(Str $name)>

Removes a tab by name.

=head3 C<clear-tabs>

Removes all tabs.

=head3 C<select-by-name(Str $name)> / C<select-by-name(&block)>

Selects a tab by name. The block variant supports reactive subscriptions.

=head3 C<select-index(UInt $idx)> / C<select-index(&block)>

Selects a tab by index (0-based). The block variant supports reactive subscriptions.

=head3 C<set-active-name-silent(Str $name)> / C<set-active-name-silent(&block)>

Sets the active tab without triggering the C<on-tab-selected> callback.

=head3 C<on-tab-selected(&block)> (idempotent)

Registers a callback for tab selection changes. The callback receives C<($builder, $name)>.

=head3 C<sync-to-app($app)>

Syncs the underlying widget to the given application.

=head3 C<set-focused(Bool $focused)>

Sets whether the tab bar has focus.

=end pod

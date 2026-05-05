unit class Selkie::UI;

use UUID;
use Selkie::UI::Base;
use Selkie::UI::AppBuilder;
use Selkie::UI::ScreenBuilder;
use Selkie::UI::VBoxBuilder;
use Selkie::UI::HBoxBuilder;
use Selkie::UI::SplitBuilder;
use Selkie::UI::ButtonBuilder;
use Selkie::UI::TextBuilder;
use Selkie::UI::TextStreamBuilder;
use Selkie::UI::TextInputBuilder;
use Selkie::UI::CheckboxBuilder;
use Selkie::UI::RadioGroupBuilder;
use Selkie::UI::SelectBuilder;
use Selkie::UI::ProgressBarBuilder;
use Selkie::UI::ListViewBuilder;
use Selkie::UI::BorderBuilder;
use Selkie::UI::ModalBuilder;
use Selkie::UI::ConfirmModalBuilder;
use Selkie::UI::ToastBuilder;
use Selkie::UI::SpinnerBuilder;
use Selkie::UI::ImageBuilder;
use Selkie::UI::ScrollViewBuilder;
use Selkie::UI::TableBuilder;
use Selkie::UI::TabBarBuilder;
use Selkie::UI::CommandPaletteBuilder;
use Selkie::UI::FileBrowserBuilder;
use Selkie::UI::HelpOverlayBuilder;
use Selkie::UI::CardListBuilder;
use Selkie::UI::RichTextBuilder;
use Selkie::UI::MultiLineInputBuilder;
use Selkie::UI::PasswordStrengthBuilder;
use Selkie::UI::PlotBuilder;
use Selkie::UI::BarChartBuilder;
use Selkie::UI::LineChartBuilder;
use Selkie::UI::ScatterPlotBuilder;
use Selkie::UI::SparklineBuilder;
use Selkie::UI::HeatmapBuilder;
use Selkie::UI::HistogramBuilder;
use Selkie::UI::AxisBuilder;
use Selkie::UI::LegendBuilder;
use Selkie::UI::Helpers;
use Selkie::UI::ReactiveArray;
use Selkie::UI::ReactiveHash;

my %states;
sub new-state(
	$default,
	:$name  = UUID.new.Str,
	:$event = "ui/automatic/{ $name }/update",
) is rw is export {
	die "State $name already exists" if %states{$name}++;

	my $store = $*UI-APP.obj.store;

	$store.register-handler: $event, -> $, %ev {
		:db{ $name => %ev<value> }
	}

	given $default -> $value {
		$store.dispatch: $event, :$value;
		$store.tick;
	}

	return-rw Proxy.new(
		FETCH => sub ($) {
			.push: ($name,) with @*UI-PATHS;
			try $store.get-in: $name
		},
		STORE => sub ($, $value) {
			$store.dispatch: $event, :$value;
			$value
		}
	)
}

sub new-array-state(@default, :$name = UUID.new.Str,
	:$event = "ui/automatic/{ $name }/update") is export {
	my $store = $*UI-APP.obj.store;

	$store.register-handler: $event, -> $, %ev {
		:db{ $name => %ev<value> }
	}

	$store.dispatch: $event, value => @default;
	$store.tick;

	ReactiveArray.new(:$store, :$name, :$event)
}

sub new-hash-state(%default, :$name = UUID.new.Str,
	:$event = "ui/automatic/{ $name }/update") is export {
	my $store = $*UI-APP.obj.store;

	$store.register-handler: $event, -> $, %ev {
		:db{ $name => %ev<value> }
	}

	$store.dispatch: $event, value => %default;
	$store.tick;

	ReactiveHash.new(:$store, :$name, :$event)
}

sub Handler(Str() $name, &block) is export {
	my $app = $*UI-APP;
	$*UI-APP.obj.store.register-handler: $name, -> $st, %ev {
		my $*UI-APP = $app;
		block $*UI-APP, %ev
	}
}

sub Detached(&block) is export {
	my @*UI-NODES;
	my $result = block();
	$result.defined ?? $result !! @*UI-NODES.head
}

multi Screen(&block, Str :$name = "main", |c) is export {
	ScreenBuilder.new: :$name, :&block, |c
}

multi Screen($node, Str :$name = "main", |c) is export {
	ScreenBuilder.new: :$name, :screen($node), |c
}

multi Tab(&block, Str :$name!, Str :$label!, |c) is export {
	ScreenBuilder.new: :$name, :$label, :&block, |c
}

multi Tab($node, Str :$name!, Str :$label!, |c) is export {
	ScreenBuilder.new: :$name, :$label, :screen($node), |c
}

sub App(&block, |c) is export { AppBuilder.new(:&block, |c).run }

sub OnFrame(&block) is export {
	$*UI-APP.obj.on-frame(with-ui-context &block)
}

sub OnKey(Str:D $spec, &handler, Str :$screen) is export {
	$*UI-APP.obj.on-key($spec, with-ui-context(&handler), |(:$screen with $screen))
}

sub Dispatch($event, *%payload) is export {
	$*UI-APP.obj.store.dispatch: $event, |%payload
}

sub Tick is export {
	$*UI-APP.obj.store.tick
}

sub Quit is export {
	$*UI-APP.obj.quit
}

sub CloseModal is export {
	$*UI-APP.obj.close-modal
}

sub ShowModal($modal) is export {
	my $m = .?modal // $_ with $modal.&selkie-obj;
	$*UI-APP.obj.show-modal: $_ with $m;
	$m
}

sub Focus($widget) is export {
	my $obj = selkie-obj $widget;
	$*UI-APP.obj.focus: $obj.?focusable-widget // $obj;
	$widget
}

sub FocusNext is export {
	$*UI-APP.obj.focus-next
}

sub FocusPrevious is export {
	$*UI-APP.obj.focus-prev
}

sub SwitchScreen(Str $name) is export {
	$*UI-APP.obj.switch-screen: $name
}

sub Toast(Str $message, Numeric :$duration = 3.0) is export {
	.obj.toast: $message, :duration($duration.Num) with $*UI-APP
}

sub ss($obj, :$size, :$style, |) {
	$obj.size:  |$_ with $size;
	$obj.style: |$_ with $style;
	$obj
}

sub VBox(&block, |c)              is export { ss |c, VBoxBuilder.new:         :&block,                                      |c }
sub HBox(&block, |c)              is export { ss |c, HBoxBuilder.new:         :&block,                                      |c }
sub CardList(&block?, |c)         is export { ss |c, CardListBuilder.new:   |(:&block with &block),                         |c }
sub Split(&block?, :$ratio, |c)   is export { ss |c, SplitBuilder.new:      |(:&block with &block), |(:$ratio with $ratio), |c }
sub Button(:$label, |c)           is export { ss |c, ButtonBuilder.new:     |(:$label with $label),                         |c }
sub Text(&block?, :$text, |c)     is export { ss |c, TextBuilder.new:       |(:&block with &block), |(:$text with $text),   |c }
sub TextStream(:$placeholder, |c) is export { ss |c, TextStreamBuilder.new: |(:$placeholder with $placeholder),             |c }
sub TextInput(:$placeholder, |c)  is export { ss |c, TextInputBuilder.new:  |(:$placeholder with $placeholder),             |c }
sub Checkbox(:$label, |c)         is export { ss |c, CheckboxBuilder.new:   |(:$label with $label),                         |c }
sub Image(&block?, :$file, |c)    is export { ss |c, ImageBuilder.new:      |(:&block with &block), |(:$file with $file),   |c }
sub RadioGroup(|c)                is export { ss |c, RadioGroupBuilder.new:                                                 |c }
sub Select(|c)                    is export { ss |c, SelectBuilder.new:                                                     |c }
sub ProgressBar(|c)               is export { ss |c, ProgressBarBuilder.new:                                                |c }
sub ListView(&block?, |c)         is export { ss |c, ListViewBuilder.new:   |(:&block with &block),                         |c }
sub ConfirmModal(|c)              is export { ss |c, ConfirmModalBuilder.new:                                               |c }
sub TabBar(&block?, |c)           is export { ss |c, TabBarBuilder.new:     |(:&block with &block),                         |c }

sub CommandPalette(&block?, |c) is export {
	ss |c, CommandPaletteBuilder.new:
	|(:&block with &block),
	|c
}

sub Table(&block?, :$show-scrollbar, |c)   is export {
	ss |c, TableBuilder.new:
	|(:&block with &block),
	|(:$show-scrollbar with $show-scrollbar),
	|c
}

multi Border(&block?, :$title, :$hide-top-border, :$hide-bottom-border, |c) is export {
	ss |c, BorderBuilder.new:
	|(:&block with &block),
	|(:$title with $title),
	|(:$hide-top-border with $hide-top-border),
	|(:$hide-bottom-border with $hide-bottom-border),
	|c
}

multi Modal(Selkie::UI::Base $widget) is export {
	$widget.modal
}

multi Modal(&block?, :$width-ratio, :$height-ratio, :$dim-background, |c) is export {
	ss |c, ModalBuilder.new:
	|(:&block with &block),
	|(:$width-ratio with $width-ratio),
	|(:$height-ratio with $height-ratio),
	|(:$dim-background with $dim-background),
	|c
}

sub Spinner(:@frames, :$interval, |c) is export {
	ss |c, SpinnerBuilder.new:
	|(:@frames with @frames),
	|(:$interval with $interval),
	|c
}

sub ScrollView(&block?, :$show-scrollbar, |c) is export {
	ss |c, ScrollViewBuilder.new:
	|(:&block with &block),
	|(:$show-scrollbar with $show-scrollbar),
	|c
}

sub FileBrowser(&block?, Bool :$show-modal, Bool :$focus, :&on-select, |c) is export {
	my $builder = FileBrowserBuilder.new: |(:&block with &block), |c;
	$builder.show-modal     if $show-modal;
	$builder.focus          if $focus;
	$builder.on-select: $_  with &on-select;
	ss |c, $builder
}

sub HelpOverlay(:$app!, :$focused-widget, |c) is export {
	ss |c, HelpOverlayBuilder.new:
	:$app,
	|(:$focused-widget with $focused-widget),
	|c
}

sub RichText(:$truncated-top, :$truncated-bottom, |c) is export {
	ss |c, RichTextBuilder.new:
	|(:$truncated-top with $truncated-top),
	|(:$truncated-bottom with $truncated-bottom),
	|c
}

sub MultiLineInput(:$placeholder, :$max-lines, |c) is export {
	ss |c, MultiLineInputBuilder.new:
	|(:$placeholder with $placeholder),
	|(:$max-lines with $max-lines),
	|c
}

sub PasswordStrength(:$input!, :$show-label, |c) is export {
	ss |c, PasswordStrengthBuilder.new:
	:$input,
	|(:$show-label with $show-label),
	|c
}

sub Plot(
	:$type,
	:$min-y,
	:$max-y,
	:$title,
	:$gridtype,
	:$rangex,
	:@store-path,
	:$empty-message,
	|c
) is export {
	ss |c, PlotBuilder.new:
	|(:$type with $type),
	|(:$min-y with $min-y),
	|(:$max-y with $max-y),
	|(:$title with $title),
	|(:$gridtype with $gridtype),
	|(:$rangex with $rangex),
	|(:@store-path with @store-path),
	|(:$empty-message with $empty-message),
	|c
}

sub BarChart(
	:@data,
	:@store-path,
	:$orientation,
	:$palette,
	:$show-axis,
	:$show-labels,
	:$min,
	:$max,
	:$tick-count,
	:$empty-message,
	|c
) is export {
	ss |c, BarChartBuilder.new:
	|(:@data with @data),
	|(:@store-path with @store-path),
	|(:$orientation with $orientation),
	|(:$palette with $palette),
	|(:$show-axis with $show-axis),
	|(:$show-labels with $show-labels),
	|(:$min with $min),
	|(:$max with $max),
	|(:$tick-count with $tick-count),
	|(:$empty-message with $empty-message),
	|c
}

sub LineChart(
	:@series,
	:&store-path-fn,
	:$palette,
	:$show-axis,
	:$show-legend,
	:$fill-below,
	:$overlap,
	:$y-min,
	:$y-max,
	:$tick-count,
	:$empty-message,
	|c
) is export {
	ss |c, LineChartBuilder.new:
	|(:@series with @series),
	|(:&store-path-fn with &store-path-fn),
	|(:$palette with $palette),
	|(:$show-axis with $show-axis),
	|(:$show-legend with $show-legend),
	|(:$fill-below with $fill-below),
	|(:$overlap with $overlap),
	|(:$y-min with $y-min),
	|(:$y-max with $y-max),
	|(:$tick-count with $tick-count),
	|(:$empty-message with $empty-message),
	|c
}

sub ScatterPlot(
	:@series,
	:@store-path,
	:$palette,
	:$x-min,
	:$x-max,
	:$y-min,
	:$y-max,
	:$overlap,
	:$empty-message,
	|c
) is export {
	ss |c, ScatterPlotBuilder.new:
	|(:@series with @series),
	|(:@store-path with @store-path),
	|(:$palette with $palette),
	|(:$x-min with $x-min),
	|(:$x-max with $x-max),
	|(:$y-min with $y-min),
	|(:$y-max with $y-max),
	|(:$overlap with $overlap),
	|(:$empty-message with $empty-message),
	|c
}

sub Sparkline(:@data, :@store-path, :$min, :$max, :$empty-message, |c) is export {
	ss |c, SparklineBuilder.new:
	|(:@data with @data),
	|(:@store-path with @store-path),
	|(:$min with $min),
	|(:$max with $max),
	|(:$empty-message with $empty-message),
	|c
}

sub Heatmap(:@data, :@store-path, :$ramp, :$min, :$max, :$empty-message, |c) is export {
	ss |c, HeatmapBuilder.new:
	|(:@data with @data),
	|(:@store-path with @store-path),
	|(:$ramp with $ramp),
	|(:$min with $min),
	|(:$max with $max),
	|(:$empty-message with $empty-message),
	|c
}

sub Histogram(
	:@values,
	:$bins,
	:@bin-edges,
	:$orientation,
	:$palette,
	:$show-axis,
	:$show-labels,
	:$min,
	:$max,
	:$tick-count,
	:$empty-message,
	|c
) is export {
	ss |c, HistogramBuilder.new:
	|(:@values with @values),
	|(:$bins with $bins),
	|(:@bin-edges with @bin-edges),
	|(:$orientation with $orientation),
	|(:$palette with $palette),
	|(:$show-axis with $show-axis),
	|(:$show-labels with $show-labels),
	|(:$min with $min),
	|(:$max with $max),
	|(:$tick-count with $tick-count),
	|(:$empty-message with $empty-message),
	|c
}

sub Axis(:$min!, :$max!, :$edge, :$tick-count, :$show-line, |c) is export {
	ss |c, AxisBuilder.new:
	:$min,
	:$max,
	|(:$edge with $edge),
	|(:$tick-count with $tick-count),
	|(:$show-line with $show-line),
	|c
}

sub Legend(:@series, :$orientation, :$swatch, |c) is export {
	ss |c, LegendBuilder.new:
	|(:@series with @series),
	|(:$orientation with $orientation),
	|(:$swatch with $swatch),
	|c
}

=begin pod

=head1 Selkie::UI

Declarative DSL for building terminal user interfaces with the Selkie framework.
See C<lib/Selkie/UI.rakudoc> for comprehensive documentation.

=head2 Core Concepts

=head3 C<new-state($default, :$name, :$event)>

Creates a reactive state variable backed by the Selkie store. Returns a Proxy
where C<FETCH> tracks access in C<@*UI-PATHS> (for auto-subscription) and
C<STORE> dispatches update events. Requires an active C<$*UI-APP> context.

For scalar values (Str, Int, Bool). For compound types, use C<new-array-state>
or C<new-hash-state>.

    my $counter := new-state 0;

=head3 C<new-array-state(@default, :$name, :$event)>

Creates a C<ReactiveArray> that implements C<Positional> and C<Iterable>. Bind
with C<:=>. All mutations (C<push>, C<pop>, C<shift>, C<unshift>, C<splice>,
C<ASSIGN-POS>) dispatch fresh values to the store.

    my @tasks := new-array-state [{:title<A>, :!done}];

=head3 C<new-hash-state(%default, :$name, :$event)>

Creates a C<ReactiveHash> that implements C<Associative> and C<Iterable>. Bind
with C<:=>. Mutations (C<ASSIGN-KEY>, C<DELETE-KEY>) dispatch fresh values.

    my %config := new-hash-state {:theme<dark>, :refresh(30)};

=head3 Builder Auto-Subscribe

Builder methods accept blocks instead of literal values. When a block is provided,
any C<new-state> variables read during evaluation are tracked via C<@*UI-PATHS>.
The builder subscribes to those state paths and re-runs the block when they change.

    my $counter := new-state 0;
    Text.text: { "Count: $counter" };  # auto-reacts to $counter changes

=head2 Exported Subs

=over 4

=item * App & Screen — C<App>, C<Screen>, C<Tab>

=item * Layouts — C<VBox>, C<HBox>, C<Split>

=item * Inputs — C<Button>, C<TextInput>, C<MultiLineInput>, C<Checkbox>, C<RadioGroup>, C<Select>, C<PasswordStrength>

=item * Text — C<Text>, C<TextStream>, C<RichText>

=item * Lists & Tables — C<ListView>, C<Table>, C<CardList>, C<TabBar>

=item * Overlays — C<Border>, C<Modal>, C<ConfirmModal>, C<Toast>, C<HelpOverlay>, C<CommandPalette>, C<FileBrowser>

=item * Misc — C<ScrollView>, C<Spinner>, C<Image>, C<ProgressBar>

=item * Charts — C<Plot>, C<BarChart>, C<LineChart>, C<ScatterPlot>, C<Sparkline>, C<Heatmap>, C<Histogram>, C<Axis>, C<Legend>

=item * State & Helpers — C<new-state>, C<new-array-state>, C<new-hash-state>, C<Handler>, C<Detached>, C<OnKey>, C<OnFrame>, C<Dispatch>, C<Tick>, C<Quit>, C<CloseModal>, C<ShowModal>, C<Focus>, C<FocusNext>, C<FocusPrevious>, C<SwitchScreen>, C<Toast>

=back

=head2 Key Differences from C<new-state>

=over 4

=item C<new-state> — Returns a Proxy, for scalar values. FETCH tracks C<@*UI-PATHS>, STORE dispatches to store.

=item C<new-array-state> — Returns C<ReactiveArray>, for array values. Direct mutation methods (push, pop, etc.) dispatch to store.

=item C<new-hash-state> — Returns C<ReactiveHash>, for hash values. ASSIGN-KEY/DELETE-KEY dispatch to store.

=back

=head2 Modal Variants

C<Modal> has two forms:

    Modal($builder);              # extracts .modal from an existing builder
    Modal { ... };                # creates a new modal overlay container

=head2 Detached Context

C<Detached> provides an isolated C<@*UI-NODES> context for building widgets
outside a layout container. Useful in tests:

    my $stream = Detached { TextStream };

=end pod

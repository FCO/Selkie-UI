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

use Selkie::App;
use Selkie::Layout::VBox;
use Selkie::Layout::HBox;
use Selkie::Layout::Split;
use Selkie::Widget::Button;
use Selkie::Widget::Text;
use Selkie::Widget::TextStream;
use Selkie::Widget::TextInput;
use Selkie::Widget::MultiLineInput;
use Selkie::Widget::Checkbox;
use Selkie::Widget::RadioGroup;
use Selkie::Widget::Select;
use Selkie::Widget::ProgressBar;
use Selkie::Widget::ListView;
use Selkie::Widget::CardList;
use Selkie::Widget::ScrollView;
use Selkie::Widget::RichText;
use Selkie::Widget::Border;
use Selkie::Widget::Modal;
use Selkie::Widget::ConfirmModal;
use Selkie::Widget::Toast;
use Selkie::Widget::Spinner;
use Selkie::Widget::Image;
use Selkie::Widget::Table;
use Selkie::Widget::TabBar;
use Selkie::Widget::CommandPalette;
use Selkie::Widget::FileBrowser;
use Selkie::Widget::HelpOverlay;
use Selkie::Widget::PasswordStrength;
use Selkie::Widget::Plot;
use Selkie::Widget::BarChart;
use Selkie::Widget::LineChart;
use Selkie::Widget::ScatterPlot;
use Selkie::Widget::Sparkline;
use Selkie::Widget::Heatmap;
use Selkie::Widget::Histogram;
use Selkie::Widget::Axis;
use Selkie::Widget::Legend;
use Selkie::Sizing;

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
			.{$name} = True with %*UI-PATHS;
			try $store.get-in: $name
		},
		STORE => sub ($, $value) {
			$store.dispatch: $event, :$value;
			$value
		}
	)
}

sub Handler(Str() $name, &block) is export {
	$*UI-APP.obj.store.register-handler($name, -> $st, %ev { block $*UI-APP, %ev })
}

multi Screen(&block, Str :$name = "main", |c) is export {
	my @*UI-NODES;
	block $*UI-APP;
	ScreenBuilder.new: :$name, :screen(@*UI-NODES.head), |c
}

multi Screen($node, Str :$name = "main", |c) is export {
	ScreenBuilder.new: :$name, :screen($node), |c
}

sub App(&block, |c) is export { AppBuilder.new(:&block, |c).run }

sub OnFrame(&block) is export {
	$*UI-APP.obj.on-frame(&block)
}

sub OnKey(Str:D $spec, &handler, Str :$screen) is export {
	$*UI-APP.obj.on-key($spec, &handler, |(:$screen with $screen))
}

sub Dispatch($event, *%payload) is export {
	$*UI-APP.obj.store.dispatch($event, |%payload)
}

sub Tick is export {
	$*UI-APP.obj.store.tick
}

sub Quit is export {
	$*UI-APP.obj.quit
}

sub VBox(&block, :$size, :$style, |c) is export {
	my $builder = VBoxBuilder.new: :&block, |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub HBox(&block, :$size, :$style, |c) is export {
	my $builder = HBoxBuilder.new: :&block, |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Split(&block, :$size, :$style, |c) is export {
	my $builder = SplitBuilder.new: :&block, |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Button(:$label, :$size, :$style, |c) is export {
	my $builder = ButtonBuilder.new: |(:$label with $label), |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Text(:$text, :$size, :$style, |c) is export {
	my $builder = TextBuilder.new: |(:$text with $text), |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub TextStream(:$placeholder, :$size, :$style, |c) is export {
	my $builder = TextStreamBuilder.new: |(:$placeholder with $placeholder), |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub TextInput(:$placeholder, :$size, :$style, |c) is export {
	my $builder = TextInputBuilder.new: :$placeholder, |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Checkbox(:$label, :$size, :$style, |c) is export {
	my $builder = CheckboxBuilder.new: |(:$label with $label), |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub RadioGroup(:$size, :$style, |c) is export {
	my $builder = RadioGroupBuilder.new: |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Select(:$size, :$style, |c) is export {
	my $builder = SelectBuilder.new: |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub ProgressBar(:$size, :$style, |c) is export {
	my $builder = ProgressBarBuilder.new: |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub ListView(:$size, :$style, |c) is export {
	my $builder = ListViewBuilder.new: |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Border(:$title, :$hide-top-border, :$hide-bottom-border, :$size, :$style, |c) is export {
	my $builder = BorderBuilder.new:
		|(:$title with $title),
		|(:$hide-top-border with $hide-top-border),
		|(:$hide-bottom-border with $hide-bottom-border),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Modal(:$width-ratio, :$height-ratio, :$dim-background, :$size, :$style, |c) is export {
	my $builder = ModalBuilder.new:
		|(:$width-ratio with $width-ratio),
		|(:$height-ratio with $height-ratio),
		|(:$dim-background with $dim-background),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub ConfirmModal(:$size, :$style, |c) is export {
	my $builder = ConfirmModalBuilder.new: |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Toast(:$size, :$style, |c) is export {
	my $builder = ToastBuilder.new: |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Spinner(:@frames, :$interval, :$style, :$size, |c) is export {
	my $builder = SpinnerBuilder.new:
		|(:@frames with @frames),
		|(:$interval with $interval),
		|(:$style with $style),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder
}

sub Image(:$file, :$size, :$style, |c) is export {
	my $builder = ImageBuilder.new: |(:$file with $file), |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub ScrollView(:$show-scrollbar, :$size, :$style, |c) is export {
	my $builder = ScrollViewBuilder.new: |(:$show-scrollbar with $show-scrollbar), |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Table(:$show-scrollbar, :$size, :$style, |c) is export {
	my $builder = TableBuilder.new: |(:$show-scrollbar with $show-scrollbar), |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub TabBar(:$size, :$style, |c) is export {
	my $builder = TabBarBuilder.new: |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub CommandPalette(:$size, :$style, |c) is export {
	my $builder = CommandPaletteBuilder.new: |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub FileBrowser(:$size, :$style, |c) is export {
	my $builder = FileBrowserBuilder.new: |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub HelpOverlay(:$app!, :$focused-widget, :$size, :$style, |c) is export {
	my $builder = HelpOverlayBuilder.new:
		:$app,
		|(:$focused-widget with $focused-widget),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

multi CardList(:$size, :$style, |c) is export {
	my $builder = CardListBuilder.new: |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

multi CardList(&block, :$size, :$style, |c) is export {
	my $builder = CardListBuilder.new: :&block, |c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub RichText(:$truncated-top, :$truncated-bottom, :$size, :$style, |c) is export {
	my $builder = RichTextBuilder.new:
		|(:$truncated-top with $truncated-top),
		|(:$truncated-bottom with $truncated-bottom),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub MultiLineInput(:$placeholder, :$max-lines, :$size, :$style, |c) is export {
	my $builder = MultiLineInputBuilder.new:
		|(:$placeholder with $placeholder),
		|(:$max-lines with $max-lines),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub PasswordStrength(:$input!, :$show-label, :$size, :$style, |c) is export {
	my $builder = PasswordStrengthBuilder.new:
		:$input,
		|(:$show-label with $show-label),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Plot(:$type, :$min-y, :$max-y, :$title, :$gridtype, :$rangex,
		:@store-path, :$empty-message, :$size, :$style, |c) is export {
	my $builder = PlotBuilder.new:
		|(:$type with $type),
		|(:$min-y with $min-y),
		|(:$max-y with $max-y),
		|(:$title with $title),
		|(:$gridtype with $gridtype),
		|(:$rangex with $rangex),
		|(:@store-path with @store-path),
		|(:$empty-message with $empty-message),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub BarChart(:@data, :@store-path, :$orientation, :$palette,
		:$show-axis, :$show-labels, :$min, :$max,
		:$tick-count, :$empty-message, :$size, :$style, |c) is export {
	my $builder = BarChartBuilder.new:
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
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub LineChart(:@series, :&store-path-fn, :$palette,
		:$show-axis, :$show-legend, :$fill-below, :$overlap,
		:$y-min, :$y-max, :$tick-count, :$empty-message, :$size, :$style, |c) is export {
	my $builder = LineChartBuilder.new:
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
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub ScatterPlot(:@series, :@store-path, :$palette,
		:$x-min, :$x-max, :$y-min, :$y-max, :$overlap,
		:$empty-message, :$size, :$style, |c) is export {
	my $builder = ScatterPlotBuilder.new:
		|(:@series with @series),
		|(:@store-path with @store-path),
		|(:$palette with $palette),
		|(:$x-min with $x-min),
		|(:$x-max with $x-max),
		|(:$y-min with $y-min),
		|(:$y-max with $y-max),
		|(:$overlap with $overlap),
		|(:$empty-message with $empty-message),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Sparkline(:@data, :@store-path, :$min, :$max, :$empty-message, :$size, :$style, |c) is export {
	my $builder = SparklineBuilder.new:
		|(:@data with @data),
		|(:@store-path with @store-path),
		|(:$min with $min),
		|(:$max with $max),
		|(:$empty-message with $empty-message),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Heatmap(:@data, :@store-path, :$ramp, :$min, :$max, :$empty-message, :$size, :$style, |c) is export {
	my $builder = HeatmapBuilder.new:
		|(:@data with @data),
		|(:@store-path with @store-path),
		|(:$ramp with $ramp),
		|(:$min with $min),
		|(:$max with $max),
		|(:$empty-message with $empty-message),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Histogram(:@values, :$bins, :@bin-edges, :$orientation, :$palette,
		:$show-axis, :$show-labels, :$min, :$max,
		:$tick-count, :$empty-message, :$size, :$style, |c) is export {
	my $builder = HistogramBuilder.new:
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
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Axis(:$min!, :$max!, :$edge, :$tick-count, :$show-line, :$size, :$style, |c) is export {
	my $builder = AxisBuilder.new:
		:$min,
		:$max,
		|(:$edge with $edge),
		|(:$tick-count with $tick-count),
		|(:$show-line with $show-line),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

sub Legend(:@series, :$orientation, :$swatch, :$size, :$style, |c) is export {
	my $builder = LegendBuilder.new:
		|(:@series with @series),
		|(:$orientation with $orientation),
		|(:$swatch with $swatch),
		|c;
	$builder.size(|$size) if $size.defined;
	$builder.style(|$style) if $style.defined;
	$builder
}

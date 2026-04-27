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

multi Screen(&block, Str :$name = "main") is export {
	my @*UI-NODES;
	block $*UI-APP;
	ScreenBuilder.new: :$name, :screen(@*UI-NODES.head)
}

multi Screen($node, Str :$name = "main") is export {
	ScreenBuilder.new: :$name, :screen($node)
}

sub App(&block) is export { AppBuilder.new(:&block).run }

sub VBox(&block) is export { VBoxBuilder.new: :&block }

sub HBox(&block) is export { HBoxBuilder.new: :&block }

sub Split(&block) is export { SplitBuilder.new: :&block }

sub Button(:$label) is export { ButtonBuilder.new: |(:$label with $label) }

sub Text(:$text) is export { TextBuilder.new: |(:$text with $text) }

sub TextStream(:$placeholder) is export { TextStreamBuilder.new: |(:$placeholder with $placeholder) }

sub TextInput(:$placeholder) is export { TextInputBuilder.new: :$placeholder }

sub Checkbox(:$label) is export { CheckboxBuilder.new: |(:$label with $label) }

sub RadioGroup is export { RadioGroupBuilder.new }

sub Select is export { SelectBuilder.new }

sub ProgressBar is export { ProgressBarBuilder.new }

sub ListView is export { ListViewBuilder.new }

sub Border(:$title, :$hide-top-border, :$hide-bottom-border) is export {
	BorderBuilder.new:
		|(:$title with $title),
		|(:$hide-top-border with $hide-top-border),
		|(:$hide-bottom-border with $hide-bottom-border)
}

sub Modal(:$width-ratio, :$height-ratio, :$dim-background) is export {
	ModalBuilder.new:
		|(:$width-ratio with $width-ratio),
		|(:$height-ratio with $height-ratio),
		|(:$dim-background with $dim-background)
}

sub ConfirmModal is export { ConfirmModalBuilder.new }

sub Toast is export { ToastBuilder.new }

sub Spinner(:@frames, :$interval, :$style) is export {
	SpinnerBuilder.new:
		|(:@frames with @frames),
		|(:$interval with $interval),
		|(:$style with $style)
}

sub Image(:$file) is export { ImageBuilder.new: |(:$file with $file) }

sub ScrollView(:$show-scrollbar) is export {
	ScrollViewBuilder.new: |(:$show-scrollbar with $show-scrollbar)
}

sub Table(:$show-scrollbar) is export {
	TableBuilder.new: |(:$show-scrollbar with $show-scrollbar)
}

sub TabBar is export { TabBarBuilder.new }

sub CommandPalette is export { CommandPaletteBuilder.new }

sub FileBrowser is export { FileBrowserBuilder.new }

sub HelpOverlay(:$app!, :$focused-widget) is export {
	HelpOverlayBuilder.new:
		:$app,
		|(:$focused-widget with $focused-widget)
}

multi CardList() is export { CardListBuilder.new }

multi CardList(&block) is export { CardListBuilder.new: :&block }

sub RichText(:$truncated-top, :$truncated-bottom) is export {
	RichTextBuilder.new:
		|(:$truncated-top with $truncated-top),
		|(:$truncated-bottom with $truncated-bottom)
}

sub MultiLineInput(:$placeholder, :$max-lines) is export {
	MultiLineInputBuilder.new:
		|(:$placeholder with $placeholder),
		|(:$max-lines with $max-lines)
}

sub PasswordStrength(:$input!, :$show-label) is export {
	PasswordStrengthBuilder.new:
		:$input,
		|(:$show-label with $show-label)
}

sub Plot(:$type, :$min-y, :$max-y, :$title, :$gridtype, :$rangex,
		:@store-path, :$empty-message) is export {
	PlotBuilder.new:
		|(:$type with $type),
		|(:$min-y with $min-y),
		|(:$max-y with $max-y),
		|(:$title with $title),
		|(:$gridtype with $gridtype),
		|(:$rangex with $rangex),
		|(:@store-path with @store-path),
		|(:$empty-message with $empty-message)
}

sub BarChart(:@data, :@store-path, :$orientation, :$palette,
		:$show-axis, :$show-labels, :$min, :$max,
		:$tick-count, :$empty-message) is export {
	BarChartBuilder.new:
		|(:@data with @data),
		|(:@store-path with @store-path),
		|(:$orientation with $orientation),
		|(:$palette with $palette),
		|(:$show-axis with $show-axis),
		|(:$show-labels with $show-labels),
		|(:$min with $min),
		|(:$max with $max),
		|(:$tick-count with $tick-count),
		|(:$empty-message with $empty-message)
}

sub LineChart(:@series, :&store-path-fn, :$palette,
		:$show-axis, :$show-legend, :$fill-below, :$overlap,
		:$y-min, :$y-max, :$tick-count, :$empty-message) is export {
	LineChartBuilder.new:
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
		|(:$empty-message with $empty-message)
}

sub ScatterPlot(:@series, :@store-path, :$palette,
		:$x-min, :$x-max, :$y-min, :$y-max, :$overlap,
		:$empty-message) is export {
	ScatterPlotBuilder.new:
		|(:@series with @series),
		|(:@store-path with @store-path),
		|(:$palette with $palette),
		|(:$x-min with $x-min),
		|(:$x-max with $x-max),
		|(:$y-min with $y-min),
		|(:$y-max with $y-max),
		|(:$overlap with $overlap),
		|(:$empty-message with $empty-message)
}

sub Sparkline(:@data, :@store-path, :$min, :$max, :$empty-message) is export {
	SparklineBuilder.new:
		|(:@data with @data),
		|(:@store-path with @store-path),
		|(:$min with $min),
		|(:$max with $max),
		|(:$empty-message with $empty-message)
}

sub Heatmap(:@data, :@store-path, :$ramp, :$min, :$max, :$empty-message) is export {
	HeatmapBuilder.new:
		|(:@data with @data),
		|(:@store-path with @store-path),
		|(:$ramp with $ramp),
		|(:$min with $min),
		|(:$max with $max),
		|(:$empty-message with $empty-message)
}

sub Histogram(:@values, :$bins, :@bin-edges, :$orientation, :$palette,
		:$show-axis, :$show-labels, :$min, :$max,
		:$tick-count, :$empty-message) is export {
	HistogramBuilder.new:
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
		|(:$empty-message with $empty-message)
}

sub Axis(:$min!, :$max!, :$edge, :$tick-count, :$show-line) is export {
	AxisBuilder.new:
		:$min,
		:$max,
		|(:$edge with $edge),
		|(:$tick-count with $tick-count),
		|(:$show-line with $show-line)
}

sub Legend(:@series, :$orientation, :$swatch) is export {
	LegendBuilder.new:
		|(:@series with @series),
		|(:$orientation with $orientation),
		|(:$swatch with $swatch)
}

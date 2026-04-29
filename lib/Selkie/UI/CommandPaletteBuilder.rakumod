use Selkie::UI::Base;
use Selkie::Widget::CommandPalette;
use Selkie::UI::Helpers;

unit class Selkie::UI::CommandPaletteBuilder is Selkie::UI::Base;

has Selkie::Widget::CommandPalette $.obj .= new;
has @!commands;
has $!modal;

multi method add-command(:$action, Str :$label!) {
	$.add-command: $action, :$label
}

multi method add-command(&action, Str :$label!) {
	@!commands.push: %(:$label, :&action);
	$!obj.add-command(&action, :$label);
	self
}

multi method add-command(&action, &label-block) {
	my %*UI-PATHS := SetHash.new;
	$ = label-block self;
	@!commands.push: %(label-block => &label-block, action => &action);
	self!rebuild-commands;
	my $idx = @!commands.end;
	$.auto-subscribe: "add-command-{$idx}", { self!rebuild-commands }
	self
}

multi method commands(@commands) {
	self.clear-commands;
	for @commands -> $cmd {
		given $cmd {
			when Pair { self.add-command($cmd.value, :label($cmd.key)) }
			when Associative {
				self.add-command($cmd<action>, :label($cmd<label>))
			}
			default { }
		}
	}
	self
}

multi method commands(&block) {
	my %*UI-PATHS := SetHash.new;
	self.commands(block self);
	$.auto-subscribe: "commands", { self.commands(block self) }
	self
}

method clear-commands {
	@!commands = ();
	$!obj.clear-commands;
	self
}

method reset {
	$!obj.reset;
	self
}

method build(:$width-ratio, :$height-ratio) {
	$!modal = $!obj.build(
		|(:$width-ratio  with $width-ratio ),
		|(:$height-ratio with $height-ratio),
	);
	self
}

method focusable-widget { $!obj.focusable-widget }

method focus {
	$*UI-APP.obj.focus: $!obj.focusable-widget;
	self
}

method modal { $!modal // $.build }

method show-modal {
	$*UI-APP.obj.show-modal: $!modal;
	self
}

method on-command(&block) {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-command.tap: -> $cmd {
		with-ui-context($app, $parent, &block)(self, $cmd)
	}
	self
}

method !rebuild-commands {
	$!obj.clear-commands;
	for @!commands -> %cmd {
		my $label = %cmd<label-block>:exists
			?? %cmd<label-block>(self)
			!! %cmd<label>;
		$!obj.add-command(%cmd<action>, :$label);
	}
}

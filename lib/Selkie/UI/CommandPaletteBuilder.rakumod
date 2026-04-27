use Selkie::UI::Base;
use Selkie::Widget::CommandPalette;

unit class Selkie::UI::CommandPaletteBuilder is Selkie::UI::Base;

has Selkie::Widget::CommandPalette $.obj .= new;
has @!commands;

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
	$!obj.build(
		|(:$width-ratio with $width-ratio),
		|(:$height-ratio with $height-ratio),
	);
}

method focusable-widget { $!obj.focusable-widget }

method modal { $!obj.modal }

method on-command(&block) {
	$!obj.on-command.tap: -> $cmd { block self, $cmd };
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

use Selkie::UI::Base;
use Selkie::Widget::CommandPalette;
use Selkie::Widget::Modal;
use Selkie::Widget::TextInput;
use Selkie::Widget::ListView;
use Selkie::UI::Helpers;

unit class Selkie::UI::CommandPaletteBuilder is Selkie::UI::Base;

has Selkie::Widget::CommandPalette $.obj .= new;
has @!commands;
has Bool() $!build;
has $!modal;

submethod TWEAK(:&block, |) {
	self.commands: $_ with &block;
	self.build with $!build;
}

multi method add-command(:$action, Str :$label!) {
	$.add-command: $action, :$label
}

multi method add-command(&action, Str :$label!) {
	@!commands.push: %(:$label, :&action);
	$!obj.add-command: :$label, with-ui-context &action;
	self
}

multi method add-command(&action, &label-block) {
	my @*UI-PATHS;
	$ = label-block self;
	@!commands.push: %(label-block => &label-block, action => &action);
	self!rebuild-commands;
	my $idx = @!commands.end;
	$.auto-subscribe: "add-command-{$idx}", with-ui-context {
		self!rebuild-commands
	}
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
	$.auto-subscribe: "commands", with-ui-context { self.commands: block self }
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
	if $!modal.defined && !$!modal.content.defined {
		self!reset-modal-cache;
	}
	$!modal = $!obj.build(
		|(:$width-ratio  with $width-ratio ),
		|(:$height-ratio with $height-ratio),
	);
	$!modal
}

method focusable-widget { $!obj.focusable-widget }

method focus {
	$*UI-APP.obj.focus: $!obj.focusable-widget;
	self
}

method modal { self.build }

method show-modal {
	$*UI-APP.obj.show-modal: self.modal;
	self
}

method on-command(&block) is idempotent {
	my $app = $*UI-APP;
	my $parent = $*UI-PARENT;
	$!obj.on-command.tap: with-ui-context -> $cmd {
		block self, $cmd
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

method !reset-modal-cache {
	$!obj.^attributes.first(*.name eq '$!modal')
		.set_value($!obj, Selkie::Widget::Modal);
	$!obj.^attributes.first(*.name eq '$!input')
		.set_value($!obj, Selkie::Widget::TextInput);
	$!obj.^attributes.first(*.name eq '$!list')
		.set_value($!obj, Selkie::Widget::ListView);
	$!modal = Selkie::Widget::Modal;
}

use Terminal::ANSIParser;

class Selkie::UI::Test::TTY {
    has Str $.script;
    has Int $.rows = 24;
    has Int $.cols = 80;
    has $!proc;
    has $!promise;
    has Bool $!quit-sent = False;
    has Int $!exitcode;
    has Str $!stdout = '';
    has Str $!stderr = '';

    submethod BUILD(Str :$script, Int :$rows = 24, Int :$cols = 80) {
        $!script = $script;
        $!rows = $rows;
        $!cols = $cols;
        $!proc = Proc::Async.new('raku', '-I', 'lib', $!script, :pty(:cols($!cols), :rows($!rows)));
        $!proc.stdout.Supply.tap: -> $buf { $!stdout ~= $buf };
        $!promise = $!proc.start;
        sleep 2;
    }

    method send-key(Str $key) {
        my $sequence = self!key-to-sequence($key);
        $!proc.print($sequence);
    }

    method send-text(Str $text) {
        $!proc.print($text);
    }

    method !key-to-sequence(Str $key --> Str) {
        given $key.lc {
            when 'enter'       { "\r" }
            when 'tab'         { "\t" }
            when 'escape' | 'esc' { "\e" }
            when 'space'       { ' ' }
            when 'backspace'   { "\x08" }
            when 'delete'      { "\x7F" }
            when 'up'          { "\e[A" }
            when 'down'        { "\e[B" }
            when 'right'       { "\e[C" }
            when 'left'        { "\e[D" }
            when 'pageup'      { "\e[5~" }
            when 'pagedown'    { "\e[6~" }
            when 'home'        { "\e[H" }
            when 'end'         { "\e[F" }
            when /^ ctrl '+' (.+) $/ {
                my $char = $0.lc;
                if $char ~~ /^ <[a..z]> $/ {
                    chr($char.ord - 96)
                } elsif $char eq 'space' || $char eq '@' {
                    chr(0)
                } elsif $char eq 'enter' {
                    "\x0A"
                } elsif $char eq '[' {
                    "\x1B"
                } else {
                    $char
                }
            }
            default { $key }
        }
    }

    method quit {
        return if $!quit-sent;
        $!quit-sent = True;
        try $!proc.print("\x11");
        sleep 1;
        my $guard = 0;
        while self.is-alive && $guard < 20 {
            sleep 0.25;
            $guard++;
        }
        if self.is-alive {
            try $!proc.kill(SIGKILL);
            sleep 1;
        }
        try {
            $!exitcode = $!promise.result.exitcode;
        }
    }

    method is-alive(--> Bool) {
        return False unless $!proc.defined;
        return False unless $!proc.pid.defined;
        try {
            my $status = $!promise.status;
            return $status ~~ Planned;
        }
        return True;
    }

    method exitcode(--> Int) {
        return $!exitcode // -1;
    }

    method stdout(--> Str) {
        return $!stdout;
    }

    method stderr(--> Str) {
        return $!stderr;
    }

    method cleanup {
        if $!proc {
            try $!proc.kill(SIGKILL);
            $!proc = Nil;
        }
    }

    submethod DESTROY {
        self.cleanup;
    }
}

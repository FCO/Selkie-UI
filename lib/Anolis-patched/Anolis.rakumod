use Terminal::ANSIParser;
use Anolis::Interface;

sub dump($text) {
    "o".IO.spurt: $text ~ "\n", :append;
}

class Anolis {
    my $empty = Anolis::Cell.new(char => ' ', sgr => '');
    class Screen {
        has @.grid is rw;
        has Bool $.cursor-visible is rw = True;
        has Int $.cursor-x is rw = 0;
        has Int $.cursor-y is rw = 0;
        has Int $.scroll-start is rw;
        has Int $.scroll-stop is rw;
    }

    has &!parse;
    has $!input-byte-buf;
    has @!parse-buf;

    has $!cols = 80;
    has $!rows = 24;
    has Screen $.norm-screen .= new;
    has @.scrollback;
    has Screen $.alt-screen .= new;
    has Screen $.screen = $!norm-screen;
    has Str $!sgr = '';
    # TODO: Find out what application cursor keys does (DECCKM)
    has Bool $!app-cursor-keys = False;
    # TODO: Find out what application keypad does (DECPAM)
    has Bool $!app-keypad = False;

    has Anolis::Interface $!interface is built;
    has Supply $!receive is built;
    has Supplier $!send is built;

    method set-size($!cols, $!rows) {
        # TODO: send size update to child
    }

    submethod TWEAK(Proc::Async :$proc-async) {
        $!cols = $proc-async.pty-cols;
        $!rows = $proc-async.pty-rows;

        &!parse = make-ansi-parser(emit-item => {
dump('    -> ' ~ self!stringify-token($_));
            @!parse-buf.push: $_;
        });
        if  $proc-async.defined && ($!receive.defined || $!send.defined) ||
           !$proc-async.defined && !$!receive.defined && !$!send.defined {
            die "Must pass either proc-async xor receive and send.";
        }
        elsif $!receive.defined ^^ $!send.defined {
            die "Must pass both receive and send.";
        }

        with $proc-async {
            $!receive = $proc-async.stdout(:bin);
            $!send .= new;
            my $send-supply = $!send.Supply;
            $send-supply.tap: -> $v {
                $proc-async.print: $v;
            };
        }

        $!receive.tap: -> $bytes {
            #&!parse($_) for $text.ords;
            for $bytes.decode.ords {
dump("IN: " ~ chr($_).raku ~ " " ~ $_);
                &!parse($_);
            }
            self!process-tokens();
        };
    }

    method !stringify-token($token) {
        if $token ~~ Int {
            "Plain {chr($token).raku} $token"
        }
        elsif $token ~~ Terminal::ANSIParser::String {
            "String {$token.Str.subst("\e", "\\e")}"
        }
        elsif $token ~~ Terminal::ANSIParser::Sequence {
            "Sequence {$token.Str.subst("\e", "\\e")}"
        }
        else {
            "Unknown token type seen"
        }
    }
    method !log-unknown($token) {
        $!interface.log("Unknown token: {self!stringify-token($token)}");
    }

    method !process-tokens() {
        # y => @areas
        my %areas;
        sub put-cell($x, $y, $cell) {
            $!screen.grid[$y; $x] = $cell;
            %areas{$y} = [] without %areas{$y};
            for %areas{$y}.kv -> $i, $area {
                if $x + 1 < $area.from-x {
                    %areas{$y}.unshift: Anolis::Interface::Area.new(from-x => $x, :$y, cells => $cell);
                    return
                }
                elsif $x + 1 == $area.from-x {
                    $area.cells.unshift: $cell;
                    $area.from-x = $area.from-x - 1;
                    return
                }
                elsif $area.from-x <= $x < $area.to-x {
                    $area.cells[$x - $area.from-x] = $cell;
                    return
                }
                elsif $x == $area.to-x {
                    $area.cells.push: $cell;
                    if $i+1 <= %areas{$y}.end && %areas{$y}[$i+1].from-x == $x {
                        $area.cells.append: %areas{$y}[$i+1].cells;
                        %areas{$y}.splice($i+1, 1);
                    }
                    return
                }
            }
            %areas{$y}.push: Anolis::Interface::Area.new(from-x => $x, :$y, cells => $cell);
        }
        sub clear-screen() {
            for ^$!rows -> $y {
                for ^$!cols -> $x {
                    put-cell($x, $y, $empty);
                }
            }
        }
        sub bump-y() {
            my $top = $!screen.scroll-start // 0;
            my $bottom = $!screen.scroll-stop // $!rows - 1;
            if $!screen.cursor-y >= $bottom {
                $!screen.cursor-y = $bottom;
                my @out = $!screen.grid.splice: $top, 1;
                if $!screen === $!norm-screen {
                    @!scrollback.push: @out;
                }
                $!screen.grid.splice: $bottom, 0, ([],);
            }
            else {
                $!screen.cursor-y++;
            }
        }

        
        for @!parse-buf -> $token {
            if $token ~~ Int {
                my $char = chr($token);
                if $char eq "\n" {
                    bump-y;
                }
                elsif $char eq "\r" {
                    $!screen.cursor-x = 0;
                }
                elsif $char eq "\b" {
                    $!screen.cursor-x = max $!screen.cursor-x - 1, 0;
                }
                elsif $char eq "\a" {
                    # Unimplemented. BELL.
                }
                elsif 0x20 <= $token {
                    my $cell = Anolis::Cell.new(:$char, :$!sgr);
                    put-cell($!screen.cursor-x, $!screen.cursor-y, $cell);
                    $!screen.cursor-x++;
                    if $!screen.cursor-x >= $!cols {
                        $!screen.cursor-x = 0;
                        bump-y;
                    }
                }
                else {
                    self!log-unknown($token);
                }
            }
            elsif $token ~~ Terminal::ANSIParser::OSC {
                my $string = $token.string.map({ chr($_) }).join;
                if $string.starts-with: '0;' {
                    my $title = $string.substr: 2;
                    # TODO: Set icon name and window title.
                }
                else {
                    self!log-unknown($token);
                }
            }
            elsif $token ~~ Terminal::ANSIParser::String {
                self!log-unknown($token);
            }
            elsif $token ~~ Terminal::ANSIParser::CSI {
                    my $command = chr($token.sequence[*-1]);
                if chr($token.sequence[2]) eq '?' { # Private codes
                    my $payload = $token.sequence[3..*-2].map({ chr($_) }).join;

                    if $command eq 'h' {
                        if $payload eq '1' {
                            $!app-cursor-keys = True;
                        }
                        elsif $payload eq '12' {
                            # Unimplemented. Start blinking cursor (AT&T 610).
                        }
                        elsif $payload eq '25' {
                            $!screen.cursor-visible = True;
                        }
                        elsif $payload eq '1004' {
                            # Unimplemented. Send FocusIn/FocusOut events, xterm.
                        }
                        elsif $payload eq '1049' {
                            $!screen = $!alt-screen;
                            clear-screen;
                        }
                        elsif $payload eq '2004' {
                            # Unimplemented. Set bracketed paste mode, xterm.
                        }
                        else {
                            self!log-unknown($token);
                        }
                    }
                    elsif $command eq 'l' {
                        if  $payload eq '1' {
                            $!app-cursor-keys = False;
                        }
                        elsif $payload eq '12' {
                            # Unimplemented. Stop blinking cursor (AT&T 610).
                        }
                        elsif $payload eq '25' {
                            $!screen.cursor-visible = False;
                        }
                        elsif $payload eq '1049' {
                            $!screen = $!norm-screen;
                            clear-screen;
                        }
                        elsif $payload eq '2004' {
                            # Unimplemented. Reset bracketed paste mode, xterm.
                        }
                        else {
                            self!log-unknown($token);
                        }
                    }
                    elsif $command eq 'm' {
                        # Unimplemented. Query key modifier options (XTQMODKEYS), xterm.
                    }
                    else {
                        self!log-unknown($token);
                    }
                }
                else {
                    my $payload = $token.sequence[2..*-2].map({ chr($_) }).join;

                    if $command eq 'A' {
                        $!screen.cursor-y = max($!screen.cursor-y - $payload.Int, 0);
                    }
                    elsif $command eq 'B' {
                        $!screen.cursor-y = min($!screen.cursor-y + $payload.Int, $!rows - 1);
                    }
                    elsif $command eq 'C' {
                        $!screen.cursor-x = min($!screen.cursor-x + $payload.Int, $!cols - 1);
                    }
                    elsif $command eq 'D' {
                        $!screen.cursor-x = max($!screen.cursor-x - $payload.Int, 0);
                    }
                    elsif $command eq 'H' {
                        if $payload eq '' {
                            $!screen.cursor-x = 0;
                            $!screen.cursor-y = 0;
                        }
                        else {
                            my @coord = $payload.split(';');
                            if @coord.elems == 2 {
                                # TODO: Check if they can be empty
                                $!screen.cursor-y = @coord[0].Int - 1;
                                $!screen.cursor-x = @coord[1].Int - 1;
                            }
                            else {
                                self!log-unknown($token);
                            }
                        }
                    }
                    elsif $command eq 'J' {
                        if $payload eq '' | '0' { # Clear to end
                            for $!screen.cursor-x ..^ $!cols -> $x {
                                put-cell($x, $!screen.cursor-y, $empty);
                            }
                            for $!screen.cursor-y ^..^ $!rows -> $y {
                                for ^$!cols -> $x {
                                    put-cell($x, $y, $empty);
                                }
                            }
                        }
                        elsif $payload eq '1' { # Clear to beginning
                            for 0 ..^ $!screen.cursor-y -> $y {
                                for ^$!cols -> $x {
                                    put-cell($x, $y, $empty);
                                }
                            }
                            for 0 .. $!screen.cursor-x -> $x {
                                put-cell($x, $!screen.cursor-y, $empty);
                            }
                        }
                        elsif $payload eq '2' { # Clear all
                            clear-screen;
                        }
                        elsif $payload eq '3' { # Clear all & scrollback
                            clear-screen;
                            #TODO: Clear scrollback
                        }
                    }
                    elsif $command eq 'K' {
                        if $payload eq '' | '0' { # Clear to end
                            for $!screen.cursor-x ..^ $!cols -> $x {
                                put-cell($x, $!screen.cursor-y, $empty);
                            }
                        }
                        elsif $payload eq '1' { # Clear to beginning
                            for 0 .. $!screen.cursor-x -> $x {
                                put-cell($x, $!screen.cursor-y, $empty);
                            }
                        }
                        elsif $payload eq '2' { # Clear all
                            for ^$!cols -> $x {
                                put-cell($x, $!screen.cursor-y, $empty);
                            }
                        }
                    }
                    elsif $command eq 'L' {
                        $payload ||= 1;

                        $!screen.grid.splice: $!screen.cursor-y, 0, [] xx $payload.Int;
                        my $bottom = $!screen.scroll-stop // $!rows - 1;
                        $!screen.grid.splice: $bottom+1, $payload.Int;
                    }
                    elsif $command eq 'M' {
                        $payload ||= 1;

                        $!screen.grid.splice: $!screen.cursor-y, $payload.Int;
                        my $bottom = $!screen.scroll-stop // $!rows - 1;
                        $!screen.grid.splice: $bottom, 0, [] xx $payload.Int;
                    }
                    elsif $command eq 'c' && $payload eq '>' {
                        $!send.emit: "\e[>41;123;0c";
                    }
                    elsif $command eq 'm' {
                        $!sgr = $token.sequence[2..*-2].map({ chr($_) }).join;
                        $!sgr = '' if $!sgr eq '0';
                    }
                    elsif $command eq 'n' && $payload eq '6' {
                        $!send.emit: "\e[{$!screen.cursor-x};{$!screen.cursor-y}R";
                    }
                    elsif $command eq 'r' {
                        my @area = $payload.split(';');
                        if @area.elems == 2 {
                            $!screen.scroll-start = @area[0].Int - 1;
                            $!screen.scroll-stop = @area[1].Int - 1;
                        }
                        else {
                            $!screen.scroll-start = Int;
                            $!screen.scroll-stop = Int;
                        }
                    }
                    elsif $command eq 't' && $payload eq '22;0;0' {
                        # Unimplemented. Save xterm icon and window title on stack. The third arg is unspecified.
                    }
                    elsif $command eq 't' && $payload eq '22;1' {
                        # Unimplemented. Save xterm icon title on stack.
                    }
                    elsif $command eq 't' && $payload eq '22;2' {
                        # Unimplemented. Save xterm window title on stack.
                    }
                    else {
                        self!log-unknown($token);
                    }
                }
            }
            elsif $token ~~ Terminal::ANSIParser::Sequence {
                my $command = chr($token.sequence[*-1]);
                my $payload = $token.sequence[1..*-2].map({ chr($_) }).join;
                if $payload eq '' {
                    if $command eq '=' {
                        $!app-keypad = True;
                    }
                    elsif $command eq '>' {
                        $!app-keypad = False;
                    }
                    else {
                        self!log-unknown($token);
                    }
                }
                else {
                    self!log-unknown($token);
                }
            }
            else {
                self!log-unknown($token);
            }
        }

        @!parse-buf = ();

        if %areas.elems {
            my @areas = %areas.keys.sort.map(-> $y {
                %areas{$y}<>
            }).flat;
            $!interface.grid-changed(@areas);
        }
    }

    method send-text($codepoints) {
        $!send.emit: $codepoints;
    }
}

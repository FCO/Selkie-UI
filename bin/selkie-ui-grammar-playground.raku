use Selkie::UI;

my $s-usual = Selkie::Style.new: :fg(0xEEEEEE), :bold;
my $s-match = Selkie::Style.new: :fg(0x33AA33), :bold;
my $s-fail  = Selkie::Style.new: :fg(0xAA3333), :bold;

sub create(%tree (Bool :$match, Str :$rule, :@children, Str :$data, |)) {
    my $size = 0;
    if @children {
        Border :title($rule), {
            $size += 2;
            VBox {
                for @children -> %data {
                    $size += create %data;
                }
            }
            .fixed: $size;
            .theme: :border($match ?? $s-match !! $s-fail);
        }
    } else {
        $size += 3;
        Border :title($rule), :3size, {
            if $match {
                .theme: :border($s-match);
                RichText.content: [
                    %( :text<MATCH:>,   :style( $s-match ) ),
                    %( :text(" \"$data\""), :style($s-usual) ),
                ];
            } else {
                .theme: :border($s-fail);
                RichText.content: [
                    %( :text<FAIL:>,    :style( $s-fail ) ),
                    %( :text(" \"$data\""), :style($s-usual) ),
                ];
            }
        }
    }
    return $size
}

sub dump(%tree (:$rule, :$match, :$data, :@children, |)) {
    join "\n", %(:$rule, :$match, :$data).raku,
    |@children.map: { dump(%$_).indent: 4 if $_ }
}

App {
    $*ERR = $*OUT = open "log.log", :w;
    my $code    := new-state "";
    my $string  := new-state "";
    my $error   := new-state "";
    my @trace   := new-array-state [];
    my %visible := new-hash-state { :GRAMMAR, :INPUT, :TRACE, :MATCH };
    VBox {
        HBox :1size, {
            for <GRAMMAR INPUT TRACE MATCH> -> $label {
                Button(:$label).on-press: {
                    %visible{$label} = !%visible{$label}
                }
            }
        }
        HBox {
            VBox {
                Border :title<Grammar>, {
                    .size: { %visible<GRAMMAR> ?? :flex !! 0 }
                    my $init = q:to/END/;
                    unit grammar MyGrammar;

                    token TOP       { <letter>+ }
                    token letter    { <vowel> || <consonant> }
                    token vowel     { <[aeiou]> }
                    token consonant { <[a..z] - vowel> }
                    END
                    MultiLineInput.focus.text($init).on-change: -> $, $text {
                        $error = "";
                        $code = $text
                    }
                    $code = $init;
                }
                Border :title<Input>, {
                    .size: { %visible<INPUT> ?? :flex !! 0 }
                    my $init = "a";
                    MultiLineInput.text($init).on-change: -> $, $text {
                        $error = "";
                        $string = $text
                    }
                    $string = $init;
                }
            }
            VBox {
                my $resp;
                HBox :size(:5flex), {
                    Border :title<Trace>, :size{ %visible<TRACE> ?? :flex !! 0 }, {
                        my @items = @trace.list;
                        ViewportedCardList {
                            note dump $_ for @items;
                            for @items -> %val {
                                create %val;
                            }
                        }
                    }
                    Border :title<Match>, :size{ %visible<MATCH> ?? :flex !! 0 }, {
                        $ = $string;
                        if $code {
                            CATCH { default { $error = .Str } }
                            my $app          = $*UI-APP;
                            my $node         = $*UI-NODE;
                            # my $grammar-code = "my grammar MyGrammar \{\n\t{ $code }\n\}";
                            my $grammar      = do { GLOBAL:: = {}; $code.EVAL }
                            my @data;
                            my $count = 0;
                            $grammar.^methods.grep({ .WHAT ~~ Regex }).map: -> &rule {
                                &rule.wrap: my method (|c) {
                                    die "Infinite loop" if $count++ > 1_000;
                                    my $indent = $*INDENT // 0;
                                    my @parent := @*CHILDREN;
                                    {
                                        my $*INDENT = $indent + 4;
                                        my %node;
                                        my @*CHILDREN := %node<children> = [];
                                        my \resp     = callsame;
                                        %node<rule>  = &rule.name;
                                        %node<match> = ?resp;
                                        %node<data>  = (resp || resp.orig.substr: resp.from).Str;

                                        @parent.push: %node;

                                        return resp
                                    }
                                }
                            }

                            my $match;
                            with $string {
                                my @*CHILDREN := my @children;
                                $match = $grammar.parse: $string;
                                my %tree := @children.head;
                                %tree<match> = False unless $match;
                                $resp = $match;
                                try @trace.shift;
                                @trace.push: %tree;
                            }
                        .theme: :border($match ?? $s-match !! $s-fail);

                            multi match(Any:U $match) { }
                            multi match(Match $match, Str() :$title = "TOP" --> Int) {
                                my $size = 2;
                                Border :$title, {
                                .theme: $*UI-APP.obj.theme;
                                    VBox {
                                        $size++;
                                        Text :text($match.Str), :size(:1fixed);
                                        if $match.hash {
                                            for $match.hash.kv -> $t, $m {
                                                my @match = $m[];
                                                for @match -> $m {
                                                    $size += match $m, :title($t)
                                                }
                                            }
                                        }
                                        if $match.list {
                                            for $match.list.kv -> $title, $match {
                                                $size += match $match, :$title
                                            }
                                        }
                                    }
                                .size: :fixed($size);
                                }
                                $size
                            }

                            ViewportedCardList {
                                match $match;
                            }
                        }
                    }
                }
                Border :title<Error>, {
                    .theme: border => $s-fail;
                    .size: :fixed( $error ?? $error.split: "\n" !! 0 );
                    given $error -> $text {
                        Text :$text
                    }
                }
            }
        }
    }
}

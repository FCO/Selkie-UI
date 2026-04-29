use Selkie::UI;

App {
    $*ERR = open "log.log", :w;
    $*OUT = open "log2.log", :w;
    my $code   := new-state "";
    my $string := new-state "";
    my $error  := new-state "";
    HBox {
        VBox {
            Border :title("unit grammar MyGrammar; # (ctrl+enter)"), {
                my $init = q:to/END/;
                token TOP {
                    .+
                }
                END
                MultiLineInput.text($init).cursor(:1row, :4col).on-submit: -> $, $text {
                    $error = "";
                    $code = $text
                }
                $code = $init;
            }
            Border :title<String>, {
                my $init = ("a".."z").roll(10).join;
                MultiLineInput.text($init).on-change: -> $, $text {
                    $error = "";
                    $string = $text
                }
                $string = $init;
            }
        }
        VBox {
            Border(:title<Match>, {
                $ = $string;
                if $code {
                    CATCH { default { $error = .Str } }
                    my $app          = $*UI-APP;
                    my $node         = $*UI-NODE;
                    my $grammar-code = "my grammar MyGrammar \{\n\t{ $code }\n\}";
                    my $grammar      = $grammar-code.EVAL;
                    my $match        = $grammar.parse: $string;
                    Text :text($match.gist)
                }
            }).size: :3flex;
            Border :title<Error>, {
                given $error -> $text {
                    Text :$text
                }
            }
        }
    }
}

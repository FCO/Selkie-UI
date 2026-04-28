use Selkie::UI;

App {
    my $code  := new-state "";
    my $error := new-state "";
    HBox {
        Border :title<Code>, {
            MultiLineInput.placeholder('Write your Selkie::UI code').on-change: -> $, $text {
                $error = "";
                $code = $text
            }
        }
        VBox {
            Border(:title<Playground>, {
                if $code {
                    CATCH {
                        default {
                            $error = .Str
                        }
                    }
                    my $app  = $*UI-APP;
                    my $node = $*UI-NODE;
                    [
                        'my $*UI-APP  = $app',
                        'my $*UI-NODE = $node',
                        $code
                    ].join("; ").EVAL
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

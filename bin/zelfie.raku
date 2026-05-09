use Selkie::UI;

$*ERR = $*OUT = open "log.log", :w;

grammar Mod {
    token TOP { <name> <par>* }
    token name { [<-[<:>]>+]+ % "::" }
    token par { ":" <name=.name> "<" ~ ">" $<value>=[.+?] }

}

my $proc = run <zef list>, :out;

my @lines = $proc.out.lines;

my @distros = @lines.map: {
    given Mod.parse: $_ {
        quietly ~.<name> => %(
            .<par>.map: {
                ~.<name> => ~.<value>
            }
        )
    }
}

my %list = @distros.classify: *.key, :as{ .value<> }

my @items = %list.keys.grep(*.so).sort;

App {
    my @names    := new-array-state @items;
    my @selected := new-array-state %list{@items.head};
    my @auth-sel := new-array-state @selected.grep({ .<auth> eq @selected.head<auth> }).unique;
    HBox {
        VBox {
            Border :title<Filter>, :3size, {
                TextInput(:1size).on-change: -> $, Str $text {
                    @names = |@items.grep: *.contains: $text
                }
            }
            Border :title<List>, {
                ListView(:select-first, { @names }).focus.on-select: -> $, $text {
                    @selected = %list{ $text }
                }
            }
        }
        Border :title<Authors>, {
            ListView(:select-first, { @selected.map(*<auth>).unique }).on-select: -> $, $text {
                @auth-sel = @selected.grep: { .<auth> eq $text }
            }
        }
        Border :title<Version>, {
            ListView :select-first, {
                @auth-sel.map({
                    "{ ":ver<{ .Str }>" with .<ver> }{ ":api<{ .Str }>" with .<api>}"
                }).sort.unique.reverse
            }
        }
    }
}

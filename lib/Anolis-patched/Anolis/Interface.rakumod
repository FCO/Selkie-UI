class Anolis::Cell {
    has $.char;
    # E.g. "3", "38;5;9", "38;2;128;133;255"
    has Str $.sgr = '';
}

class Anolis::Interface::Area {
    has Int $.from-x is rw; # inclusive
    has Int $.y;
    has Anolis::Cell @.cells;

    method to-x() { # exclusive
        $!from-x + @!cells.elems;
    }
}

role Anolis::Interface {
    method heading-changed(Str $heading) { ... }
    method grid-changed(@areas) { ... }
    method log(Str $text) { ... }
}

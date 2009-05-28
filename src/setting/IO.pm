class IO is also {

    multi method close() is export {
        try {
            ?$!PIO.close()
        }
        $! ?? fail($!) !! Bool::True
    }

    multi method eof() is export {
        ?$!PIO.eof();
    }

    multi method get() is export {
        $!ins++;
        $!PIO.readline.chomp;
    }

    multi method ins() {
        $!ins;
    }

    multi method lines($limit = *) {
        my @result;
        my $l = $limit ~~ Whatever ?? Inf !! $limit;
        while !$.eof && $l-- > 0 {
            push @result, $!PIO.readline().chomp()
        }
        @result;
    }

    multi method print(*@items) {
        try {
            for @items -> $item {
                $!PIO.print($item);
            }
        }
        $! ?? fail($!) !! Bool::True;
    }

    multi method printf($format, *@args) {
        self.print(sprintf($format, |@args));
    }

    multi method say(*@items) {
        self.print(@items, "\n");
    }

    multi method slurp() {
        $!PIO.readall();
    }

}

multi sub lines(IO $filehandle,
                :$bin = False,
                :$enc = 'Unicode',
                :$nl = "\n",
                :$chomp = True) {

    fail 'Binary mode not supported yet'    if $bin;
    fail 'Encodings not supported yet'      if $enc ne 'Unicode';
    fail 'Fancy newlines not supported yet' if $nl ne "\n";
    fail 'Lack of chomp not supported yet'  if !$chomp;

    $filehandle.lines();
}

# vim: ft=perl6

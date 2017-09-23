
###
https://github.com/asyncly/cdir/blob/223fe0039fade4fad2bb08c2f7affac3bdcf2f89/cdir.js#L24
http://tldp.org/HOWTO/Bash-Prompt-HOWTO/x361.html
http://ascii-table.com/ansi-escape-sequences-vt-100.php
Position the Cursor: \033[<L>;<C>H or \033[<L>;<C>f (puts the cursor at line L and column C)
Move the cursor up N lines: \033[<N>A
Move the cursor down N lines: \033[<N>B
Move the cursor forward N columns: \033[<N>C
Move the cursor backward N columns: \033[<N>D
Clear the screen, move to (0,0): \033[2J
Erase to end of line: \033[K
Save cursor position: \033[s
Restore cursor position: \033[u
###

module.exports = 
    colors:
        Reset      : "\x1b[0m"
        Bright     : "\x1b[1m"
        Dim        : "\x1b[2m"
        Underscore : "\x1b[4m"
        Blink      : "\x1b[5m"
        Reverse    : "\x1b[7m"
        Hidden     : "\x1b[8m"

        FgBlack    : "\x1b[30m"
        FgRed      : "\x1b[31m"
        FgGreen    : "\x1b[32m"
        FgYellow   : "\x1b[33m"
        FgBlue     : "\x1b[34m"
        FgMagenta  : "\x1b[35m"
        FgCyan     : "\x1b[36m"
        FgWhite    : "\x1b[37m"

        BgBlack    : "\x1b[40m"
        BgRed      : "\x1b[41m"
        BgGreen    : "\x1b[42m"
        BgYellow   : "\x1b[43m"
        BgBlue     : "\x1b[44m"
        BgMagenta  : "\x1b[45m"
        BgCyan     : "\x1b[46m"
        BgWhite    : "\x1b[47m"

    pos: (x,y)->
        "\x1B[#{y};#{x}H"
    

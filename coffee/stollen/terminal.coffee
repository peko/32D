
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
    clr:
        Reset      : "\x1B[0m"
        Bright     : "\x1B[1m"
        Dim        : "\x1B[2m"
        Underscore : "\x1B[4m"
        Blink      : "\x1B[5m"
        Reverse    : "\x1B[7m"
        Hidden     : "\x1B[8m"

        FgBlack    : "\x1B[30m"
        FgRed      : "\x1B[31m"
        FgGreen    : "\x1B[32m"
        FgYellow   : "\x1B[33m"
        FgBlue     : "\x1B[34m"
        FgMagenta  : "\x1B[35m"
        FgCyan     : "\x1B[36m"
        FgWhite    : "\x1B[37m"

        BgBlack    : "\x1B[40m"
        BgRed      : "\x1B[41m"
        BgGreen    : "\x1B[42m"
        BgYellow   : "\x1B[43m"
        BgBlue     : "\x1B[44m"
        BgMagenta  : "\x1B[45m"
        BgCyan     : "\x1B[46m"
        BgWhite    : "\x1B[47m"
        
    reset:      -> process.stdout.write "\x1B[2J\x1B[0f\u001B[0;0H"
    pos  : (x,y)-> process.stdout.write "\x1B[#{y};#{x}H"
    write:   (t)-> process.stdout.write t

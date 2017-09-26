
trm = require "./terminal"
cfg = require "./config"

first = true
# Отладочный вывод
stollen_log = (stollen)->

    if first
        first = false
        trm.reset()

    dwarf_colors = ["FgRed", "FgGreen", "FgYellow", "FgBlue", "FgMagenta", "FgCyan"]
    # Очистка термианала
    # trm.reset()
    trm.pos(0,0)
    for r in stollen.map
       for c in r
           switch c
               when cfg.EMPTY    then trm.write '.'
               when cfg.MUSHROOM then trm.write '+'
               when cfg.ROCK     then trm.write "#{trm.clr.BgWhite}/#{trm.clr.Reset}"
               else
                   dwarf_clr = trm.clr[dwarf_colors[c.clan_id%dwarf_colors.length]]
                   dwarf_char = switch
                       when c.action is 'rest'  then rnd ['z', 'Z']
                       when c.action is 'eat'   then 'е'
                       when c.action is 'fight' then rnd ['x','X','*','#','%']
                       else                          '@'
                   trm.write "#{dwarf_clr}#{dwarf_char}#{trm.clr.Reset}"
       trm.write '\n'
    # Выводим статы гномов
    for clan, i in stollen.clans
       j = 0
       for d in clan
           if d?
               j++
               trm.pos(stollen.width+4+i*18,j)
               trm.write "#{d.inv.length} #{d.health} #{d.energy} "
               trm.write trm.clr.FgRed if d.satiety < 0
               trm.write "#{Math.abs(d.satiety)}  "
               trm.write trm.clr.Reset
       trm.pos(stollen.width+4+i*18,j+1)
       trm.write "              "
       trm.pos(stollen.width+4+i*18,j+2)
       trm.write "              "

    # Выводим одного зрение одного гнома
    for clan, i in stollen.clans
       for d in clan
           if d?
               dwarf_log(d, i*d.vision*3, stollen.height+2)
               break
                   
# Вывод информации по гному
dwarf_log = (dwarf, x, y)->
    for row, i in dwarf.introspection.env
        trm.pos x, y+i
        for e, j in row
            switch e
                when cfg.EMPTY    then trm.write "."
                when cfg.MUSHROOM then trm.write "+"
                when cfg.ROCK     then trm.write "#{trm.clr.BgWhite}##{trm.clr.Reset}"
                else
                    if typeof(e) is 'object'
                        clr = if e.enemy then trm.clr.FgRed else trm.clr.FgGreen
                        trm.write "#{clr}@#{trm.clr.Reset}"

rnd = (array)->array[Math.random()*array.length|0]

module.exports =
    stollen_log: stollen_log

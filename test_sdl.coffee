#!/bin/coffee

timeout = 50

sdl = require "node-sdl2"

app = sdl.app
Win = sdl.window

Img = sdl.image
sprites = new Img "img/sprites.png"
dwarf_sprites = []
[0..1].map (i)-> [0..7].map (j)->dwarf_sprites.push [j,i]


win = new Win
    background: 0

win.on 'close', ->
    app.quit()

#win.on 'change', -> draw()

Stollen = require "./stollen/Stollen"

stollen = new Stollen 
    width        :  16
    height       :  16
    max_mushrooms:  20
    dwarfs_per_ai:   3
    rocks_percent: 0.5

# Каждый гном ходит рандомно
ai_fsm   = require "./AIs/basic_fsm.coffee"
ai_fsm_a = require "./AIs/aggresive_fsm.coffee"

stollen.add_ai ai_fsm()
stollen.add_ai ai_fsm_a()
# stollen.add_ai ai_fsm()

EMPTY    = 0
MUSHROOM = 1
ROCK     = 2

ss = 16
sc =  2
draw = ->

    stollen.update()
    # stollen.log()

    ctx = win.render
    gfx = ctx.gfx
    
    size = ctx.outputSize
    
    for r, y in stollen.map 
        for c, x in r
            sp = switch
                when typeof c is'object' then dwarf_sprites[c.dwarf_id%dwarf_sprites.length]
                when c is MUSHROOM       then [1, 2]
                when c is ROCK           then [0, 2]
                else  [2, 2]
                    
            ctx.copy sprites.texture(ctx), [sp[0]*ss,sp[1]*ss,ss,ss], [x*ss*sc, y*ss*sc, ss*sc, ss*sc]

    dx = stollen.width*16*sc+8
    ctx.color = 0
    ctx.fillRect [[dx, 0,(ss*sc+64)*2, 32*16]]
    for clan, i in stollen.clans
        for dwarf, j in clan
            if dwarf?
                x = dx+i*(ss*sc+48)
                y = 8 +j*(ss*sc+4)
                dwarf_stats dwarf, ctx, x, y
    ctx.present()

stat_color = (v)-> switch
    when    v> 75 then 0x00A000
    when 25<v<=75 then 0xA0A000
    else               0xA00000

dwarf_stats = (dwarf, ctx, x, y)->

    sp = dwarf_sprites[dwarf.dwarf_id%dwarf_sprites.length]
    ctx.copy sprites.texture(ctx), [sp[0]*ss,sp[1]*ss,ss,ss], [x, y, ss*sc, ss*sc]
    x+=16*sc+2
    ctx.color = stat_color dwarf.health
    ctx.fillRect [[x,y+0, dwarf.health *0.01*32|0, 2]]
    ctx.color = stat_color dwarf.energy
    ctx.fillRect [[x,y+3, dwarf.energy *0.01*32|0, 2]]
    ctx.color = stat_color dwarf.satiety
    ctx.fillRect [[x,y+6, dwarf.satiety*0.01*32|0, 2]]
    ctx.color = 0xFFFFFF
    [0..dwarf.inv.length].map (i)-> ctx.fillRect [[x+i*3,y+9,2,2]]
    

setInterval draw, timeout

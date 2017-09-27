#!/bin/coffee

timeout = 100

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
    width        :  32
    height       :  32
    max_mushrooms:  20
    dwarfs_per_ai:   8
    rocks_percent: 0.5

# Каждый гном ходит рандомно
ai_fsm = require "./AIs/basic_fsm.coffee"
ai_fsm_a = require "./AIs/aggresive_fsm.coffee"

stollen.add_ai ai_fsm()
stollen.add_ai ai_fsm_a()
# stollen.add_ai ai_fsm()

tick = ->

setInterval tick, 50

EMPTY    = 0
MUSHROOM = 1
ROCK     = 2

ss = 16
sc =  1
draw = ->

    stollen.update()
    # stollen.log()

    ctx = win.render
    size = ctx.outputSize
    for r, y in stollen.map 
        for c, x in r
            sp = switch
                when typeof c is'object' then dwarf_sprites[c.dwarf_id%dwarf_sprites.length]
                when c is MUSHROOM       then [1, 2]
                when c is ROCK           then [0, 2]
                else  [2, 2]
                    
            ctx.copy sprites.texture(ctx), [sp[0]*ss,sp[1]*ss,ss,ss], [x*ss*sc, y*ss*sc, ss*sc, ss*sc]

    ctx.present()

setInterval draw, timeout

#!/usr/bin/coffee

Stollen = require "./Stollen"
stollen = new Stollen 80, 40

# Marшируем туда/сюда
ai2_dir = "n"
ai2 = (dwarf)->
    if Math.random()>0.99
        ai2_dir = ["n", "e", "s", "w", "eat", "rest"][Math.random()*6|0]
    ai2_dir

# Рандомно ходит
ai1 = (dwarf)->
    a = ["n", "w", "e", "s", "rest", "eat"]
    a[Math.random()*a.length|0]

stollen.add_ai ai1
stollen.add_ai ai2

cnt=0
tick = ->
    stollen.update()
    stollen.log()

setInterval tick, 100

#!/usr/bin/coffee

World = require "./World"
world = new World 80, 40

# Все время спит
ai1 = (dwarf)->"rest"

# Marшируем туда/сюда
ai2_dir = "n"
ai2 = (dwarf)->
    if Math.random()>0.99
        ai2_dir = ["n", "e", "s", "w", "eat", "rest"][Math.random()*6|0]
    ai2_dir

# Рандомно ходит
ai3 = (dwarf)->
    a = ["n", "w", "e", "s", "rest", "eat"]
    a[Math.random()*a.length|0]

world.add_ai ai1
world.add_ai ai2
world.add_ai ai3

cnt=0
tick = ->
    world.update()
    world.log()

setInterval tick, 100

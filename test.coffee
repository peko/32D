#!/usr/bin/coffee

World = require "./World"

world = new World 50, 50


# Все время спит
ai1 = (dwarf)->"rest"

# Идет на север
ai2 = (dwarf)->"n"

# Рандомно ходит
ai3 = (dwarf)->
    a = ["n", "w", "e", "s", "rest", "eat"]
    a[Math.random()*a.length|0]

world.add_ai ai1
world.add_ai ai2
world.add_ai ai3

tick = ->
    world.update()
    world.log()
    
setInterval tick, 1000

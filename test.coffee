#!/usr/bin/coffee

Stollen = require "./Stollen"
stollen = new Stollen 80, 40

base_actions = ["n", "e", "s", "w", "eat", "rest", "grab", "dig", "fight"]
# Гномы ходят строем
ai1_action = "rest"
ai1 = (dwarf)->
    if Math.random()>0.99
        ai1_action = base_actions[Math.random()*base_actions.length|0]
    ai1_action

# Каждый гном ходит рандомно
ai2 = (dwarf)->
    base_actions[Math.random()*base_actions.length|0]

stollen.add_ai ai2
stollen.add_ai ai2
stollen.add_ai ai2
stollen.add_ai ai2
stollen.add_ai ai2

cnt=0
tick = ->
    stollen.update()
    stollen.log()

setInterval tick, 10


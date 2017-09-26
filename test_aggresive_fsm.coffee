#!/usr/bin/coffee

Stollen = require "./stollen/Stollen"
trm     = require "./stollen/terminal"

stollen = new Stollen 
    width        :  40
    height       :  20
    max_mushrooms:  20
    dwarfs_per_ai:   5
    rocks_percent: 0.2

# Каждый гном ходит рандомно
ai_fsm = require "./AIs/basic_fsm.coffee"
ai_fsm_a = require "./AIs/aggresive_fsm.coffee"

stollen.add_ai ai_fsm()
stollen.add_ai ai_fsm_a()
# stollen.add_ai ai_fsm()

tick = ->
    stollen.update()
    stollen.log()

setInterval tick, 50

trm.reset()

#!/usr/bin/coffee

Stollen = require "./stollen/Stollen"
trm     = require "./stollen/terminal"

stollen = new Stollen 
    width        :  40
    height       :  20
    max_mushrooms: 100
    dwarfs_per_ai:   5
    rocks_percent: 0.1

# Каждый гном ходит рандомно
ai = require "./AIs/random"
ai_fsm = require "./AIs/basic_fsm.coffee"

# stollen.add_ai ai
stollen.add_ai ai_fsm

tick = ->
    stollen.update()
    stollen.log()

setInterval tick, 100

trm.reset()

#!/usr/bin/coffee

Stollen = require "./stollen/Stollen"
{stollen_log} = require "./stollen/utils"

stollen = new Stollen 
    width        :  40
    height       :  40
    max_mushrooms:  20
    dwarfs_per_ai:  15
    rocks_percent: 0.2

# Каждый гном ходит рандомно
ai_fsm = require "./AIs/basic_fsm.coffee"
{stollen_log} = require "./stollen/utils"

stollen.add_ai ai_fsm()
stollen.add_ai ai_fsm()
stollen.add_ai ai_fsm()

tick = ->
    stollen.update()
    stollen_log stollen

setInterval tick, 50


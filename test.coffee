#!/usr/bin/coffee

Stollen = require "./stollen/Stollen"
stollen = new Stollen 40, 20

# Каждый гном ходит рандомно
ai = require "./AIs/random"

stollen.add_ai ai
stollen.add_ai ai
stollen.add_ai ai

tick = ->
    stollen.update()
    stollen.log()

setInterval tick, 10


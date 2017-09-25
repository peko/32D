#!/usr/bin/coffee
readline = require "readline"
TIMEOUT = 10
EXIT_KEY = 'q'

Stollen = require "./stollen/Stollen"
stollen = new Stollen 40, 20


# Каждый гном ходит рандомно
ai = require "./AIs/random"
ai_fsm = require "./AIs/basic_fsm.coffee"

# stollen.add_ai ai
stollen.add_ai ai_fsm

quit = 0

process.stdin.setRawMode(true)
process.stdin.resume
process.stdin.setEncoding 'utf8'
 
process.stdin.on('data', (chunk) ->
    if chunk == EXIT_KEY
        quit = 1
)

tick = (() ->
    stollen.update()
    stollen.log()
    if quit == 1 
        process.exit 0
    setTimeout (tick), TIMEOUT
)

setTimeout (tick), TIMEOUT

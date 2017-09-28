#!/usr/bin/coffee

TIMEOUT = 10
EXIT_KEY = 'q'

Stollen = require "./stollen/Stollen"
{stollen_log} = require "./stollen/utils"
    
stollen = new Stollen 
    width        : 40
    height       : 20
    dwarfs_per_ai: 10
    rocks_percent: 0.1

# Каждый гном ходит рандомно
ai = require "./AIs/random"

stollen.add_ai ai
stollen.add_ai ai
stollen.add_ai ai

quit = 0

process.stdin.setRawMode(true)
process.stdin.resume
process.stdin.setEncoding 'utf8'
 
process.stdin.on 'data', (chunk) ->
    if chunk == EXIT_KEY
        quit = 1


tick = ()->
    stollen.update()
    stollen_log stollen
    if quit == 1 
        process.exit 0
    setTimeout tick, TIMEOUT


setTimeout tick, TIMEOUT

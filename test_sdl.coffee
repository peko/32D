sdl = require "node-sdl2"

app = sdl.app
Win = sdl.window

Img = sdl.image
dorfs = new Img "img/dorfs.png"

win = new Win
win.on 'close', ->
    app.quit()

win.on 'change', -> draw()


ss = 16
sc =  1
draw = ->
    ctx = win.render
    size = ctx.outputSize
    for y in [0...20]
        for x in [0...20]
            tx = Math.random()*4|0
            ty = Math.random()*4|0
            ctx.copy dorfs.texture(ctx), [tx*ss,ty*ss,ss,ss], [x*ss*sc, y*ss*sc, ss*sc, ss*sc]
    ctx.present()

setInterval draw, 100

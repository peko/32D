###
Основная задача разработать ai гнома
В данной симуляции ai это метод,
получающий на вход внутренние параметры гнома и
выдающий на выходе действие которое необходимо осуществить

action = ai(dwarf)
dwarf:
   id  : 0..m   # id гнома
   hl  : 0..100 # здоровье
   en  : 0..100 # энергия
   st  : 0..100 # сытость  
   env : []     # окружающие гнома объекты
   inv : []     # инвентарь
action:
   rest           - передохнуть
   eat            - съесть грибочек
   grab, drop     - подобрать / бросить грибочек
   n, e, s, w     - идти на с, в, ю, з
   dn, de, ds, dw - копать на с, в, ю, з
   an, ae, as, aw - атаковать с, в, ю, з
env:   - массив (VISION*2+1 x VISION*2+1]
   0   - пусто
   1   - грибочек
   2   - камень
   dwarf:
      enemy: true/false
      hl   : 0..100
###

EMPTY    = 0
MUSHROOM = 1
ROCK     = 2

MAX_MUSHROOMS = 20
MAX_DWARFS    = 33  # Один гном запасной :3

class World

    musrom_cnt: 0
    constructor: (@W, @H)->
       @colonies = []
       @mushroms = []
       @map = []
       for y in [0...@H]
           @map[y] = []
           for x in [0...@W]
               @map[y][x] = if Math.random()>0.75 then ROCK else EMPTY
              

    # Тик мира
    update: ->
        @grow_mushroms()
        # все гномы мира
        dwarfs = [].concat.apply([], @colonies)
        # перемешиваем случайным образом
        for d, i in dwarfs
            j = Math.random()*dwarfs.length|0
            [dwarfs[i], dwarfs[j]] = [dwarfs[j], dwarfs[i]]
        for d in dwarfs
            d.update(@)
            
    # новая колония
    add_ai:(ai)->
        # id колонии
        colony_id = @colonies.length
        colony = []
        x = Math.random()*@W|0
        y = Math.random()*@H|0
        for dwarf_id in [1..MAX_DWARFS]
            [xd, yd] = @get_nearest_free_place(x, y)
            dwarf = new Dwarf(@, colony_id, dwarf_id, ai, xd, yd)
            @set_element_at xd, yd, dwarf
            colony.push dwarf

        @colonies.push colony
        colony

    # Назначаение элемента карте
    set_element_at: (x, y, e)->
        x%=@W
        y%=@H
        x=@W+x if x<0
        y=@H+y if y<0
        @map[y][x] = e
        
    # Получение объекта мира по координатам
    get_element_at:(x, y)->
        x%=@W
        y%=@H
        x=@W+x if x<0
        y=@H+y if y<0
        @map[y][x]

    # Ближайшее пустое место вокруг точки
    get_nearest_free_place: (x, y)->

        e = @get_element_at x, y
        return [x, y] if e is EMPTY
        
        for r in [1..20]
            steps = r*Math.PI
            for a in [0...steps]
                x1 = (x+Math.sin(a*Math.PI*2/steps)*r)|0
                y1 = (y+Math.cos(a*Math.PI*2/steps)*r)|0
                e = @get_element_at x1, y1
                return [x1, y1] if e is EMPTY


    move_element_at: ( x, y, d)->
        
    # Элементы вокруг точки начиная с N
    # d=1 N     d=2 N  
    #             ..123     
    #    812      .   4
    #  W 7@3 E   W. @ 5E
    #    654      .   6
    #             ..987
    #     S         S
    get_elements_arround: (x, y, o)->
        elements = []
        # N
        for i in [0..d]
            elements.push @get_element_at x+i, y+d
        # E
        for i in [-d+1..d]
            elements.push @get_element_at x+d, y+i
        # S
        for i in [-d+1..d]
            elements.push @get_element_at x-i, y-d
        # W
        for i in [-d+1..d]
            elements.push @get_element_at x-d, y-i
        # N
        for i in [-d+1..-1]
            elements.push @get_element_at x+i, y+d

        elements
            
    # Элементы вокруг точки квадратная матрица 2d+1 x 2d+1
    get_elements_rect:(x, y, d)->
        elements = []
        for i in [-d..d]
            for j in [-d..d]
                elements.push @get_element_at x, y

        elements

    # Случайное пустое место на карте   
    get_random_free_place: ->
        for i in [0...100]
            x = Math.random()*@W|0
            y = Math.ranodm()*@H|0
            e = @get_element_at x, y
            return [x,y] if e is EMPTY
        return [0, 0]

    # Выращиваем грибочки     
    grow_mushroms: ->
        while @mushrom_cnt<MAX_MUSHROOMS
            [x,y] = @get_random_free_place()    
            @set_element_at(x, y, MUSHROOM)
            @mushroms_cnt++

    log:->
       w = (t)->process.stdout.write t
       dwarf_colors = ["FgRed", "FgGreen", "FgYellow", "FgBlue", "FgMagenta", "FgCyan"]
       # Очистка термианала
       w '\x1B[2J\x1B[0f\u001b[0;0H'
       for r in @map
           for c in r
               switch c
                   when 0 then w '.'
                   when 1 then w '~'
                   when 2 then w '#'
                   else
                       dwarf_color = terminal_colors[dwarf_colors[c.colony_id%dwarf_colors.length]]
                       w "#{dwarf_color}@#{terminal_colors.Reset}"
           w '\n'

terminal_colors =
    Reset      : "\x1b[0m"
    Bright     : "\x1b[1m"
    Dim        : "\x1b[2m"
    Underscore : "\x1b[4m"
    Blink      : "\x1b[5m"
    Reverse    : "\x1b[7m"
    Hidden     : "\x1b[8m"

    FgBlack    : "\x1b[30m"
    FgRed      : "\x1b[31m"
    FgGreen    : "\x1b[32m"
    FgYellow   : "\x1b[33m"
    FgBlue     : "\x1b[34m"
    FgMagenta  : "\x1b[35m"
    FgCyan     : "\x1b[36m"
    FgWhite    : "\x1b[37m"

    BgBlack    : "\x1b[40m"
    BgRed      : "\x1b[41m"
    BgGreen    : "\x1b[42m"
    BgYellow   : "\x1b[43m"
    BgBlue     : "\x1b[44m"
    BgMagenta  : "\x1b[45m"
    BgCyan     : "\x1b[46m"
    BgWhite    : "\x1b[47m"

# Цена действия
#          hl  en  st 
action_costs =
    rest: [+5, +5, -1] # Отдыхаем +5 здоровья +5 энергии  -1 сытость 
    eat:  [+5, -1,+20] # Едим     +5 здоровья -1 энергии +20 сытость

    grab: [ 0, -1, -1] # подбираем грибочек
    drop: [ 0, -1, -1] # борсаем грибочек
    
    n:    [ 0, -1, -1] # идем на север
    е:    [ 0, -1, -1] # ....... восток
    s:    [ 0, -1, -1] # ....... юг
    w:    [ 0, -1, -1] # ....... запад

    dig:  [ 0, -2, -2] # копаем слуайное ближайшее место
    dn:   [ 0, -2, -2] # копаем на север
    dе:   [ 0, -2, -2] # ......... восток
    ds:   [ 0, -2, -2] # ......... юг
    dw:   [ 0, -2, -2] # ......... запад

    fight:[ 0, -2, -2] # атакуем ближайшего гнома из другого клана
    fn:   [ 0, -2, -2] # атакуем на север
    fw:   [ 0, -2, -2] # .......... восток
    fe:   [ 0, -2, -2] # .......... юг
    fs:   [ 0, -2, -2] # .......... запад


class Dwarf

    @vision: 5
    
    constructor:(@world, @colony_id, @dwarf_id, @ai, @x, @y)->
        @inv     = [MUSHROOM, MUSHROOM, MUSHROOM]
        @heath   = 100
        @energy  = 100
        @satiety = 100
        
    # Тик гнома
    update:->

        env = @world.get_elements_rect @x, @y, Dwarf.vision
        # Интроспекция — метод углубленного исследования и познания моментов собственной активности:
        # отдельных мыслей, образов, чувств, переживаний, актов мышления как деятельности разума.
        introspection =
            id: @id
            hl: @health
            en: @energy
            st: @satiety
            inv: @inv.slice(0)
            env: env
            
        @do_action @ai? introspection
    
    do_action:(a)->
       a = "rest" unless a? or action_costs[a]?
       cost = action_costs[a]
       
       if cost?
           @health  += cost[0]
           @energy  += cost[1]
           @satiety += cost[2]
      
       if @satiety < 0
          @health += @satiety

       if @health <= 0
          return false
       
       true

module.exports = World

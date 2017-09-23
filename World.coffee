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

terminal = require "./terminal"
cfg      = require "./config"

EMPTY    = 0
MUSHROOM = 1
ROCK     = 2

class World

    mushroom_cnt: 0
    constructor: (@W, @H)->
       @colonies = []
       @mushroms = []
       @map = []
       for y in [0...@H]
           @map[y] = []
           for x in [0...@W]
               @map[y][x] = if Math.random()>0.85 then ROCK else EMPTY
       @grow_mushrooms()

    # Тик мира
    update: ->
        @grow_mushrooms()
        # все гномы мира
        dwarfs = [].concat.apply([], @colonies)
        # перемешиваем случайным образом
        for d, i in dwarfs
            j = Math.random()*dwarfs.length|0
            [dwarfs[i], dwarfs[j]] = [dwarfs[j], dwarfs[i]]

        for d in dwarfs
            d?.update(@)
            
    # новая колония
    add_ai:(ai)->
        # id колонии
        colony_id = @colonies.length
        colony = []
        x = Math.random()*@W|0
        y = Math.random()*@H|0
        for dwarf_id in [0...cfg.max_dwarfs]
            [xd, yd] = @get_nearest_free_place(x, y)
            dwarf = new Dwarf(@, colony_id, dwarf_id, ai, xd, yd)
            @set_element_at xd, yd, dwarf
            colony[dwarf_id] = dwarf

        @colonies.push colony
        colony

    # Назначаение элемента карте
    set_element_at: (x, y, e)->
        x%=@W
        y%=@H
        x=@W+x if x<0
        y=@H+y if y<0
        e.x = x if e.x?
        e.y = y if e.y?
        @map[y][x] = e
         
    # Получение объекта мира по координатам
    get_element_at: (x, y)->
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

    # Перемещаем элемент если в заданном направлении
    move_element_at: (x, y, d)->
        return unless d in ["n", "e", "s", "w"]
        delta =
            n: x: 0, y:-1
            e: x:+1, y: 0
            s: x: 0, y:+1
            w: x:-1, y: 0
        d = delta[d]

        e = @get_element_at x, y
        t = @get_element_at x+d.x, y+d.y
        return unless t is EMPTY
        
        @set_element_at x+d.x, y+d.y, e
        @set_element_at     x,     y, EMPTY
        
        
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
    get_elements_rect: (x, y, d)->
        elements = []
        for i in [-d..d]
            for j in [-d..d]
                elements.push @get_element_at x, y

        elements

    # Элементы до которых можно дотянутся
    get_reacheble_elements: (x, y)->[
        @get_element_at(x  , y-1)  # N
        @get_element_at(x+1, y  )  # E
        @get_element_at(x  , y+1)  # S
        @get_element_at(x-1, y  )] # W
    search_reacheble_elements: (x, y, type)->
        return [x  , y-1] if @get_element_at(x  , y-1) is type
        return [x+1, y  ] if @get_element_at(x+1, y  ) is type
        return [x  , y+1] if @get_element_at(x  , y+1) is type
        return [x-1, y  ] if @get_element_at(x-1, y  ) is type
        undefined
        
    # Случайное пустое место на карте   
    get_random_free_place: ->
        for i in [0...100]
            x = Math.random()*@W|0
            y = Math.random()*@H|0
            e = @get_element_at x, y
            return [x,y] if e is EMPTY
        return [0, 0]
    
    # Выращиваем грибочки     
    grow_mushrooms: ->
        while @mushroom_cnt<cfg.max_mushrooms
            [x,y] = @get_random_free_place()
            @set_element_at(x, y, MUSHROOM)
            @mushroom_cnt++

    # Гном умер
    remove_dwarf: (dwarf)->
        @set_element_at dwarf.x, dwarf.y, EMPTY
        delete @colonies[dwarf.colony_id][dwarf.dwarf_id]

    log:->
       w = (t)->process.stdout.write t
       dwarf_colors = ["FgRed", "FgGreen", "FgYellow", "FgBlue", "FgMagenta", "FgCyan"]
       # Очистка термианала
       w '\x1B[2J\x1B[0f\u001b[0;0H'
       for r in @map
           for c in r
               switch c
                   when EMPTY    then w '.'
                   when MUSHROOM then w 'o'
                   when ROCK     then w '\x1b[47m\x1b[2m%\x1b[0m'
                   else
                       dwarf_color = terminal.colors[dwarf_colors[c.colony_id%dwarf_colors.length]]
                       w "#{dwarf_color}@#{terminal.colors.Reset}"
           w '\n'
           
       # Выводим гномов
       for colony, i in @colonies
           for d, j in colony
               w "#{terminal.pos(@W+4+i*18, j+2)}"
               if d?
                   w "#{d.health} #{d.energy} #{d.satiety} #{d.action}"
               else
                   w "#{terminal.colors.FgRed}dead#{terminal.colors.Reset}"

class Dwarf

    @vision: 5
    
    constructor:(@world, @colony_id, @dwarf_id, @ai, @x, @y)->
        @inv     = [MUSHROOM, MUSHROOM, MUSHROOM]
        @health  = 100
        @energy  = 100
        @satiety = 100
        
    # Тик гнома
    update:->

        env = @world.get_elements_rect @x, @y, Dwarf.vision

        # Интроспекция — метод углубленного исследования и познания моментов собственной активности:
        # отдельных мыслей, образов, чувств, переживаний, актов мышления как деятельности разума.
        introspection =
            id : @id
            hl : @health
            en : @energy
            st : @satiety
            inv: @inv.slice(0)
            env: env
            
        @do_action @ai? introspection
    
    do_action: (@action)->
        
       @action = "rest" unless @action? or cfg.action_costs[@action]?

       cost = cfg.action_costs[@action]
       
       # Обновляем параметры гнома 
       if cost?
            @update_stats cost

       # Голодаем    
       if @satiety <= 0
           @health += @satiety

       # Умираем
       if @health <= 0
           return @die()

       # Нет сил - сделать ничего не можем
       if @energy <=0
           return
           
       switch @action
           when "n", "e", "s", "w"
               @world.move_element_at @x, @y, @action

           when "eat"
               mushroom_pos = @world.search_reacheble_elements @x, @y, MUSHROOM
               if mushroom_pos?
                   @world.set_element_at mushroom_pos[0], mushroom_pos[1], EMPTY
                   @update_stats cfg.resource_costs[MUSHROOM]
                   
    update_stats: (cost)->
       @health  += cost[0]
       @energy  += cost[1]
       @satiety += cost[2]
       @health  = 100 if @health  > 100
       @energy  = 100 if @energy  > 100
       @satiety = 100 if @satiety > 100

       @energy  = 0 if @energy  < 0

    # Гном умер, просто удаляем его из мира
    die: ->
       @world.remove_dwarf @


module.exports = World

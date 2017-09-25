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

trm = require "./terminal"
cfg = require "./config"

# Штольня
class Stollen

    mushroom_cnt :  0   # Счетчик грибочков
    max_mushrooms:100   # Максиму гробочков
    width        : 40   # Ширина штольни
    height       : 20   # высота штольни
    dwarfs_per_ai: 10   # Гномов в клане
    rocks_percent: 0.5  # Плотность породы

    constructor: (settings)->
        @[n]=v for n, v of settings
        @clans = []
        @mushroms = []
        @map = []
        for y in [0...@height]
            @map[y] = []
            for x in [0...@width]
                @map[y][x] = if Math.random() < @rocks_percent then cfg.ROCK else cfg.EMPTY
        console.log @rocks_percent, cfg.ROCK, cfg.EMPTY

        @grow_mushrooms()

    # Тик мира
    update: ->
        
        # Закон грибочков
        @grow_mushrooms()
        
        # все гномы мира
        dwarfs = [].concat.apply([], @clans)

        # Закон тапков
        # гномы дейтвуют в случайном порядке
        for d, i in dwarfs
            j = Math.random()*dwarfs.length|0
            [dwarfs[i], dwarfs[j]] = [dwarfs[j], dwarfs[i]]

        # Тик гномов 
        for d in dwarfs
            d?.update(@)
            
    # новая колония
    add_ai:(ai)->
        # id колонии
        clan_id = @clans.length
        clan = []
        x = Math.random()*@width |0
        y = Math.random()*@height|0
        for dwarf_id in [0...@dwarfs_per_ai]
            [xd, yd] = @get_nearest_free_place x, y
            dwarf = new Dwarf(@, clan_id, dwarf_id, ai, xd, yd)
            @set_element_at xd, yd, dwarf
            clan[dwarf_id] = dwarf

        @clans.push clan
        clan

    # Назначаение элемента карте
    set_element_at: (x, y, e)->
        x%= @width
        y%= @height
        x = @width+x if x<0
        y = @height+y if y<0
        e.x = x if e.x?
        e.y = y if e.y?
        @map[y][x] = e
         
    # Получение объекта мира по координатам
    get_element_at: (x, y)->
        x%= @width
        y%= @height
        x = @width+x  if x<0
        y = @height+y if y<0
        @map[y][x]

    # Ближайшее пустое место вокруг точки
    get_nearest_free_place: (x, y)->
        e = @get_element_at x, y
        return [x, y] if e is cfg.EMPTY
        for r in [1..20]
            steps = r*Math.PI
            for a in [0...steps]
                x1 = (x+Math.sin(a*Math.PI*2/steps)*r)|0
                y1 = (y+Math.cos(a*Math.PI*2/steps)*r)|0
                e = @get_element_at x1, y1
                return [x1, y1] if e is cfg.EMPTY

    # Перемещаем элемент если в заданном направлении
    move_element_at: (x, y, d)->
        return unless d in ["n", "e", "s", "w"]
        delta =
            n: [ 0, -1]
            e: [+1,  0]
            s: [ 0, +1]
            w: [-1,  0]
        d = delta[d]

        e = @get_element_at x, y
        t = @get_element_at x+d[0], y+d[1]
        return unless t is cfg.EMPTY
        
        @set_element_at x+d[0], y+d[1], e
        @set_element_at x     , y     , cfg.EMPTY
        
        
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
        rows = []
        for i in [-d..d]
            cols = []
            for j in [-d..d]
                cols.push @get_element_at x+j, y+i
            rows.push cols
        rows

    # Элементы до которых можно дотянутся
    get_reacheble_elements: (x, y)->[
        @get_element_at(x  , y-1)  # N
        @get_element_at(x+1, y  )  # E
        @get_element_at(x  , y+1)  # S
        @get_element_at(x-1, y  )] # W
        
    # Ищем ближайший объект
    get_nearest_object: (x, y, obj_id)->
        for pos in [[0,-1], [+1,0], [0,+1], [-1,0]]
            return [x+pos[0],y+pos[1]] if @get_element_at(x+pos[0], y+pos[1]) is obj_id
        undefined
        
    # Ищем ближайжих гномов
    get_nearest_dwarfs: (x, y)->
        dwarfs = []
        for pos in [[0,-1], [+1,0], [0,+1], [-1,0]]
            d = @get_element_at(x+pos[0], y+pos[1])
            dwarfs.push d if d instanceof Dwarf
        return dwarfs
        
    # Случайное пустое место на карте   
    get_random_free_place: ->
        for i in [0...100]
            x = Math.random()*@width|0
            y = Math.random()*@height|0
            e = @get_element_at x, y
            return [x,y] if e is cfg.EMPTY
        return [0, 0]
    
    # Выращиваем грибочки
    grow_mushrooms: ->
        while @mushroom_cnt<@max_mushrooms
            [x,y] = @get_random_free_place()
            @set_element_at(x, y, cfg.MUSHROOM)
            @mushroom_cnt++

    # Гном отправляет в Валхаллу
    move_to_valhalla: (dwarf)->
        # Гном исчезает с карты
        @set_element_at dwarf.x, dwarf.y, cfg.EMPTY
        # Грибочки остаются
        @mushroom_cnt -= dwarf.inv.length
        # Колония сиротеет
        delete @clans[dwarf.clan_id][dwarf.dwarf_id]

    # Отладочный вывод
    log:->
       dwarf_colors = ["FgRed", "FgGreen", "FgYellow", "FgBlue", "FgMagenta", "FgCyan"]
       # Очистка термианала
       # trm.reset()
       trm.pos(0,0)
       for r in @map
           for c in r
               switch c
                   when cfg.EMPTY    then trm.write '.'
                   when cfg.MUSHROOM then trm.write '+'
                   when cfg.ROCK     then trm.write "#{trm.clr.BgWhite}/#{trm.clr.Reset}"
                   else
                       dwarf_clr = trm.clr[dwarf_colors[c.clan_id%dwarf_colors.length]]
                       trm.write "#{dwarf_clr}@#{trm.clr.Reset}"
           trm.write '\n'
           
       # Выводим статы гномов
       for clan, i in @clans
           j = 0
           for d in clan
               if d?
                   j++
                   trm.pos(@width+4+i*18,j)
                   trm.write "#{d.inv.length} #{d.health} #{d.energy} "
                   trm.write trm.clr.FgRed if d.satiety < 0
                   trm.write "#{Math.abs(d.satiety)}  "
                   trm.write trm.clr.Reset
           trm.pos(@width+4+i*18,j+1)
           trm.write "              "
           trm.pos(@width+4+i*18,j+2)
           trm.write "              "

       # Выводим одного зрение одного гнома
       for clan, i in @clans
           for d in clan
               if d?
                   d.log(i*Dwarf.vision*3, @height+2)
                   break

# Гном в вакуме
class Dwarf

    @vision: 5
    
    constructor:(@world, @clan_id, @dwarf_id, @ai, @x, @y)->
        @inv     = [cfg.MUSHROOM, cfg.MUSHROOM, cfg.MUSHROOM]
        @health  = 100
        @energy  = 100
        @satiety = 100
        
    # Тик гнома
    update:->

        env = @world.get_elements_rect @x, @y, Dwarf.vision
        for row, i in env
            for d, j in row
                if d instanceof Dwarf
                    row[j] =
                        enemy : d.clan_id isnt @clan_id
                        health: d.health
                        
        # Интроспекция — метод углубленного исследования и познания моментов собственной активности:
        # отдельных мыслей, образов, чувств, переживаний, актов мышления как деятельности разума.
        @introspection =
            id : @id
            hl : @health
            en : @energy
            st : @satiety
            inv: @inv.slice(0)
            env: env
            
        @do_action @ai? @introspection
    
    do_action: (@action)->
        
       @action = "rest" unless @action? and cfg.action_costs[@action]?

       cost = cfg.action_costs[@action]
       
       # Обновляем параметры гнома 
       if cost?
            @update_stats cost

       # Голодаем    
       if @satiety <= 0
           @health += @satiety*0.1|0

       # Умираем
       if @health <= 0
           return @valhalla()

       # Нет сил - сделать ничего не можем
       if @energy <=0
           return
           
       switch @action
           when           "n",  "e",  "s",  "w"       then @world.move_element_at @x, @y, @action
           when "eat"  , "en", "ee", "es", "ew", "ei" then @eat   @action
           when "dig"  , "dn", "de", "ds", "dw"       then @dig   @action
           when "fight", "an", "ae", "as", "aw"       then @fight @action
           when "grab" , "gn", "ge", "gs", "gw"       then @take  @action

    # Съесть грибочек если есть рядом или из инвентаря      
    eat: (action)->
        unless @eat_near()
            @eat_from_inv()
            
    # Съесть грибочек рядом        
    eat_near: ->
        mushroom_pos = @world.get_nearest_object @x, @y, cfg.MUSHROOM

        if mushroom_pos?
           @world.set_element_at mushroom_pos[0], mushroom_pos[1], cfg.EMPTY
           @update_stats cfg.resource_costs[cfg.MUSHROOM]
           @world.mushroom_cnt--
           return true
        false
        
    # Съесть грибочек из инвентаря 
    eat_from_inv: ->
        if @inv.length
            @inv.pop()
            @update_stats cfg.resource_costs[cfg.MUSHROOM]
            @world.mushroom_cnt--
            return true
        return false
        
    # Взять грибочек с собой
    take: ->
        mushroom_pos = @world.get_nearest_object @x, @y, cfg.MUSHROOM
        if mushroom_pos?
           @world.set_element_at mushroom_pos[0], mushroom_pos[1], cfg.EMPTY
           @inv.push cfg.MUSHROOM
           return true
        false
        
    # Копать породу
    dig: (action)->
        rock_pos = @world.get_nearest_object @x, @y, cfg.ROCK
        if rock_pos?
           @world.set_element_at rock_pos[0], rock_pos[1], cfg.EMPTY
           return true
        false

    # Драться
    fight: (action)->
        dwarfs = @world.get_nearest_dwarfs @x, @y

        # Бьём одного ближайшего гнома из чужего клана
        for d in dwarfs
            if d.clan_id is not @clan_id
                d.health -= Math.random()*10|0
                return

        # Врагов нет, бьём любого ближайшего гнома
        for d in dwarfs
            d.health -= Math.random()*10|0
            return

        for d in dwarfs
            if d.clan_id is not @clan_id
                d.health -= Math.random()*10|0
                return

    # Обновляем параметры гнома
    update_stats: (cost)->
        @health += cost[0]
        @energy += cost[1]
        @satiety+= cost[2]
        @health  = 100 if @health  > 100
        @energy  = 100 if @energy  > 100
        @satiety = 100 if @satiety > 100
        @energy  =   0 if @energy  <   0

    # Гном отправляется в Вальхаллу
    valhalla: ->
        @world.move_to_valhalla @

    # Вывод информации по гному
    log: (x, y)->
        for row, i in @introspection.env
            trm.pos x, y+i
            for e, j in row
                switch e
                    when cfg.EMPTY    then trm.write "."
                    when cfg.MUSHROOM then trm.write "+"
                    when cfg.ROCK     then trm.write "#{trm.clr.BgWhite}##{trm.clr.Reset}"
                    else
                        if typeof(e) is 'object'
                            clr = if e.enemy then trm.clr.FgRed else trm.clr.FgGreen
                            trm.write "#{clr}@#{trm.clr.Reset}"


module.exports = Stollen

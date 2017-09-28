###

Гном как конечный автомат может быть описан в виде графа состояний и событий

Состояния:

   ВЫЖИВАНИЕ:
       ОТДЫХ
       ПОЕДАНИЕ ГРИБОЧКА
       ПОИСК ГРИБОЧКОВ
       СБОР ГРИБОЧКОВ
       ИЗБЕГАНИЕ ВРАГА

   ДОМИНИРОВАНИЕ: 
       ПОИСК ВРАГА
       ПРЕСЛЕДОВАНИЕ ВРАГА
       АТАКА ВРАГА
             

События:
    в общей форме событие это полный набор численных параметров:
    hl, en, st, inv, evn - здоровье, энергия, сытость, запасы, окржение

    из этого события можно выделит высокоуровневую форму / пороговые переходы

    мало энергии / отдохнувший
    мало здоровья / здоровый
    голодно / наелись
    враг рядом / враг неподалеку
    грибочек рядом / грибочек неподалеку

###

fsm =
    REST:
        data  : "RST"
        action: (d)-> "rest"
        update: (e)-> switch
            when e.hungry    then fsm.EAT
            when e.injurned and
                 e.enemy_nearby then fsm.AVOID
            when e.rested and e.healed
                if e.low_supplies then fsm.HARVEST
                else fsm.ATTACK
            when e.enemy_nearby then fsm.ATTACK

            else fsm.REST

    EAT:
        data  : "EAT" 
        action: (d)-> "eat"
        update: (e)-> switch
            when e.injurned and
                 e.enemy_nearby then fsm.AVOID
            when e.full and
                 e.low_supplies then fsm.HARVEST
            when e.enemy_near then fsm.ATTACK

            else fsm.EAT

           
    HARVEST:
        data  : "HRV"
        action: (d)-> harvest(d)
        update: (e)-> switch
            when e.hungry then fsm.EAT
            when e.tired then fsm.REST
            when e.injurned and
                 e.enemy_nearby then fsm.AVOID 
            when e.tired or
                 e.wounded then fsm.REST
            when e.full_supplies then fsm.REST

            else fsm.HARVEST
                
    AVOID:
        data  : "AVD"
        action: (d)-> avoid(d)
        update: (e)-> switch
            when e.hungry then fsm.EAT
            when e.tired then fsm.REST
            when e.enemy_far then fsm.REST

            else fsm.AVOID
            
    ATTACK:
        data  : "FGT"
        action: (d)-> attack(d)
        update: (e)-> switch
            when e.hungry   then fsm.EAT
            when e.tired    then fsm.REST
            when e.injurned then fsm.AVOID

            else fsm.ATTACK


extract_events = (d)->
    ed = enemy_distance d.env
    mc = d.inv.length
    e =
       healed  : d.hl > 90
       wounded : d.hl < 75
       injurned: d.hl < 25
       
       hungry: d.st < 25
       full  : d.st > 80
       
       tired : d.en < 25
       rested: d.en > 80
       
       low_supplies : mc < 2
       full_supplies: mc > 8

       no_enemies  : ed > 20
       enemy_far   : 6 <= ed <= 20
       enemy_nearby: 2 <= ed < 6
       enemy_near  : ed < 1
    
center = undefined
# Сортированный список объектов заданного типа
# type может быть численной константой:
#    get_object_by_type env, MUSHROOM
# или парой ["property", value] для поиска объектов с заданным аттрибутом:
#    get_object_by_type env, ["enemy", true]
get_objects_by_type = (env, type)->
    obj = []
    for row, i in env
        for col, j in row
            switch
                when typeof type is 'number'
                    obj.push [j-center, i-center] if col is type
                when type instanceof Array
                    obj.push [j-center, i-center] if typeof col is 'object' and col[type[0]] is type[1]

    # Сразу сортируем выдачу по расстоянию до центра
    obj.sort (a, b)-> Math.abs(a[0])+Math.abs(a[1]) - Math.abs(b[0])-Math.abs(b[1])

# Координаты ближайшего объекта
get_nearest_object = (env, type)->
    obj = get_objects_by_type env, type
    return  obj[0] if obj.length > 0
    undefined

# Координаты ближайшего объекта
enemy_distance = (env)->
    obj = get_nearest_object env, ["enemy", true]
    return  Math.abs(obj[0])+Math.abs(obj[1]) if obj?
    return Infinity

# Сбор грибочков
EMPTY    = 0
MUSHROOM = 1
ROCK     = 2
directions = ["n","e","s","w"]
offsets    = n:[0,-1], e:[+1,0], s:[0,+1], w:[-1,0]
avoids     = n:"e", e:"s", s:"w", w:"n"
harvest = (dwarf)->

    # Поиск ближайшего грибочка
    nearest = get_nearest_object dwarf.env, MUSHROOM

    # Что делать если на пути препятствие
    avoid_obstacles = (dir)->
        return dir unless dir in directions 
        [dx, dy] = offsets[dir]
        x = center+dx
        y = center+dy
        obj = dwarf.env[y][x]

        switch
            when obj is EMPTY           then dir    # Пусто    -> идем
            when obj is MUSHROOM        then "grab" # Грибочек -> берем
            when obj is ROCK            then "dig"  # Стена    -> копаем
            when typeof obj is 'object' then switch # Гном?
                when obj.enemy then "fight"         #   враг   -> дермся
                else                avoids[dir]     #   свой   -> обходим
                    
     
    # Грибочков не видно, идем на север
    unless nearest?
        return avoid_obstacles directions[dwarf.id%4]
   
    [x,y] = nearest
    # грибочек рядом, подбираем
    return "grab" if (Math.abs(x)+Math.abs(y)) is 1
    
    # идем в сторону грибочка
    if Math.abs(x)>Math.abs(y)
       return avoid_obstacles "e" if x>0
       return avoid_obstacles "w" if x<0
    else 
       return avoid_obstacles "s" if y>0
       return avoid_obstacles "n" if y<0

    "err"

# Ищем врага, убегаем от врага
avoid = (dwarf)->

    # получаем ближайшего врага
    enemy = get_nearest_object dwarf.env, ["enemy", true]

    # Врагов нет -> отдыхаем
    unless nearest?
        return "rest"

    [x,y] = nearest
    
    # Идем в противоположном направлении от врага    
    if Math.abs(x)>Math.abs(y)
       return "e" if x<0
       return "w" if x>0
    else 
       return "s" if y<0
       return "n" if y>0

    "err"
    
# Ищем врага, пинаем врага
attack = (dwarf)->
        
    # получаем ближайшего врага
    enemy = get_nearest_object dwarf.env, ["enemy", true]

    # Врагов нет -> ищем врага пока не найдем
    unless nearest?
        return directions[dwarf.id%4]

    [x,y] = nearest
    # Если в соседней клетке -> НА КИРКОЙ!
    return "fight" if (Math.abs(x)+Math.abs(y)) is 1
    
    # Сейчас прольётся чья-то кров, сейчас-сейчас
    # ... подкрадываемся
    if Math.abs(x)>Math.abs(y)
       return "e" if x>0
       return "w" if x<0
    else 
       return "s" if y>0
       return "n" if y<0

    "err"
rnd = (array)-> array[Math.random()*array.length|0]
module.exports = ->

    # Глобальные переменные AI
    dwarf_states = [] # текущий стейт гнома

    (dwarf)->

        # Центр поля зрения
        center?=dwarf.env[0].length*0.5|0
        state = dwarf_states[dwarf.id]
        state?= fsm.HARVEST
        action = state.action dwarf
        dwarf_states[dwarf.id] = state.update extract_events dwarf
        return action

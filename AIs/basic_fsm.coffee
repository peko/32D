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

    мало энергии
    мало здоровья
    голодно
    враг рядом

###

fsm =
    REST:
        action: (d)-> "rest"
        update: (d)->
            switch true
                when d.st < 50 then fsm.HARVEST
                when d.en is 100 and d.hl is 100 then fsm.HARVEST
                else fsm.REST

    EAT:
        action: (d)-> "eat"
        update: (d)->
            switch true
                when d.inv.length > 0 and d.st isnt 100 then fsm.EAT
                else fsm.HARVEST

    HARVEST:
        action: (d)-> harvest(d)
        update: (d)->
            switch true
                when d.st < 25 then fsm.EAT
                when d.en < 25 or d.hl < 25 then fsm.REST
                else fsm.HARVEST
            

# Глобальные переменные AI
center = undefined
dwarf_states = []

module.exports = (dwarf)->

    # Центр поля зрения
    center?=dwarf.env[0].length*0.5|0
        
    state = dwarf_states[dwarf.dwarf_id]
    state?= fsm.HARVEST
    action = state.action dwarf
    dwarf_states[dwarf.dwarf_id] = state.update dwarf
    return action

# ----------------------------------------------------------------------

# Сортированный список объектов заданного типа
get_objects_by_type = (env, type)->
    obj = []
    for row, i in env
        for col, j in row
            obj.push [i-center,j-center] if col is type
    obj.sort (a, b)-> Math.abs(a[0])+Math.abs(a[1]) - Math.abs(b[0])+Math.abs(b[1])

# Координаты ближайшего объекта
get_nearest_object = (env, type)->
    obj = get_objects_by_type env, type
    return  obj[0] if obj.length > 0
    undefined
    
# Сбор грибочков
MUSHROOM = 1
ROCK     = 2
directions = ["n","e","s","w"]
offsets    =  n:[0,-1], e:[+1,0], s:[0,+1], w:[-1,0]

harvest = (dwarf)->
    
    # Поиск ближайшего грибочка
    nearest = get_nearest_object dwarf.env, MUSHROOM

    # Что делать если на пути препятствие
    avoid_obstacles = (dir)->
        return dir unless dir in directions 
        
        [dx, dy]=offsets[dir]
        x=center+dx
        y=center+dy
        obj = dwarf.env[y][x]
        switch
            when obj is MUSHROOM        then "eat"
            when obj is ROCK            then "dig"
            when typeof obj is 'object' then "fight"
            
        
    # Грибочков не видно, идем на север
    return avoid_obstacles "n" unless nearest?

    [x,y] = nearest
    # грибочек рядом, подбираем
    return "get" if (Math.abs(x)+Math.abs(y)) is 1
    
    # идем в сторону грибочка
    return avoid_obstacles "e" if x>0
    return avoid_obstacles "s" if y>0
    return avoid_obstacles "w" if x<0
    return avoid_obstacles "n" if y<0


###

Гном как конечный автомат может быть описан в виде графа состояний и событий

ОТДЫХ --> ОТДЫХ
ОТДЫХ -- голодно --> КУШАТЬ ГРИБОЧЕК
                 --> ИСКАТЬ ГРИБОЧЕК --> ИДТИ К ГРИБОЧКУ --> КУШАТЬ ГРИБОЧЕК

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
            
                
dwarf_states = []
module.exports = (dwarf)->
    state = dwarf_states[dwarf.dwarf_id]
    state?= fsm.REST
    action = state.action dwarf
    dwarf_states[dwarf.dwarf_id] = state.update dwarf
    return action

# ----------------------------------------------------------------------

# Предметы воруг
get_near_objects = (e)-> 
    c = e.length*0.5|0 
    #N          E          S          W
    [e[c][c-1], e[c+1][c], e[c][c+1], e[c-1][c]]

# Сортированный список объектов заданного типа
get_objects_by_type = (env, type)->
    c = env.length*0.5|0
    obj = []
    for row, i in env
        for col, j in row
            obj.push [i-c,j-c] if col is type
    obj.sort (a, b)-> Math.abs(a[0])+Math.abs(a[1]) - Math.abs(b[0])+Math.abs(b[1])

# Координаты ближайшего объекта
get_nearest_object = (env, type)->
    obj = get_objects_by_type env, type
    return  obj[0] if obj.length > 0
    undefined
    
# Сбор грибочков
MUSROOM = 1
harvest = (d)->

    nearest = get_nearest_object d.env, MUSROOM

    # Грибочков не видно, идем на север
    return "n" unless nearest?

    [x,y] = nearest
    # грибочек рядом, подбираем
    return "get" if (Math.abs(x)+Math.abs(y)) is 1
    
    # идем в сторону грибочка
    return "e" if x>0
    return "s" if y>0
    return "w" if x<0
    return "n" if y<0
    

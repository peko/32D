
base_actions = ["n", "e", "s", "w", "eat", "rest", "grab", "dig", "fight"]

ai  = (dwarf)->
    base_actions[Math.random()*base_actions.length|0]

module.exports = ai

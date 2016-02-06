module.exports = class LuacheckError extends Error
    constructor: (match) ->
        [@raw, @file, line, character, @code, @reason] = match
        @line = Number(line)
        @character = Number(character)
        super(@reason, @file, @line)

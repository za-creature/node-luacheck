module.exports = class LuacheckError extends Error
    constructor: (match) ->
        [@raw, @file, @line, @character, @code, @reason] = match
        super(@reason, @file, @line)

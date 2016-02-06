argparse = require "./argparse"
LuacheckError = require "./Error"

subprocess = require "child_process"
fs = require "fs"
os = require "os"
path = require "path"


module.exports = (filename, options, next) ->
    # arg shuffling
    if typeof options is "function"
        next = options
        options = null
    if not options?
        options = {async: true}

    # arg sanity check
    if typeof filename isnt "string"
        err = new Error("Please pass in a filename")
        if options.async
            return next(err)
        throw err

    # figure out what to run
    
    if options.exec?
        exec = options.exec
    else
        exec = "luacheck"
        if os.platform() is "win32"
            exec += ".bat"

    # figure out where to run it from
    if options.cwd
        cwd = options.cwd
    else
        cwd = path.dirname(filename)

    # construct args
    args = [
        path.resolve(".", filename),
        "--quiet",
        "--codes",
        "--no-color",
        "--formatter", "plain"
    ].concat(argparse(options))

    if options.async
        if typeof next isnt "function"
            next = -> undefined
        module.exports._luacheckAsync(filename, exec, args, cwd, next)
    else
        module.exports._luacheckSync(filename, exec, args, cwd)


module.exports._getErrors = (data) ->
    regexp = /^(.+)\:(\d+)\:(\d+)\:\s*\(([EW]\d+)\)\s*(.+)$/

    errors = []
    for line in data.split(/\r?\n/)
        match = regexp.exec(line)
        if match
            errors.push(new LuacheckError(match))
    errors


module.exports._luacheckAsync = (filename, exec, args, cwd, next) ->
    fs.stat filename, (err, stats) ->
        if err
            return next(err)

        if not stats.isFile()
            return next(new Error("'#{filename}' is not a file"))

        child = subprocess.spawn(exec, args, cwd: cwd, encoding: "utf-8")

        stdout = ""
        child.stdout.on "data", (data) ->
            stdout += data

        child.on("error", next)
        child.on "close", (code) ->
            next(null, module.exports._getErrors(stdout))


module.exports._luacheckSync = (filename, exec, args, cwd) ->
    stats = fs.statSync(filename)
    if not stats.isFile()
        throw new Error("'#{filename}' is not a file")

    child = subprocess.spawnSync(exec, args, cwd: cwd, encoding: "utf-8")
    if child.error
        throw child.error

    module.exports._getErrors(child.stdout)

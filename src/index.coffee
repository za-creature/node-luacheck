{exec}      = require "child_process"
gutil       = require "gulp-util"
path        = require "path"
PluginError = require "gulp-util/lib/PluginError"
through     = require "through2"

PLUGIN_NAME = "gulp-luacheck"


logRed = (msg) ->
    gutil.log(gutil.colors.red(msg))


logYellow = (msg) ->
    gutil.log(gutil.colors.yellow(msg))


isResultOk = (msg) ->
    msg = msg.replace("\r", "")
    return msg.substring(msg.length - 2).toLowerCase() is "ok"


isResultFailure = (msg) ->
    msg = msg.replace("\r", "")
    msg.substring(msg.length - 7).toLowerCase() is "failure"


isResultSyntaxError = (msg) ->
    msg = msg.replace("\r", "")
    msg.substring(msg.length - 12).toLowerCase() is "syntax error"


processLines = (lines, filePath) ->
    return (
        line.replace("\r", "").replace(filePath, path.basename(filePath)) \
        for line in lines when ~line.indexOf(filePath)
    )


check = (file, opts, next) ->
    runs = 0

    filePath = file.path

    cmd = "luacheck "

    if opts.noConfig is true
        cmd += "--no-config "
    else if opts.config isnt ""
        cmd += "--config " + opts.config + " "

    cmd += filePath

    exec "luacheck --help", (err, stdout, stderr) ->
        if err
            logRed("[gulp-luacheck] YOU MUST INSTALL luacheck TO RUN THIS
                    PLUGIN. See https://github.com/mpeterv/luacheck for
                    installation instructions.")
            next(null)
            return

        exec cmd, (err, stdout, stderr) ->
            # Grab the first line of stdout which ends in either "OK" if
            # everything is clean or "Failure" if something is amiss.
            lines = stdout.split("\n")
            msg = lines[0]
            lines.shift()

            # Not okay and an error we know how to deal with
            if \
                    not isResultOk(msg) and \
                    (isResultFailure(msg) or isResultSyntaxError(msg))
                logRed("[gulp-luacheck] Issue in '#{filePath}'")

                errLines = processLines(lines, filePath)
                errLines.forEach (line, index, arr) ->
                    logYellow("  " + line)

                err = null

            # Something else went sideways
            if err
                return next(new PluginError(PLUGIN_NAME, err.message,
                    fileName: filePath,
                    lineNumber: 0,
                    stack: err.stack
                ))

            next(null)


module.exports = (opts) ->
    opts = opts or {}
    opts.config = opts.config or ""
    opts.noConfig = opts.noConfig or false

    through.obj (file, encoding, next) ->
        if file.isNull()
            return next(null, file)

        if file.isStream()
            return next(new PluginError(
                PLUGIN_NAME,
                "Streaming is not supported", {
                    fileName: file.path,
                    showStack: false
                }))

        check file, opts, (err) ->
            if err
                return next(err)

            next(null, file)

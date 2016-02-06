FLAGS = {
    noGlobal: "no-global"
    noUnused: "no-unused"
    noRedefined: "no-redefined"
    noUnusedArgs: "no-unused-args"
    noUnusedSecondaries: "no-unused-secondaries"
    noUnusedGlobals: "no-unused-globals"
    compat: "compat"
    allowDefined: "allow-defined"
    allowDefinedTop: "allow-defined-top"
    module: "module"
    noInline: "no-inline"
    noConfig: "no-config"
    noCache: "no-cache"
}


SIMPLE = {
    std: "std"
    config: "config"
    cache: "cache"
}


MULTIPLE = {
    globals: "globals"
    readGlobals: "read-globals"
    newGlobals: "new-globals"
    newReadGlobals: "new-read-globals"
    ignore: "ignore"
    enable: "enable"
    only: "only"
}


module.exports = (options = {}) ->
    args = []

    for key of FLAGS
        if options[key]
            args.push("--#{FLAGS[key]}")

    for own key of SIMPLE
        if options[key]
            args.push("--#{SIMPLE[key]}")
            args.push(String(options[key]))

    if options.jobs and Number(options.jobs) > 1
        args.push("--jobs")
        args.push(String(options.jobs))

    for own key of MULTIPLE
        if options[key]
            args.push("--#{MULTIPLE[key]}")
            if options[key] instanceof Array
                for value in options[key]
                    args.push(String(value))
            else
                args.push(String(options[key]))

    args

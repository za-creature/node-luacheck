{expect} = require "chai"
{EventEmitter} = require "events"
fs = require "fs"
proxyquire = require "proxyquire"

LuacheckError = require "../src/Error"


describe "index", ->
    describe "getErrors", ->
        {_getErrors} = require "../src"

        it "should correctly identify warnings and errors", ->
            result = _getErrors(
                "foo.lua:1:2: (W101) bar\n" +
                "baz.lua:5:1: (E404) not found\n"
            )
            result.should.be.an("array")
            result.should.have.length(2)
            result[0].should.be.an.instanceof(LuacheckError)
            result[0].should.have.property("file", "foo.lua")
            result[0].should.have.property("line", 1)
            result[0].should.have.property("character", 2)
            result[0].should.have.property("code", "W101")
            result[0].should.have.property("reason", "bar")
            result[1].should.be.an.instanceof(LuacheckError)
            result[1].should.have.property("file", "baz.lua")
            result[1].should.have.property("line", 5)
            result[1].should.have.property("character", 1)
            result[1].should.have.property("code", "E404")
            result[1].should.have.property("reason", "not found")


        it "should accept no output", ->
            result = _getErrors("")
            result.should.be.an("array")
            result.should.have.length(0)


        it "should accept both windows and unix line endings", ->
            result = _getErrors(
                "foo.lua:1:2: (W101) warn\r\n" +
                "bar.lua:5:1: (E404) err\n" +
                "baz.lua:1:1: (E123) err2"
            )
            result.should.be.an("array")
            result.should.have.length(3)
            result[2].should.have.property("reason", "err2")


        it "should ignore empty or malformed lines", ->
            result = _getErrors(
                "foo.lua:1:2: (W101) warn" +
                "\n" +
                "OOPS: we dun goof'd\r\n" +
                "baz.lua:1:1: (E123) err2"
            )
            result.should.be.an("array")
            result.should.have.length(2)
            result[1].should.have.property("reason", "err2")


    describe "luacheckAsync", ->
        it "should forward fs.stat errors", (next) ->
            {_luacheckAsync} = proxyquire "../src",
                fs:
                    stat: (filename, next) -> next("foo")

            _luacheckAsync "", "", [], "", (err, msg) ->
                err.should.equal("foo")
                next()


        it "should throw an error when path is not a file", (next) ->
            {_luacheckAsync} = proxyquire "../src",
                fs:
                    stat: (filename, next) -> next(null, {isFile: -> false})

            _luacheckAsync "luaname", "", [], "", (err, msg) ->
                err.should.have.property("message", "'luaname' is not a file")
                next()


        it "should spawn an async process with the passed args", (next) ->
            called = false
            {_luacheckAsync} = proxyquire "../src",
                fs:
                    stat: (filename, next) -> next(null, {isFile: -> true})
                child_process:
                    spawn: (exec, args, opts) ->
                        exec.should.equal("bin")
                        args.should.have.length(2)
                        args[0].should.equal("foo")
                        args[1].should.equal("bar")
                        opts.should.have.property("cwd", "cwd")
                        opts.should.have.property("encoding", "utf-8")
                        called = true

                        result = new EventEmitter()
                        result.stdout = new EventEmitter()

                        process.nextTick ->
                            result.stdout.emit("data", "foo:1:2: (W01) warn\n")
                            result.emit("close", 0)

                        return result

            _luacheckAsync "file", "bin", ["foo", "bar"], "cwd", (err, msg) ->
                expect(err).to.not.exist
                called.should.be.true
                next()


        it "should forward child_process.spawn errors", (next) ->
            {_luacheckAsync} = proxyquire "../src",
                fs:
                    stat: (filename, next) -> next(null, {isFile: -> true})
                child_process:
                    spawn: (exec, args, opts) ->
                        result = new EventEmitter()
                        result.stdout = new EventEmitter()

                        process.nextTick ->
                            result.emit("error", "foobar")

                        return result

            _luacheckAsync "", "", [], "", (err, msg) ->
                err.should.equal("foobar")
                next()


        it "should buffer the process output, parse it via getErrors and
            return the result", (next) ->

            luacheck = proxyquire "../src",
                fs:
                    stat: (filename, next) -> next(null, {isFile: -> true})
                child_process:
                    spawn: (exec, args, opts) ->
                        result = new EventEmitter()
                        result.stdout = new EventEmitter()

                        process.nextTick ->
                            result.stdout.emit("data", "foo")
                            result.stdout.emit("data", "bar")
                            result.stdout.emit("data", "baz")
                            result.emit("close", 0)

                        return result

            called = false
            luacheck._getErrors = (output) ->
                output.should.equal("foobarbaz")
                called = true
                return [1, 2, 3, 4]

            {_luacheckAsync} = luacheck
            _luacheckAsync "file", "bin", ["foo", "bar"], "cwd", (err, msg) ->
                expect(err).to.not.exist
                called.should.be.true
                msg.should.have.length(4)
                msg[0].should.equal(1)
                msg[1].should.equal(2)
                msg[2].should.equal(3)
                msg[3].should.equal(4)
                next()


    describe "luacheckSync", ->
        it "should forward fs.statSync errors", ->
            {_luacheckSync} = proxyquire "../src",
                fs:
                    statSync: (filename) -> throw "foo"

            try
                _luacheckSync("", "", [], "")
                throw new Error("Did not throw")
            catch err
                err.should.equal("foo")


        it "should throw an error when path is not a file", ->
            {_luacheckSync} = proxyquire "../src",
                fs:
                    statSync: (filename) -> {isFile: -> false}

            try
                _luacheckSync("luaname", "", [], "")
                throw new Error("Did not throw")
            catch err
                err.should.be.an.instanceof(Error)
                err.message.should.equal("'luaname' is not a file")


        it "should spawn a sync process with the passed args", ->
            called = false
            {_luacheckSync} = proxyquire "../src",
                fs:
                    statSync: (filename) -> {isFile: -> true}
                child_process:
                    spawnSync: (exec, args, opts) ->
                        exec.should.equal("bin")
                        args.should.have.length(2)
                        args[0].should.equal("foo")
                        args[1].should.equal("bar")
                        opts.should.have.property("cwd", "cwd")
                        opts.should.have.property("encoding", "utf-8")
                        called = true

                        return stdout: "foo.lua:1:2: (W001) warn\n"

            _luacheckSync("file", "bin", ["foo", "bar"], "cwd")
            called.should.be.true


        it "should forward child_process.spawnSync errors", ->
            {_luacheckSync} = proxyquire "../src",
                fs:
                    statSync: (filename) -> {isFile: -> true}
                child_process:
                    spawnSync: (exec, args, opts) -> {error: "foobar"}

            try
                _luacheckSync("", "", [], "")
                throw new Error("Did not throw")
            catch err
                err.should.equal("foobar")


        it "should parse the process output and return the result", ->
            luacheck = proxyquire "../src",
                fs:
                    statSync: (filename) -> isFile: -> true
                child_process:
                    spawnSync: (exec, args, opts) -> {stdout: "foobarbaz"}

            called = false
            luacheck._getErrors = (output) ->
                output.should.equal("foobarbaz")
                called = true
                return [1, 2, 3, 4]

            {_luacheckSync} = luacheck
            msg = _luacheckSync("file", "bin", ["foo", "bar"], "cwd")
            called.should.be.true
            msg.should.have.length(4)
            msg[0].should.equal(1)
            msg[1].should.equal(2)
            msg[2].should.equal(3)
            msg[3].should.equal(4)


    describe "luacheck", ->
        it "should default to asynchronous operation", (next) ->
            luacheck = require "../src"

            luacheck._luacheckAsync = (a, b, c, d, next) -> next(null, "foo")

            luacheck "foo", null, (err, result) ->
                expect(err).to.not.exist
                result.should.equal("foo")
                next()


        it "should work without options", (next) ->
            luacheck = require "../src"

            luacheck._luacheckAsync = (a, b, c, d, next) -> next(null, "foo")

            luacheck "foo", (err, result) ->
                expect(err).to.not.exist
                result.should.equal("foo")
                next()


        it "should generate a callback if not provided", (next) ->
            luacheck = require "../src"

            luacheck._luacheckAsync = (a, b, c, d, cb) ->
                expect(cb).to.exist
                cb()
                next()

            luacheck("foo")


        it "should allow synchronous operation", ->
            luacheck = require "../src"

            luacheck._luacheckSync = -> "foo"

            luacheck("foo", sync: true).should.equal("foo")


        it "should fail synchronously when an invalid file is sent", ->
            luacheck = require "../src"

            try
                luacheck(1234, sync: true)
            catch err
                err.message.should.equal("Please pass in a filename")


        it "should fail asynchronously when an invalid file is sent", (next) ->
            luacheck = require "../src"

            luacheck 1234, (err) ->
                err.message.should.equal("Please pass in a filename")
                next()


        it "should forward errors from _luacheckSync", ->
            luacheck = require "../src"

            luacheck._luacheckSync = -> throw "bar"

            try
                luacheck("foo", sync: true)
            catch err
                err.should.equal("bar")


        it "should forward errors from _luacheckAsync", (next) ->
            luacheck = require "../src"

            luacheck._luacheckAsync = (a, b, c, d, next) -> next("bar")

            luacheck "foo", (err) ->
                err.should.equal("bar")
                next()


        it "should execute `luacheck` on unix", (next) ->
            luacheck = proxyquire "../src",
                os:
                    platform: -> "unix"

            luacheck._luacheckAsync = (a, exec, c, d, next) ->
                exec.should.be.equal("luacheck")
                next(null, [])

            luacheck "foo", (err, msg) ->
                expect(err).to.not.exist
                msg.should.be.an("array")
                msg.should.have.length(0)
                next()


        it "should execute `luacheck.bat` on windows", ->
            luacheck = proxyquire "../src",
                os:
                    platform: -> "win32"

            luacheck._luacheckSync = (a, exec) ->
                exec.should.be.equal("luacheck.bat")
                return []

            msg = luacheck("foo", sync: true)
            msg.should.be.an("array")
            msg.should.have.length(0)


        it "should execute a custom `luacheck` on demand", ->
            luacheck = require "../src"

            luacheck._luacheckSync = (_, exec) ->
                exec.should.equal("foobar")
                return []

            msg = luacheck("foo", sync: true, exec: "foobar")
            msg.should.be.an("array")
            msg.should.have.length(0)


        it "should execute `luacheck` in a custom folder", ->
            luacheck = require "../src"

            luacheck._luacheckSync = (a, exec, b, cwd) ->
                cwd.should.equal("foobar")
                return []

            msg = luacheck("foo", sync: true, cwd: "foobar")
            msg.should.be.an("array")
            msg.should.have.length(0)

argparse = require "../src/argparse"


describe "argparse", ->
    it "should default to no args", ->
        result = argparse()
        result.should.be.an("array")
        result.should.have.length(0)


    it "should translate true-ish flags", ->
        result = argparse(noGlobal: "foo", compat: 1, noCache: true)
        result.should.be.an("array")
        result.should.have.length(3)
        result.should.contain("--no-global")
        result.should.contain("--compat")
        result.should.contain("--no-cache")


    it "should ignore false-ish flags", ->
        result = argparse(noGlobal: "", compat: 0, noCache: false)
        result.should.be.an("array")
        result.should.have.length(0)


    it "should ignore unknown flags", ->
        result = argparse(xoxo: true)
        result.should.be.an("array")
        result.should.have.length(0)


    it "should translate single-value props", ->
        result = argparse(config: "foo")
        result.should.be.an("array")
        result.should.have.length(2)
        result[0].should.equal("--config")
        result[1].should.equal("foo")


    it "should ignore unknown single-value props", ->
        result = argparse(foo: "bar")
        result.should.be.an("array")
        result.should.have.length(0)


    it "should ignore less than 2 jobs", ->
        result = argparse(jobs: 1)
        result.should.be.an("array")
        result.should.have.length(0)


    it "should ignore invalid values for jobs", ->
        result = argparse(jobs: "foo")
        result.should.be.an("array")
        result.should.have.length(0)


    it "should forward valid multiple job requests", ->
        result = argparse(jobs: 1234)
        result.should.be.an("array")
        result.should.have.length(2)
        result[0].should.equal("--jobs")
        result[1].should.equal("1234")


    it "should translate multi-value props", ->
        result = argparse(readGlobals: ["foo"])
        result.should.be.an("array")
        result.should.have.length(2)
        result[0].should.equal("--read-globals")
        result[1].should.equal("foo")


    it "should accept single-valued multi-value props", ->
        result = argparse(readGlobals: "foo")
        result.should.be.an("array")
        result.should.have.length(2)
        result[0].should.equal("--read-globals")
        result[1].should.equal("foo")


    it "should maintain value order in multi-value props", ->
        result = argparse(readGlobals: ["foo", "bar", "baz"])
        result.should.be.an("array")
        result.should.have.length(4)
        result[0].should.equal("--read-globals")
        result[1].should.equal("foo")
        result[2].should.equal("bar")
        result[3].should.equal("baz")


    it "should not mix flags, single-value props and multi-value props", ->
        result = argparse(
            config: "foo",
            noGlobal: true,
            globals: ["bar", "baz"]
        )
        result.should.be.an("array")
        result.should.have.length(6)
        result.should.contain("--no-global")
        result.should.contain("--config")
        result.should.contain("--globals")
        result.should.contain("foo")
        result.should.contain("bar")
        result.should.contain("baz")
        result.indexOf("foo").should.equal(result.indexOf("--config") + 1)
        result.indexOf("baz").should.equal(result.indexOf("bar") + 1)
        result.indexOf("bar").should.equal(result.indexOf("--globals") + 1)

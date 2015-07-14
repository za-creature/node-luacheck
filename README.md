# node-luacheck

Node.JS bindings for [luacheck](https://github.com/mpeterv/luacheck).

## Dependencies

You must have [luacheck](https://github.com/mpeterv/luacheck) 0.10.0+ installed
and available in your `PATH` variable.

## Installation

```bash
npm install luacheck
```

## Usage

```javascript

var luacheck = require("luacheck");

var errors = luacheck(sourceFilename, options);

console.log(errors); // or `luacheck.errors` for the most recent invocation
```

## Options

The `options` argument is a dictionary that accepts the following keys:

### Options added by `node-luacheck`:

#### `cwd`

Type: `String`

Default: `undefined`

By default `luacheck` is executed from the source file's directory to work
around some weird `.luacheckrc` behavior in [older versions of luacheck](
https://github.com/mpeterv/luacheck/issues/33). If this is not what you want,
you can override the working directory by passing a path to this parameter.

**WARNING**: source filenames are resolved relative to the current process' working
directory, not `cwd`.

#### `exec`

Type: `String`

Default: `undefined`

If set, it should be a directory that contains `luacheck` (or `luacheck.bat` on
Windows). Useful if for whatever reason you can't have it added to your `PATH`.

### Options passed directly to `luacheck`:

#### `noGlobal`

Type: `Boolean`

Default: `false`

Filter out warnings related to global variables.

**DEPRECATED**: use `global` in a `.luacheckrc` file instead.

#### `noUnused`

Type: `Boolean`

Default: `false`

Filter out warnings related to unused variables and values.

**DEPRECATED**: use `unused` in a `.luacheckrc` file instead.

#### `noRedefined`

Type: `Boolean`

Default: `false`

Filter out warnings related to redefined variables.

**DEPRECATED**: use `redefined` in a `.luacheckrc` file instead.

#### `noUnusedArgs`

Type: `Boolean`

Default: `false`

Filter out warnings related to unused arguments and loop variables.

**DEPRECATED**: use `unused_args` in a `.luacheckrc` file instead.

#### `noUnusedSecondaries`

Type: `Boolean`

Default: `false`

Filter out warnings related to unused variables set together with used ones.
[See Secondary values and variables](http://luacheck.readthedocs.org/warnings.html#secondaryvaluesandvariables).

**DEPRECATED**: use `unused_secondaries` in a `.luacheckrc` file instead.

#### `noUnusedGlobals`

Type: `Boolean`

Default: `false`

Filter out warnings related to set but unused global variables.

**DEPRECATED**: use `unused_globals` in a `.luacheckrc` file instead.

#### `std`

Type: `String`

Default: `_G`

Set [standard globals](
http://luacheck.readthedocs.org/warnings.html#global-variables) to use. Must be
one of:

* `_G` - globals of the Lua interpreter luacheck runs on (default);
* `lua51` - globals of Lua 5.1;
* `lua52` - globals of Lua 5.2;
* `lua52c` - globals of Lua 5.2 compiled with LUA_COMPAT_ALL;
* `lua53` - globals of Lua 5.3;
* `lua53c` - globals of Lua 5.3 compiled with LUA_COMPAT_5_2;
* `luajit` - globals of LuaJIT 2.0;
* `min` - intersection of globals of Lua 5.1, Lua 5.2 and LuaJIT 2.0;
* `max` - union of globals of Lua 5.1, Lua 5.2 and LuaJIT 2.0;
* `none` - no standard globals.

**DEPRECATED**: use `std` in a `.luacheckrc` file instead.

#### `globals`

Type: `Array of Strings`

Default: `[]`

Add custom globals on top of standard ones.

**DEPRECATED**: use `globals` in a `.luacheckrc` file instead.

#### `readGlobals`

Type: `Array of Strings`

Default: `[]`

Add custom read-only globals on top of standard ones.

**DEPRECATED**: use `read_globals` in a `.luacheckrc` file instead.

#### `newGlobals`

Type: `Array of Strings`

Default: `[]`

Set custom globals. Removes custom globals added previously.

**DEPRECATED**: use `new_globals` in a `.luacheckrc` file instead.

#### `newReadGlobals`

Type: `Array of Strings`

Default: `[]`

Set read-only globals. Removes read-only globals added previously.

**DEPRECATED**: use `new_read_globals` in a `.luacheckrc` file instead.

#### `compat`

Type: `Boolean`

Default: `false`

Equivalent to `{"std": "max"}`.

**DEPRECATED**: use `std = "max"` or `compat` in a `.luacheckrc` file instead.

#### `allowDefined`

Type: `Boolean`

Default: `false`

Allow defining globals implicitly by setting them.
[See Implicitly defined globals](
http://luacheck.readthedocs.org/warnings.html#implicitly-defined-globals)

**DEPRECATED**: use `allow_defined` in a `.luacheckrc` file instead.

#### `allowDefinedTop`

Type: `Boolean`

Default: `false`

Allow defining globals implicitly by setting them in the top level scope.
[See Implicitly defined globals](
http://luacheck.readthedocs.org/warnings.html#implicitly-defined-globals)

**DEPRECATED**: use `allow_defined_top` in a `.luacheckrc` file instead.

#### `module`

Type: `Boolean`

Default: `false`

Limit visibility of implicitly defined globals to their files.
[See Modules](http://luacheck.readthedocs.org/warnings.html#modules)

**DEPRECATED**: use `module` in a `.luacheckrc` file instead.

#### `ignore`

Type: `Array of Strings`

Default: `[]`

Filter out warnings matching patterns.
[See Patterns](http://luacheck.readthedocs.org/cli.html#patterns)

**DEPRECATED**: use `ignore` in a `.luacheckrc` file instead.

#### `enable`

Type: `Array of Strings`

Default: `[]`

Do not filter out warnings matching patterns.
[See Patterns](http://luacheck.readthedocs.org/cli.html#patterns)

**DEPRECATED**: use `enable` in a `.luacheckrc` file instead.

#### `only`

Type: `Array of Strings`

Default: `[]`

Filter out warnings not matching patterns.
[See Patterns](http://luacheck.readthedocs.org/cli.html#patterns)

**DEPRECATED**: use `only` in a `.luacheckrc` file instead.

#### `noInline`

Type: `Boolean`

Default: `false`

Disable inline options.

**DEPRECATED**: use `inline` in a `.luacheckrc` file instead.

#### `config`

Type: `String`

Default: `undefined`

Path to custom [config file](http://luacheck.readthedocs.org/config.html)
(default: `.luacheckrc`).

#### `noConfig`

Type: `Boolean`

Default: `false`

Flag indicating whether config loading should be disabled or not. Pass in
`true` to disable config loading.

**DEPRECATED**: You should *always* use a `.luacheckrc` file instead of passing
options via the CLI.

#### `cache`

Type: `String`

Default: `undefined`

Path to cache file. (default: `.luacheckcache`).
[See Caching](http://luacheck.readthedocs.org/cli.html#cache)

#### `noCache`

Type: `Boolean`

Default: `true`

Do not use cache. Defaults to `true` in order to work without `LuaFileSystem`.
[See Caching](http://luacheck.readthedocs.org/cli.html#cache)

### `jobs`

Type: `Integer (Strictly Positive)`

Default: `1`

Check `jobs` files in parallel. Requires `LuaLanes`. Defaults to `1` in order
to work without it.

## Known Issues

Q: Help, I'm getting a `The input line is too long` error message on Windows.

A: This is a [known issue](https://support.microsoft.com/en-us/kb/830473)
   on all versions of Windows. Switch to using config files and it's highly
   unlikely that you'll hit the limit again.

## Bugs

Since this is a thin wrapper on top of `luacheck`, we don't consider bugs
unless running luacheck with identical options produces different results.
Everything else should be reported directly to [luacheck](
https://github.com/mpeterv/luacheck/issues)

## License

node-luacheck is licensed under the [MIT license](LICENSE.md).

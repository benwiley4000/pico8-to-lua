# pico8-to-lua

A command-line utility written in Lua that converts the PICO-8 variety of extended Lua syntax to standard Lua syntax.

It's a thin wrapper around the internal syntax convertor from [PICOLOVE](https://github.com/picolove/picolove).

Reasons you might find this useful:
- You want to run a tool built for Lua on your code, and the tool won't recognize it because you're using special PICO-8 syntax
- You want better syntax highlighting support in your text editor
- You want to extract a function you wrote for PICO-8 and use it in a different Lua program

## Installation

1. Install [Lua](https://www.lua.org/start.html) for your operating system. This doesn't come with PICO-8, which has its own Lua compiler, so you'll need to install Lua separately.
2. You can either:

    a. Install with [LuaRocks](https://luarocks.org/):
    ```console
    $ luarocks install pico8-to-lua
    ```

    b. Clone the repository from GitHub and enter the project directory:
    ```console
    $ git clone https://github.com/benwiley4000/pico8-to-lua.git
    $ cd pico-to-lua/
    ```

## Usage

> ***NOTE:*** All the examples assume you have installed `pico-to-lua` globally, but if you're using it from inside the cloned directory, you can replace all instances of `pico8-to-lua` with `./pico8-to-lua.lua` (or `lua pico8-to-lua.lua` for non-UNIX environments) in the commands that you run.

Assuming you have an input Lua file that looks like this:

```lua
-- input.lua
function next_even_number(num)
 if (num % 2 != 0) num += 1
 return num
end
```

You can generate a standard Lua version with the command (depending on your system, you may need to add `lua ` in front of this command):

```console
$ pico8-to-lua input.lua
```

You should see this output:

```lua
function next_even_number(num)
 if num % 2 ~= 0 then num = num +  1 end
 return num
end
```

You can also use a `.p8` file as input...

```lua
pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
 local num = 0b10
 if (num+1==0b11) print('yes!')
end
```

```console
$ pico8-to-lua input.p8
```

...which will output transformed p8 file contents:

```lua
pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
 local num = 0x2
 if num+1==0x3 then print('yes!') end
end
```

If you only want the lua output, you can pass the `--lua-only` flag when input a p8 file:

```console
$ pico8-to-lua input.p8 --lua-only
```

```lua
function _init()
 local num = 0x2
 if num+1==0x3 then print('yes!') end
end
```

If you're in a UNIX environment, you can pipe the output directly to a file:

```console
$ pico8-to-lua input.lua > output.lua
```

```
$ pico8-to-lua input.p8 > output.p8
```

Or you can pipe into another program:

```console
$ pico8-to-lua input.p8 --lua-only | luacheck -
```

You can even pipe output from another program into this one by passing `-` as the filename argument:

```console
$ cat input.lua | pico8-to-lua - > output.lua
```

```console
$ curl https://someurl.com/mycart.p8 | pico8-to-lua - --lua-only | luacheck -
```

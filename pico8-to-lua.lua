#!/usr/bin/env lua

-- FUNCTIONS
-- (all functions are borrowed from other projects; see citations above each)

-- Got this function from picolove!
-- https://github.com/picolove/picolove/blob/d5a65fd6dd322532d90ea612893a00a28096804a/main.lua#L820
-- PICOLOVE is licensed under the Zlib license:

-- Copyright (c) 2015 Jez Kabanov <thesleepless@gmail.com>

-- This software is provided 'as-is', without any express or implied
-- warranty. In no event will the authors be held liable for any damages
-- arising from the use of this software.

-- Permission is granted to anyone to use this software for any purpose,
-- including commercial applications, and to alter it and redistribute it
-- freely, subject to the following restrictions:

-- 1. The origin of this software must not be misrepresented; you must not
--    claim that you wrote the original software. If you use this software
--    in a product, an acknowledgement in the product documentation would be
--    appreciated but is not required.
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 3. This notice may not be removed or altered from any source distribution.
function patch_lua(lua)
  -- patch lua code
  lua = lua:gsub("!=","~=")
  lua = lua:gsub("//","--")
  -- rewrite shorthand if statements eg. if (not b) i=1 j=2
  lua = lua:gsub("if%s*(%b())%s*([^\n]*)\n",function(a,b)
    local nl = a:find('\n',nil,true)
    local th = b:find('%f[%w]then%f[%W]')
    local an = b:find('%f[%w]and%f[%W]')
    local o = b:find('%f[%w]or%f[%W]')
    local ce = b:find('--',nil,true)
    if not (nl or th or an or o) then
      if ce then
        local c,t = b:match("(.-)(%s-%-%-.*)")
        return "if "..a:sub(2,-2).." then "..c.." end"..t.."\n"
      else
        return "if "..a:sub(2,-2).." then "..b.." end\n"
      end
    end
  end)
  -- rewrite assignment operators
  lua = lua:gsub("(%S+)%s*([%+-%*/%%])=","%1 = %1 %2 ")
  -- rewrite inspect operator "?"
  lua = lua:gsub("^(%s*)?([^\n\r]*)","%1print(%2)")
  -- convert binary literals to hex literals
  lua = lua:gsub("([^%w_])0[bB]([01.]+)", function(a, b)
    local p1, p2 = b, ""
    if b:find(".", nil, true) then
      p1, p2 = b:match("(.-)%.(.*)")
    end
    -- pad to 4 characters
    p2 = p2 .. string.rep("0", 3 - ((#p2 - 1) % 4))
    p1, p2 = tonumber(p1, 2), tonumber(p2, 2)
    if p1 then
      if p2 then
        return string.format("%s0x%x.%x", a, p1, p2)
      else
        return string.format("%s0x%x", a, p1)
      end
    end
  end)

  return lua
end

-- thanks to https://helloacm.com/split-a-string-in-lua/
function split(s, delimiter)
  result = {}
  for match in (s..delimiter):gmatch("(.-)"..delimiter) do
    table.insert(result, match)
  end
  return result
end

-- PROCEDURE

before_delimiter = "__lua__\n"
after_delimiter = "__gfx__"

filename = arg[1]
output_lua_only = arg[2] == "--lua-only"

if not filename then
  error("ERROR: Must provide filename argument")
elseif filename == '-' then
  f = io.input()
else
  f = io.open(filename)
  if not f then
    error("ERROR: File "..filename.." not found")
  end
end
input_contents = f:read('*all')
f:close()

pico8_lua = input_contents
before_lua = ""
after_lua = ""
is_p8_file = pico8_lua:sub(1,16) == "pico-8 cartridge"
if is_p8_file then
  local t1 = split(pico8_lua, before_delimiter)
  local t2 = split(t1[2], after_delimiter)
  pico8_lua = t2[1]
  before_lua = t1[1]
  after_lua = t2[2]
end

plain_lua = patch_lua(pico8_lua)

out_str = plain_lua
if is_p8_file and not output_lua_only then
  out_str = before_lua..before_delimiter..out_str
  if after_lua then
    out_str = out_str..after_delimiter..after_lua
  end
end

-- we'll get an extra newline when
-- we print so remove the newline at
-- the end if there is one
if out_str:sub(-1) == '\n' then
 out_str = out_str:sub(0, -2)
end

print(out_str)

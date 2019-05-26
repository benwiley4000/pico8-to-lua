package = "pico8-to-lua"
version = "0.1.0-1"
source = {
  url = "git://github.com/benwiley4000/pico8-to-lua.git",
  tag = "v0.1.0"
}
description = {
  detailed = "A command-line utility written in Lua that converts the PICO-8 variety of extended Lua syntax to standard Lua syntax.",
  homepage = "https://github.com/benwiley4000/pico8-to-lua",
  license = "Zlib"
}
build = {
  type = "builtin",
  install = {
    bin = {
      ["pico8-to-lua"] = "pico8-to-lua.lua"
    }
  }
}

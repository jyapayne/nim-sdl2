import os, strutils, strformat
import sdl2
import nimterop/[cimport, build]

export sdl2

const
  baseDir = currentSourcePath.parentDir().parentDir().parentDir()
  buildDir = baseDir / "build"
  sdlIncludeDir = buildDir / "sdl2" / "include"
  srcDir = buildDir / "sdl2_net"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

getHeader(
  "SDL_net.h",
  dlurl = "https://www.libsdl.org/projects/SDL_net/release/SDL2_net-$1.tar.gz",
  outdir = srcDir,
  altNames = "SDL2_net"
)

# static:
#   cDebug()
#   cDisableCaching()

cPluginPath(symbolPluginPath)

when defined(SDL_net_Static):
  cImport(SDL_net_Path, recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDLnetsys.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
else:
  cImport(SDL_net_Path, recurse = false, dynlib = "SDL_net_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDLnetsys.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
import os, strutils, strformat
import sdl2
import nimterop/[cimport, build]

export sdl2

const
  baseDir = currentSourcePath.parentDir().parentDir().parentDir()
  buildDir = baseDir / "build"
  sdlIncludeDir = buildDir / "sdl2" / "include"
  srcDir = buildDir / "sdl2_gfx"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

getHeader(
  "SDL2_gfxPrimitives.h",
  dlurl = "http://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$1.tar.gz",
  outdir = srcDir,
  altNames = "SDL2_gfx,SDL_gfx"
)

# static:
#   cDebug()
#   cDisableCaching()

cPluginPath(symbolPluginPath)

when defined(SDL2_GfxPrimitives_Static):
  cImport(srcDir / "SDL2_gfxPrimitives.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_rotozoom.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_framerate.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_imageFilter.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
else:
  cImport(srcDir / "SDL2_gfxPrimitives.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_rotozoom.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_framerate.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_imageFilter.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")
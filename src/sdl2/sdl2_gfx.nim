import os, strutils, strformat
import sdl2
import nimterop/[cimport, build]

const
  baseDir = SDLCacheDir
  sdlIncludeDir = baseDir / "sdl2" / "include"
  srcDir = baseDir / "sdl2_gfx"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

when defined(windows):
  when defined(amd64):
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=x86_64-w64-mingw32"
  else:
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=i686-w64-mingw32"
else:
  const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir}"

getHeader(
  "SDL2_gfxPrimitives.h",
  dlurl = "http://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$1.tar.gz",
  outdir = srcDir,
  altNames = "SDL2_gfx,SDL_gfx",
  conFlags = flags,
  buildTypes = [btAutoConf]
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
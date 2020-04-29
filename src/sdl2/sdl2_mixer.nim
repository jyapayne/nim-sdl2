import os, strutils, strformat
import sdl2
import nimterop/[cimport, build]

const
  baseDir = SDLCacheDir
  sdlIncludeDir = baseDir / "sdl2" / "include"
  sdlBuildDir = baseDir / "sdl2" / "buildcache"
  srcDir = baseDir / "sdl2_mixer"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

when defined(windows):
  const dlurl = "https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-$1.zip"
else:
  const dlurl = "https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-$1.tar.gz"

getHeader(
  "SDL_mixer.h",
  dlurl = dlurl,
  outdir = srcDir,
  altNames = "SDL2_mixer",
)

# static:
  # cDebug()
  # cDisableCaching()

cOverride:
  const
    GetError* = ""
    SetError* = ""
    ClearError* = ""

cPluginPath(symbolPluginPath)

when defined(SDL_Mixer_Static):
  cImport(srcDir/"SDL_mixer.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
else:
  cImport(srcDir/"SDL_mixer.h", recurse = false, dynlib = "SDL_mixer_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")

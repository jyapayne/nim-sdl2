import os, strutils, strformat
import sdl2
import nimterop/[cimport, build]

export sdl2

const
  baseDir = currentSourcePath.parentDir().parentDir().parentDir()
  buildDir = baseDir / "build"
  sdlIncludeDir = buildDir / "sdl2" / "include"
  srcDir = buildDir / "sdl2_mixer"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

getHeader(
  "SDL_mixer.h",
  dlurl = "https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-$1.tar.gz",
  outdir = srcDir,
  altNames = "SDL2_mixer"
)

# static:
  # cDebug()
  # cDisableCaching()

cPluginPath(symbolPluginPath)

when defined(SDL_mixer_Static):
  cImport(SDL_mixer_Path, recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
else:
  cImport(SDL_mixer_Path, recurse = false, dynlib = "SDL_mixer_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")

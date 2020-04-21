import os, strutils, strformat
import sdl2
import nimterop/[cimport, build]

const
  baseDir = SDLCacheDir
  sdlIncludeDir = baseDir / "sdl2" / "include"
  srcDir = baseDir / "sdl2_image"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

getHeader(
  "SDL_image.h",
  dlurl = "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-$1.tar.gz",
  outdir = srcDir,
  altNames = "SDL2_image"
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

when defined(SDL_image_Static):
  cImport(SDL_image_Path, recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
else:
  cImport(SDL_image_Path, recurse = false, dynlib = "SDL_image_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")

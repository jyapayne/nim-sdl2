import os, strutils, strformat
import sdl2
import nimterop/[cimport, build]

const
  baseDir = SDLCacheDir
  sdlDir = baseDir / "sdl2"
  sdlIncludeDir = sdlDir / "include"
  srcDir = baseDir / "sdl2_ttf"
  currentPath = currentSourcePath().parentDir().parentDir()
  cmakeModPath = currentPath / "cmake" / "sdl2"
  symbolPluginPath = currentPath / "sdl2" / "cleansymbols.nim"

getHeader(
  "SDL_ttf.h",
  dlurl = "https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$1.tar.gz",
  outdir = srcDir,
  altNames = "SDL2_ttf",
  cmakeFlags = &"-DCMAKE_C_FLAGS=-I{sdlIncludeDir} -DCMAKE_MODULE_PATH={cmakeModPath} " &
               &"-DSDL2MAIN_LIBRARY={SDLMainLib} -DSDL2_LIBRARY={SDLDyLibPath} -DSDL2_PATH={sdlDir}"
)

# static:
#   cDebug()
#   cDisableCaching()

cPluginPath(symbolPluginPath)

cOverride:
  const
    GetError* = ""
    SetError* = ""

when defined(SDL_ttf_Static):
  cImport(SDL_ttf_Path, recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2 -d")
else:
  cImport(SDL_ttf_Path, recurse = false, dynlib = "SDL_ttf_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")

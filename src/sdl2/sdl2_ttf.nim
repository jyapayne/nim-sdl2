import os, strutils, strformat
import sdl2
import nimterop/[cimport, build]

const
  baseDir = currentSourcePath.parentDir().parentDir().parentDir()
  buildDir = baseDir / "build"
  sdlDir = buildDir / "sdl2"
  sdlIncludeDir = sdlDir / "include"
  cmakeModPath = baseDir / "cmake" / "sdl2"
  srcDir = buildDir / "sdl2_ttf"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

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

when defined(SDL_ttf_Static):
  cImport(SDL_ttf_Path, recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
else:
  cImport(SDL_ttf_Path, recurse = false, dynlib = "SDL_ttf_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")

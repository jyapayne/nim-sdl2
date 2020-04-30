import os, strutils, strformat
import sdl2
import nimterop/[cimport, build]

const
  baseDir = SDLCacheDir
  sdlDir = (baseDir / "sdl2").sanitizePath
  sdlIncludeDir = (sdlDir / "include").sanitizePath
  srcDir = (baseDir / "sdl2_ttf").sanitizePath
  currentPath = currentSourcePath().parentDir().parentDir().sanitizePath
  cmakeModPath = (currentPath / "cmake" / "sdl2").replace("\\", "/")
  symbolPluginPath = (currentPath / "sdl2" / "cleansymbols.nim").sanitizePath

when defined(windows):
  const dlurl = "https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$1.zip"
else:
  const dlurl = "https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$1.tar.gz"

getHeader(
  "SDL_ttf.h",
  dlurl = dlurl,
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
  cImport(srcDir / "SDL_ttf.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2 -d")
else:
  cImport(srcDir / "SDL_ttf.h", recurse = false, dynlib = "SDL_ttf_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")

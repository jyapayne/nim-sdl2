import os, strformat, strutils
import sdl2
import nimterop/[build, cimport]

const
  baseDir = currentSourcePath.parentDir().parentDir().parentDir()
  buildDir = baseDir / "build"
  sdlDir = buildDir / "sdl2"
  sdlIncludeDir = sdlDir / "include"
  cmakeModPath = baseDir / "cmake" / "sdl2"
  srcDir = buildDir / "sdl2_gpu"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

getHeader(
  "SDL_gpu.h",
  giturl = "https://github.com/grimfang4/sdl-gpu",
  outdir = srcDir,
  altNames = "SDL2_gpu",
  cmakeFlags = &"-DCMAKE_C_FLAGS=-I{sdlIncludeDir} -DCMAKE_MODULE_PATH={cmakeModPath} -DSDL2_LIBRARY={SDLDyLibPath} " &
               &"-DSDL2MAIN_LIBRARY={SDLMainLib} -DSDL2_PATH={sdlDir} -DSDL2_INCLUDE_DIR={sdlIncludeDir} -DSDL_gpu_BUILD_DEMOS=OFF"
)

# static:
#   cDebug()
#   cDisableCaching()

cOverride:
  type
    LogLevelEnum* = enum
      LOG_LEVEL_INFO = 0
      LOG_LEVEL_WARNING
      LOG_LEVEL_ERROR

cPluginPath(symbolPluginPath)

when defined(SDL_gpu_Static):
  cImport(SDL_gpuPath, recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
else:
  cImport(SDL_gpuPath, recurse = false, dynlib = "SDL_gpuLPath", flags = &"-I={sdlIncludeDir} -f=ast2")
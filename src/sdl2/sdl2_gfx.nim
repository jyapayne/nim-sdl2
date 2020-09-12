import macros
import os, strutils, strformat
import sdl2
import nimterop/[cimport, build, globals]

const
  baseDir = SDLCacheDir
  srcDir = baseDir / "sdl2_gfx"
  buildDir = srcDir / ".libs"
  currentPath = getProjectPath().parentDir().sanitizePath
  generatedPath = (currentPath / "generated" / "sdl2_gfx").replace("\\", "/")
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

  defs = """
    SDL2gfxPrimitivesSetVer=1.0.4
    SDL2gfxPrimitivesDL
    SDL2gfxPrimitivesStatic
    SDL2gfxStatic
  """

setDefines(defs.splitLines())

static:
  let ver = getDefine("SDL2gfxPrimitivesSetVer")
  downloadUrl(fmt"http://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-{ver}.tar.gz", outdir=srcDir)

# getHeader(
#   "SDL2_gfxPrimitives.h",
#   dlurl = "http://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$1.tar.gz",
#   outdir = srcDir,
#   altNames = "SDL2_gfx,SDL_gfx",
#   conFlags = flags,
#   buildTypes = [btAutoConf]
# )

const ver = getDefine("SDL2gfxPrimitivesSetVer")
const newSrcDir = srcDir / fmt"SDL2_gfx-{ver}"
cIncludeDir(newSrcDir)
cCompile(newSrcDir / "SDL2_gfxPrimitives.c")
cCompile(newSrcDir / "SDL2_rotozoom.c")
cCompile(newSrcDir / "SDL2_framerate.c")
cCompile(newSrcDir / "SDL2_imageFilter.c")

static:
  discard
  # cDebug()
  # cDisableCaching()

cPluginPath(symbolPluginPath)

cImport(
  @[newSrcDir / "SDL2_gfxPrimitives.h", newSrcDir / "SDL2_rotozoom.h",
   newSrcDir / "SDL2_framerate.h", newSrcDir / "SDL2_imageFilter.h"],
   recurse = false, flags = &"-I={SDLIncludeDir} -f=ast2 -H", nimFile = generatedPath / "sdl2_gfx.nim"
)
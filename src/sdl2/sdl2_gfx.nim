import os, strutils, strformat
import sdl2
import nimterop/[cimport, build, globals]

const
  baseDir = SDLCacheDir
  srcDir = baseDir / "sdl2_gfx"
  buildDir = srcDir / ".libs"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

  defs = """
    SDL2gfxPrimitivesSetVer=1.0.4
    SDL2gfxPrimitivesDL
    SDL2gfxPrimitivesStatic
    SDL2gfxStatic
  """

setDefines(defs.splitLines())

when defined(windows):
  when defined(amd64):
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=x86_64-w64-mingw32 CFLAGS=\"-fPIC -I{SDLIncludeDir}\""
  else:
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=i686-w64-mingw32 CFLAGS=\"-fPIC -I{SDLIncludeDir}\""
else:
  const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} CFLAGS=\"-fPIC -I{SDLIncludeDir}\""

getHeader(
  "SDL2_gfxPrimitives.h",
  dlurl = "http://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$1.tar.gz",
  outdir = srcDir,
  altNames = "SDL2_gfx,SDL_gfx",
  conFlags = flags,
  buildTypes = [btAutoConf]
)

static:
  when defined(macosx):
    fixStaticFile(buildDir)
  # cDebug()
  # cDisableCaching()

cPluginPath(symbolPluginPath)

when isDefined(SDL2gfxPrimitivesStatic):
  cImport(srcDir / "SDL2_gfxPrimitives.h", recurse = false, flags = &"-I={SDLIncludeDir} -f=ast2 -H")
  cImport(srcDir / "SDL2_rotozoom.h", recurse = false, flags = &"-I={SDLIncludeDir} -f=ast2 -H")
  cImport(srcDir / "SDL2_framerate.h", recurse = false, flags = &"-I={SDLIncludeDir} -f=ast2 -H")
  cImport(srcDir / "SDL2_imageFilter.h", recurse = false, flags = &"-I={SDLIncludeDir} -f=ast2 -H")
else:
  cImport(srcDir / "SDL2_gfxPrimitives.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={SDLIncludeDir} -f=ast2 -H")
  cImport(srcDir / "SDL2_rotozoom.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={SDLIncludeDir} -f=ast2 -H")
  cImport(srcDir / "SDL2_framerate.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={SDLIncludeDir} -f=ast2 -H")
  cImport(srcDir / "SDL2_imageFilter.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={SDLIncludeDir} -f=ast2 -H")

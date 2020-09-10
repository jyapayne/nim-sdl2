import os, strutils, strformat
import sdl2
import nimterop/[cimport, build, globals]

const
  baseDir = SDLCacheDir
  sdlDir = (baseDir / "sdl2").sanitizePath
  srcDir = (baseDir / "sdl2_ttf").sanitizePath
  buildDir = srcDir / ".libs"
  currentPath = currentSourcePath().parentDir().parentDir().sanitizePath
  generatedPath = (currentPath / "generated").replace("\\", "/")
  symbolPluginPath = (currentPath / "sdl2" / "cleansymbols.nim").sanitizePath

  defs = """
    SDLttfSetVer=2.0.15
    SDLttfDL
    SDLttfStatic
  """

setDefines(defs.splitLines())

when defined(windows):
  const dlurl = "https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$1.zip"
else:
  const dlurl = "https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$1.tar.gz"

when defined(windows):
  when defined(amd64):
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=x86_64-w64-mingw32 CFLAGS=\"-fPIC -I{SDLIncludeDir}\""
  else:
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=i686-w64-mingw32 CFLAGS=\"-fPIC -I{SDLIncludeDir}\""
else:
  const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} CFLAGS=\"-fPIC -I{SDLIncludeDir}\""


getHeader(
  "SDL_ttf.h",
  dlurl = dlurl,
  outdir = srcDir,
  altNames = "SDL2_ttf",
  conFlags = flags,
  buildTypes = [btAutoConf]
)

static:
  when defined(macosx):
    fixStaticFile(buildDir)
#   cDebug()
#   cDisableCaching()

cPluginPath(symbolPluginPath)

cOverride:
  const
    GetError* = ""
    SetError* = ""

when isDefined(SDLttfStatic):
  cImport(srcDir / "SDL_ttf.h", recurse = false, flags = &"-I={SDLIncludeDir} -f=ast2 -H", nimFile = generatedPath / "sdl2_ttf.nim")
else:
  cImport(srcDir / "SDL_ttf.h", recurse = false, dynlib = "SDL_ttf_LPath", flags = &"-I={SDLIncludeDir} -f=ast2 -H", nimFile = generatedPath / "sdl2_ttf.nim")

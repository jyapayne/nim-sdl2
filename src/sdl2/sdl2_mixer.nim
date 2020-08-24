import os, strutils, strformat
import sdl2
import nimterop/[cimport, build, globals]

const
  baseDir = SDLCacheDir
  srcDir = baseDir / "sdl2_mixer"
  buildDir = srcDir / "build" / ".libs"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

  defs = """
    SDLmixerSetVer=2.0.4
    SDLmixerDL
    SDLmixerStatic
  """

setDefines(defs.splitLines())

when defined(windows):
  const dlurl = "https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-$1.zip"
else:
  const dlurl = "https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-$1.tar.gz"

when defined(windows):
  when defined(amd64):
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=x86_64-w64-mingw32 CFLAGS=\"-fPIC -I{SDLIncludeDir}\""
  else:
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=i686-w64-mingw32 CFLAGS=\"-fPIC -I{SDLIncludeDir}\""
else:
  const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} CFLAGS=\"-fPIC -I{SDLIncludeDir}\""

getHeader(
  "SDL_mixer.h",
  dlurl = dlurl,
  outdir = srcDir,
  conFlags = flags,
  altNames = "SDL2_mixer",
  buildTypes = [btAutoConf]
)

static:
  when defined(macosx):
    fixStaticFile(buildDir)
  # cDebug()
  # cDisableCaching()

cOverride:
  const
    GetError* = ""
    SetError* = ""
    ClearError* = ""

cPluginPath(symbolPluginPath)

when isDefined(SDLmixerStatic):
  cImport(srcDir/"SDL_mixer.h", recurse = false, flags = &"-I={SDLIncludeDir} -f=ast2 -H")
else:
  cImport(srcDir/"SDL_mixer.h", recurse = false, dynlib = "SDL_mixer_LPath", flags = &"-I={SDLIncludeDir} -f=ast2 -H")

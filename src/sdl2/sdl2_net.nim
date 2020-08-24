import os, strutils, strformat
import sdl2
import nimterop/[cimport, build, globals]

const
  baseDir = SDLCacheDir
  srcDir = baseDir / "sdl2_net"
  buildDir = srcDir / ".libs"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

  defs = """
    SDLnetSetVer=2.0.1
    SDLnetDL
    SDLnetStatic
  """

setDefines(defs.splitLines())

when defined(windows):
  const dlurl = "https://www.libsdl.org/projects/SDL_net/release/SDL2_net-$1.zip"
else:
  const dlurl = "https://www.libsdl.org/projects/SDL_net/release/SDL2_net-$1.tar.gz"

when defined(windows):
  when defined(amd64):
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=x86_64-w64-mingw32 CFLAGS=\"-fPIC -I{SDLIncludeDir}\""
  else:
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=i686-w64-mingw32 CFLAGS=\"-fPIC -I{SDLIncludeDir}\""
else:
  const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} CFLAGS=\"-fPIC -I{SDLIncludeDir}\""

getHeader(
  "SDL_net.h",
  dlurl = dlurl,
  outdir = srcDir,
  conFlags = flags,
  altNames = "SDL2_net",
  buildTypes = [btAutoConf]
)

static:
  when defined(macosx):
    fixStaticFile(buildDir)
#   cDebug()
#   cDisableCaching()

cOverride:
  type
    Version* = sdl2.Version

cPluginPath(symbolPluginPath)

when isDefined(SDLnetStatic):
  cImport(srcDir / "SDL_net.h", recurse = false, flags = &"-I={SDLIncludeDir} -f=ast2 -H")
  cImport(srcDir / "SDLnetsys.h", recurse = false, flags = &"-I={SDLIncludeDir} -f=ast2 -H")
else:
  cImport(srcDir / "SDL_net.h", recurse = false, dynlib = "SDL_net_LPath", flags = &"-I={sdlIncludeDir} -f=ast2 -H")
  cImport(srcDir / "SDLnetsys.h", recurse = false, flags = &"-I={SDLIncludeDir} -f=ast2 -H")

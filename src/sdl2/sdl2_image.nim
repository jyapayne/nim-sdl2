import os, strutils, strformat
import sdl2
import nimterop/[cimport, build]

const
  baseDir = SDLCacheDir
  sdlIncludeDir = baseDir / "sdl2" / "include"
  srcDir = baseDir / "sdl2_image"
  buildDir = srcDir / ".libs"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

when defined(windows):
  const dlurl = "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-$1.zip"
else:
  const dlurl = "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-$1.tar.gz"

when defined(windows):
  when defined(amd64):
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=x86_64-w64-mingw32"
  else:
    const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --host=i686-w64-mingw32"
else:
  const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir}"

{.passC: "-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk -fPIC".}

getHeader(
  "SDL_image.h",
  dlurl = dlurl,
  outdir = srcDir,
  altNames = "SDL2_image",
  conFlags = flags,
  buildTypes = [btAutoConf]
)

proc findStaticlib(): string =
  const pathRegex = "(lib)?SDL2_image[0-9.\\-]*\\.a"
  return findFile(pathRegex, buildDir, regex = true)

static:
  when defined(macosx):
    # For some reason on MacOSX Catalina, the default static
    # binary is linked weird and causes the error:
    # "ld: warning: ignoring file
    #  /path/to/sdl2_image/.libs/libSDL2_image.a,
    #  building for macOS-x86_64 but attempting to link
    #  with file built for macOS-x86_64"
    #
    # Simply recombining the object files into a static file seems to work
    let staticFile = findStaticlib()
    rmFile(staticFile)
    let res = execAction(&"ar ru {staticFile} {buildDir}/*.o")
    if res.ret != 0:
      raise newException(CatchableError, &"Error: could not build static lib {staticFile}")
    let ranres = execAction(&"ranlib {staticFile}")
    if ranres.ret != 0:
      raise newException(CatchableError, &"Error: could not build static lib {staticFile}")
  # cDebug()
  # cDisableCaching()

cOverride:
  const
    GetError* = ""
    SetError* = ""
    ClearError* = ""

cPluginPath(symbolPluginPath)
cIncludeDir(sdlIncludeDir)

when defined(SDL_image_Static):
  cImport(srcDir/"SDL_image.h", recurse = false, flags = &"-f=ast2")
else:
  cImport(srcDir/"SDL_image.h", recurse = false, dynlib = "SDL_image_LPath", flags = &"-f=ast2")

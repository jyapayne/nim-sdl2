import macros
import os, strutils, strformat
import sdl2
import nimterop/[cimport, build, globals]

const
  baseDir = SDLCacheDir
  srcDir = baseDir / "sdl2_image"
  buildDir = srcDir / ".libs"
  currentPath = getProjectPath().parentDir().sanitizePath
  generatedPath = (currentPath / "generated" / "sdl2_image").replace("\\", "/")
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

  defs = """
    SDLimageSetVer=2.0.5
    SDLimageDL
    SDLimageStatic
  """

setDefines(defs.splitLines())


when defined(windows):
  const dlurl = "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-$1.zip"
else:
  const dlurl = "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-$1.tar.gz"

when defined(windows):
  const winBDir = SDLBuildDir.replace("C:\\", "/c/").replace("\\", "/")
  const winIDir = SDLIncludeDir.replace("C:\\", "/c/").replace("\\", "/")
  when defined(amd64):
    const flags = &"--libdir={winBDir} --includedir={winIDir} --host=x86_64-w64-mingw32 CFLAGS=\"-fPIC -I{winIDir}\""
  else:
    const flags = &"--libdir={winBDir} --includedir={winIDir} --host=i686-w64-mingw32 CFLAGS=\"-fPIC -I{winIDir}\""
else:
  const flags = &"--libdir={SDLBuildDir} --includedir={SDLIncludeDir} --with-pic CFLAGS=\"-fPIC -I{SDLIncludeDir}\""

when defined(macosx):
  {.passC: "-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX10.15.sdk -fPIC".}
else:
  {.passC: "-fPIC -I{SDLIncludeDir}".}

getHeader(
  "SDL_image.h",
  dlurl = dlurl,
  outdir = srcDir,
  altNames = "SDL2_image",
  conFlags = flags,
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
cIncludeDir(SDLIncludeDir)

{.passL: "-lwebp -lpng -ltiff -ljpeg".}

when isDefined(SDLimageStatic):
  cImport(srcDir/"SDL_image.h", recurse = false, flags = &"-f=ast2 -H", nimFile = generatedPath / "sdl2_image.nim")
else:
  cImport(srcDir/"SDL_image.h", recurse = false, dynlib = "SDL_image_LPath", flags = &"-f=ast2 -H", nimFile = generatedPath / "sdl2_image.nim")

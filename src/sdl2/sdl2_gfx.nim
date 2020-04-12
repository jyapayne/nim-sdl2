import os, strutils, strformat
import sdl2
import nimterop/[cimport, build]

export sdl2

const
  baseDir = currentSourcePath.parentDir().parentDir().parentDir()
  buildDir = baseDir / "build"
  sdlIncludeDir = buildDir / "sdl2" / "include"
  srcDir = buildDir / "sdl2_gfx"

getHeader(
  "SDL2_gfxPrimitives.h",
  dlurl = "http://www.ferzkopp.net/Software/SDL2_gfx/SDL2_gfx-$1.tar.gz",
  outdir = srcDir,
  altNames = "SDL2_gfx,SDL_gfx"
)

# static:
#   cDebug()
#   cDisableCaching()

cPlugin:
  import strutils, nre
  import sets

  const EVENT_TYPES = toHashSet([
    "FIRSTEVENT",
    "QUIT",
    "APP_TERMINATING",
    "APP_LOWMEMORY",
    "APP_WILLENTERBACKGROUND",
    "APP_DIDENTERBACKGROUND",
    "APP_WILLENTERFOREGROUND",
    "APP_DIDENTERFOREGROUND",
    "DISPLAYEVENT",
    "WINDOWEVENT",
    "SYSWMEVENT",
    "KEYDOWN",
    "KEYUP",
    "TEXTEDITING",
    "TEXTINPUT",
    "KEYMAPCHANGED",
    "MOUSEMOTION",
    "MOUSEBUTTONDOWN",
    "MOUSEBUTTONUP",
    "MOUSEWHEEL",
    "JOYAXISMOTION",
    "JOYBALLMOTION",
    "JOYHATMOTION",
    "JOYBUTTONDOWN",
    "JOYBUTTONUP",
    "JOYDEVICEADDED",
    "JOYDEVICEREMOVED",
    "CONTROLLERAXISMOTION",
    "CONTROLLERBUTTONDOWN",
    "CONTROLLERBUTTONUP",
    "CONTROLLERDEVICEADDED",
    "CONTROLLERDEVICEREMOVED",
    "CONTROLLERDEVICEREMAPPED",
    "FINGERDOWN",
    "FINGERUP",
    "FINGERMOTION",
    "DOLLARGESTURE",
    "DOLLARRECORD",
    "MULTIGESTURE",
    "CLIPBOARDUPDATE",
    "DROPFILE",
    "DROPTEXT",
    "DROPBEGIN",
    "DROPCOMPLETE",
    "AUDIODEVICEADDED",
    "AUDIODEVICEREMOVED",
    "SENSORUPDATE",
    "RENDER_TARGETS_RESET",
    "RENDER_DEVICE_RESET",
    "USEREVENT",
    "LASTEVENT",
  ])

  # Symbol renaming examples
  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    # Get rid of leading and trailing underscores
    if sym.kind == nskProc or sym.kind == nskType or sym.kind == nskConst:
      if sym.name != "_":
        sym.name = sym.name.strip(chars={'_'}).replace("___", "_")

    sym.name = sym.name.replace(re"^SDL_", "")

    if sym.name.startsWith("SDLK_"):
      sym.name = sym.name.replace("SDLK_", "KEYCODE_")

    if EVENT_TYPES.contains(sym.name):
      sym.name = "EVENT_" & sym.name

    if sym.name == "version":
      sym.name = "Version"

    if sym.name == "ThreadID":
      sym.name = "CurrentThreadID"
    if sym.name == "GLContextResetNotification":
      sym.name = "GLContextResetNotificationEnum"
    if sym.name == "KeyCode":
      sym.name = "KeyCodeEnum"


when defined(SDL2_GfxPrimitives_Static):
  cImport(srcDir / "SDL2_gfxPrimitives.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_rotozoom.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_framerate.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_imageFilter.h", recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
else:
  cImport(srcDir / "SDL2_gfxPrimitives.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_rotozoom.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_framerate.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")
  cImport(srcDir / "SDL2_imageFilter.h", recurse = false, dynlib="SDL2_GfxPrimitives_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")
import os, strutils, strformat
import ../nim_sdl2/wrapper as sdl2_wrapper
import nimterop/[cimport, build]

const
  baseDir = currentSourcePath.parentDir().parentDir().parentDir()
  buildDir = baseDir / "build"
  sdlDir = buildDir / "sdl2"
  sdlIncludeDir = sdlDir / "include"
  cmakeModPath = baseDir / "cmake" / "sdl2"
  srcDir = buildDir / "sdl2_ttf"

getHeader(
  "SDL_ttf.h",
  dlurl = "https://www.libsdl.org/projects/SDL_ttf/release/SDL2_ttf-$1.tar.gz",
  outdir = srcDir,
  altNames = "SDL2_ttf",
  cmakeFlags = &"-DCMAKE_C_FLAGS=-I{sdlIncludeDir} -DCMAKE_MODULE_PATH={cmakeModPath} " &
               &"-DSDL2MAIN_LIBRARY={SDLMainLib} -DSDL2_LIBRARY={SDLDyLibPath} -DSDL2_PATH={sdlDir}"
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
    # sym.name = sym.name.strip(chars = {'_'})

    # Remove prefixes or suffixes from procs
    if sym.name == "__MACOSX__":
      sym.name = "MACOSX"
    if sym.kind == nskProc or sym.kind == nskType or sym.kind == nskConst:
      if sym.name != "_":
        sym.name = sym.name.replace(re"^_+", "")
        sym.name = sym.name.replace(re"_+$", "")
    sym.name = sym.name.replace(re"^SDL_", "")

    if sym.name.startsWith("SDLK_"):
      sym.name = sym.name.replace("SDLK_", "KEYCODE_")

    if EVENT_TYPES.contains(sym.name):
      sym.name = "EVENT_" & sym.name

    if sym.name == "ThreadID":
      sym.name = "CurrentThreadID"
    if sym.name == "GLContextResetNotification":
      sym.name = "GLContextResetNotificationEnum"
    if sym.name == "KeyCode":
      sym.name = "KeyCodeEnum"

when defined(SDL_ttf_Static):
  cImport(SDL_ttf_Path, recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
else:
  cImport(SDL_ttf_Path, recurse = false, dynlib = "SDL_ttf_LPath", flags = &"-I={sdlIncludeDir} -f=ast2")

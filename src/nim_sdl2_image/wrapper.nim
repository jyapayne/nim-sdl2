import os, strutils
import ../nim_sdl2/wrapper
import nimterop/[cimport, build]

const
  baseDir = currentSourcePath.parentDir().parentDir().parentDir()
  srcDir = baseDir / "build" / "sdl2_image"

getHeader(
  "SDL_image.h",
  dlurl = "https://www.libsdl.org/projects/SDL_image/release/SDL2_image-2.0.5.tar.gz",
  outdir = srcDir,
  altNames = "SDL2_image"
)

static:
  # cDebug()
  # cDisableCaching()
  let contents = readFile(srcDir/"SDL_image.h")
  let newContents = contents.replace("""#include "SDL.h"
#include "SDL_version.h"
#include "begin_code.h"""", """
#include <SDL2/SDL.h>
#include <SDL2/SDL_version.h>
#include <SDL2/begin_code.h>
""").
    replace("""#include "close_code.h"""", "#include <SDL2/close_code.h>")

  writeFile(srcDir/"SDL_image.h", newContents)

# cOverride:
#   type


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


when not defined(SDL_Static):
  cImport(SDL_image_Path, recurse = false, dynlib = "SDL_image_LPath")
else:
  cImport(SDL_image_Path, recurse = false)

import os
import nimterop/[cimport, build]

const
  baseDir = currentSourcePath.parentDir().parentDir().parentDir()
  srcDir = baseDir/"build"/"sdl2"

getHeader(
  "SDL.h",
  dlurl = "https://www.libsdl.org/release/SDL2-2.0.12.tar.gz",
  outdir = srcDir
)

static:
  cDebug()
  cDisableCaching()
#   # let contents = readFile(srcDir/"include/SDL_gpu.h")
#   # let newContents = contents.replace(re"""#include "SDL.h"""", "#include <SDL2/SDL.h>", limit=1).
#   #   replace(re"""#include "begin_code.h"""", "", limit=1).
#   #   replace(re"""#include "close_code.h"""", "", limit=1)

#   # writeFile(srcDir/"include/SDL_gpu.h", newContents)

cOverride:
  const KEYCODE_UNDERSCORE* = ('_').KeyCodeEnum

  type
    BlitMap* {.incompleteStruct.} = object
    RWops* {.incompleteStruct.} = object

    GameControllerBindType* = enum
      CONTROLLER_BINDTYPE_NONE = 0,
      CONTROLLER_BINDTYPE_BUTTON,
      CONTROLLER_BINDTYPE_AXIS,
      CONTROLLER_BINDTYPE_HAT

    ButtonBindHat* = object
      hat*: int
      hatMask*: int

    GameControllerButtonBind* = object
      case bindType*: GameControllerBindType
      of CONTROLLER_BINDTYPE_BUTTON:
        button*: cint
      of CONTROLLER_BINDTYPE_AXIS:
        axis*: cint
      of CONTROLLER_BINDTYPE_HAT:
        hat*: ButtonBindHat
      of CONTROLLER_BINDTYPE_NONE:
        discard

    # This should work, but also overrides some types
    # Nimterop bug? @genotrance, comment these out
    # and uncomment the checks in onSymbol for it to kind of work
    # (it compiles but overrides nim types)
    Uint64* = uint64
    Uint32* = uint32
    Uint16* = uint16
    Uint8* = uint8

    Sint64* = int64
    Sint32* = int32
    Sint16* = int16
    Sint8* = int8
    Bool* = bool

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

    # if sym.name == "Uint64":
    #   sym.name = "uint64"
    # if sym.name == "Uint32":
    #   sym.name = "uint32"
    # if sym.name == "Uint16":
    #   sym.name = "uint16"
    # if sym.name == "Uint8":
    #   sym.name = "uint8"

    # if sym.name == "Sint64":
    #   sym.name = "int64"
    # if sym.name == "Sint32":
    #   sym.name = "int32"
    # if sym.name == "Sint16":
    #   sym.name = "int16"
    # if sym.name == "Sint8":
    #   sym.name = "int8"
    # if sym.name == "Bool":
    #   sym.name = "bool"


when not defined(SDL_Static):
  cImport(SDL_Path, recurse = true, dynlib = "SDL_LPath")
else:
  cImport(SDL_Path, recurse = true)
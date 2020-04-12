import os
import nimterop/[cimport, build]

const
  baseDir = currentSourcePath.parentDir().parentDir().parentDir()
  srcDir = baseDir / "build" / "sdl2"
  buildDir = srcDir / "buildcache"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

getHeader(
  "SDL.h",
  dlurl = "https://www.libsdl.org/release/SDL2-$1.tar.gz",
  outdir = srcDir
)

static:
  cSkipSymbol @["bool", "compile_time_assert_SDL_Event"]
  # cDebug()
  # cDisableCaching()

cOverride:
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

cPluginPath(symbolPluginPath)

when defined(SDL_Static):
  cImport(SDL_Path, recurse = true, flags = "-f=ast2 -DDOXYGEN_SHOULD_IGNORE_THIS")
else:
  cImport(SDL_Path, recurse = true, dynlib = "SDL_LPath", flags = "-f=ast2 -DDOXYGEN_SHOULD_IGNORE_THIS")

proc getDynlibExt(): string =
  when defined(windows):
    result = ".dll"
  elif defined(linux):
    result = ".so[0-9.]*"
  elif defined(macosx):
    result = ".dylib[0-9.]*"

proc findDynlib(): string =
  const pathRegex = "(lib)?SDL2[_-]?(static)?[0-9.\\-]*\\" & getDynlibExt()
  return findFile(pathRegex, buildDir, regex = true)

const SDLDyLibPath* = findDynlib()
const SDLMainLib* = buildDir / "libSDL2main.a"
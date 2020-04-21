import os, strutils, strformat
import nimterop/[cimport, build]

const
  SDLCacheDir* = currentSourcePath.parentDir().parentDir() / "build" #getProjectCacheDir("nimsdl2")
  baseDir = SDLCacheDir
  srcDir = baseDir / "sdl2"
  buildDir = srcDir / "buildcache"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

getHeader(
  "SDL.h",
  dlurl = "https://www.libsdl.org/release/SDL2-$1.tar.gz",
  outdir = srcDir,
  cmakeFlags = "-DSDL_STATIC_PIC=ON"
)

# {.passL: "-framework GLUT -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo -framework Carbon -framework CoreAudio -lm".}
static:
  cSkipSymbol @[
    "bool", "compile_time_assert_SDL_Event", "INLINE", "FUNCTION",
    "FILE", "LINE", "PRIu64", "PRIx64", "SDLPRIX64", "assert_state",
    "assert_data",
    # "SDL_AssertState", "SDL_AssertData", "SDL_threadID", "SDL_Keycode", "SDL_HapticConstant", "SDL_HapticRamp", "SDL_HapticLeftRight", "SDL_HapticCustom", "SDL_HapticPause", "SDL_Log"
  ]
  # cDebug()
  # cDisableCaching()
  # let contents = readFile(srcDir/"src"/"dynapi"/"SDL_dynapi_procs.h")
  # writeFile(srcDir/"src"/"dynapi"/"SDL_dynapi_procs.c", contents)

template sdl_button*(x: untyped): untyped =
  (1 shl ((x) - 1))

template WINDOWPOS_UNDEFINED_DISPLAY*(x: untyped): untyped =
  (WINDOWPOS_UNDEFINED_MASK or (x))

template WINDOWPOS_ISUNDEFINED*(x: untyped): untyped =
  (((x) and 0xFFFF0000) == WINDOWPOS_UNDEFINED_MASK)

template WINDOWPOS_CENTERED_DISPLAY*(x: untyped): untyped =
  (WINDOWPOS_CENTERED_MASK or (x))

template WINDOWPOS_ISCENTERED*(x: untyped): untyped =
  (((x) and 0xFFFF0000) == WINDOWPOS_CENTERED_MASK)

cOverride:
  const
    WINDOWPOS_UNDEFINED_MASK* = 0x1FFF0000.uint
    WINDOWPOS_CENTERED_MASK* = 0x2FFF0000.uint
    Colour* = ""
    BlitSurface* = ""
    BlitScaled* = ""
    MAX_SINT8* = int8.high
    MIN_SINT8* = int8.low
    MAX_UINT8* = uint8.high
    MIN_UINT8* = uint8.low
    MAX_SINT16* = int16.high
    MIN_SINT16* = int16.low
    MAX_UINT16* = uint16.high
    MIN_UINT16* = uint16.low
    MAX_SINT32* = int32.high
    MIN_SINT32* = int32.low
    MAX_UINT32* = uint32.high
    MIN_UINT32* = uint32.low
    MIN_UINT64* = uint64.low
    MAX_SINT64* = int64.high
    MAX_UINT64* = uint64.high
    TOUCH_MOUSEID* = cast[uint32](-1)
    MOUSE_TOUCHID* = -1.int64
    MUTEX_MAXWAIT* = ((not cast[uint32](0)))

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

static:
  when SDL_Static:
    const conf = staticExec(&"cd {srcDir}; ./sdl2-config --static-libs || (./configure --silent; ./sdl2-config --static-libs)").replace("-lSDL2 ", "").split('\n')[^1]
  else:
    const conf = staticExec(&"cd {srcDir}; ./sdl2-config --libs || (./configure --silent; ./sdl2-config --libs)").split('\n')[^1]
  {.passL: conf.}

when defined(SDL_Static):
  cImport(SDL_Path, recurse = true, flags = "-f=ast2 -DDOXYGEN_SHOULD_IGNORE_THIS -E__,_ -F__,_")
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
const SDLStaticLib* = buildDir / "libSDL2.a"

const
  WINDOWPOS_UNDEFINED* = WINDOWPOS_UNDEFINED_DISPLAY(0)
  WINDOWPOS_CENTERED* = WINDOWPOS_CENTERED_DISPLAY(0)

  SCANCODE_MASK* = (1 shl 30)

  BUTTON_LMASK* = sdl_button(BUTTON_LEFT)
  BUTTON_MMASK* = sdl_button(BUTTON_MIDDLE)
  BUTTON_RMASK* = sdl_button(BUTTON_RIGHT)
  BUTTON_X1MASK* = sdl_button(BUTTON_X1)
  BUTTON_X2MASK* = sdl_button(BUTTON_X2)

  HAPTIC_CONSTANT_TYPE* = (1 shl 0)
  HAPTIC_SINE_TYPE* = (1 shl 1)
  HAPTIC_LEFTRIGHT_TYPE* = (1 shl 2)
  HAPTIC_TRIANGLE_TYPE* = (1 shl 3)
  HAPTIC_SAWTOOTHUP_TYPE* = (1 shl 4)
  HAPTIC_SAWTOOTHDOWN_TYPE* = (1 shl 5)
  HAPTIC_RAMP_TYPE* = (1 shl 6)
  HAPTIC_SPRING_TYPE* = (1 shl 7)
  HAPTIC_DAMPER_TYPE* = (1 shl 8)
  HAPTIC_INERTIA_TYPE* = (1 shl 9)
  HAPTIC_FRICTION_TYPE* = (1 shl 10)
  HAPTIC_CUSTOM_TYPE* = (1 shl 11)
  HAPTIC_GAIN_TYPE* = (1 shl 12)
  HAPTIC_AUTOCENTER_TYPE* = (1 shl 13)
  HAPTIC_STATUS_TYPE* = (1 shl 14)
  HAPTIC_PAUSE_TYPE* = (1 shl 15)
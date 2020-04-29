import os, strutils, strformat
import nimterop/[cimport, build]

const
  SDLCacheDir* = currentSourcePath.parentDir().parentDir() / "build" #getProjectCacheDir("nimsdl2")
  baseDir = SDLCacheDir
  srcDir = baseDir / "sdl2"
  buildDir = srcDir / "buildcache"
  includeDir = srcDir / "include"
  symbolPluginPath = currentSourcePath.parentDir() / "cleansymbols.nim"

when defined(windows):
  const dlurl = "https://www.libsdl.org/release/SDL2-$1.zip"
else:
  const dlurl = "https://www.libsdl.org/release/SDL2-$1.tar.gz"

getHeader(
  "SDL.h",
  dlurl = dlurl,
  outdir = srcDir,
  cmakeFlags = "-DSDL_STATIC_PIC=ON",
  altNames = "SDL2"
)

# {.passL: "-framework GLUT -framework OpenGL -framework Cocoa -framework IOKit -framework CoreVideo -framework Carbon -framework CoreAudio -lm".}
static:
  cSkipSymbol @[
    "bool", "compile_time_assert_SDL_Event", "INLINE", "FUNCTION",
    "FILE", "LINE", "PRIu64", "PRIx64", "SDLPRIX64", "assert_state",
    "assert_data", "NULL"
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

    Bool* = bool

cPluginPath(symbolPluginPath)

static:
  # when SDL_Static:
  #   when defined(windows):
  #     const conf = "-lmingw32 -mwindows -Wl,--no-undefined -Wl,--dynamicbase -Wl,--nxcompat -Wl,--high-entropy-va -lm -ldinput8 -ldxguid -ldxerr8 -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lshell32 -lsetupapi -lversion -luuid -static-libgcc"
  #   else:
  #     const conf = staticExec(&"cd {srcDir}; ./sdl2-config --static-libs").replace("-lSDL2 ", "").replace("-lSDL2main", "").split('\n')[^1]
  # else:
  #   when defined(windows):
  #     const conf = "-lmingw32 -lSDL2main -lSDL2 -mwindows"
  #   else:
  #     const conf = staticExec(&"cd {srcDir}; ./sdl2-config --libs || (./configure --silent; ./sdl2-config --libs)").split('\n')[^1]

  when defined(windows):
    when defined(amd64):
      const flags = "--host=x86_64-w64-mingw32"
    else:
      const flags = "--host=i686-w64-mingw32"
  else:
    const flags = ""
  configure(srcDir.sanitizePath, "sdl2-config", flags)

proc unixizePath*(path: string, noQuote = false, sep = $DirSep): string =
  result = path.multiReplace([("C:\\", "/c/"), (sep, "/")])
  if not noQuote:
    result = result.quoteShell

static:
  proc getLibOutput(output: string): string =
    for line in output.split('\l'):
      if "lSDL2" in line:
        return line.strip()#.replace("-lSDL2 ", "").replace("-lSDL2main ", "")

  when defined(SDL_Static):
    when defined(windows):
      #TODO: Find a way to automate this on Windows reliably
      const conf = "-lmingw32 -lSDL2main -lSDL2 -mwindows -Wl,--no-undefined -Wl,--dynamicbase -Wl,--nxcompat -Wl,--high-entropy-va -lm -ldinput8 -ldxguid -ldxerr8 -luser32 -lgdi32 -lwinmm -limm32 -lole32 -loleaut32 -lshell32 -lsetupapi -lversion -luuid -static-libgcc"
    else:
      const cmd = &"cd {srcDir.sanitizePath} && bash ./sdl2-config --static-libs"
      const conf = execAction(cmd).output.getLibOutput
  else:
    when defined(windows):
      #TODO: Find a way to automate this on Windows reliably
      const conf = "-lmingw32 -lSDL2main -lSDL2 -mwindows"
    else:
      const cmd = &"cd {srcDir.sanitizePath} && bash ./sdl2-config --libs"
      const conf = execAction(cmd).output.getLibOutput
  echo conf
  echo buildDir.unixizePath
  {.passL: &"-L{buildDir.sanitizePath} -L{buildDir.unixizePath} {conf}".}

when defined(SDL_Static):
  cImport(srcDir/"include"/"SDL.h", recurse = true, flags = "-f=ast2 -DDOXYGEN_SHOULD_IGNORE_THIS -E__,_ -F__,_")
else:
  cImport(srcDir/"include"/"SDL.h", recurse = true, dynlib = "SDL_LPath", flags = "-f=ast2 -DDOXYGEN_SHOULD_IGNORE_THIS -E__,_ -F__,_")

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

proc findStaticlib(): string =
  const pathRegex = "(lib)?SDL2[_-]?(static)?[0-9.\\-]*\\.a"
  return findFile(pathRegex, buildDir, regex = true)

proc findStaticMainlib(): string =
  const pathRegex = "(lib)?SDL2[_-]?(static)?[0-9.\\-]*\\main.a"
  return findFile(pathRegex, buildDir, regex = true)

const SDLDyLibPath* = findDynlib()
const SDLMainLib* = buildDir / findStaticMainlib()
const SDLStaticLib* = buildDir / findStaticlib()
const SDL2ConfigPath* = srcDir / "sdl2-config"
const SDLSrcDir* = srcDir

static:
  let pathenv = getEnv("PATH")
  when defined(windows):
    putEnv("PATH", buildDir.sanitizePath & ";" & pathenv)
  else:
    putEnv("PATH", buildDir.sanitizePath & ":" & pathenv)
  echo pathenv
  echo includeDir
  putEnv("CFLAGS", "-I" & includeDir.sanitizePath)
  putEnv("LDFLAGS", &"-L{buildDir.sanitizePath} -L{buildDir.unixizePath}") # & " " & buildDir/"libSDL2main.a")
  putEnv("SDL2_CONFIG", (srcDir/"sdl2-config").sanitizePath)
  putEnv("LIBS", &"-L{buildDir.sanitizePath} -L{buildDir.unixizePath}")
  putEnv("SDL_CFLAGS", "-I" & includeDir.sanitizePath)
  putEnv("LD_LIBRARY_PATH", &"{buildDir.sanitizePath}:{buildDir.unixizePath}")
  putEnv("SDL2_PATH", srcDir.sanitizePath)

const
  WINDOWPOS_UNDEFINED* = WINDOWPOS_UNDEFINED_DISPLAY(0)
  WINDOWPOS_CENTERED* = WINDOWPOS_CENTERED_DISPLAY(0)

  SCANCODE_MASK* = (1 shl 30)

  BUTTON_LMASK* = sdl_button(BUTTON_LEFT)
  BUTTON_MMASK* = sdl_button(BUTTON_MIDDLE)
  BUTTON_RMASK* = sdl_button(BUTTON_RIGHT)
  BUTTON_X1MASK* = sdl_button(BUTTON_X1)
  BUTTON_X2MASK* = sdl_button(BUTTON_X2)
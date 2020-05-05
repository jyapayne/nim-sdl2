import os, strutils, strformat
import nimterop/[cimport, build]

const
  SDLCacheDir* = currentSourcePath.parentDir().parentDir() / "build" #getProjectCacheDir("nimsdl2")
  baseDir = SDLCacheDir
  srcDir = (baseDir / "sdl2").sanitizePath
  buildDir = (srcDir / "build" / ".libs").sanitizePath
  includeDir = (srcDir / "include").sanitizePath
  symbolPluginPath = (currentSourcePath.parentDir() / "cleansymbols.nim").sanitizePath

when defined(windows):
  const dlurl = "https://www.libsdl.org/release/SDL2-$1.zip"
else:
  const dlurl = "https://www.libsdl.org/release/SDL2-$1.tar.gz"

when defined(windows):
  when defined(amd64):
    const flags = &"--libdir={buildDir} --includedir={includeDir} --host=x86_64-w64-mingw32"
  else:
    const flags = &"--libdir={buildDir} --includedir={includeDir} --host=i686-w64-mingw32"
else:
  const flags = &"--libdir={buildDir} --includedir={includeDir}"

getHeader(
  "SDL.h",
  dlurl = dlurl,
  outdir = srcDir,
  conFlags = flags,
  altNames = "SDL2",
  buildTypes = [btAutoConf]
)

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
const SDLMainLib* = findStaticMainlib()
const SDLStaticLib* = findStaticlib()
const SDL2ConfigPath* = srcDir / "sdl2-config"
const SDLSrcDir* = srcDir
const SDLBuildDir* = buildDir
const SDLIncludeDir* = includeDir


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
      const conf = execAction(cmd).output.getLibOutput.replace("-lSDL2", SDLStaticLib)
  else:
    when defined(windows):
      #TODO: Find a way to automate this on Windows reliably
      const conf = "-lmingw32 -lSDL2main -lSDL2 -mwindows"
    else:
      const cmd = &"cd {srcDir} && bash ./sdl2-config --libs"
      const conf = execAction(cmd).output.getLibOutput

  when defined(linux):
    {.passL: &"-L{buildDir} -L{buildDir.unixizePath} {conf} -Wl,--no-as-needed -ldl -lsndio".}
  else:
    {.passL: &"{conf}".}

  echo conf
  when defined(SDL_Static):
    {.passC: "-static".}

  # let pathenv = getEnv("PATH")
  # when defined(windows):
  #   putEnv("PATH", buildDir & ";" & pathenv)
  # else:
  #   putEnv("PATH", buildDir & ":" & pathenv)
  let cflags = getEnv("CFLAGS")
  putEnv("CFLAGS", &"-I{includeDir} {cflags}")
  when defined(linux):
    putEnv("LDFLAGS", &"-L{buildDir} -L{buildDir.unixizePath} {conf} -Wl,--no-as-needed -lsndio -ldl") # & " " & buildDir/"libSDL2main.a")
  else:
    putEnv("LDFLAGS", &"-L{buildDir} -L{buildDir.unixizePath} {conf}") # & " " & buildDir/"libSDL2main.a")
  putEnv("SDL2_CONFIG", (srcDir/"sdl2-config").sanitizePath)
  putEnv("SDL_CONFIG", (srcDir/"sdl2-config").sanitizePath)
  putEnv("SDL_LIBS", &"-L{buildDir} -L{buildDir.unixizePath} {conf}")
  # let ldpath = getEnv("LD_LIBRARY_PATH")
  # putEnv("LD_LIBRARY_PATH", &"{buildDir}:{buildDir.unixizePath}:{ldpath}")
  # when defined(macosx):
  #   let dyldpath = getEnv("DYLD_LIBRARY_PATH")
  #   putEnv("DYLD_LIBRARY_PATH", &"{buildDir}:{buildDir.unixizePath}:{dyldpath}")
  # putEnv("SDL2_PATH", srcDir)

when defined(SDL_Static):
  cImport(srcDir/"include"/"SDL.h", recurse = true, flags = "-f=ast2 -DDOXYGEN_SHOULD_IGNORE_THIS -E__,_ -F__,_")
else:
  cImport(srcDir/"include"/"SDL.h", recurse = true, dynlib = "SDL_LPath", flags = "-f=ast2 -DDOXYGEN_SHOULD_IGNORE_THIS -E__,_ -F__,_")

const
  WINDOWPOS_UNDEFINED* = WINDOWPOS_UNDEFINED_DISPLAY(0)
  WINDOWPOS_CENTERED* = WINDOWPOS_CENTERED_DISPLAY(0)

  SCANCODE_MASK* = (1 shl 30)

  BUTTON_LMASK* = sdl_button(BUTTON_LEFT)
  BUTTON_MMASK* = sdl_button(BUTTON_MIDDLE)
  BUTTON_RMASK* = sdl_button(BUTTON_RIGHT)
  BUTTON_X1MASK* = sdl_button(BUTTON_X1)
  BUTTON_X2MASK* = sdl_button(BUTTON_X2)

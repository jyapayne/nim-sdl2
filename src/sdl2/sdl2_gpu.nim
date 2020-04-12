import os, strformat, strutils
import sdl2
import nimterop/[build, cimport]

export sdl2

const
  baseDir = currentSourcePath.parentDir().parentDir().parentDir()
  buildDir = baseDir / "build"
  sdlDir = buildDir / "sdl2"
  sdlIncludeDir = sdlDir / "include"
  cmakeModPath = baseDir / "cmake" / "sdl2"
  srcDir = buildDir / "sdl2_gpu"

getHeader(
  "SDL_gpu.h",
  giturl = "https://github.com/grimfang4/sdl-gpu",
  outdir = srcDir,
  altNames = "SDL2_gpu",
  cmakeFlags = &"-DCMAKE_C_FLAGS=-I{sdlIncludeDir} -DCMAKE_MODULE_PATH={cmakeModPath} -DSDL2_LIBRARY={SDLDyLibPath} " &
               &"-DSDL2MAIN_LIBRARY={SDLMainLib} -DSDL2_PATH={sdlDir} -DSDL2_INCLUDE_DIR={sdlIncludeDir} -DSDL_gpu_BUILD_DEMOS=OFF"
)

static:
  cDebug()
  cDisableCaching()

  # This shouldn't be needed, but for some reason is
  let contents = readFile(srcDir/"include/SDL_gpu.h")
  let newContents = contents.replace("""typedef struct GPU_Renderer GPU_Renderer;
typedef struct GPU_Target GPU_Target;""", "")

  writeFile(srcDir/"include/SDL_gpu.h", newContents)

cOverride:
  type
    LogLevelEnum* = enum
      LOG_LEVEL_INFO = 0
      LOG_LEVEL_WARNING
      LOG_LEVEL_ERROR

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
    # Remove prefixes or suffixes from procs
    if sym.name == "SDL_init_flags":
      sym.name = "sdlInitFlags"
    if sym.name == "GPU_init_flags":
      sym.name = "gpuInitFlags"

    if sym.kind == nskProc or sym.kind == nskType or sym.kind == nskConst:
      if sym.name != "_":
        sym.name = sym.name.strip(chars={'_'}).replace("___", "_")

    sym.name = sym.name.replace(re"^GPU_", "")
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

when defined(SDL_gpu_Static):
  cImport(SDL_gpuPath, recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
else:
  cImport(SDL_gpuPath, recurse = false, dynlib = "SDL_gpuLPath", flags = &"-I={sdlIncludeDir} -f=ast2")
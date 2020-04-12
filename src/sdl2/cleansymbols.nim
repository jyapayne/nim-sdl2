# import macros, nimterop / plugin
import strutils, regex
import sets

proc firstLetterLower(m: RegexMatch, s: string): string =
  s[m.group(0)[0]].toLowerAscii

proc camelCase(m: RegexMatch, s: string): string =
  s[m.group(0)[0]].toUpperAscii

proc nothing(m: RegexMatch, s: string): string =
  s[m.group(0)[0]]

const gpuReg = re"^GPU_(.)"
const sdlReg = re"^SDL_(.)"
const underscoreReg = re"_(.)"

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

  if sym.kind == nskProc:
    sym.name = sym.name.replace(gpuReg, firstLetterLower)
    sym.name = sym.name.replace(sdlReg, firstLetterLower)
  else:
    sym.name = sym.name.replace(gpuReg, nothing)
    sym.name = sym.name.replace(sdlReg, nothing)

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

  if sym.kind == nskField:
    sym.name = sym.name.replace(underscoreReg, camelCase)
import macros, nimterop / plugin
import strutils
import sets

template camelCase(str: string): string =
  var res = newStringOfCap(str.len)
  var i = 0
  while i < str.len:
    if str[i] == '_' and i < str.len - 1:
      res.add(str[i+1].toUpperAscii)
      i += 1
    else:
      res.add(str[i])
    i += 1
  res

template lowerFirstLetter(str, rep: string): string =
  if str.startsWith(rep):
    var res = str[rep.len .. ^1]
    res[0] = res[0].toLowerAscii
    res
  else:
    str

template removeBeginning(str, rep: string): string =
  if str.startsWith(rep):
    str[rep.len .. ^1]
  else:
    str

const replacements = [
  "GPU_",
  "SDL_",
  "TTF_",
  "SDLNet_",
  "Mix_",
  "IMG_"
]

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

const INT_TYPES = toHashSet([
  "Uint64",
  "Uint32",
  "Uint16",
  "Uint8",
  "Sint64",
  "Sint32",
  "Sint16",
  "Sint8",
])

# Symbol renaming examples
proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
  if sym.kind == nskType:
    if sym.name == "_SDL_Haptic":
      sym.name = "PHaptic"

  # Remove prefixes or suffixes from procs
  if sym.name.startsWith("SDL_HAPTIC_"):
    sym.name = sym.name.replace("SDL_HAPTIC_", "HAPTIC_TYPE_")
  if sym.name == "SDL_init_flags":
    sym.name = "sdlInitFlags"
  if sym.name == "GPU_init_flags":
    sym.name = "gpuInitFlags"

  if sym.kind == nskProc or sym.kind == nskType or sym.kind == nskConst:
    if sym.name != "_":
      sym.name = sym.name.strip(chars={'_'}).replace("__", "_")

  for rep in replacements:
    if sym.kind == nskProc:
      sym.name = lowerFirstLetter(sym.name, rep)
    else:
      sym.name = removeBeginning(sym.name, rep)


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

  if sym.name == "PRIX64":
    sym.name = "SDLPRIX64"

  if sym.kind == nskField:
    sym.name = camelCase(sym.name)
    if sym.name == "type":
      sym.name = "kind"

  # if INT_TYPES.contains(sym.name):
  #   sym.name = sym.name.replace("S", "")
  #   sym.name = sym.name.toLowerAscii() & "_ty"

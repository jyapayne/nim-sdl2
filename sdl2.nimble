# Package

version       = "0.1.0"
author        = "Joey Yakimowich-Payne"
description   = "SDL2 Autogenerated wrapper"
license       = "MIT"
srcDir        = "src"
skipDirs      = @["build"]

# Dependencies
requires "nim >= 1.0.6", "https://github.com/jyapayne/nimterop#367ec05", "regex >= 0.14.1"

when gorgeEx("nimble path nimterop").exitCode == 0:
  import nimterop/docs
  task docs, "Generate docs":
    buildDocs(@["src/sdl2.nim", "src/sdl2/sdl2_gpu.nim"], "build/htmldocs")
    cpFile("build/htmldocs/dochack.js", "build/htmldocs/sdl2/dochack.js")

else:
  task docs, "Do nothing": discard

task buildSDL2, "Build SDL2 example":
  exec "nimble c -f -r src/sdl2.nim"
  exec "nimble c -f -r src/sdl2/sdl2_gpu.nim"

task test, "Test":
  buildSDL2Task()
  # Doc building doesn't work on linux yet
  when not defined(linux):
    docsTask()

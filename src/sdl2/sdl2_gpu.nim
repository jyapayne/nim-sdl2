import os, strformat, strutils
import sdl2
import nimterop/[build, cimport]

const
  baseDir = SDLCacheDir
  sdlDir = baseDir / "sdl2"
  sdlIncludeDir = sdlDir / "include"
  srcDir = baseDir / "sdl2_gpu"
  currentPath = currentSourcePath().parentDir().parentDir()
  cmakeModPath = currentPath / "cmake" / "sdl2"
  symbolPluginPath = currentPath / "sdl2" / "cleansymbols.nim"

getHeader(
  "SDL_gpu.h",
  giturl = "https://github.com/grimfang4/sdl-gpu",
  outdir = srcDir,
  altNames = "SDL2_gpu",
  cmakeFlags = &"-DCMAKE_C_FLAGS=-I{sdlIncludeDir} -DCMAKE_MODULE_PATH={cmakeModPath} -DSDL2_LIBRARY={SDLDyLibPath} " &
               &"-DSDL2MAIN_LIBRARY={SDLMainLib} -DSDL2_PATH={sdlDir} -DSDL2_INCLUDE_DIR={sdlIncludeDir} -DSDL_gpu_BUILD_DEMOS=OFF"
)

static:
  cSkipSymbol @["Log"]
  # cDebug()
  # cDisableCaching()

cOverride:
  type
    WindowFlagEnum* = WindowFlags
    LogLevelEnum* = enum
      LOG_LEVEL_INFO = 0
      LOG_LEVEL_WARNING
      LOG_LEVEL_ERROR

const
  NONE* = 0.uint32
  FEATURE_NON_POWER_OF_TWO* = 0x1.uint32
  FEATURE_RENDER_TARGETS* = 0x2.uint32
  FEATURE_BLEND_EQUATIONS* = 0x4.uint32
  FEATURE_BLEND_FUNC_SEPARATE* = 0x8.uint32
  FEATURE_BLEND_EQUATIONS_SEPARATE* = 0x10.uint32
  FEATURE_GL_BGR* = 0x20.uint32
  FEATURE_GL_BGRA* = 0x40.uint32
  FEATURE_GL_ABGR* = 0x80.uint32
  FEATURE_VERTEX_SHADER* = 0x100.uint32
  FEATURE_FRAGMENT_SHADER* = 0x200.uint32
  FEATURE_PIXEL_SHADER* = 0x200.uint32
  FEATURE_GEOMETRY_SHADER* = 0x400.uint32
  FEATURE_WRAP_REPEAT_MIRRORED* = 0x800.uint32
  FEATURE_CORE_FRAMEBUFFER_OBJECTS* = 0x1000.uint32
  FEATURE_ALL_BASE* = FEATURE_RENDER_TARGETS
  FEATURE_ALL_BLEND_PRESETS* = (FEATURE_BLEND_EQUATIONS or FEATURE_BLEND_FUNC_SEPARATE)
  FEATURE_ALL_GL_FORMATS* = (FEATURE_GL_BGR or FEATURE_GL_BGRA or FEATURE_GL_ABGR)
  FEATURE_BASIC_SHADERS* = (FEATURE_FRAGMENT_SHADER or FEATURE_VERTEX_SHADER)
  FEATURE_ALL_SHADERS* = (FEATURE_FRAGMENT_SHADER or FEATURE_VERTEX_SHADER or FEATURE_GEOMETRY_SHADER)

  INIT_ENABLE_VSYNC* = 0x1.uint32
  INIT_DISABLE_VSYNC* = 0x2.uint32
  INIT_DISABLE_DOUBLE_BUFFER* = 0x4.uint32
  INIT_DISABLE_AUTO_VIRTUAL_RESOLUTION* = 0x8.uint32
  INIT_REQUEST_COMPATIBILITY_PROFILE* = 0x10.uint32
  INIT_USE_ROW_BY_ROW_TEXTURE_UPLOAD_FALLBACK* = 0x20.uint32
  INIT_USE_COPY_TEXTURE_UPLOAD_FALLBACK* = 0x40.uint32

  POINTS* = 0x0.uint32
  LINES* = 0x1.uint32
  LINE_LOOP* = 0x2.uint32
  LINE_STRIP* = 0x3.uint32
  TRIANGLES* = 0x4.uint32
  TRIANGLE_STRIP* = 0x5.uint32
  TRIANGLE_FAN* = 0x6.uint32

  BATCH_XY* = 0x1.uint32
  BATCH_XYZ* = 0x2.uint32
  BATCH_ST* = 0x4.uint32
  BATCH_RGB* = 0x8.uint32
  BATCH_RGBA* = 0x10.uint32
  BATCH_RGB8* = 0x20.uint32
  BATCH_RGBA8* = 0x40.uint32

  BATCH_XY_ST* = (BATCH_XY or BATCH_ST)
  BATCH_XYZ_ST* = (BATCH_XYZ or BATCH_ST)
  BATCH_XY_RGB* = (BATCH_XY or BATCH_RGB)
  BATCH_XYZ_RGB* = (BATCH_XYZ or BATCH_RGB)
  BATCH_XY_RGBA* = (BATCH_XY or BATCH_RGBA)
  BATCH_XYZ_RGBA* = (BATCH_XYZ or BATCH_RGBA)
  BATCH_XY_ST_RGBA* = (BATCH_XY or BATCH_ST or BATCH_RGBA)
  BATCH_XYZ_ST_RGBA* = (BATCH_XYZ or BATCH_ST or BATCH_RGBA)
  BATCH_XY_RGB8* = (BATCH_XY or BATCH_RGB8)
  BATCH_XYZ_RGB8* = (BATCH_XYZ or BATCH_RGB8)
  BATCH_XY_RGBA8* = (BATCH_XY or BATCH_RGBA8)
  BATCH_XYZ_RGBA8* = (BATCH_XYZ or BATCH_RGBA8)
  BATCH_XY_ST_RGBA8* = (BATCH_XY or BATCH_ST or BATCH_RGBA8)
  BATCH_XYZ_ST_RGBA8* = (BATCH_XYZ or BATCH_ST or BATCH_RGBA8)

  FLIP_NONE* = 0x0.uint32
  FLIP_HORIZONTAL* = 0x1.uint32
  FLIP_VERTICAL* = 0x2.uint32

  TYPE_BYTE* = 0x1400.uint32
  TYPE_UNSIGNED_BYTE* = 0x1401.uint32
  TYPE_SHORT* = 0x1402.uint32
  TYPE_UNSIGNED_SHORT* = 0x1403.uint32
  TYPE_INT* = 0x1404.uint32
  TYPE_UNSIGNED_INT* = 0x1405.uint32
  TYPE_FLOAT* = 0x1406.uint32
  TYPE_DOUBLE* = 0x140A.uint32

  RENDERER_UNKNOWN* = 0.uint32
  RENDERER_OPENGL_1_BASE* = 1.uint32
  RENDERER_OPENGL_1* = 2.uint32
  RENDERER_OPENGL_2* = 3.uint32
  RENDERER_OPENGL_3* = 4.uint32
  RENDERER_OPENGL_4* = 5.uint32
  RENDERER_GLES_1* = 11.uint32
  RENDERER_GLES_2* = 12.uint32
  RENDERER_GLES_3* = 13.uint32
  RENDERER_D3D9* = 21.uint32
  RENDERER_D3D10* = 22.uint32
  RENDERER_D3D11* = 23.uint32

cPluginPath(symbolPluginPath)

when defined(SDL_gpu_Static):
  cImport(SDL_gpuPath, recurse = false, flags = &"-I={sdlIncludeDir} -f=ast2")
else:
  cImport(SDL_gpuPath, recurse = false, dynlib = "SDL_gpuLPath", flags = &"-I={sdlIncludeDir} -f=ast2")
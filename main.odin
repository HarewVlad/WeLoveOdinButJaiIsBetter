package main

import "core:fmt"
import "vendor:glfw"
import "core:c"
import gl "vendor:OpenGL"

GL_MAJOR_VERSION : c.int : 4
GL_MINOR_VERSION :: 6

IsRunning : b32 = true

KeyCallback :: proc "c" (window : glfw.WindowHandle, key, scancode, action, mods : i32) {
  if key == glfw.KEY_ESCAPE {
    IsRunning = false
  }
}

SizeCallback :: proc "c" (window : glfw.WindowHandle, width, height : i32) {
  gl.Viewport(0, 0, width, height)
}

main :: proc() {
  glfw.WindowHint(glfw.RESIZABLE, 1)
  glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION) 
  glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)
  glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

  if glfw.Init() != 1 {
    fmt.println("Faled to call glfw.Init()")
    return
  }

  defer glfw.Terminate()

  window := glfw.CreateWindow(1024, 1024, "Main", nil, nil)
  defer glfw.DestroyWindow(window)

  if window == nil {
    fmt.println("Failed to call glfw.CreateWindow()")
    return
  }

  glfw.MakeContextCurrent(window)

  glfw.SwapInterval(1)

  glfw.SetKeyCallback(window, KeyCallback)

  gl.load_up_to(int(GL_MAJOR_VERSION), GL_MINOR_VERSION, glfw.gl_set_proc_address)

  Initialize();

  for (!glfw.WindowShouldClose(window) && IsRunning) {
    glfw.PollEvents()

    Update();
    Render();

    glfw.SwapBuffers(window)
  }
}

Initialize :: proc() {
  
}

Update :: proc() {
  
}

Render :: proc() {
  
}
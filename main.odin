package main

import "core:os"
import s "core:strings"
import "core:fmt"
import "vendor:glfw"
import "core:c"
import gl "vendor:OpenGL"

GL_MAJOR_VERSION : c.int : 3
GL_MINOR_VERSION :: 3

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

  window := glfw.CreateWindow(1920, 1080, "Main", nil, nil)
  defer glfw.DestroyWindow(window)

  if window == nil {
    fmt.println("Failed to call glfw.CreateWindow()")
    return
  }

  glfw.MakeContextCurrent(window)

  glfw.SwapInterval(1)

  glfw.SetKeyCallback(window, KeyCallback)

  gl.load_up_to(int(GL_MAJOR_VERSION), GL_MINOR_VERSION, glfw.gl_set_proc_address)

  program, vao : u32;
  Initialize(&program, &vao);

  for (!glfw.WindowShouldClose(window) && IsRunning) {
    glfw.PollEvents()

    Update();
    Render(program, vao);

    glfw.SwapBuffers((window))
  }
}

GetShaderCode :: proc(filename : string) -> cstring {
  bytes, success := os.read_entire_file_from_filename(filename)

  if !success {
    fmt.println("Failed to call os.read_entire_file_from_filename()")
    return ""
  }

  string := s.clone_from_bytes(bytes)

  return s.clone_to_cstring(string)
}

PrintShaderErrorLog :: proc(name : string, shader : u32) {
  result : i32
  gl.GetShaderiv(shader, gl.COMPILE_STATUS, &result)
  if result == 0 {
    buffer : [^]u8
    gl.GetShaderInfoLog(shader, 512, nil, buffer)
  }  
}

PrintProgramErrorLog :: proc(program : u32) {
  result : i32;
  gl.GetProgramiv(program, gl.LINK_STATUS, &result)
  if result == 0 {
    buffer : [^]u8
    gl.GetProgramInfoLog(program, 512, nil, buffer)
  }
}

Initialize :: proc(program, vao : ^u32) {
  // Vertex shader
  vs_code := GetShaderCode("vs.hlsl")
  vs := gl.CreateShader(gl.VERTEX_SHADER)
  gl.ShaderSource(vs, 1, &vs_code, nil)
  gl.CompileShader(vs)

  // Fragment shader
  fs_code := GetShaderCode("fs.hlsl")
  fs := gl.CreateShader(gl.FRAGMENT_SHADER)
  gl.ShaderSource(fs, 1, &fs_code, nil)
  gl.CompileShader(fs)

  defer {
    gl.DeleteShader(vs)
    gl.DeleteShader(fs)
  }

  // Program
  program^ = gl.CreateProgram()
  gl.AttachShader(program^, vs)
  gl.AttachShader(program^, fs)
  gl.LinkProgram(program^)
  gl.UseProgram(program^)

  // VAO
  gl.GenVertexArrays(1, vao)
  gl.BindVertexArray(vao^)

  // Vertex buffer
  vertices := [9]f32 {
    -0.5, -0.5, 0.0, 
    0.5, -0.5, 0.0, 
    0.0, 0.5, 0.0,
  }

  vbo : u32;
  gl.GenBuffers(1, &vbo)
  gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
  gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), &vertices, gl.STATIC_DRAW)

  // Vertex attributes
  void : uintptr
  gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), void)
  gl.EnableVertexAttribArray(0)
}

Update :: proc() {
  
}

Render :: proc(program, vao : u32) {
  gl.ClearColor(0.3, 0.3, 0.3, 1)
  gl.Clear(gl.COLOR_BUFFER_BIT)

  gl.UseProgram(program);
  gl.BindVertexArray(vao);
  gl.DrawArrays(gl.TRIANGLES, 0, 3);
}
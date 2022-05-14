package main

import "core:fmt"
import "core:os"
import sc "core:strconv"
import s  "core:strings"


Vector3f :: [3] f32
Vector2f :: [2] f32

Face :: struct {
    vertex_ids: [dynamic] int,
    vertex_texture_ids: [dynamic] int,
    vertex_normal_ids: [dynamic] int,
}

Obj :: struct {
    vertices: [dynamic] Vector3f,
    texture_vertices: [dynamic] Vector2f,
    normal_vertices:  [dynamic] Vector3f,
    faces: [dynamic] ^Face,
}

parse_Vector3f :: proc(strings: [] string) -> (result: Vector3f, ok: bool) {
    x, ok_x := sc.parse_f32(strings[0]);
    y, ok_y := sc.parse_f32(strings[1]);
    z, ok_z := sc.parse_f32(strings[2]);

    if ok_x && ok_y && ok_z  { return Vector3f{x, y, z}, true;  }
    else                     { return Vector3f{0, 0, 0}, false; }
}

parse_Vector2f :: proc(strings: [] string) -> (result: Vector2f, ok: bool) {
    x, ok_x := sc.parse_f32(strings[0]);
    y, ok_y := sc.parse_f32(strings[1]);

    if ok_x && ok_y  { return Vector2f{x, y}, true;  }
    else             { return Vector2f{0, 0}, false; }
}

parse_obj :: proc(filename: string) -> (result: ^Obj, sucess: bool) {
    data, success := os.read_entire_file_from_filename(filename);
    if !success {
        fmt.println("ERROR: Cannot read file with name", filename);
        return nil, false;
    }

    obj_text := s.clone_from_bytes(data);
    obj_lines := s.split_lines(obj_text);

    result = new(Obj);

    for line in obj_lines {
        if len(line) == 0 { continue; }

        line_array := s.split(line, " ");
        specifier := line_array[0];

        switch specifier {
        case "v":
            vec, ok := parse_Vector3f(line_array[1:]);
            if !ok  { fmt.println("Error reading vertex data!"); };

            append(&result.vertices, vec);

        case "vt":
            vec, ok := parse_Vector2f(line_array[1:]);
            if !ok  { fmt.println("Error reading vertex texture data!"); };

            append(&result.texture_vertices, vec);

        case "vn":
            vec, ok := parse_Vector3f(line_array[1:]);
            if !ok  { fmt.println("Error reading vertex normals data!"); };

            append(&result.normal_vertices, vec);

        case "f":
            face := new(Face);
            for joined_ids in line_array[1:] {
                string_ids := s.split(joined_ids, "/");

                append(&face.vertex_ids, sc.atoi(string_ids[0]));

                if len(string_ids) > 1 && len(string_ids[1]) != 0 {
                    append(&face.vertex_texture_ids, sc.atoi(string_ids[1]));
                }

                if len(string_ids) > 2 && len(string_ids[2]) != 0 {
                    append(&face.vertex_normal_ids, sc.atoi(string_ids[2]));
                }
            }

            append(&result.faces, face);

        // Unhandled
        case "s":
        case "o":

        case "usemtl":
            // Handle usemtl
        case "mtllib":
            // Handle mtllib
        case "#": fallthrough
        case:
            // Skip line
        }
    }
    
    return result, false;
}
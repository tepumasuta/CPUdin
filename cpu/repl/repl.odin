package repl

import "../../cpu"

import "core:io"
import "core:os"
import "core:bufio"
import "core:strings"
import "core:strconv"

Action :: union #no_nil {
    Quit,
    Print,
    Error,
}
Error :: struct {
    excuse: string,
    err: ErrorType,
}
ErrorType :: union #no_nil {
    io.Error,
    ReplError,
}
ReplError :: enum {
    InvalidArguments,
    UnknownCommand,
    InvalidRegister,
}
Quit :: struct {}
Print :: union #no_nil {
    CPU,
    uint,
    ProgramCounter,
    Flags,
    Mem,
}
CPU :: struct {}
ProgramCounter :: struct {}
Flags :: struct {}
Mem :: union {
    RAM,
    uint,
}
RAM :: struct {}

repl :: proc(processor: ^cpu.CPU, mem: ^cpu.RAM) {
    for action := get_action();; action = get_action() {
        unimplemented("TODO: repl loop")
    }
}

get_action :: proc() -> Action {
    stdin_reader: bufio.Reader
    bufio.reader_init(&stdin_reader, os.stream_from_handle(os.stdin))
    defer bufio.reader_destroy(&stdin_reader)
    line, err := bufio.reader_read_string(&stdin_reader, '\n')
    defer if err == nil do delete(line)
    if err != nil do return Error { "Failed to read line", err }
    if strings.starts_with("quit", line) do return Quit{}
    parts := strings.split(line, " ")
    if len(parts) > 3 do return Error { "Too many arguments", .InvalidArguments }
    if strings.starts_with("print", parts[0]) {
        if len(parts) == 1 do return Print(CPU{})
        if len(parts) == 2 {
            if strings.compare("pc", parts[1]) == 0 do return Print(ProgramCounter{})
            if strings.starts_with("flags", parts[1]) do return Print(Flags{})
            if parts[1][0] == 'r' {
                num, ok := strconv.parse_uint(parts[1][1:])
                if !ok do return Error { "Unknown command", .UnknownCommand }
                if num == 0 || num > 4 do return Error { "Incorrect register index", .InvalidRegister }
                return Print(num)
            }
        }
        if strings.starts_with("memory", parts[1]) {
            if len(parts) == 2 do return Print(Mem(RAM{}))
            num, ok := strconv.parse_uint(parts[2])
            if !ok do return Error { "Unknown memory cell", .InvalidArguments }
            if num > 255 do return Error { "Incorrect memory address", .InvalidArguments }
            return Print(Mem(num))
        }
        return Error { "Invalid print arguments", .InvalidArguments }
    }
    return Error { "Unknown command", .UnknownCommand }
}

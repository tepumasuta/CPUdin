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

try_parse_quit :: proc(line: string) -> Maybe(Quit) {
    if strings.starts_with("quit", line) do return Quit{}
    return nil
}

try_parse_print_registers :: proc(parts: []string) -> Maybe(Action) {
    if strings.compare("pc", parts[1]) == 0 do return Print(ProgramCounter{})
    if strings.starts_with("flags", parts[1]) do return Print(Flags{})
    if parts[1][0] != 'r' do return nil
    num, ok := strconv.parse_uint(parts[1][1:])
    if !ok do return Error { "Unknown print command", .UnknownCommand }
    if num == 0 || num > 4 do return Error { "Incorrect register index", .InvalidRegister }
    return Print(num)
}

try_parse_print_memory :: proc(parts: []string) -> Maybe(Action) {
    if !strings.starts_with("memory", parts[1]) do return nil
    if len(parts) == 2 do return Print(Mem(RAM{}))
    num, ok := strconv.parse_uint(parts[2])
    if !ok do return Error { "Unknown memory cell", .InvalidArguments }
    if num > 255 do return Error { "Incorrect memory address", .InvalidArguments }
    return Print(Mem(num))
}

try_parse_print :: proc(parts: []string) -> Maybe(Action) {
    if !strings.starts_with("print", parts[0]) do return nil
    if len(parts) == 1 do return Print(CPU{})
    if print, ok := try_parse_print_registers(parts).(Action); ok do return print
    if print, ok := try_parse_print_memory(parts).(Action); ok do return print
    return Error { "Invalid print arguments", .InvalidArguments }
}

get_action :: proc() -> Action {
    stdin_reader: bufio.Reader
    bufio.reader_init(&stdin_reader, os.stream_from_handle(os.stdin))
    defer bufio.reader_destroy(&stdin_reader)
    line, err := bufio.reader_read_string(&stdin_reader, '\n')
    defer if err == nil do delete(line)
    if err != nil do return Error { "Failed to read line", err }
    if action, empty := try_parse_quit(line).(Quit); !empty do return action
    parts := strings.split(line, " ")
    defer delete(parts)
    if action, empty := try_parse_print(parts).(Action); !empty do return action
    return Error { "Unknown command", .UnknownCommand }
}

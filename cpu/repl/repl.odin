package repl

import "../../cpu"

import "core:io"
import "core:os"
import "core:bufio"
import "core:strings"
import "core:strconv"

@(private)
Action :: union #no_nil {
    Quit,
    Print,
    Step,
    Error,
}
@(private)
Error :: struct {
    excuse: string,
    err: ErrorType,
}
@(private)
ErrorType :: union #no_nil {
    io.Error,
    ReplError,
}
@(private)
ReplError :: enum {
    InvalidArguments,
    UnknownCommand,
    InvalidRegister,
}
@(private) Quit :: struct {}
@(private)
Print :: union #no_nil {
    CPU,
    uint,
    ProgramCounter,
    Flags,
    Mem,
}
@(private) CPU :: struct {}
@(private) ProgramCounter :: struct {}
@(private) Flags :: struct {}
@(private)
Mem :: union {
    RAM,
    uint,
}
@(private) RAM :: struct {}
@(private) Step :: struct {}

repl :: proc(processor: ^cpu.CPU, mem: ^cpu.RAM) {
    for action := get_action();; action = get_action() {
        unimplemented("TODO: repl loop")
    }
}

@(private)
try_parse_quit :: proc(line: string) -> Maybe(Quit) {
    if strings.starts_with("quit", line) do return Quit{}
    return nil
}

@(private)
try_parse_step :: proc(line: string) -> Maybe(Step) {
    if strings.starts_with("step", line) do return Step{}
    return nil
}

@(private)
try_parse_print_registers :: proc(parts: []string) -> Maybe(Action) {
    if strings.compare("pc", parts[1]) == 0 do return Print(ProgramCounter{})
    if strings.starts_with("flags", parts[1]) do return Print(Flags{})
    if parts[1][0] != 'r' do return nil
    num, ok := strconv.parse_uint(parts[1][1:])
    if !ok do return Error { "Unknown print command", .UnknownCommand }
    if num == 0 || num > 4 do return Error { "Incorrect register index", .InvalidRegister }
    return Print(num)
}

@(private)
try_parse_print_memory :: proc(parts: []string) -> Maybe(Action) {
    if !strings.starts_with("memory", parts[1]) do return nil
    if len(parts) == 2 do return Print(Mem(RAM{}))
    num, ok := strconv.parse_uint(parts[2])
    if !ok do return Error { "Unknown memory cell", .InvalidArguments }
    if num > 255 do return Error { "Incorrect memory address", .InvalidArguments }
    return Print(Mem(num))
}

@(private)
try_parse_print :: proc(parts: []string) -> Maybe(Action) {
    if !strings.starts_with("print", parts[0]) do return nil
    if len(parts) == 1 do return Print(CPU{})
    if print, ok := try_parse_print_registers(parts).(Action); ok do return print
    if print, ok := try_parse_print_memory(parts).(Action); ok do return print
    return Error { "Invalid print arguments", .InvalidArguments }
}

@(private)
get_action :: proc() -> Action {
    stdin_reader: bufio.Reader
    bufio.reader_init(&stdin_reader, os.stream_from_handle(os.stdin))
    defer bufio.reader_destroy(&stdin_reader)
    line, err := bufio.reader_read_string(&stdin_reader, '\n')
    defer if err == nil do delete(line)
    if err != nil do return Error { "Failed to read line", err }
    if action, empty := try_parse_quit(line).(Quit); !empty do return action
    if action, empty := try_parse_step(line).(Step); !empty do return action
    parts := strings.split(line, " ")
    defer delete(parts)
    if action, empty := try_parse_print(parts).(Action); !empty do return action
    return Error { "Unknown command", .UnknownCommand }
}

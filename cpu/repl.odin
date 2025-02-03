package cpu

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
    WrongArguments,
    UnknownCommand,
}
Quit :: struct {}
Print :: union #no_nil {
    All,
    int,
    ProgramCounter,
    Flags,
}
All :: struct {}
ProgramCounter :: struct {}
Flags :: struct {}

repl :: proc(cpu: ^CPU, mem: ^RAM) {
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
    if len(parts) > 2 do return Error { "Too many arguments", .WrongArguments }
    if strings.starts_with("print", parts[0]) {
        unimplemented("TODO: parse print")
    }
    return Error { "Unknown command", .UnknownCommand }
}

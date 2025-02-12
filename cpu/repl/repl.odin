package repl

import "../../cpu"
import "../../vendor/editline"

import "core:io"
import "core:os"
import "core:bufio"
import "core:strings"
import "core:strconv"
import "core:fmt"

@(private)
Action :: union {
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
@(private) Quit :: distinct struct {}
@(private)
Print :: union #no_nil {
    CPU,
    uint,
    ProgramCounter,
    Flags,
    Mem,
}
@(private) CPU :: distinct struct {}
@(private) ProgramCounter :: distinct struct {}
@(private) Flags :: distinct struct {}
@(private)
Mem :: union {
    RAM,
    uint,
}
@(private) RAM :: distinct struct {}
@(private) Step :: distinct struct {}

repl :: proc(processor: ^cpu.CPU, mem: ^cpu.RAM) {
    editline.hist_size = 20
    editline.initialize()
    defer editline.uninitialize()
    editline.read_history(".cpudin-history.txt")

    last_action: Action = nil
    for action := get_action_pretty();; action = get_action_pretty() {
        if action == nil do action = last_action
        switch act in action {
        case Quit: return
        case Step: cpu.step(processor, mem)
        case Error: fmt.eprintfln("[ERROR]: %v because %v", act.err, act.excuse)
        case Print: print(processor, mem, act)
        }
        last_action = action
    }
}

@(private)
get_action_pretty :: proc() -> Action {
    return get_action()
}

@(private)
print_prelude :: proc() {
    fmt.print("")
}

@(private)
get_action :: proc() -> Action {
    // full_line, err := bufio.reader_read_string(&stdin_reader, '\n')
    full_line_c, ok := editline.readline("$> ")
    if !ok do return Quit{}
    defer delete(full_line_c)
    line := strings.trim_right(string(full_line_c), " ")
    if len(line) == 0 do return nil
    if action, ok := try_parse_quit(line).(Quit); ok do return action
    if action, ok := try_parse_step(line).(Step); ok do return action
    parts := strings.split(line, " ")
    defer delete(parts)
    if action, ok := try_parse_print(parts).(Action); ok do return action
    return Error { "Unknown command", .UnknownCommand }
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
print :: proc(processor: ^cpu.CPU, mem: ^cpu.RAM, print_case: Print) {
    switch value in print_case {
    case Mem:
        switch address in value {
        case RAM: fmt.printfln("%x", mem^)
        case uint:
            print_raw_value_u8(mem[address])
            fmt.println()
        }
    case ProgramCounter:
        fmt.print("pc = ")
        print_raw_value_u8(processor.pc)
        fmt.println()
    case uint:
        fmt.printf("r%v = ", value)
        print_raw_value_u8(processor.regs[value - 1])
        fmt.println()
    case Flags:
        fmt.printfln("Flags {{ OF = %d, ZF = %d, GR = %d }}", int(processor.flags.OF), int(processor.flags.ZF), int(processor.flags.GR))
    case CPU:
        fmt.print("CPU { pc = ")
        print_raw_value_u8(processor.pc)
        fmt.printf(", Flags {{ OF = %d, ZF = %d, GR = %d }}", int(processor.flags.OF), int(processor.flags.ZF), int(processor.flags.GR))
        for i in 0..=3 {
            fmt.printf(", r%v = ", i + 1)
            print_raw_value_u8(processor.regs[i])
        }
        fmt.println(" }")
    }
}

@(private)
print_raw_value_u8 :: proc(value: u8) {
    fmt.printf("%x (%v)", value, value)
}

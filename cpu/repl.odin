package cpu

Action :: enum {
    Quit,
    Print,
}

repl :: proc(cpu: ^CPU, mem: ^RAM) {
    for action := get_action(); action != .Quit; action = get_action() {
        unimplemented("TODO: repl loop")
    }
}

get_action :: proc() -> Action { unimplemented("TODO: action") }

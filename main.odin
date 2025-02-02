package main

import "core:fmt"
import "core:os"
import "./cpu"

main :: proc() {
    processor: cpu.CPU
    memory: cpu.RAM = ---

    if len(os.args) < 2 {
        fmt.eprintln("[ERROR]: RAM file required")
        os.exit(1)
    }

    data, success := os.read_entire_file(os.args[1])
    if !success {
        fmt.eprintfln("[ERROR]: Failed to read file `%v`", os.args[1])
        os.exit(1)
    }
    copy(memory[:], data[:256] if len(data) > 256 else data[:])

    for {
        cpu.step(&processor, &memory)
    }
}

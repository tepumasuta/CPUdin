package cpu

CPU :: struct {
    using registers: struct #raw_union {
        regs: [4]u8,
        using rs: struct { r1, r2, r3, r4: u8 },
    },
    flags: struct {
        OF, GT, LT, ZF, : bool, // Overflow, Greater, Less, Zero
    },
    pc: u8,
}

Mem :: [256]u8

step :: proc(cpu: ^CPU, memory: ^Mem) {
    command := fetch(cpu, memory)
    decode(cpu, memory, command)
}

fetch :: proc(cpu: ^CPU, memory: ^Mem) -> u8 {
    return memory[cpu.pc]
}

decode :: proc(cpu: ^CPU, memory: ^Mem, command: u8) {
    switch (command & 0xC0) >> 6 {
    case 0b00: unimplemented("TODO: arithmetic")
    case 0b01: unimplemented("TODO: move low")
    case 0b10: unimplemented("TODO: move high")
    case 0b11: unimplemented("TODO: misc")
    }
}

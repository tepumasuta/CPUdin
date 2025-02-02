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

ARITHMETIC: [4]proc(cpu: ^CPU, memory: Mem, command: u8) = {
    add, sub, div, mul,
}

step :: proc(cpu: ^CPU, memory: ^Mem) {
    command := fetch(cpu, memory)
    decode(cpu, memory, command)
}

fetch :: proc(cpu: ^CPU, memory: ^Mem) -> u8 {
    return memory[cpu.pc]
}

decode :: proc(cpu: ^CPU, memory: ^Mem, command: u8) -> proc(cpu: ^CPU, memory: Mem, command: u8) {
    switch (command & 0xC0) >> 6 {
    case 0b00: return ARITHMETIC[(command & 0x30) >> 4] // 00BBCCDD -> BB -- command, CC, DD -- operands
    case 0b01: unimplemented("TODO: move low")
    case 0b10: unimplemented("TODO: move high")
    case 0b11: unimplemented("TODO: misc")
    }
    unreachable()
}

add :: proc(cpu: ^CPU, memory: Mem, command: u8) { unimplemented("TODO: implement add") }
sub :: proc(cpu: ^CPU, memory: Mem, command: u8) { unimplemented("TODO: implement sub") }
div :: proc(cpu: ^CPU, memory: Mem, command: u8) { unimplemented("TODO: implement div") }
mul :: proc(cpu: ^CPU, memory: Mem, command: u8) { unimplemented("TODO: implement mul") }

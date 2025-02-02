package cpu

CPU :: struct {
    using registers: struct #raw_union {
        regs: [4]u8,
        using rs: struct { r1, r2, r3, r4: u8 },
    },
    flags: struct {
        OF, ZF, GR: bool, // Overflow, Zero, Greater
    },
    pc: u8,
}

Mem :: [256]u8

ARITHMETIC: [4]proc(cpu: ^CPU, memory: ^Mem, command: u8) = {
    add, sub, div, mul,
}

step :: proc(cpu: ^CPU, memory: ^Mem) {
    command := fetch(cpu, memory)
    decode(cpu, memory, command)
}

fetch :: proc(cpu: ^CPU, memory: ^Mem) -> u8 {
    return memory[cpu.pc]
}

decode :: proc(cpu: ^CPU, memory: ^Mem, command: u8) -> proc(cpu: ^CPU, memory: ^Mem, command: u8) {
    switch (command & 0xC0) >> 6 {
    case 0b00: return ARITHMETIC[(command & 0x30) >> 4] // 00BBCCDD -> BB -- command, CC, DD -- operands
    case 0b01: return move_low // mov.l
    case 0b10: return move_high // mov.h
    case 0b11: return jump // 11UABCDD -> U -- uncond, A -- OF, B -- ZF, C -- GR, DD -- reg
    }
    unreachable()
}

add :: proc(cpu: ^CPU, memory: ^Mem, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: u16 = u16(op1) + u16(op2)
    regs[(command & 0x0C) >> 2] = u8(res)
    flags.ZF = res == 0
    flags.OF = res >= (1 << 8)
}

sub :: proc(cpu: ^CPU, memory: ^Mem, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: i16 = i16(op1) - i16(op2)
    regs[(command & 0x0C) >> 2] = u8(res %% 255)
    flags.ZF = res == 0
    flags.OF = op1 < op2
    flags.GR = op1 > op2
}

mul :: proc(cpu: ^CPU, memory: ^Mem, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: u16 = u16(op1) * u16(op2)
    regs[(command & 0x0C) >> 2] = u8(res)
    flags.ZF = res == 0
    flags.OF = res >= (1 << 8)
}

div :: proc(cpu: ^CPU, memory: ^Mem, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: u16 = u16(op1) / u16(op2)
    regs[(command & 0x0C) >> 2] = u8(res)
    flags.ZF = res == 0
}


move_low :: proc(cpu: ^CPU, memory: ^Mem, command: u8) {
    cpu.regs[(command & 0x30) >> 4] = (cpu.regs[command & 0x30] & 0xF0) | (command & 0x0F)
}


move_high :: proc(cpu: ^CPU, memory: ^Mem, command: u8) {
    cpu.regs[(command & 0x30) >> 4] = (cpu.regs[command & 0x30] & 0x0F) | (command & 0xF0)
}

jump :: proc(cpu: ^CPU, memory: ^Mem, command: u8) {
    using cpu
    if command & 0x20 != 0 do pc = regs[command & 0x03]
    if command & 0x10 != 0 && flags.OF || command & 0x08 != 0 && flags.ZF || command & 0x04 != 0 && flags.GR {
        pc = regs[command & 0x03]
    }
}

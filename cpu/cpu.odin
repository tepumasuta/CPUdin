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
    case 0b01: return mov_h // mov.l
    case 0b10: return mov_l // mov.h
    case 0b11: unimplemented("TODO: misc")
    }
    unreachable()
}

add :: proc(cpu: ^CPU, memory: Mem, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: u16 = u16(op1) + u16(op2)
    regs[(command & 0x0C) >> 2] = u8(res)
    flags.ZF = res == 0
    flags.OF = res >= (1 << 8)
}

sub :: proc(cpu: ^CPU, memory: Mem, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: i16 = i16(op1) - i16(op2)
    regs[(command & 0x0C) >> 2] = u8(res %% 255)
    flags.ZF = res == 0
    flags.OF = op1 < op2
}

mul :: proc(cpu: ^CPU, memory: Mem, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: u16 = u16(op1) * u16(op2)
    regs[(command & 0x0C) >> 2] = u8(res)
    flags.ZF = res == 0
    flags.OF = res >= (1 << 8)
}

div :: proc(cpu: ^CPU, memory: Mem, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: u16 = u16(op1) / u16(op2)
    regs[(command & 0x0C) >> 2] = u8(res)
    flags.ZF = res == 0
}


mov_l :: proc(cpu: ^CPU, memory: Mem, command: u8) {
    cpu.regs[command & 0x30] = (cpu.regs[command & 0x30] & 0xF0) | (command & 0x0F)
}


mov_h :: proc(cpu: ^CPU, memory: Mem, command: u8) {
    cpu.regs[command & 0x30] = (cpu.regs[command & 0x30] & 0xF0) | (command & 0x0F)
}


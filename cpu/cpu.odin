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

RAM :: [256]u8

ARITHMETIC: [4]proc(cpu: ^CPU, memory: ^RAM, command: u8) = {
    add, sub, mul, div,
}

LEFTOVER: [4]proc(cpu: ^CPU, memory: ^RAM, command: u8) = {
    jump, cmp, store, load,
}

step :: proc(cpu: ^CPU, memory: ^RAM) {
    command := fetch(cpu, memory)
    execute := decode(cpu, memory, command)
    execute(cpu, memory, command)
    cpu.pc += 1
}

fetch :: proc(cpu: ^CPU, memory: ^RAM) -> u8 {
    return memory[cpu.pc]
}

decode :: proc(cpu: ^CPU, memory: ^RAM, command: u8) -> proc(cpu: ^CPU, memory: ^RAM, command: u8) {
    switch (command & 0xC0) >> 6 {
    case 0b00: return ARITHMETIC[(command & 0x30) >> 4] // 00BBCCDD -> BB -- command, CC, DD -- operands
    case 0b01: return move_low // mov.l
    case 0b10: return move_high // mov.h
    case 0b11: return LEFTOVER[(command & 0x30) >> 4] // 11AABBCCDD, DD -- reg, AA{00->jmp, 10->store, 11->load}
    }
    unreachable()
}

add :: proc(cpu: ^CPU, memory: ^RAM, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: u16 = u16(op1) + u16(op2)
    regs[(command & 0x0C) >> 2] = u8(res)
    flags.ZF = res == 0
    flags.OF = res >= (1 << 8)
}

sub :: proc(cpu: ^CPU, memory: ^RAM, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: i16 = i16(op1) - i16(op2)
    regs[(command & 0x0C) >> 2] = u8(res %% 255)
    flags.ZF = res == 0
    flags.OF = op1 < op2
    flags.GR = op1 > op2
}

mul :: proc(cpu: ^CPU, memory: ^RAM, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: u16 = u16(op1) * u16(op2)
    regs[(command & 0x0C) >> 2] = u8(res)
    flags.ZF = res == 0
    flags.OF = res >= (1 << 8)
}

div :: proc(cpu: ^CPU, memory: ^RAM, command: u8) {
    using cpu
    op1, op2 := cpu.regs[(command & 0x0C) >> 2], cpu.regs[command & 0x03]
    res: u16 = u16(op1) / u16(op2)
    regs[(command & 0x0C) >> 2] = u8(res)
    flags.ZF = res == 0
}


move_low :: proc(cpu: ^CPU, memory: ^RAM, command: u8) {
    cpu.regs[(command & 0x30) >> 4] = (cpu.regs[(command & 0x30) >> 4] & 0xF0) | (command & 0x0F)
}

move_high :: proc(cpu: ^CPU, memory: ^RAM, command: u8) {
    cpu.regs[(command & 0x30) >> 4] = (cpu.regs[(command & 0x30) >> 4] & 0x0F) | ((command & 0x0F) << 4)
}

jump :: proc(cpu: ^CPU, memory: ^RAM, command: u8) {
    using cpu
    switch (command & 0x0C) >> 2 {
    case 0b00: pc = command & 0x03
    case 0b01: if flags.GR do pc = command & 0x03
    case 0b10: if flags.OF do pc = command & 0x03
    case 0b11: if flags.ZF do pc = command & 0x03
    }
    unreachable()
}

cmp :: proc(cpu: ^CPU, memory: ^RAM, command: u8) { unimplemented("cmp") }

store :: proc(cpu: ^CPU, memory: ^RAM, command: u8) {
    memory[cpu.regs[(command & 0x0C) >> 2]] = cpu.regs[command & 0x03]
}

load :: proc(cpu: ^CPU, memory: ^RAM, command: u8) {
    cpu.regs[command & 0x03] = memory[cpu.regs[(command & 0x0C) >> 2]]
}

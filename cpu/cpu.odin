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

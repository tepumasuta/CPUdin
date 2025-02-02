# CPUdin 😈

## Overview

An 8-bit minimalistic cpu implemented in [Odin](https://odin-lang.org/) programming language. It has 4 registers, the flag reister and the program counter registers and can address 256 bytes of memory. Following flags are supported: ZF (zero), OF (overflow), GR (greater). For instruction set see Encoding section. All programs starts with progam counter = 0

## Build

To build an executable run:

```bash
odin build .
```

To execute a program you must pass a binary with RAM, containing program and other relevant values. For example (assuming urmom is in the same directory as executable):

```bash
./8bit-cpu-odin urmom.bin
```

## Encoding

Each opcode is one byte long. Suppose byte has this structure, where each letter is a bit: `AABBCCDD`. Then following tables describe different opcodes:

| AA | operation type |
| -- | -------------- |
| 00 | arithmetic     |
| 01 | move low       |
| 10 | move high      |
| 11 | misc           |

### Arithmetic

For an arithmetic operation, CC and DD encode a pair of registers and BB specifies operation (`CC op DD`):

| BB | operation |
| -- | --------- |
| 00 | add       |
| 01 | sub       |
| 10 | mul       |
| 11 | div       |

`add` sets ZF and OF flags. `sub` sets ZF, OF and GR flags. `mul` sets ZF and OF flags. `div` sets ZF flag

### Move

Move operations encode register in BB and CCDD specifies actual bits. `move low` moves in least significant bits and `move low` moves in most significant bits in order from most to least significant bits

### Misc

Misc operation type encodes some more operation based on this table:

| BB | misc operation type |
| -- | ------------------- |
| 00 | jmp                 |
| 01 | cmp                 |
| 10 | load                |
| 11 | store               |

`load` and `store` interact with memory and exchange values of register encoded by DD with memory cell addressed with content of register specified by CC bits.

`cmp` compares registers, specified by CC and DD bits and sets all flags

`jmp` encodes following jump variants with CC bits and jumps to address specified by DD register:

| CC | jump type     |
| -- | ------------- |
| 00 | unconditional |
| 01 | jump if GR    |
| 10 | jump if OF    |
| 11 | jump if ZF    |

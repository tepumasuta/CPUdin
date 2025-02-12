# CPUdin 😈

## Overview

An 8-bit minimalistic cpu implemented in [Odin](https://odin-lang.org/) programming language. It has 4 registers, the flag reister and the program counter registers and can address 256 bytes of memory. Following flags are supported: ZF (zero), OF (overflow), GR (greater). For instruction set see the Encoding section. All programs start with progam counter = 0

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

Move operations encode register in BB and CCDD specifies actual bits. `move low` moves in the least significant bits and `move low` moves in the most significant bits in order from most to least significant bits

### Misc

Misc operation type encodes some more operations based on this table:

| BB | misc operation type |
| -- | ------------------- |
| 00 | jmp                 |
| 01 | cmp                 |
| 10 | ldr                 |
| 11 | str                 |

`ldr` and `str` interact with memory and exchange values of register encoded by DD with memory cell addressed with content of register specified by CC bits

`cmp` compares registers, specified by CC and DD bits and sets all flags

`jmp` encodes following jump variants with CC bits and jumps to address specified by DD register:

| CC | jump type     |
| -- | ------------- |
| 00 | unconditional |
| 01 | jump if GR    |
| 10 | jump if OF    |
| 11 | jump if ZF    |

## REPL

`CPUdin` supports REPL. It has basic command for printing both CPU state and memory; and stepping the execution. If command can be distinguished uniqely from the beginning substring, it most of the time will be; in other cases the behaviour is unspecified. The previous command will be repeated if you simple hit enter

### Print

All examples:

```gdb
$> print
CPU { pc = 0 (0), Flags { OF = 0, ZF = 0, GR = 0 }, r1 = 0 (0), r2 = 0 (0), r3 = 0 (0), r4 = 0 (0) }
$> p pc
pc = a (10)
$> p fl
Flags { OF = 0, ZF = 0, GR = 0 }
$> p flags
Flags { OF = 1, ZF = 0, GR = 0 }
$> p r4
r4 = 35 (53)
$> p r1
r1 = 20 (32)
$> p mem
[41, 81, 52, 91, f2, f7, b, 40, 82, 5b, 90, d2, c4, 19, c1, 0, 0, 34, 35, 18, fd, 7f, 0, 0, a8, a2, a6, 2f, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, a8, a2, a6, 2f, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, a8, a2, a6, 2f, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, a8, a2, a6, 2f, 0, 0, 0, 0, 20, 0, 0, 0, 0, 0, 0, 0, f0, d7, 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, b1, 5f, 41, 0, 0, 0, 0, 0, e0, 92, a3, 18, fd, 7f, 0, 0, 29, 9c, a3, 18, fd, 7f, 0, 0, 3d, 9c, a3, 18, fd, 7f, 0, 0, 29, 9c, a3, 18, fd, 7f, 0, 0, 29, 9c, a3, 18, fd, 7f, 0, 0, b0, 3d, 41, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 29, 9c, a3, 18, fd, 7f, 0, 0, 29, 9c, a3, 18, fd, 7f, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0, 14, 0, 0, 0, 0, 0, 0, 0]
$> p memory 5
f7 (247)
```

### Quit

To quit simple type something that `quit` starts with, for example `q`

### Step

To step type something that `step` starts with, for example `s`

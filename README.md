This is a microcode implementation of MMIX, in slightly-off VHDL.

The following things have not been written:
Virtual address translation caches
Memory cache
The actual microcode

The microcode implementation is very Harvard-architecture.

There are 32 registers of eight bytes each, numbered 0 to 31.
These can also be considered as 64 tregisters of four bytes each,
numbered `000` to `077` (in octal),
128 wregisters of two bytes each, numbered `0x00` to `0x7F`,
or 256 bregisters of one byte each, numbered `0x00` to `0xFF`.

We name the registers `uN`, the tregisters `tO`,
the wregisters `wX`, and the bregisters `bX`, with `X` in hexadecimal,
`O` in octal, and `N` in decimal.

There are 128 one-bit input flags (`iX`), set by hardware outside the CPU core,
and 256 one-bit output flags (`oX`), assertable by the CPU core.
Both are numbered in hexadecimal.

Instructions are 19 bits long; the opcode is the first three bits,
followed by a one-byte `X` field and a one-byte `Y` field.
There is an implicit increment of `uP` (the microcode pointer)
after every instruction.
(`uS` stands for the microcode stack;
`uPS` stands for the microcode stack including `uP`.)
Instructions are:

| Abbreviation | Opcode | `X`         | `Y`          | Meaning                  |
|--------------|--------|-------------|--------------|--------------------------|
| `MVB bA bB`  | 0      | `A`         | `B`          | `bA <= bB`               |
| `MVW wA wB`  | 1      | `2A`        | `2B`         | `wA <= wB`               |
| `MVT tA tB`  | 2      | `4A`        | `4B`         | `tA <= tB`               |
| `MVO uA uB`  | 3      | `8A`        | `8B`         | `uA <= uB`               |
| `SET bA V`   | 4      | `A`         | `V`          | `bA <= V`                |
| `BIF N iA`   | 5      | `N`         | `A`          | `uP <= uP + (iA? N : 0)` |
| `BUN N iA`   | 5      | `N`         | `A + 0x80`   | `uP <= uP + (iA? 0 : N)` |
| `AST oA`     | 5      | `0x80`      | `A`          | `oA <= true`             |
| `PGO L`      | 6      | `(L-1)/256` | `(L-1)%256`  | `push(uPS, L-1)`         |
| `POP`        | 7      | `0x00`      | `0x00`       | `pop(uPS)`               |
| `PST`        | 7      | `0x80`      | `0x00`       | `pop(uS)`                |
| `CJP wN`     | 7      | `0x04`      | `2N`         | `uP <= wN`               |
| `CLW wN`     | 7      | `0x01`      | `2N`         | `wN <= 0`                |
| `CLT tN`     | 7      | `0x02`      | `4N`         | `tN <= 0`                |
| `CLO oN`     | 7      | `0x03`      | `8N`         | `uN <= 0`                |

There is no `CLB bN` instruction, as it would be equivalent to `SET bN 0x00`.
For branches, `N` is represented in two's complement and may not be 0.
All output flags are false unless the current instruction is an `AST`.

There are also plenty of special registers
(in other words, registers with special meanings):

| Name    | Synonym | Usage                                                                                                                                                                                      | Is read-only? |
|---------|---------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| `ALUEF` | `b60`   | Forces on ALU exceptions.                                                                                                                                                                  |               |
| `ALUEP` | `b61`   | Gives the location of the highest-priority ALU exception in bits 1-3; bit 0 is on when bits 1-3 are off.                                                                                   | √             |
| `ALUS`  | `b00`   | Selects the ALU operation. Put in any MMIX opcode referring to an arithmetic operation (`FCMP` to `SRUI`, `LDSF`, `STSF`, `OR` to `MXORI`), the ALU performs it.                           |               |
| `ALUX`  | `u3`    | Output of ALU                                                                                                                                                                              | √             |
| `ALUY`  | `u1`    | Input 'Y' of ALU                                                                                                                                                                           |               |
| `ALUZ`  | `u2`    | Input 'Z' of ALU                                                                                                                                                                           |               |
| `B210A` | `w28`   | Bits 14-23 of `B210W`, in positions 3-12 (other bits are 0).                                                                                                                               | √             |
| `B210B` | `w29`   | Bits 24-33 of `B210W`, in positions 3-12 (other bits are 0).                                                                                                                               | √             |
| `B210C` | `w2A`   | Bits 34-43 of `B210W`, in positions 3-12 (other bits are 0).                                                                                                                               | √             |
| `B210D` | `w2B`   | Bits 44-53 of `B210W`, in positions 3-12 (other bits are 0).                                                                                                                               | √             |
| `B210E` | `w2C`   | Bits 54-63 of `B210W`, in positions 3-12 (other bits are 0).                                                                                                                               | √             |
| `B210W` | `u9`    | Except for the top byte (which is `GRS`), this is the base-1024 handler. Insert 'ABCDE' into here, pull it out of `B210A` to `B210E`.                                                      |               |
| `CND`   | `bFF`   | Bit-test register. Set a byte here, its bits are `CND0` to `CND7`.                                                                                                                         |               |
| `GDR`   | `u5`    | General-purpose register data. If `GRS<rL`, equivalent to `l[α+GRS]`; if `GRS≥rG`, equivalent to `g[GRS]` (see MMIXware on the register stack); otherwise read-only and gives 0 when read. |               |
| `GRS`   | `b48`   | General-purpose register selector.                                                                                                                                                         |               |
| `INS`   | `t1`    | The instruction we are currently executing. Should not be modified by instruction code unless we are doing a `RESUME`.                                                                     |               |
| `IP`    | `u14`   | MMIX instruction pointer.                                                                                                                                                                  |               |
| `Ly`    | `u18`   | Equivalent to l[γ] (see MMIXware on the register stack).                                                                                                                                   |               |
| `MAR`   | `u7`    | Memory access register.                                                                                                                                                                    |               |
| `MDR`   | `u6`    | Memory data register.                                                                                                                                                                      |               |
| `prQ`   | `u30`   | The value of `rQ` when it was last read.                                                                                                                                                   |               |
| `PTN`   | `w23`   | Bits 3-12 of `PTW`, in positions 3-12 (other positions are blank).                                                                                                                         | √             |
| `PTW`   | `w22`   | Page table handler. Bits 13-15 are placed in iflags.                                                                                                                                       |               |
| `rG`    | `b2`    | MMIX's `rG`.                                                                                                                                                                               |               |
| `rL`    | `b3`    | MMIX's `rL`.                                                                                                                                                                               |               |
| `rO`    | `u15`   | MMIX's `rO`.                                                                                                                                                                               |               |
| `rS`    | `u16`   | MMIX's `rS`.                                                                                                                                                                               |               |
| `rU`    | `u17`   | MMIX's `rU`.                                                                                                                                                                               |               |
| `rX`    | `u26`   | What should be stored in `rX` if we trip?                                                                                                                                                  |               |
| `rY`    | `u27`   | What should be stored in `rY` if we trip?                                                                                                                                                  |               |
| `rZ`    | `u28`   | What should be stored in `rZ` if we trip?                                                                                                                                                  |               |
| `SDR`   | `u4`    | Hardwired to special register `SRS%32`.                                                                                                                                                    |               |
| `SRS`   | `b1`    | Special register selector.                                                                                                                                                                 |               |
| `TCKR`  | `u13`   | Holds the translation cache key.                                                                                                                                                           |               |
| `TCVR`  | `u12`   | Holds the translation cache value. Note that the high byte of this is `ALUEF` (and the next two are `ALUEP` and `Vs`), so be careful!                                                      |               |
| `Um`    | `b89`   | The MMIX usage mask, the second byte of `rU`.                                                                                                                                              |               |
| `Up`    | `b88`   | The MMIX usage pattern, the first byte of `rU`.                                                                                                                                            |               |
| `Vb1`   | `b40`   | The `b1` field of `rV`. See MMIXware under 'virtual address translation'.                                                                                                                  | √             |
| `Vb2`   | `b41`   | The `b2` field of `rV`. See MMIXware under 'virtual address translation'.                                                                                                                  | √             |
| `Vb3`   | `b42`   | The `b3` field of `rV`. See MMIXware under 'virtual address translation'.                                                                                                                  | √             |
| `Vb4`   | `b43`   | The `b4` field of `rV`. See MMIXware under 'virtual address translation'.                                                                                                                  | √             |
| `Vnf`   | `w2D`   | The `n` (address space number) and `f` (function) fields of `rV`. See MMIXware under 'virtual address translation'.                                                                        | √             |
| `Vr`    | `t27`   | The `r` (root) field of `rV`. See MMIXware under 'virtual address translation'.                                                                                                            | √             |
| `Vs`    | `b62`   | The `s` (page size) field of `rV`. See MMIXware under 'virtual address translation'.                                                                                                       | √             |

A register may be divided up into two, four, or eight pieces of equal size,
so long as they are all at least one byte long.
These pieces are referred to with the suffixes `.h` and `.l` for two,
`.h`, `.mh`, `.ml`, and `.l` for four,
and `.[0-7]` for eight (in numerical order); size is inferred from instruction.

Attempts to write a read-only register simply fail.
Attempts to write read-only and read-write registers simultaneously
succeed at writing read-write registers.

MMIX special-register abbreviations and opcode abbreviations are treated as
their MMIX numerical equivalents in the `V` field of `SET`.

The flags are as follows:

| Name       | Synonym | Usage                                                                                                                                                              |
|------------|---------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ALUER`    | `i03`   | Any errors in the ALU?                                                                                                                                             |
| `ALUN`     | `i02`   | Is `ALUY` negative?                                                                                                                                                |
| `ALUNZ`    | `i01`   | Is `ALUY` nonzero?                                                                                                                                                 |
| `ALUOD`    | `i00`   | Is `ALUY` odd?                                                                                                                                                     |
| `CACCDBK`  | `o0A`   | The data-cache block containing `MAR` should be the next to be replaced.                                                                                           |
| `CACCLNBT` | `o13`   | Data-cache blocks containing any addresses between `MDR` and `MAR` should be written to core if dirty.                                                             |
| `CACCLND`  | `o10`   | Write all dirty blocks in the data cache to core.                                                                                                                  |
| `CACCLRBT` | `o21`   | Data-cache blocks containing any addresses between `MDR` and `MAR` should be deleted.                                                                              |
| `CACCLRI`  | `o15`   | Instruction-cache blocks containing any addresses between `MDR` and `MAR` should be deleted.                                                                       |
| `CACDELBA` | `o14`   | Data-cache blocks containing any addresses between `MDR` and `MAR` should be written to core if dirty and deleted.                                                 |
| `CACDELBT` | `o0D`   | Data-cache blocks containing only addresses between `MDR` and `MAR` should be written to core if dirty and deleted.                                                |
| `CACDELD`  | `o12`   | Delete the data cache.                                                                                                                                             |
| `CACDELI`  | `o16`   | Delete the instruction cache.                                                                                                                                      |
| `CACPLDD`  | `o0B`   | Preload data-cache blocks containing any addresses between `MDR` and `MAR`.                                                                                        |
| `CACPLDI`  | `o0C`   | Preload instruction-cache blocks containing any addresses between `MDR` and `MAR`.                                                                                 |
| `CNDi`     | `i1i`   | The ith bit of `CND`.                                                                                                                                              |
| `DYTRP`    | `i05`   | The dynamic trap bit. On if any bits of `rQ&rK` are.                                                                                                               |
| `FALS`     | `i0D`   | Always false.                                                                                                                                                      |
| `MEMLOCK`  | `o0E`   | Lock the memory location in `MAR` and bypass the cache until further notice.                                                                                       |
| `MEMNF`    | `i0C`   | Is the cache busy in such a way that it is uninterruptable? (This condition cannot be caused by instructions to delete some portion of a cache, or by preloading.) |
| `MEMRDD`   | `o08`   | Read data from memory (`MDR <= m8[MAR]`).                                                                                                                          |
| `MEMRDI`   | `o09`   | Read instruction from memory (`MDR <= m4[MAR]`).                                                                                                                   |
| `MEMUNLK`  | `o0F`   | Further notice.                                                                                                                                                    |
| `MEMWRB`   | `o25`   | Write data to memory (`m1[MAR] <= MDR`).                                                                                                                           |
| `MEMWRO`   | `o22`   | Write data to memory (`m8[MAR] <= MDR`).                                                                                                                           |
| `MEMWRT`   | `o23`   | Write data to memory (`m4[MAR] <= MDR`).                                                                                                                           |
| `MEMWRW`   | `o24`   | Write data to memory (`m2[MAR] <= MDR`).                                                                                                                           |
| `PTPR`     | `i08`   | Bit 13 of `PTW`: Is reading from this page allowed?                                                                                                                |
| `PTPW`     | `i09`   | Bit 14 of `PTW`: Is writing to this page allowed?                                                                                                                  |
| `PTPX`     | `i0A`   | Bit 15 of `PTW`: Is executing this page allowed?                                                                                                                   |
| `REMNF`    | `i04`   | The floating-point remainder operation is unfinished.                                                                                                              |
| `RKAC`     | `i0B`   | Are all the program bits of `rK` on?                                                                                                                               |
| `rQb`      | `o1D`   | Break bit of `rK`.                                                                                                                                                 |
| `rKk`      | `i1C`   | Kernel bit of `rK`.                                                                                                                                                |
| `rKn`      | `i1B`   | Negative bit of `rK`.                                                                                                                                              |
| `rKp`      | `i1F`   | Privilege bit of `rK`.                                                                                                                                             |
| `rKr`      | `i18`   | Read bit of `rK`.                                                                                                                                                  |
| `rKs`      | `i1E`   | Security bit of `rK`.                                                                                                                                              |
| `rKw`      | `i19`   | Write bit of `rK`.                                                                                                                                                 |
| `rKx`      | `i1A`   | Execute bit of `rK`.                                                                                                                                               |
| `rQb`      | `o05`   | Break bit of `rQ`. Set if emulated instruction is illegal even at a negative address.                                                                              |
| `rQk`      | `o04`   | Kernel bit of `rQ`. Set if emulated instruction is legal only at a negative address.                                                                               |
| `rQn`      | `o03`   | Negative bit of `rQ`. Set if emulated instruction tried to refer to a negative virtual address in any way except by having the next address be negative.           |
| `rQp`      | `o07`   | Privilege bit of `rQ`. Set if emulated instruction was in a negative virtual address.                                                                              |
| `rQr`      | `o00`   | Read bit of `rQ`. Set if emulated load tried to read from a page without read permission.                                                                          |
| `rQs`      | `o06`   | Security bit of `rQ` and `rK`. Set if emulated instruction tried to run with any program bits of `rK` off from a positive virtual address.                         |
| `rQw`      | `o01`   | Write bit of `rQ`. Set if emulated store tried to write to a page without write permission.                                                                        |
| `rQx`      | `o02`   | Execute bit of `rQ`. Set if emulated instruction was in a page without execute permission.                                                                         |
| `SETA`     | `o20`   | Set `rA` according to the arithmetic operation.                                                                                                                    |
| `SETH`     | `o1F`   | Set `rH` to the high half of an unsigned multiplication.                                                                                                           |
| `SETR`     | `o1E`   | Set `rR` to the remainder of a division.                                                                                                                           |
| `SLP`      | `o11`   | Go to sleep. Go directly to sleep. Do not pass Go.                                                                                                                 |
| `TCDEL`    | `o1D`   | Delete the contents of the translation caches.                                                                                                                     |
| `TCDKK`    | `i07`   | Does the data translation cache contain the key in `TCKR`?                                                                                                         |
| `TCDR`     | `o1A`   | `TCVR <= DTC[TCKR]`.                                                                                                                                               |
| `TCDW`     | `o1B`   | `DTC[TCKR] <= TCVR`                                                                                                                                                |
| `TCDWP`    | `o1C`   | Set the last three bits of `DTC[TCKR]` (if that exists) to those of `TCKR`. If they are now 0, delete `TCKR` from the data translation cache.                      |
| `TCIKK`    | `i06`   | Does the instruction translation cache contain the key in `TCKR`?                                                                                                  |
| `TCIR`     | `o17`   | `TCVR <= ITC[TCKR]`.                                                                                                                                               |
| `TCIW`     | `o18`   | `ITC[TCKR] <= TCVR`                                                                                                                                                |
| `TCIWP`    | `o19`   | Set the last three bits of `ITC[TCKR]` (if that exists) to those of `TCKR`. If they are now 0, delete `TCKR` from the instruction translation cache.               |

One thing that isn't covered in `cpu.vhdl` is where execution should start.
There should be a `PGO` to execute fetch/decode in microcode address 0,
and microcode for MMIX opcode n should start in location 256n+1.

When the execution of an emulated instruction finishes,
it should leave the result (the octabyte to store in `$X`) in `RES`
and jump to the xstore-and-finish routine.
If it is an instruction with no result, or with a complicated result
that should be handled in some other way, it should instead handle its result
and jump to the finish-execution routine.
The address of the next instruction should be left in `u14`.
(The address of the current instruction plus 4 will be found there
when execution starts after fetch/decode.)
There is (or will be) a 'check-for-trips-and-traps' routine,
and when calling it, store sensible values for MMIX's `rX`, `rY`, and `rZ` in
`u26`-`u28`. `rW` will be read from `IP`.
It is permissible to require that `u26` starts out at 0 when executing
an instruction normally.

`u30` is reserved for the contents of `rQ` at the time it was last read.
(Attempting to set `rQ` to `x` sets it instead to `x|rQ&~prQ`,
according to the documentation.
To do this takes five microinstructions
(`MVO ALUZ prQ; SET ALUS ANDN; SET SRS rQ` to set up,
then `MVO ALUY SDR; MVO ALUZ ALUX; SET ALUS OR; MVO ALUY x; MVO SDR ALUX`
to complete),
so interrupts might be ignored by accident if they stay on for fewer than
five clock cycles, unless they are generated by microinstructions.)

This leaves seven registers that are entirely general-purpose,
as well as `t76`, `w7E` and `bFE`. `u26` to `u28` are almost general-purpose,
as the microarchitecture has no interrupts,
and `b63`, `bFF`, `w00`, `w22`, `t77`, `u1`, `u2`, `u6`, `u7`, `u9`, and `u13`
can be used as temporary storage,
as long as they are reset to proper values before their effects are used.
`t01` should be treated as inviolate
during execution of an instruction.

Stack overflow causes discard of overflowed addresses
and an OS trap if too many pops are attempted
(this is because `TRAP` has opcode 0).

# Monoid Forth

A simple and easy-to-understand UEFI-based operating system and Forth playground in a weekend.

<p align="center"><i>"The meaning function is a homomorphism from a syntactic monoid to a semantic monoid."</i></p>

<p align="center"><i>"The concatenation of two programs denotes the composition of the functions denoted by the two programs."</i></p>

The interpreter and the REPL is written in Forth itself, and kept as pure data using the `dq` macros. For maximum portability, only the most primitive building blocks need to be ported since the main interpreter is essentially written in Forth itself.

The interpreter is executed by a standard

```asm
lodsq
jmp qword [rax]
```

loop, with the `next` macro as the trampolining code between functions. The code focuses on simplicity rather than efficiency, but it's still pretty performant since there is little to no overhead in code execution.

The dictionary is organized as a simple linear structure with $O(n)$ lookup.

## Quick setup

Simply clone this repository and run

```./build.sh```

to compile and execute `qemu`, with the compiled image saved in `out/`.

## Files description

- `kernel.asm`: self-contained kernel; half x86_64 assembly, half Forth data.
- `uefi.asm`: well encapsulated UEFI procedures.
- `uefi_structs.asm`: types, flags, and definitions for UEFI data structures.
- `OVMF.fd`: [UEFI image for QEMU](https://wiki.ubuntu.com/UEFI/OVMF).

## Prerequisites

- `fasm`
- `QEMU`

## Further reading

- [UEFI 2.6 specification](https://uefi.org/sites/default/files/resources/UEFI%20Spec%202_6.pdf)
- [Miniforth](https://compilercrim.es/bootstrap/miniforth/)
- [BootOS](https://github.com/nanochess/bootOS)
- [Jonasforth](https://github.com/c2d7fa/jonasforth/)

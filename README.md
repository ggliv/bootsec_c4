# bootsec_c4
![demo of connect four gameplay](https://raw.githubusercontent.com/ggliv/bootsec_c4/main/demo.gif)

Connect Four written in x86 real mode assembly, made to fit into a 512-byte BIOS boot sector.

## Build + Run
Requires [NASM](https://en.wikipedia.org/wiki/Netwide_Assembler) to build and an x86 emulator like [qemu](https://en.wikipedia.org/wiki/QEMU) to run.
```bash
# build
git clone https://github.com/ggliv/bootsec_c4
cd bootsec_c4
make
# run, for qemu
qemu-system-i386 -fda connect_four.bin
```

## Controls
Use the left and right arrows to select a column and space to drop a token. Colors alternate between player one (red) and player two (yellow). Press [Esc] to reset the board.

## TODO
- Win detection
- Computer opponent (minimax+alpha/beta pruning?)

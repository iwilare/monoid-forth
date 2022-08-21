#!/bin/sh
mkdir -p out/
rm -rf out/*
fasm kernel.asm out/E &&
qemu-system-x86_64 -bios OVMF.fd -net none -drive format=raw,file=fat:rw:./out

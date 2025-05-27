@echo off
REM --- Assemble bootloader and kernel ---
nasm -f bin bootload_2.asm -o boot.bin
nasm -f bin kernel_2.0.asm -o kernel.bin

REM --- Combine bootloader and kernel ---
copy /b boot.bin + kernel.bin final_version.bin

REM --- Run with QEMU ---
REM qemu-system-i386 -fda final_version.bin
qemu-system-i386 -fda final_version.bin -display gtk,zoom-to-fit=on 

pause
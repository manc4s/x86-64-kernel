@echo off
REM --- Assemble bootloader and kernel ---
nasm -f bin bootload_protectedmode.asm -o boot2.bin
nasm -f bin kernel_4.0.asm -o kernel2.bin

REM --- Combine bootloader and kernel ---
copy /b boot2.bin + kernel2.bin final_version2.bin

REM --- Run with QEMU ---
REM qemu-system-i386 -fda final_version.bin
qemu-system-i386 -fda final_version2.bin -display gtk,zoom-to-fit=on 

pause
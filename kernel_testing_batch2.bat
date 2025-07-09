@echo off
REM --- Assemble bootloader and kernel ---
nasm -f bin bootload_protectedmode.asm -o boot2.bin
nasm -f bin kernel_4.0.asm -o kernel2.bin

REM --- Combine bootloader and kernel ---
::copy /b boot2.bin + kernel2.bin final_version2.bin
::copy /b boot2.bin + kernel2.bin final_version2.img

fsutil file createnew pad.tmp 65536
copy /b kernel2.bin+pad.tmp padded_kernel2.bin
del pad.tmp
copy /b boot2.bin+padded_kernel2.bin final_version2.img



REM --- Run with QEMU ---
REM qemu-system-i386 -fda final_version.bin
::qemu-system-i386 -fda final_version2.img -display gtk,zoom-to-fit=on 

qemu-system-i386 -hda final_version2.img 
pause


REM --- qemu-system-i386 -hda final_version2.bin -boot order=c -display gtk,zoom-to-fit=on ---




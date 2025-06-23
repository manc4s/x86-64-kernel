## x86-64-kernel

---
This is where my code is for the kernel and bootloader.
+ bash script (kernel_testing_batch2.bat) to run and concatenate the binaries together and run the code in QEMU emulator with NASM assembler to turn x86 assembly code to binaries.<br>
<br>

---
Current implementation in protected mode x86. 
---

---

*Bootloader behaviour*<br>
Bootloader, outputs Booting…(only shows if there’s an error in the kernel and jump doesn’t occur), then creates gdt, enables a20, disables interrupts and jumps to 0x10000 or 0x08 in the gdt for the code segment (gdt sectors defined below.) <br>

---

*Current CLI(command line interface) features,(protected mode) after bootloader runs and then far jumping to 0x10000/0x08 in gdt*<br>
&nbsp;&nbsp;-protected mode 32 bit, 1mb of space currently playing with, but up to 4GB available in protected mode. <br>
&nbsp;&nbsp;-4x6 custom glyphs<br>
&nbsp;&nbsp;-13-hour mode<br>
&nbsp;&nbsp;-2112 chars per page.<br>
&nbsp;&nbsp;-accepts input into input buffer, with cursor to edit input before entering.<br>
&nbsp;&nbsp;-keywords for commands<br>

---

*Current working keywords:*<br>
new_file() <br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;- if entered input buffer = new_file() opens up a empty file with no shell printing, no input buffer, just 2112 bytes to edit, however. Currently limited on 2112 bytes, will not &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;take more input.<br>
						



---



**demonstration of working input buffer June 17th 2025**<br>



https://github.com/user-attachments/assets/6167dc8e-5e9f-4bb4-b218-16c2c86f79e0




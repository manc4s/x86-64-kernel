## x86-64-kernel

---
This is where my code is for the kernel and bootloader.<br>
+ bash script (kernel_testing_batch.bat) to run and concatenate the binaries together and run the code in QEMU emulator with NASM assembler to turn x86 assembly code to binaries.<br>
---
Current implementation in real mode x86. Planning on adding switch to protected mode keyword now that input buffer works for any kind of input and wont cause errors.<br>

---

**I developped my bootloader in another repository. On boot it looks for a quick input y or n to continue onto the far jump.** <br>

***Current CLI(command line interface) features,(real mode) after bootloader runs and then far jumping to 0x10000*** <br>
&nbsp;&nbsp;- 4x6 custom glyphs<br>
&nbsp;&nbsp;- 13 hour mode<br>
&nbsp;&nbsp;- 2112 chars per page.<br>
&nbsp;&nbsp;- accepts input into input buffer, with cursor to edit input before entering.<br>




**demonstration of working input buffer June 17th 2025, full video in repository as June17-2025 - demonstration-working_input_buffer.mp4**<br>
https://github.com/user-attachments/assets/8a1ebe96-592c-4319-b0a0-e1f4ce9744db


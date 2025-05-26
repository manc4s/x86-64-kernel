# x86-64-kernel
This is where my code is for the kernel and bootloader, + bash script to run and concatenate the binaries together quickly and run.<br>
<br>
This kernel will be developped in real mode because of the ascii interupts rather than using the<br> 
scancode, but even if i do swap to the scan codes then i will change the display resolutinon. Currently<br>
no protected mode so no segmentation, no gdt. Once i eventually get a working shell I will<br>
swap to protected mode and look into VBE for higher resolution, because VGA 640x480x16 has less<br>
colors with 4 planes, and is a big pain to get working. I'd prefer to continue with the real <br>
mode (0xA0000 - 0xAFFFF) video memory for 13 h mode where its one byte per pixel for 256 colors <br>
rather than messing with the planes, while messing with the gdt, while trying to figure out 32 bit<br>
mode completely.<br>
<br>
**Thus for now the project will resume in real mode.**<br>
<br>
**I developped my bootloader in another repository.** <br>
&nbsp;&nbsp;-4x6 custom glyphs<br>
&nbsp;&nbsp;-13 hour mode<br>
&nbsp;&nbsp;-2112 chars per page.<br>

**next steps:**<br>
&nbsp;&nbsp;-shell<br>
&nbsp;&nbsp;-input<br>
&nbsp;&nbsp;-input buffer<br>
&nbsp;&nbsp;-parser<br>
&nbsp;&nbsp;-some kind of commands<br>
    

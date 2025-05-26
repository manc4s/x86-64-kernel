# x86-64-kernel
This is where my code is for the kernel and bootloader, + bash script to run and concatenate the binaries together quickly and run.<br>
<br>
This kernel will be developped in real mode because<br> 
of the ascii interupts rather than using the<br> 
scancode, but even if i do swap to the scan codes<br>
then i will change the display resolutinon.<br>
Currently no protected mode so no segmentation, no gdt<br>
, once i eventually get a working shell I will swap to<br>
protected mode and look into VBE for higher resolution<br>
because VGA 640x480x16 has less colors with 4 planes, and<br>
is a big pain to get working, i'd prefer to continue with<br>
the real mode 0xA0000 - 0xAFFFF video memory for 13 h<br> 
mode simply with one byte per pixel for 256 colors than<br> 
messing with the planes, while messing with the gdt,<br>
while trying to figure out 32 bit mode completely.<br>
<br>
So for now the project will resume in real mode.<br>
<br>
I developped my bootloader in another repository. <br>
&nbsp;&nbsp;-4x6 custom glyphs<br>
&nbsp;&nbsp;-13 hour mode<br>
&nbsp;&nbsp;-2112 chars per page.<br>

next steps:<br>
&nbsp;&nbsp;-shell<br>
&nbsp;&nbsp;-input<br>
&nbsp;&nbsp;-input buffer<br>
&nbsp;&nbsp;-parser<br>
&nbsp;&nbsp;-some kind of commands<br>
    

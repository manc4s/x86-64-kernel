BITS 16

    ORG 0x7C00



;Take one input y/n for now
;Change the Bg to white
;Show some print output using 0x03 memory
;Use my delay to have it type out slower with a cool effect
;



;Beginning of code, set variables to 0, set vga text mode
;set white background and jump to main
start:
    
    mov ax, 0x03  ;
    int 0x10      ; vga text mode set with interupt ax = 0x03 mode.
                    ;0xB8000  vga text mode color memory 8 pages for 32768 bytes
                    ;4000 bytes per page
                    ;2000 characters
                    ; each character 2 bytes, ascii(lower byte), attribute(higher byte)


    


    mov ax, 0xB800  ;0xb800 * 0x10 = 0xB8000
    mov es, ax                                  ;vga text mode address stored in es





    mov ax, 0
    mov bx, 0
    mov word [0x0600], 0 ; row
    mov word [0x0602], 0 ; col

   
    call white_background
    jmp main



;loop through all the 2000 char starting at 0xB8000 and enterting a white red on white text spaces to make the illusion of white background
white_background:
    push ax
    push bx
    push dx
    push cx
    mov di, 0
    mov cx, 2000           ; 80 * 25 repeat the loop 2000 times, loop looks at cx register


    mov ah, 0x44  ;0x44           ; attribute: white bg, black text White bg
    mov al, 0x20           ; ASCII space     , spaces

       
.fill:
    mov [es:di], ax
    add di, 2
    loop .fill


    pop cx
    pop dx
    pop bx
    pop ax
    ret



;output the message at memory location di, which is mapped to one of messages 1-4 after comp1 call.
print_message:
    mov dx, 0x4F00           ; attribute (color)
    mov cx, [0x0600]         ; row
    imul cx, 160             ; cx = row * 160


    mov word [0x0602], 0

    xor bx, bx               ; character index = 0

.print_char:    
    mov dl, [di + bx]        ; get next character
    cmp dl, 0                ; null terminator?
    je .done

    mov si, bx
    shl si, 1                ; si = bx * 2 (column * 2)
    add si, cx               ; si = row*160 + col*2

    mov word [es:si], dx     ; write char+attr at [es:si]
    inc bx                   ; next character in string
    inc word [0x0602]     ;inc column count

    
    ;call big_delay   if u want delay feature or not for bootloader
    jmp .print_char
    
.done:
    ret










;main code for BOOTLOADER
main:

    mov di, message
    call print_message


    
    ; 13 hour mode, 
    mov ax, 0x13
    int 0x10


    
    ;a20 line
    
    in al, 0x92       ; read port 0x92
    or al, 2          ; set bit 1 (A20 gate enable)
    out 0x92, al      ; write back to port 0x92



    
     ; Load kernel (1 sector = 512 bytes) to 0x1000:0000 (physical 0x10000)
    mov ax, 0x1000
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, 128
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc disk_error


    lgdt [gdt_descriptor] ; load the gdt
    cli ;interupts






    ;pe bit
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax



    jmp 0x08:start_protected_mode ; selector (index 1 * 8), offset 0
 



disk_error:
    mov di, disk_fail_msg
    call print_message
    jmp end


end:

.hang:
    jmp .hang




disk_fail_msg: db "DISK READ ERROR", 0

BOOT_DRIVE: db 0


message:
    db "Booting...", 0 











gdt_start:
    ; Entry 0: Null descriptor
    dq 0
    


    ;flat memory mode so code segment and data segment are both 1mb from 0x0 addresss.


    ;entry 1 code segment
    ;base address of code sector 0x00000 to 0xFFFFF
    ;1048575 byte code space. 1mb
    ; Code Segment (Selector 0x08)
    dw 0x1111           ; Limit low 
    dw 0x0000            ; Base low
    db 0x00              ; Base mid
    db 10011010b         ; Access
    db 01001111b         ; Flags
    db 0x00              ; Base high

    ;0x10
    ; Entry 2: Data Segment 0x00000 to 0xfffff
    ;1mb space
    dw 0x1111            ; Limit low
    dw 0x0000            ; Base low
    db 0x00              ; Base mid
    db 10010010b         ; Acces
    db 01001111b         ; Flags
    db 0x00              ; Base high

    ;0x18
    ;stack
    ;one 4096 byte area at 0x100000
    dw 0x1000       ; Limit low (4095 bytes)
    dw 0x0000       ; Base low
    db 0x10         ; Base mid 
    db 10010010b    ; Access:
    db 01000000b    ; Flags
    db 0x00         ; Base high

    ;;0x20
    ;;defninf the video memory to write to.
    dw 0xFFFF           ; Limit (64KB)
    dw 0x0000           ; Base low (VGA memory at 0xA0000)
    db 0x0A             ; Base middle
    db 10010010b        ; Access: Present, Ring 0, Data, Writable
    db 01001111b        ; Flags: 4KB granularity
    db 0x00             ; Base high


    ;;0x28
    ;;from 0xCFFFF to 0xFFFFF space for pages of size 2112 (2304 until finding out why)
    dw 0xFFFF           ; Limit 
    dw 0xFFFF           ; Base low 
    db 0x0C             ; Base middle
    db 10010010b        ; Access:
    db 01001111b        ; Flags: 
    db 0x00             ; Base high
  
gdt_end:


gdt_descriptor:
    dw gdt_end - gdt_start - 1     ; Size
    dd gdt_start                   ; Address







[bits 32]
start_protected_mode:
    
    ; Set up segments
    mov ax, 0x10        ; Data segment selector
    mov ds, ax
    mov es, ax
    mov gs, ax
    mov fs, ax


    mov ax, 0x18
    mov ss, ax
    mov ebp, 0xB0FFF
    mov esp, ebp    ; Top of your stack segment
    
    ; Test - write something to video memory



    jmp 0x08:0x10000




times 510 - ($ - $$) db 0
dw 0xAA55







    



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
    mov word [0x0601], 0 ; cursor
   
    mov byte [0x0900], 0   ;first input char n - 0x0E y-0x79
    mov byte [0x0901], 0   ; enter input char 0x0D
   
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


    mov ah, 0x8E           ; attribute: white bg, black text White bg
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











;calling comp1 will check what ax is, depending on ax input match di to the correct message
comp1:
    cmp ax, 0
    jne comp2
    mov di, message_1
    ret

comp2:
    cmp ax, 1
    jne comp3
    mov di, message_2
    ret

comp3:
    cmp ax, 2
    jne comp4
    mov di, message_3
    
    ret

comp4:
    cmp ax, 3
    jne main
    mov di, message_4   
    ret









;output the message at memory location di, which is mapped to one of messages 1-4 after comp1 call.
print_message:
    mov dx, 0x8E00           ; attribute (color)
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










;increment the row being tracked in memory loc [0x0600]
increment_row:
    inc word [0x0600]
    ret











;increment the cursor by updating the row and column to be where the end of the last line of text is.
inc_cursor:
    push ax

    mov ah, 0x02        ; BIOS set cursor position
    ;parameters below
    mov bh, 0x00        ; Page number (usually 0)
    mov dl, [0x0602]        ;col 0-79
    mov dh, [0x0600]         ; Row (0–24)
    
    
    int 0x10   ;set cursor
    
    pop ax

    ret







;Takes two inputs, the first is a y or n, the second is an enter. 
;No other inputs will be accepted.
two_input:
    ;   Enter: 0x0D (Carriage Return, CR)
    ;   y': 0x79
    ;   'n': 0x6E
    push ax
    
    mov ah, 0 
    int 0x16

    mov byte [0x0900], al  ;move first input into 0x0900


    cmp byte [0x0900], 0x79 ;check if yes
    je .next

    cmp byte [0x0900], 0x6E ;check if no
    je .next
    jmp two_input


;print the character selected y or n
.next:  
    mov ah, 0x0e  ;print first char
    int 0x10


;takes the second input, must be an enter. Nothing else will be accepted.
.second:

    mov ah, 0 
    int 0x16


    ;second char input
    mov byte [0x0901], al   


    ;check if second char input is an enter, enter ascii - 0x0D
    cmp byte [0x0901], 0x0D 
    jne .second



    pop ax
    ret


   







;After input set ax for corresponding ax output depending on if y or n ascii. 
set_ax:

    cmp byte [0x0900], 0x79 ; yes ; print message 4, ax = 3
                                    ; no print message 3 ax = 2
    
    je .booting
    jne .cancelling

.booting:
    mov ax, 3
    ret

.cancelling:
    mov ax, 2
    ret






;Delay that is million loop cycles for cool typing effect
big_delay:

    ;200 * 65535 = 13,107,000 loop cycle delay
    push bx
    push cx

    mov bx, 400       ; outer loop count (increase for longer delay)

.outer:
    mov cx, 0FFFFh    ; inner loop count (max for cx)
    ;decrement from 0xFFFF = 655535

.inner:
    loop .inner
    dec bx
    jnz .outer

    pop cx
    pop bx
    ret



;After input set ax for corresponding ax output depending on if y or n ascii. 
boot_or_end:

    cmp byte [0x0900], 0x79 ; yes ; print message 4, ax = 3
                                    ; no print message 3 ax = 2
    
    je .booting
    jne .cancelling

.booting:
    ret

.cancelling:
    jmp end







;main code for BOOTLOADER
main:

    ;set the message depending on ax is 0,1,2,3 for bootloader outputs
    call comp1   
    
    ;output the selected message
    call print_message

    
    ;increment ax, increment cursor, increment row
    call inc_cursor
    call increment_row
    inc ax


    ;after the second message, ax = 1, take an input y or no in main2, if not second message go back to top of main
    cmp ax, 1
    jg main2
    jle main


;second part of main
main2:

    call two_input
    
    ;checks if y or n
    call set_ax
    
    ;set the final message, print and increment row and cursor
    call comp1
    call print_message
    call inc_cursor
    call increment_row
    



    call boot_or_end
    call inc_cursor
    call increment_row


     ; Load kernel (1 sector = 512 bytes) to 0x1000:0000 (physical 0x10000)
    mov ax, 0x1000
    mov es, ax
    xor bx, bx
    mov ah, 0x02
    mov al, 4
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc disk_error

    jmp 0x1000:0x0000

    
 end:
    cli
    hlt
    jmp $


disk_error:
    hlt
    jmp disk_error

BOOT_DRIVE: db 0



message_1:
    db "Bootloader for my x86 64 practice and testing.",0
message_2:
    db "Would you like to boot the system (y/n)?",0
message_3:
    db "Booting cancelled.",0
message_4:
    db "Booting...", 0 






times 510 - ($ - $$) db 0
dw 0xAA55


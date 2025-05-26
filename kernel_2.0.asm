[BITS 16]
ORG 0x10000




start:
    ;initialize all pointers to 0x10000 to begin
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    mov ss, ax


    mov word [0x0600], 0 ; row
    

    mov ax, 0xB800
    mov es, ax                      ; 0xA000 stored in es


    jmp main















;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;String Output;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Output To the screen based on message at di.
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;







main:
    call clear
    mov di, entered
    call print_message
    jmp .hang



.hang:
    jmp .hang



clear:

    mov di, 0
    mov cx, 2000          ; 80 x 25 = 2000 characters

    mov ah, 0x07          ; attribute: light grey on black
    mov al, 0x20          ; ASCII space
    

.clear_loop:
    mov word [es:di], 0x8E20    ;attrobute 8E, yellow on dark gray, 0x20 space in ascii.
    add di, 2
    loop .clear_loop
    ret


entered: db "Entered Kernel", 0
[BITS 16]
ORG 0x10000

start:
    ;initialize the pointers
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; 13 hour mode, 
    mov ax, 0x13
    int 0x10
    
    ;track location where VRAM is for 13 hour mode
    mov ax, 0xA000
    mov es, ax


    ;draw the bg, so you can see the 320x200 screen in qemu, turns to selected bg_color
    call clear_screen

    
     
    jmp main






;clears the screen with selected color in al
clear_screen:
    mov di, 0                ; Start at offset 0 (row 0)
    mov cx, 320*200              ; 320 pixels in the first row
    mov al, [bg_color]    ;selected bg color in data, byte long        ; Color 00011100 (28),


.fill_row:
    mov [es:di], al
    inc di
    loop .fill_row
    ret







main:
    

    mov ax, 64  ;A ascii
    mov si, entered
    call print_string

    jmp end









print_string:
    ;string location in si when callling
    ;si must contain a memory location of string

    push ax
    push bx
    push cx
    mov bx, 0
    

.printloop:
    ;location of entered string at si + character offset
    mov al, [si + bx]
    cmp al, 0
    je .done


    call print_char

    inc bx
    call next_char
   
    jmp .printloop

.done:
    pop cx
    pop bx
    pop ax


    ret





print_char:
    push si
    push bx
    ;both these counters need to be reset before every glyph anyways, universal locations are kept track of in [x_offset], [y_offset], divided by 4,for actual character location out of 0-79 cols and 0-32 rows, for a toal of 2640 chars
    mov bx, 0
    mov di, 0 ; [x_offset] works great for printing char by offset as well
    

.rest_of_print_char:

    call plot_4by5

    inc bx          ;increment row of glyph
    add di, 320     ;next row, 320 pixel offset for di
    cmp bx, 6        ;loop 0-5
    jl .rest_of_print_char


    pop bx
    pop si
    ret


next_char:
    add word [x_offset], 5    ; should increment by 5
    ret

;take ascii, x, and y
;ascii - ax
;si is always reset in here
plot_4by5:
   
    push ax
    

    ;alphabet(location of all 4x6 glyphs)
    mov si, alphabet
    add si, bx  ;which glyph row
    imul ax, 6
    add si, ax
    sub si, 192
   
    ;After adding glyph row from prvious bx
    push bx
    mov al, [si]         ; AL = row byte, lower 4 bits are the pixels
    mov bx, 0            ; pixel index (0 to 3)

    

    push di
    add di, [x_offset]
.loop:
    ;If the glyph row find a 1, draw the text oen color, if its not, jump to bg color
    mov ah, al
    mov cl, 3
    sub cl, bl           ; cl = (3-bl): bit index for current pixel (left to right)
    shr ah, cl           ; move the target bit into the LSB
    and ah, 1


    jz .write_bg
    

    mov byte [es:di+bx], 0x0F    ; plot pixel (red) if bit is set
 
    jmp .next
    
.write_bg:

 
    mov byte [es:di+bx], 0x00    ; plot background
  
    
.next:

    
    inc bx
    cmp bx, 4
    jl .loop
    pop di    


    pop bx
    pop ax


    ret













end:

.hang:
    loop .hang 
















%include "data_3.0.asm"
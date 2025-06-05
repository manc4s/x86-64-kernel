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
    ;preserve di
    push di

    mov di, 0                ; Start at offset 0 (row 0)
    mov cx, 320*200              ; 320 pixels in the first row
    mov al, [bg_color]    ;selected bg color in data, byte long        ; Color 00011100 (28),


.fill_row:
    mov [es:di], al
    inc di
    loop .fill_row

    pop di
    ret








;Delay that is million loop cycles for cool typing effect
big_delay:

    ;200 * 65535 = 13,107,000 loop cycle delay
    push bx
    push cx

    mov bx, 2500     ; outer loop count (increase for longer delay)

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


main:
    mov ax, 66
    call print_char

    ;mov byte [bg_color], 0x44
    
    mov word [x_offset], 100
    mov word [y_offset], 100

    mov si, shell_line
    call print_string

    call new_line
    
    mov byte [bg_color], 0x04

    mov al, 65
    call print_char



    ;where inputs should go
    mov word [x_offset], 5
    mov word [y_offset], 0
    




.main_loop:



    call toggle_cursor_color
    
    mov word [x_offset], 100
    mov word [y_offset], 120

    call draw_cursor

    mov ah, 1
    int 0x16
    jz .main_loop

    
    mov ax, 0x10                      ;the input value ascii goes in al
    int 0x16


    push ax
    mov word ax, [cursor_x]
    mov word [x_offset], ax
    mov word ax, [cursor_y]
    mov word [y_offset], ax
    pop ax

    
    call print_char
    add word [cursor_x], 5
    
    

    jmp .main_loop




toggle_cursor_color:
    push si
    push dx
    push ax

    inc word [cursor_counter]


    mov ax, [cursor_counter]
    mov dx, 0
    mov cx, 20000  ;100ticks
    div cx  ;ax/cx remainder in dx
    cmp dx, 0
    je .change_to_bg_color
    jmp .end

.change_to_bg_color:    
   
    cmp byte [cursor_bg], 0x57
    je .to_black
    mov byte [cursor_bg], 0x57
    jmp .end

.to_black:
    mov byte [cursor_bg], 0x00

.end:
    pop ax
    pop dx
    pop si
    
    ret



draw_cursor:

    ;preserve ax
    push ax
    mov al, [cursor_bg]
    mov [bg_color], al
    mov al, [cursor_text]
    mov [text_color], al
    mov al, 32
    call print_char
    
    mov al, [olive]
    mov [bg_color], al
    mov al, [white]
    mov [text_color], al
    pop ax
    ret


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
    mov di, [x_offset] ; [x_offset] works great for printing char by offset as well
    
    
    ;preserve ax here just in case
    push ax
    mov ax, [y_offset]
    imul ax, 320   ;y*320
    add di, ax
    pop ax

.rest_of_print_char:


    call plot_row_glyph


    inc bx          ;increment row of glyph
    add di, 320     ;next row, 320 pixel offset for di
    cmp bx, 6        ;loop 0-5
    jl .rest_of_print_char


    pop bx
    pop si
    ret






new_line:
    add word [y_offset], 6
    mov word [x_offset], 0

    cmp word [y_offset], 198
    jge .row_end
    ret

.row_end:
    call clear_screen
    mov word [y_offset], 0
    mov word [x_offset], 0
    ret




next_char:
    add word [x_offset], 5    ; should increment by 5
    cmp word [x_offset], 320
    je .next
    ret

.next:
    mov word [x_offset], 0
    add word [y_offset], 6  ;glyphs are 8 pixels tall. so increment by 6
    ret


;take ascii, x, and y
;ascii - ax
;si is always reset in here
;plots a row from a glyph
plot_row_glyph:
   
    mov ah, 0
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

    
   
.loop:

   

    ;If the glyph row find a 1, draw the text oen color, if its not, jump to bg color
    mov ah, al
    mov cl, 3
    sub cl, bl           ; cl = (3-bl): bit index for current pixel (left to right)
    shr ah, cl           ; move the target bit into the LSB
    and ah, 1


    jz .write_bg
    
    push ax
    mov al, [text_color]
    mov byte [es:di+bx], al    ; plot pixel (red) if bit is set
    pop ax


    jmp .next
    
.write_bg:

    
    push ax
    mov al, [bg_color]
    mov byte [es:di+bx], al    ; plot background
    pop ax
    
.next:

    
    inc bx
    cmp bx, 4
    jl .loop
    


    pop bx
    pop ax


    ret













end:

.hang:
    jmp .hang 
















%include "data_3.0.asm"

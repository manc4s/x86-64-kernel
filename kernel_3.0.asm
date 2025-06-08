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
    ;clear the tracked page asciis
    call clear_page_data

    ;entered kernel message
    mov si, entered
    call print_string
    call new_line


    jmp main




main:
 
    mov si, shell_line
    call print_string
    mov word [input_size], 0
    
.main_loop:



    call toggle_cursor_color
    call draw_cursor

    mov ah, 1
    int 0x16
    jz .main_loop

    
    mov ax, 0x10                      ;the input value ascii goes in al
    int 0x16

    
   
    cmp byte ah, 0x1C  ; enter pressed
    je .enter_press
    cmp byte ah, 0x4D   ;right arrow
    je .rightarrow
    cmp byte ah, 0x4B   ;left arrow
    je .leftarrow
    cmp byte al, 0x08   ;backspace
    je .backspace



    ; limit reached?
    cmp word [x_offset], 315
    jne .continue
    cmp word [row], 32
    jne .continue
    jmp .main_loop      ; at last char, don't allow more input

.continue:
    push bx
    mov bx, [input_size]
    mov byte [input_buffer + bx], al
    mov byte [input_buffer + bx + 1], 0  ;always zero terminated.
    pop bx
   
    inc word [input_size]

    ;else
    call print_char
    call next_char
    jmp .main_loop



.enter_press:
    call draw_blank
    call new_line

    mov word [cursor_left], 0 ; reset cursor left movement
    call cursor_to_text



    cmp word [input_size], 0
    je main

    push si
    mov si, input_buffer
    call print_string
    call new_line
    pop si

    jmp main

.backspace:


    ;size of input buffer is none, jump. to the top of taking inputs again
    cmp word [input_size], 0
    je .main_loop


    ;sub buffer size by 1
    sub word [input_size], 1

    ;backspace needs to delete from the buffer, so the buffer most recent location will be turned to 0, the end   
    push bx
    mov bx, [input_size]
    mov byte [input_buffer + bx], 0
    pop bx
    ;------------------------------------------------------------------------------------------

    ;call backspace for visually drawing
    ;call backspace
    call draw_blank
    call decrement_position
    call draw_blank
    jmp .main_loop


.rightarrow:
    call move_cursor_right
    jmp .main_loop


.leftarrow:
    call move_cursor_left
    jmp .main_loop










cursor_to_text:

    push ax
    push bx

    mov word ax, [x_offset]
    mov word bx, [y_offset]

    mov word [cursor_offsetx], ax
    mov word [cursor_offsety], bx

    pop bx
    pop ax
    ret





;move the cursor left counter and move
move_cursor_left:

    ;preserve
    push ax
    push bx
    mov word ax, [input_size]
    cmp word [cursor_left], ax
    jl .continue

    pop bx
    pop ax
    ret


.continue:
    
    add word [cursor_left], 1  ;increment left movements
    call erase_cursor  ;erase old position of cursor before editing the positions


    cmp word [cursor_offsetx], 0
    je .set320
    sub word [cursor_offsetx], 5
    pop bx
    pop ax
    ret



.set320:

    mov word [cursor_offsetx], 315  ;next character from leftarrowing from cursorx of zero
    cmp word [cursor_offsety], 6
    jge .substract

    
    pop bx
    pop ax
    ret

.substract:
    sub word [cursor_offsety], 6

    pop bx
    pop ax
    ret





;move the cursor right counter and move
move_cursor_right:

    ;preserve
    push ax
    push bx
    cmp word [cursor_left], 0 ;at the newest position so cant keep moving right
    jg .continue

    pop bx
    pop ax
    ret


.continue:
    
    sub word [cursor_left], 1  ;move right by subbing from left cursor counter
    call erase_cursor  ;erase old position of cursor before editing the positions


    cmp word [cursor_offsetx], 315
    je .set0
    add word [cursor_offsetx], 5
    pop bx
    pop ax
    ret



.set0:

    mov word [cursor_offsetx], 0  ;next character from leftarrowing from cursorx of zero
    cmp word [cursor_offsety], 192
    jg .clear_page
    add word [cursor_offsety], 6

    pop bx
    pop ax
    ret

.clear_page:
    ;call clear_screen
    ;call clear_page_data
    
    pop bx
    pop ax
    ret







decrement_position:
    
    cmp word [x_offset], 0
    je .set320

    sub word [x_offset], 5
    sub word [cursor_offsetx], 5
    ret
    

.set320: 
    mov word [x_offset], 315  ;next character from backspacing from x of zero
    mov word [cursor_offsetx], 315

    cmp word [y_offset], 6
    jge .substract
    ret

.substract:
    sub word [y_offset], 6
    sub word [cursor_offsety], 6
    ret





toggle_cursor_color:
    push si
    push dx
    push ax

    inc word [cursor_counter]
    cmp word [cursor_counter], 5000    ;the cursor blink rate 10000 ~= to 1 sec 

    ;to avoid skipping, do when greater than 1000 than when equal.
    jg .change_to_bg_color
    jmp .end

.change_to_bg_color:    
   
    ;reset the counter
    mov word [cursor_counter], 0
    
    ;cursor color 1
    mov byte al, [black]
    cmp byte [cursor_bg], al
    je .to_black
    mov byte [cursor_bg], al
    jmp .end

.to_black:
    
    ;cursor_color2
    mov al, [yella]
    mov byte [cursor_bg], al

.end:
    pop ax
    pop dx
    pop si
    
    ret




draw_blank:
    
    ;preserve ax
    push ax
    mov al, [olive]
    mov [bg_color], al
    mov al, [olive]
    mov [text_color], al
    mov al, 32  ;blank space
    call print_char
    
    mov al, [olive]
    mov [bg_color], al
    mov al, [white]
    mov [text_color], al
    pop ax
    ret



erase_cursor:


    ;preserve ax
    push ax
    push bx
    push cx

    
    mov word bx, [x_offset]
    mov word cx, [y_offset]
    push bx
    push cx  ;save old cursor x and y to print cursor x and y positions

    mov word bx, [cursor_offsetx]
    mov word cx, [cursor_offsety]


    ;x and y offset are set to cursor x and y offset before printing the cursor
    mov word [x_offset], bx
    mov word [y_offset], cx



    mov al, [olive]
    mov [bg_color], al
    mov al, [white]
    mov [text_color], al
    
    ;call scan_glyph_at_cursor
    call hovering
    mov al, [hovering_char] 
    call print_char

    
    ;grab old x and y offsets
    pop cx
    pop bx

    mov word [y_offset], cx
    mov word [x_offset], bx

    
    mov al, [olive]
    mov [bg_color], al
    mov al, [white]
    mov [text_color], al



    pop cx
    pop bx
    pop ax
    ret





draw_cursor:

    ;preserve ax
    push ax
    push bx
    push cx

    
    mov word bx, [x_offset]
    mov word cx, [y_offset]
    push bx
    push cx  ;save old cursor x and y to print cursor x and y positions

    mov word bx, [cursor_offsetx]
    mov word cx, [cursor_offsety]


    ;x and y offset are set to cursor x and y offset before printing the cursor
    mov word [x_offset], bx
    mov word [y_offset], cx



    mov al, [cursor_bg]
    mov [bg_color], al
    mov al, [cursor_text]
    mov [text_color], al

    ;call scan_glyph_at_cursor
    call hovering
    mov al, [hovering_char]   
    ;mov al, [page_data + 1] ; change to [hovering_char] after hovering the page_data
    call print_char



    ;grab old x and y offsets
    pop cx
    pop bx

    mov word [y_offset], cx
    mov word [x_offset], bx



    
    mov al, [olive]
    mov [bg_color], al
    mov al, [white]
    mov [text_color], al


    pop cx
    pop bx
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



;grab value at [x_offset], [y_offset], put it into hovering_chat byte the asci value from page_data
hovering:
    push ax
    push di
    push dx
    push bx
    push si
    push ds


     ;x/5
    push ax
    mov ax, [x_offset]
    mov dx, 0
    mov bx, 5
    div bx
    mov si, ax
  

    ;y/6 * 64
   
    mov ax, [y_offset]
    mov dx, 0
    mov bx, 6
    div bx

    imul ax, 64    
    add si, ax
    pop ax


    ;si should be offset for page_data now for entered al
    mov byte al, [page_data + si]
    mov byte [hovering_char], al
    ;al is stores its ascii character in the 2112 bytes of characters


    
    pop ds
    pop si
    pop bx
    pop dx
    pop di
    pop ax

    ret




;x and y taken, divided by 5 and 6 respectively. Values are added, y value * 64, for ascii location
;page data 33*64 chars are stroed into 2112 bytes in memory at page_data
;value hovered at x_offset y_offset saved to hovering_char
save_char:

    push ax
    push di    
    push dx
    push bx
    push si
    push ds

    ;x/5
    push ax
    mov ax, [x_offset]
    mov dx, 0
    mov bx, 5
    div bx
    mov si, ax
    pop ax

    ;y/6 * 64
    push ax
    mov ax, [y_offset]
    mov dx, 0
    mov bx, 6
    div bx
    imul ax, 64
    add si, ax
    pop ax


    ;si should be offset for page_data now for entered al
    mov byte [page_data + si], al
    ;al is stores its ascii character in the 2112 bytes of characters


    pop ds
    pop si
    pop bx
    pop dx
    pop di
    pop ax

    ret




;prints the ascii byte in al
print_char:
    push si
    push bx
    ;both these counters need to be reset before every glyph anyways, universal locations are kept track of in [x_offset], [y_offset], divided by 4,for actual character location out of 0-79 cols and 0-32 rows, for a toal of 2640 chars
    mov bx, 0
    mov di, [x_offset] ; [x_offset] works great for printing char by offset as well
    
    

    call save_char  ;saves the char into page_data in its character of 2112 spots

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
    add word [cursor_offsety], 6

    mov word [x_offset], 0
    mov word [cursor_offsetx], 0


    ;33 rows startinf including 0
    cmp word [row], 32
    
    je .row_end
    inc word [row]
    ret

.row_end:

    call clear_screen
    call clear_page_data


    mov word [row], 0
    mov word [y_offset], 0
    mov word [cursor_offsety], 0


    mov word [x_offset], 0
    mov word [cursor_offsetx], 0
    ret






next_char:
    add word [x_offset], 5    ; should increment by 5
    add word [cursor_offsetx], 5

    cmp word [x_offset], 320
    jge .next
    ret

.next:
    call new_line
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







clear_page_data:

    push si
    push ax
    push cx

    mov si, page_data     ; start of buffer
    mov cx, 2112          ; number of bytes
    xor al, al            ; value to write (0)

.clear_loop:
    mov [si], al
    inc si
    loop .clear_loop



    pop cx
    pop ax
    pop si
    ret


end:

.hang:
    jmp .hang 











%include "data_3.0.asm"

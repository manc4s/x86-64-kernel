
ORG 0x10000


[bits 32]
protected_start:
    ; Set up segments
    mov ax, 0x10        ; Data segment selector
    mov ds, ax
    mov es, ax

    mov ax, 0x18
    mov ss, ax
    mov esp, 0x101000    ; Top of your stack segment
    
    ; Test - write something to video memory
    
    mov eax, 'P'
    push eax
    mov byte [0xB8000], al
    mov byte [0xB8001], 0x07

    
    mov eax, "E"
    mov byte [0xB8002], al
    mov byte [0xB8003], 0x07
    

    pop eax
    mov byte [0xB8002], al
    mov byte [0xB8003], 0x07
    

    mov ecx, 0    
    jmp lain


lain:

    
    mov eax, "E"
    mov byte [0xB8000], al
    mov byte [0xB8001], 0x07


    ;32 bit solution for taking scancodes and convering to ascii.
    in al, 0x64
    test al, 1
    jz lain

    in al, 0x60
    test al, 0x80
    jnz lain


    mov ah, al
    movzx ebx, ah
    mov al, [scancode_to_ascii + ebx]

    mov dword ecx, [test_counter]
    mov byte [0xb8000 + ecx], al
    inc ecx
    mov byte [0xb8000 + ecx], 0x07
    inc ecx
    add dword [test_counter], 2

    jmp lain








kernel:

    ; Set up segment registers
    mov ax, 0x10     ; data segment selector = index 2 * 8
    mov ds, ax
    mov fs, ax
    mov gs, ax

    mov ax, 0x18
    mov ss, ax

    mov esp, 0xB0FFF ; top of your stack (stack segment base + limit)
 

    
    ;track location where VRAM is for 13 hour mode
    mov ax, 0xA000
    mov es, ax


    ;draw the bg, so you can see the 320x200 screen in qemu, turns to selected bg_color
    call clear_screen

     
    jmp main



main:
    jmp .hang

    mov di, 0
    mov ax, 65
    call print_char
    add word [x_offset], 6


    mov byte [text_color], 0x00
    mov si, shell_line
    call print_string


    mov byte [bg_color], 0x04
    mov byte [text_color], 0x0f
    mov word [x_offset], 100
    mov word [y_offset], 100
    call print_string



    mov word [x_offset], 0
    mov word [y_offset], 6


.input_loop:
   

    mov al, 'A'
    call print_char
    call next_char

    jmp .input_loop



    
.hang:
    jmp .hang









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





next_char:
    add word [x_offset], 5    ; should increment by 5
    cmp word [x_offset], 320
    je .next
    ret

.next:
    mov word [x_offset], 0
    add word [y_offset], 6  ;glyphs are 8 pixels tall. so increment by 6
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




;take ascii, x, and y
;ascii - ax
;si is always reset in here
;plots a row from a glyph
plot_row_glyph:
   

    mov ah, 0 ; just in case the input in ah is not 0 so it doesn mess up
    
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
    mov al, 0x1f    ;selected bg color in data, byte long        ; Color 00011100 (28),


.fill_row:
    mov [es:di], al
    inc di
    loop .fill_row

    pop di
    ret















%include "data_4.0.asm"
































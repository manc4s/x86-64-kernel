
ORG 0x10000


[bits 32]
protected_start:
    ;; Set up segments
    ; Set up segment registers
    mov ax, 0x10     ; data segment selector = index 2 * 8
    mov ds, ax
    mov fs, ax
    mov gs, ax

    mov ax, 0x18
    mov ss, ax

    mov esp, 0x101000    ;; Top of your stack segment

    
    ;track location where VRAM is for 13 hour mode
    mov ax, 0x20
    mov es, ax
    
    ;; Test - write something to video memory
    
    ;mov eax, 'P'
    ;push eax
    ;mov byte [0xB8000], al
    ;mov byte [0xB8001], 0x07

    
    ;mov eax, "E"
    ;mov byte [0xB8002], al
    ;mov byte [0xB8003], 0x07
    

    ;pop eax
    ;mov byte [0xB8002], al
    ;mov byte [0xB8003], 0x07
    

    ;mov ecx, 0    
    ;mov edx, 0

    mov eax, 0
    jmp kernel

    



lain:

    cmp edx, 0
    jne .notequal
    mov eax, "E"
    mov byte [0xB8000], al
    mov byte [0xB8001], 0x07
    inc edx


.notequal:
    mov edx, 0
    mov eax, "P"
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



    ;draw the bg, so you can see the 320x200 screen in qemu, turns to selected bg_color
    call clear_screen

     
    



main:
    


.input_loop:
   

    mov al, 65
    call print_char
    call next_char



    mov al, 66
    call print_char
    call next_char


    



    
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
    push esi
    push ebx
    ;both these counters need to be reset before every glyph anyways, universal locations are kept track of in [x_offset], [y_offset], divided by 4,for actual character location out of 0-79 cols and 0-32 rows, for a toal of 2640 chars
    mov ebx, 0
    mov edi, [x_offset] ; [x_offset] works great for printing char by offset as well
    
    
    ;preserve ax here just in case
    push eax
    mov eax, [y_offset]
    imul eax, 320   ;y*320
    add edi, eax
    pop eax

.rest_of_print_char:


    call plot_row_glyph


    inc ebx          ;increment row of glyph
    add edi, 320     ;next row, 320 pixel offset for di
    cmp ebx, 6        ;loop 0-5
    jl .rest_of_print_char


    pop ebx
    pop esi
    ret




;take ascii, x, and y
;ascii - ax
;si is always reset in here
;plots a row from a glyph
plot_row_glyph:
   

    mov ah, 0 ; just in case the input in ah is not 0 so it doesn mess up
    
    push eax
    

    ;alphabet(location of all 4x6 glyphs)
    ;mov esi, alphabet
    ;add esi, ebx  ;which glyph row
    ;imul eax, 6
    ;add esi, eax
    ;sub esi, 192



      ;ASCII 32 (space) is the first character in your alphabet array
    sub eax, 32           ; Convert ASCII to index (space = 0, ! = 1, etc.)
    mov esi, alphabet     ; Start of glyph data
    imul eax, 6           ; Each glyph is 6 bytes
    add esi, eax           ; Point to start of character's glyph data
    add esi, ebx           ; Add row offset (0-5 for each row of the glyph)
   
   
    ;After adding glyph row from prvious bx
    push ebx
    mov al, [esi]         ; AL = row byte, lower 4 bits are the pixels
    mov ebx, 0            ; pixel index (0 to 3)

    
   
.loop:
    ;If the glyph row find a 1, draw the text oen color, if its not, jump to bg color
    mov ah, al
    mov cl, 3
    sub cl, bl           ; cl = (3-bl): bit index for current pixel (left to right)
    shr ah, cl           ; move the target bit into the LSB
    and ah, 1


    jz .write_bg
    
    push eax
    mov al, [text_color]
    mov byte [es:edi+ebx], al    ; plot pixel (red) if bit is set
    pop eax


    jmp .next
    
.write_bg:

    
    push eax
    mov al, [bg_color]
    mov byte [es:edi+ebx], al    ; plot background
    pop eax
    
.next:

    
    inc ebx
    cmp ebx, 4
    jl .loop
    


    pop ebx
    pop eax


    ret





;clears the screen with selected color in al
clear_screen:
    ;preserve di
    push di

    mov di, 0                ; Start at offset 0 (row 0)
    mov cx, 320*200              ; 320 pixels in the first row
    mov al, 0x44    ;selected bg color in data, byte long        ; Color 00011100 (28),


.fill_row:
    mov [es:di], al
    inc di
    loop .fill_row

    pop di
    ret















%include "data_4.0.asm"
































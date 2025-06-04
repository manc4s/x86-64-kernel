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



main:

    mov di, 0
    mov ax, 65
    call print_char


    mov byte [text_color], 0x00
    mov si, shell_line
    call print_string


    mov byte [bg_color], 0x04
    mov byte [text_color], 0x0f
    mov word [x_offset], 100
    mov word [y_offset], 100
    call print_string

    
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















































entered: db "Successfully Entered Kernel ...........................................................................................",0 
shell_line: db "kernel-shell-v1-$", 0


x_offset: dw 0   ;current position
y_offset: dw 0


bg_color: db 0x44  ;0xd5 olive green
text_color: db 0x0f  ;white




cursor_x: dw 0
cursor_y: dw 0

plot_4by5_color: db 0x00 ;

;all chars 0-128, 4x6. 
;for 13h mode, custom 4x6 font
alphabet:  

    ;32: Space
    db 0b0000,0b0000,0b0000,0b0000,0b0000,0b0000
    ; 33: !
    db 0b0010,0b0010,0b0010,0b0010,0b0000,0b0010
    ; 34: "
    db 0b0101,0b0101,0b0000,0b0000,0b0000,0b0000
    ; 35: #
    db 0b0101,0b1111,0b0101,0b1111,0b0101,0b0000
    ; 36: $
    db 0b0110,0b1010,0b0110,0b0101,0b0110,0b0000
    ; 37: %
    db 0b1100,0b1101,0b0010,0b1011,0b0011,0b0000
    ; 38: &
    db 0b0110,0b1001,0b0110,0b1001,0b0111,0b0000
    ; 39: '
    db 0b0010,0b0010,0b0000,0b0000,0b0000,0b0000
    ; 40: (
    db 0b0010,0b0100,0b0100,0b0100,0b0010,0b0000
    ; 41: )
    db 0b0100,0b0010,0b0010,0b0010,0b0100,0b0000
    ; 42: *
    db 0b0000,0b0101,0b0010,0b0101,0b0000,0b0000
    ; 43: +
    db 0b0000,0b0010,0b0111,0b0010,0b0000,0b0000
    ; 44: ,
    db 0b0000,0b0000,0b0000,0b0010,0b0100,0b0000
    ; 45: -
    db 0b0000,0b0000,0b0111,0b0000,0b0000,0b0000
    ; 46: .
    db 0b0000,0b0000,0b0000,0b0010,0b0000,0b0000
    ; 47: /
    db 0b0001,0b0010,0b0100,0b1000,0b0000,0b0000
    ; 48: 0
    db 0b0110,0b1001,0b1001,0b1001,0b0110,0b0000
    ; 49: 1
    db 0b0010,0b0110,0b0010,0b0010,0b0111,0b0000
    ; 50: 2
    db 0b0110,0b1001,0b0010,0b0100,0b1111,0b0000
    ; 51: 3
    db 0b0110,0b0001,0b0110,0b0001,0b0110,0b0000
    ; 52: 4
    db 0b0001,0b0011,0b0101,0b1111,0b0001,0b0000
    ; 53: 5
    db 0b1111,0b1000,0b1110,0b0001,0b1110,0b0000
    ; 54: 6
    db 0b0110,0b1000,0b1110,0b1001,0b0110,0b0000
    ; 55: 7
    db 0b1111,0b0001,0b0010,0b0100,0b0100,0b0000
    ; 56: 8
    db 0b0110,0b1001,0b0110,0b1001,0b0110,0b0000
    ; 57: 9
    db 0b0110,0b1001,0b0111,0b0001,0b0110,0b0000
    ; 58: :
    db 0b0000,0b0010,0b0000,0b0010,0b0000,0b0000
    ; 59: ;
    db 0b0000,0b0010,0b0000,0b0010,0b0100,0b0000
    ; 60: <
    db 0b0001,0b0010,0b0100,0b0010,0b0001,0b0000
    ; 61: =
    db 0b0000,0b0111,0b0000,0b0111,0b0000,0b0000
    ; 62: >
    db 0b0100,0b0010,0b0001,0b0010,0b0100,0b0000
    ; 63: ?
    db 0b0110,0b1001,0b0010,0b0000,0b0010,0b0000
    ; 64: @
    db 0b0110, 0b1001, 0b1011, 0b1011, 0b0110, 0b0000
    ; 65: A
    db 0b0110,0b1001,0b1111,0b1001,0b1001,0b0000
    ; 66: B
    db 0b1110,0b1001,0b1110,0b1001,0b1110,0b0000
    ; 67: C
    db 0b0110,0b1001,0b1000,0b1001,0b0110,0b0000
    ; 68: D
    db 0b1110,0b1001,0b1001,0b1001,0b1110,0b0000
    ; 69: E
    db 0b1111,0b1000,0b1110,0b1000,0b1111,0b0000
    ; 70: F
    db 0b1111,0b1000,0b1110,0b1000,0b1000,0b0000
    ; 71: G
    db 0b0110,0b1000,0b1011,0b1001,0b0111,0b0000
    ; 72: H
    db 0b1001,0b1001,0b1111,0b1001,0b1001,0b0000
    ; 73: I
    db 0b0111,0b0010,0b0010,0b0010,0b0111,0b0000
    ; 74: J
    db 0b0001,0b0001,0b0001,0b1001,0b0110,0b0000
    ; 75: K
    db 0b1001,0b1010,0b1100,0b1010,0b1001,0b0000
    ; 76: L
    db 0b1000,0b1000,0b1000,0b1000,0b1111,0b0000
    ; 77: M
    db 0b1001,0b1111,0b1111,0b1001,0b1001,0b0000
    ; 78: N
    db 0b1001,0b1101,0b1111,0b1011,0b1001,0b0000
    ; 79: O
    db 0b0110,0b1001,0b1001,0b1001,0b0110,0b0000
    ; 80: P
    db 0b1110,0b1001,0b1110,0b1000,0b1000,0b0000
    ; 81: Q
    db 0b0110,0b1001,0b1001,0b1011,0b0111,0b0000
    ; 82: R
    db 0b1110,0b1001,0b1110,0b1010,0b1001,0b0000
    ; 83: S
    db 0b0111,0b1000,0b0110,0b0001,0b1110,0b0000
    ; 84: T
    db 0b1111,0b0010,0b0010,0b0010,0b0010,0b0000
    ; 85: U
    db 0b1001,0b1001,0b1001,0b1001,0b0110,0b0000
    ; 86: V
    db 0b1001,0b1001,0b1001,0b0110,0b0100,0b0000
    ; 87: W
    db 0b1001,0b1001,0b1111,0b1111,0b1001,0b0000
    ; 88: X
    db 0b1001,0b0110,0b0100,0b0110,0b1001,0b0000
    ; 89: Y
    db 0b1001,0b0110,0b0010,0b0010,0b0010,0b0000
    ; 90: Z
    db 0b1111,0b0001,0b0110,0b1000,0b1111,0b0000
    ; 91: [
    db 0b0110,0b0100,0b0100,0b0100,0b0110,0b0000
    ; 92: '\'
    db 0b1000,0b0100,0b0010,0b0001,0b0000,0b0000
    ; 93: ]
    db 0b0110,0b0010,0b0010,0b0010,0b0110,0b0000
    ; 94: ^
    db 0b0010,0b0101,0b0000,0b0000,0b0000,0b0000
    ; 95: _
    db 0b0000,0b0000,0b0000,0b0000,0b1111,0b0000
    ; 96: `
    db 0b0100,0b0010,0b0000,0b0000,0b0000,0b0000
    ; 97: a
    db 0b0000,0b0110,0b0001,0b0111,0b0111,0b0000
    ; 98: b
    db 0b1000,0b1110,0b1001,0b1001,0b1110,0b0000
    ; 99: c
    db 0b0000,0b0111,0b1000,0b1000,0b0111,0b0000
    ; 100: d
    db 0b0001,0b0111,0b1001,0b1001,0b0111,0b0000
    ; 101: e
    db 0b0000,0b0111,0b1111,0b1000,0b0111,0b0000
    ; 102: f
    db 0b0011,0b0100,0b1110,0b0100,0b0100,0b0000
    ; 103: g
    db 0b0000,0b0110,0b1010,0b0110,0b0010,0b0110
    ; 104: h
    db 0b1000,0b1110,0b1001,0b1001,0b1001,0b0000
    ; 105: i
    db 0b0010,0b0000,0b0110,0b0010,0b0111,0b0000
    ; 106: j
    db 0b0000,0b0001,0b0000,0b0001,0b0001,0b0110
    ; 107: k
    db 0b1000,0b1010,0b1100,0b1010,0b1001,0b0000
    ; 108: l
    db 0b0110,0b0010,0b0010,0b0010,0b0111,0b0000
    ; 109: m
    db 0b0000,0b1110,0b1111,0b1001,0b1001,0b0000
    ; 110: n
    db 0b0000,0b1110,0b1001,0b1001,0b1001,0b0000
    ; 111: o
    db 0b0000,0b0110,0b1001,0b1001,0b0110,0b0000
    ; 112: p
    db 0b0000,0b1100,0b1010,0b1100,0b1000,0b1000
    ; 113: q
    db 0b0000,0b0110,0b1010,0b0110,0b0010,0b0010
    ; 114: r
    db 0b0000,0b1011,0b1100,0b1000,0b1000,0b0000
    ; 115: s
    db 0b0000,0b0111,0b0100,0b0010,0b0111,0b0000
    ; 116: t
    db 0b0100,0b1110,0b0100,0b0100,0b0011,0b0000
    ; 117: u
    db 0b0000,0b1001,0b1001,0b1001,0b0111,0b0000
    ; 118: v
    db 0b0000,0b1001,0b1001,0b0110,0b0100,0b0000
    ; 119: w
    db 0b0000,0b1001,0b1111,0b1111,0b0110,0b0000
    ; 120: x
    db 0b0000,0b1001,0b0110,0b0110,0b1001,0b0000
    ; 121: y
    db 0b0000,0b1001,0b0111,0b0001,0b0110,0b0000
    ; 122: z
    db 0b0000,0b1110,0b0010,0b0100,0b1110,0b0000
    ; 123: {
    db 0b0011,0b0010,0b1100,0b0010,0b0011,0b0000
    ; 124: |
    db 0b0010,0b0010,0b0010,0b0010,0b0010,0b0000
    ; 125: }
    db 0b1100,0b0100,0b0011,0b0100,0b1100,0b0000
    ; 126: ~
    db 0b0000,0b0101,0b1010,0b0000,0b0000,0b0000
    ; 127: (DEL, blank)
    db 0b1111,0b1111,0b1111,0b1111,0b1111,0b1111
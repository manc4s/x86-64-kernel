[BITS 16]
ORG 0x10000




start:
    ;initialize all pointers to 0x10000 to begin
    mov ax, 0x1000
    mov ds, ax
    mov es, ax
    mov ss, ax


    
    
    mov ax, 0x13 ;13 hour mode, graphics mode
    int 0x10 
    
    
    
    mov word [0x0600], 0 ; row
    mov word [0x09999], 0 ;*6 fucking value from ax


    ;below for if in 0x13 mode, 13 hour mode
    mov ax, 0xA000               ;start of vram, 64 kb from there to 0xAFFFF
    mov es, ax


    
    ;below for if in 0x3 mode
    ;mov ax, 0xB800
    ;mov es, ax                      ; 0xA000 stored in es


    jmp main















;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;String Output;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;Output To the screen based on message at di.
;output the message at memory location di, which is mapped to one of messages 1-4 after comp1 call.
print_message_0x03mode:
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







main_0x03_mode_check:
    call clear_0x03_mode
    mov di, entered
    call print_message_0x03mode
    jmp .hang



.hang:
    jmp .hang



clear_0x03_mode:
    mov di, 0
    mov cx, 2000          ; 80 x 25 = 2000 characters

    mov ah, 0x07          ; attribute: light grey on black
    mov al, 0x20          ; ASCII space
    

.clear_loop:
    mov word [es:di], 0x8E20    ;attrobute 8E, yellow on dark gray, 0x20 space in ascii.
    add di, 2
    loop .clear_loop
    ret



loop_through_first_row:
    mov di, 0                ; Start at offset 0 (row 0)
    mov cx, 320*200              ; 320 pixels in the first row
    mov al, 0x9F    ;white bg         ; Color 00011100 (28),
            

            ;0x90 - 0x9F are not really any of waht im looking for
            ;0x00 - 0x0F


            ;0x9D almost pink
            ;0x98 nice purple
            ;0xb6 dark pink
            ;0x3e nice pink
            ;0x36 sky blue
            ;0x0c nice light red
            ;0x0e yellow
            ;0xd5 olive green
            ;0xdc turquoise good for white text
            ;0xbb brown gold weird
            ;good orangey redish brown 0x88 white or black text good
            ;good lacoste monotone green for white text 0xda
            ;0xd4 barf green good for white text
            ;0xe3 good purple for a shell
            ;0x28 strong red 
            ;0x38 nice light purple
            ;3F strong pink
            ;35 nice blue
            ;34 nice blue

.fill_row:
    mov [es:di], al
    inc di
    loop .fill_row
    ret




;loops form 0-5. offset is alphabet ((ascii -32)*6)
;but i expanded it so its easier because i was having issues with the multiplication and taking input
;so it is alphabet_location + 6*ascii -192      
;minus 32  because i only have 32(space) to 128 in my own data
;di is for keeping track of row, rows of 200 of them 320 pixels in length
;bx is for keeping track of glyph row
print_char:
    push si
    push bx
    ;both these counters need to be reset before every glyph anyways, universal locations are kept track of in [x_offset], [y_offset], divided by 4,for actual character location out of 0-79 cols and 0-32 rows, for a toal of 2640 chars
    mov bx, 0
    mov di, 0

.rest_of_print_char:
    ;mov si, alphabet + ((66-32)*6) ;backup working line
    mov si, alphabet
    add si, [0x09999]       ;this value just holds the ascii you want to enter * 6
    sub si, 192


    add si, bx     ;add offset for which row of glyph                             ; si points to 'A' glyph
                                                ;6 rows 0-6 bx being 0-6 off the loop. to grab all 6 bytes where only the lower halves of the bytes are used for 4x6 glyphs

  
    call plot_4bits_row
    
  

    inc bx          ;increment row of glyph
    add di, 320     ;next row, 320 pixel offset for di
    cmp bx, 6        ;loop 0-5
    jl .rest_of_print_char

    add word [x_offset], 5   ;4 but 5 for space we will see
    cmp word [x_offset], 320    ;are you at the edge of the x
    jge .reset_line


    pop bx
    pop si
    ret

.reset_line:
    call new_line
    pop bx
    pop si
    ret



;takes an input
;or sets al,
;then [0x09999] is set to al * 6 for later use when writing text with alphabet + 6x - 192
set_ascii_to_print:


    mov ax, 0                       ;the input value ascii goes in al
    int 0x16

    ;mov al, 97

    ;al contains input from 0x16 interupt
    mov ah, 0
    mov cl, 6
    mul cl        ; AX = AL * 6, result in AX
    mov word [0x09999], ax                          ;ascii value * 6 input for plot_4bit_row

    ret



set_ascii:

    ;al contains input from 0x16 interupt
    mov ah, 0
    mov cl, 6
    mul cl        ; AX = AL * 6, result in AX
    mov word [0x09999], ax                          ;ascii value * 6 input for plot_4bit_row

    ret
    


menu_specs_message:
    mov si, entered ;argument string
    call print_string
    call new_line
    call new_line


    mov si, specs
    call print_string
    call new_line

    mov si, line
    call print_string
    call new_line

    mov si, mode
    call print_string
    call new_line


    mov si, ints
    call print_string
    call new_line


    mov si, start_point
    call print_string
    call new_line
    call new_line
    call new_line


    mov si, check_alpha
    call print_string
    call new_line


    mov si, line
    call print_string
    call new_line

    mov si, alpha
    call print_string
    call new_line
    call new_line

    mov si, check_nums
    call print_string
    call new_line


    mov si, line
    call print_string
    call new_line


    mov si, nums
    call print_string
    call new_line
    
    
    
    
    ret


main:
   
   ; print 'A' at (0,0)
   ;db 0b0110,0b1001,0b1111,0b1001,0b1001,0b0000

    call loop_through_first_row        ;sets the background one colour by looping through every pixel and turning every byte into a color.

    ;mov di, 0 ;is offset for VGA memory from es so you have to reset again after setting the background

    

    ;;call set_ascii_to_print

    mov word [x_offset], 0              
    mov word [y_offset], 0




    ;prints char that is entered in al
    ;;call print_char

    call set_ascii_to_print
    call print_char
    
    
    call menu_specs_message





;.the_main_loop:
   ; add word [x_offset], 5
   ; call print_char
   ; inc word [counter_0]
   ; cmp word [counter_0], 3
  ;  jle .the_main_loop

   

.hang:
    jmp .hang

print_value_6_time:
    push bx
    mov bx, 0
   
.loopzone:
    call print_char
    inc bx
    cmp bx, 5
    jle .loopzone

    pop bx
    ret




new_line:
    add word [y_offset], 6
    mov word [x_offset], 0
    ret


print_string:
    ;string location in si when callling
    ;si must contain a memory location of string

    push ax
    push bx
    mov bx, 0
    

.printloop:
    mov al, [si+bx]
    cmp al, 0
    je .done


    call set_ascii
    call print_char

    inc bx
   
    jmp .printloop

.done:
    pop bx
    pop ax


    ret



print_string_2:
    ;string label in ax when calling print
    ;same as print_string
    ;si must contain a memory location of string

    push ax
    push bx
    mov bx, 0

.printloop:
    mov al, [si+bx]
    cmp al, 0
    je .done

    call set_ascii
    call print_char

    inc bx
    jmp .printloop

.done:
    pop bx
    pop ax
    ret


; IN:
;   SI = address of row byte (font data, e.g. 00000110)
;   DI = VGA memory offset (0xA000:DI is pixel 0 position for this row)
;   ES = 0xA000
; OUT:
;   Colors the 4 bytes [es:di], [es:di+1], [es:di+2], [es:di+3] red if the corresponding lower 4 bits are set in [si]
;   (bit 3 = leftmost pixel, bit 0 = rightmost pixel)

plot_4bits_row:
    push bx
    mov al, [si]         ; AL = row byte, lower 4 bits are the pixels
    mov bx, 0            ; pixel index (0 to 3)

    

.loop:
    mov ah, al
    mov cl, 3
    sub cl, bl           ; cl = (3-bl): bit index for current pixel (left to right)
    shr ah, cl           ; move the target bit into the LSB
    and ah, 1
    jz .skip
    
    ;push bx
    ;add bx, [x_offset]
    ;push es
    ;add es, [x_offset]
    push bx
    push ax

    mov ax, [y_offset]
    imul ax, 320
    add bx, ax
    add bx, [x_offset]

    mov byte [es:di+bx], 0x0F    ; plot pixel (red) if bit is set
                        ;red 0x04
                        ;white 0x0F
    pop ax
    pop bx

    ;pop es
  
.skip:
    inc bx
    cmp bx, 4
    jl .loop
    pop bx

    ret




;simple text for 0x03 mode if 0x13 mode is failing
entered: db "Successfully entered Kernel.", 0

specs: db "Specifications:",0
line: db "=====================",0
mode: db "Mode: Real Mode.", 0
ints: db "Interupts on.", 0
start_point: db "Code at 0x10000 for kernel.", 0
check_alpha: db "alphabet font 4x6 glyphs:",0
alpha: db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.|~", 0
check_nums: db "nums font 4x6 glyphs:",0
nums: db "0123456789 10",0
row: dw 0

other: db ';',0
x_offset: dw 0
y_offset: dw 0

counter_0: dw 0

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
    db 0b0110,0b1001,0b1111,0b1000,0b0110,0b0000
    ; 102: f
    db 0b0011,0b0100,0b1110,0b0100,0b0100,0b0000
    ; 103: g
    db 0b0111,0b1001,0b0111,0b0001,0b0110,0b0000
    ; 104: h
    db 0b1000,0b1110,0b1001,0b1001,0b1001,0b0000
    ; 105: i
    db 0b0010,0b0000,0b0110,0b0010,0b0111,0b0000
    ; 106: j
    db 0b0001,0b0000,0b0001,0b0001,0b0110,0b0000
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
    db 0b0000,0b0000,0b0000,0b0000,0b0000,0b0000
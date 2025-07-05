;;drawing text to the screen related functions
;;also newline
;;
;;
;;print_char()                           ;clears screen visually with [bg_color]
;; -> plot_row_glyphs()   6 times  ;clears ascii glyphs in page_data to page_data_end
;;  
;;next_char()                       ;moves x and y offset one char forward     
;;print_string()              
;;new_line()
;;next_char_nocursor()
;;new_line_nocursor()
;;print_char_cursor()
;;save_char_cursor()
;;draw_blank()
;;draw_blank_at_cursor()
;;decrement_position()
;;back_char_only()

;;print_page()






;prints what in al
print_char:
    push esi
    push ebx
    ;both these counters need to be reset before every glyph anyways, universal locations are kept track of in [x_offset], [y_offset], divided by 4,for actual character location out of 0-79 cols and 0-32 rows, for a toal of 2640 chars
    mov ebx, 0
    mov edi, [x_offset] ; [x_offset] works great for printing char by offset as well
    
    

    call save_char


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










next_char:
    add dword [x_offset], 5    ; should increment by 5
    add dword [cursor_offsetx], 5

    cmp dword [x_offset], 320
    jge .next
    ret

.next:
    call new_line
    ret












;calls print char for multiple char bytes at label passed in si
print_string:
    ;string location in si when callling
    ;si must contain a memory location of string

    push eax
    push ebx
    push ecx
    mov ebx, 0
    

.printloop:
    ;location of entered string at si + character offset
    mov al, [esi + ebx]
    cmp al, 0
    je .done


    call print_char

    inc ebx
    call next_char
   
    jmp .printloop

.done:
    pop ecx
    pop ebx
    pop eax


    ret





;;for git test



;goes to next line, incrementing offset and cursor
new_line:
    add dword [y_offset], 6
    add dword [cursor_offsety], 6

    mov dword [x_offset], 0
    mov dword [cursor_offsetx], 0


    ;33 rows startinf including 0
    cmp dword [row], 32
    
    je .row_end
    inc dword [row]
    ret

.row_end:

    call clear_screen
    call clear_page_data


    mov dword [row], 0
    mov dword [y_offset], 0
    mov dword [cursor_offsety], 0


    mov dword [x_offset], 0
    mov dword [cursor_offsetx], 0
    ret












;;increment the x_offset and y_offset without incrementing the cursor
next_char_nocursor:
    add dword [x_offset], 5    ; should increment by 5

    cmp dword [x_offset], 320
    jge .next
    ret

.next:
    call new_line_nocursor
    ret




;;go to next line x_offset y_offset without moving the cursor as well
new_line_nocursor:
    add word [y_offset], 6
    mov word [x_offset], 0

    ;33 rows startinf including 0
    cmp word [row], 32
    
    je .row_end
    inc word [row]
    ret

.row_end:


    mov word [row], 0
    mov word [y_offset], 0

    mov word [x_offset], 0

    ret






;prints the ascii byte in al at the cursor location
print_char_cursor:
    push esi
    push ebx
    ;both these counters need to be reset before every glyph anyways, universal locations are kept track of in [x_offset], [y_offset], divided by 4,for actual character location out of 0-79 cols and 0-32 rows, for a toal of 2640 chars
    mov ebx, 0
    mov edi, [cursor_offsetx] ; [x_offset] works great for printing char by offset as well
    
    

    call save_char_cursor  ;saves the char into page_data in its character of 2112 spots

    ;preserve ax here just in case
    push eax
    mov eax, [cursor_offsety]
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






;;saves character just called to print at cursoroffset x and y
;;called inside print_char_cursor
save_char_cursor:

    push eax
    push edi    
    push edx
    push ebx
    push esi
 

    ;x/5
    push eax
    mov eax, [cursor_offsetx]
    mov edx, 0
    mov ebx, 5
    div ebx
    mov esi, eax
    pop eax

    ;y/6 * 64
    push eax
    mov eax, [cursor_offsety]
    mov edx, 0
    mov ebx, 6
    div ebx
    imul eax, 64
    add esi, eax
    pop eax


    ;si should be offset for page_data now for entered al
    mov byte [page_data + esi], al
    ;al is stores its ascii character in the 2112 bytes of characters


    
    pop esi
    pop ebx
    pop edx
    pop edi
    pop eax

    ret








;;draws a space using print_char at xoffset yoffset
draw_blank:

      ;preserve ax
    push eax
    mov al, [bg_revert]
    mov [bg_color], al
    mov al, [bg_revert]
    mov [text_color], al
    
    mov al, 32  ;blank space
    call print_char
    
    mov al, [bg_revert]
    mov [bg_color], al
    mov al, [text_revert]
    mov [text_color], al
    pop eax
    ret







;draw blank at cursoroffset x and y
draw_blank_at_cursor:

     ;preserve registers
    push eax
    push ebx
    push ecx


    mov dword ebx, [x_offset]
    mov dword ecx, [y_offset]
    push ebx
    push ecx  ;save old cursor x and y to print cursor x and y positions

    mov dword ebx, [cursor_offsetx]
    mov dword ecx, [cursor_offsety]


    ;x and y offset are set to cursor x and y offset before printing the cursor
    mov dword [x_offset], ebx
    mov dword [y_offset], ecx


    mov al, [bg_revert]
    mov [bg_color], al
    mov al, [bg_revert]
    mov [text_color], al
    
    mov al, 32  ;blank space
    call print_char
    
    ;grab old x and y offsets
    pop ecx
    pop ebx

    mov dword [y_offset], ecx
    mov dword [x_offset], ebx


    mov al, [bg_revert]
    mov [bg_color], al
    mov al, [text_revert]
    mov [text_color], al 


    pop ecx
    pop ebx
    pop eax
    ret











;;decrements the position of 
;;xoffset and yoffset and cursorsoffset x and y
decrement_position:
    
    cmp dword [x_offset], 0
    je .set320

    sub dword [x_offset], 5
    sub dword [cursor_offsetx], 5
    ret
    

.set320: 
    sub dword [row], 1
    mov dword [x_offset], 315  ;next character from backspacing from x of zero
    mov dword [cursor_offsetx], 315

    cmp dword [y_offset], 6
    jge .substract
    ret

.substract:
    sub dword [y_offset], 6
    sub dword [cursor_offsety], 6
    ret


















;;decrement only the offsetx and y, not the cursor
back_char_only:

    cmp dword [x_offset], 0
    jle .next

    
    sub dword [x_offset], 5    ; should increment by 5
    ret

.next:
    sub dword [row], 1
    sub dword [y_offset], 6
    mov dword [x_offset], 315
    ret















;same as print_string just set to 2112 bytes from saved area
;not looking fro nul reminator like in print_string.
;print from label in esi when called
print_page:

    push eax
    push ebx
    push ecx
    mov ebx, 0
    
    mov ecx, 2112

.printloop:
    ;location of entered string at si + character offset
    mov al, [esi + ebx]
    call print_char
    inc bx
    call next_char
    
    
    cmp bx, 2111
    jb .printloop

.done:
    pop ecx
    pop ebx
    pop eax


    ret

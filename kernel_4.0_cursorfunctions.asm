;;Cursor related functions
;;
;;
;;
;;
;;
;;
;;
;;
;;toggle_cursor_color()              ;flips between two cursor colors every time called.
;;draw_cursor()                      ;draws cursor at cursor_offsetx and y
;;hoverinit()
;;save_char()
;;erase_cursor()
;;next_cursor_only()
;;decrement_cursor_only()
;;cursor_to_text()
;;move_cursor_left()
;;move_cursor_right()











toggle_cursor_color:
    push esi
    push edx
    push eax

    inc dword [cursor_counter]
    cmp dword [cursor_counter], 12000    ;the cursor blink rate 10000 ~= to 1 sec 

    ;to avoid skipping, do when greater than 1000 than when equal.
    jg .change_to_bg_color
    jmp .end

.change_to_bg_color:    
   
    ;reset the counter
    mov dword [cursor_counter], 0
    
    ;cursor color 1
    mov byte al, [cursor_bg_1]
    cmp byte [cursor_bg], al
    je .to_black
    mov byte [cursor_bg], al
    jmp .end

.to_black:
    
    ;cursor_color2
    mov al, [cursor_bg_2]
    mov byte [cursor_bg], al

.end:
    pop eax
    pop edx
    pop esi
    
    ret














draw_cursor:

    ;preserve ax
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











;grab value at [x_offset], [y_offset], put it into hovering_chat byte the asci value from page_data
hovering:
    push eax
    push edi
    push edx
    push ebx
    push esi
    


     ;x/5
    push eax
    mov eax, [x_offset]
    mov edx, 0
    mov ebx, 5
    div ebx
    mov esi, eax
  

    ;y/6 * 64
   
    mov eax, [y_offset]
    mov edx, 0
    mov ebx, 6
    div ebx

    imul eax, 64    
    add esi, eax
    pop eax


    ;si should be offset for page_data now for entered al
    mov byte al, [page_data + esi]
    mov byte [hovering_char], al
    ;al is stores its ascii character in the 2112 bytes of characters


    
    
    pop esi
    pop ebx
    pop edx
    pop edi
    pop eax

    ret




;x and y taken, divided by 5 and 6 respectively. Values are added, y value * 64, for ascii location
;page data 33*64 chars are stroed into 2112 bytes in memory at page_data
;value hovered at x_offset y_offset saved to hovering_char
save_char:

    push eax
    push edi    
    push edx
    push ebx
    push esi
    

    ;x/5
    push eax
    mov eax, [x_offset]
    mov edx, 0
    mov ebx, 5
    div ebx
    mov esi, eax
    pop eax

    ;y/6 * 64
    push eax
    mov eax, [y_offset]
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










;;erases the cursor at cursor location
;;draws the ascii from page data that was there 
;;called erase_cursor in shifting page_data functioins and backspace
erase_cursor:

    ;preserve ax
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
    mov al, [text_revert]
    mov [text_color], al
    
    ;call scan_glyph_at_cursor
    call hovering
    mov al, [hovering_char] 
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











;;increment cursoroffsetx and y without affecting offsetx and y
next_cursor_only:

    cmp dword [cursor_offsetx], 315
    jge .next


    add dword [cursor_offsetx], 5


    ret

.next:

    add dword [cursor_offsety], 6
    mov dword [cursor_offsetx], 0
    ret






;;decrement only the cursoroffsetx and y without x and y offset
decrement_cursor_only:

    cmp dword [cursor_offsetx], 0
    jle .next

    sub dword [cursor_offsetx], 5
    
    ret

.next:

    sub dword [cursor_offsety], 6
    mov dword [cursor_offsetx], 315
    ret










;;move the cursoroffsetx 
;;and y to be equal to x and y offset
cursor_to_text:

    push eax
    push ebx

    mov dword eax, [x_offset]
    mov dword ebx, [y_offset]

    mov dword [cursor_offsetx], eax
    mov dword [cursor_offsety], ebx

    pop ebx
    pop eax
    ret











;move the cursor left counter and move
move_cursor_left:

    ;preserve
    push eax
    push ebx
    mov dword eax, [input_size]
    cmp dword [cursor_left], eax
    jl .continue

    pop ebx
    pop eax
    ret


.continue:
    
    add dword [cursor_left], 1  ;increment left movements
    call erase_cursor  ;erase old position of cursor before editing the positions


    cmp dword [cursor_offsetx], 0
    je .set320
    sub dword [cursor_offsetx], 5
    pop ebx
    pop eax
    ret



.set320:

    mov dword [cursor_offsetx], 315  ;next character from leftarrowing from cursorx of zero
    cmp dword [cursor_offsety], 6
    jge .substract

    
    pop ebx
    pop eax
    ret

.substract:
    sub dword [cursor_offsety], 6

    pop ebx
    pop eax
    ret







;move the cursor right counter and move
move_cursor_right:

    ;preserve
    push eax
    push ebx
    cmp dword [cursor_left], 0 ;at the newest position so cant keep moving right
    jg .continue

    pop ebx
    pop eax
    ret


.continue:
    
    sub dword [cursor_left], 1  ;move right by subbing from left cursor counter
    call erase_cursor  ;erase old position of cursor before editing the positions


    cmp dword [cursor_offsetx], 315
    je .set0
    add dword [cursor_offsetx], 5
    pop ebx
    pop eax
    ret



.set0:

    mov dword [cursor_offsetx], 0  ;next character from leftarrowing from cursorx of zero
    cmp dword [cursor_offsety], 192
    jg .clear_page
    add dword [cursor_offsety], 6

    pop ebx
    pop eax
    ret

.clear_page:

    pop ebx
    pop eax
    ret






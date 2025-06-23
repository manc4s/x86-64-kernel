;;shifting text visually and in page_data left or right
;;
;;
;;
;;
;;
;;
;;shift_right()  ;shift everything right
;;shift_left()
;;
;;right related stuff
;;  shift_page_data_right()
;;  shift_VRAM_right()
;;  shift_input_buffer()
;;
;;left related stuff
;;  shift_VRAM_left()
;;  shift_page_data_back()
;;  shift_input_buffer_back()
;;smaller functions
;;shift5()
;;shift1605()
;;shift5left()
;;shift1605left()












;;shifts everything on the screen to the right
;; VRAM - visuals
;; page_data - ascii glyphs at each position
;; entered input in input buffer
shift_right:

    
    call shift_page_data_right
    call shift_VRAM_right
    call shift_input_buffer
    
    
    call next_char_nocursor ;make sure to increment x and y offset on inputs
    call print_char_cursor
    call next_cursor_only

    
    ret











;shift everything back for backspace, overwrite the current position is the easiest way.
;shouldnt need print char or next char or next cursor
shift_left:


    call shift_VRAM_left
    call shift_page_data_back
    call shift_input_buffer_back



    dec dword [input_size]
    call erase_cursor
    call decrement_cursor_only
    call back_char_only
        
    ret






















;shift page_data one byte at a time from the back to the cursor xy position
;this preserves all the values and shifts to make space for values to enter.
;shifts asciis in page_data right
shift_page_data_right:
    push esi
    push eax
    push ecx
    push edx
    push ebx


    mov esi, page_data_end       ; Start from last pixel (320*200-1)
    sub esi, 1




    mov ecx, 2304       ; Shift 63995 pixels (64000-5)

    mov eax, [cursor_offsety]
    mov edx, 0
    mov ebx, 6
    div ebx
    imul eax, 64
    sub ecx, eax


    mov eax, [cursor_offsetx]
    mov edx, 0
    mov ebx, 5
    div ebx 
    
    sub ecx, eax

    


.shift_loop:

    
    mov al, [esi-1]   ; Get pixel 5 positions back
    mov [esi], al     ; Store it
    dec esi
    loop .shift_loop
    
    pop ebx
    pop edx
    pop ecx
    pop eax
    pop esi
    ret












; Shift entire video memory (320x200)
shift_VRAM_right:
    push esi
    push edi
    push eax
    push ecx
    push edx
  

    call erase_cursor

    mov edx, 200         ; Number of rows (entire screen height)
    sub edx, [cursor_offsety]
    sub edx, 6
    

    mov eax, [cursor_offsety]
    imul eax, 320
    add eax, 319
    mov esi, eax         ; Start from end of first row

    jmp .other_end
    


.row_loop:
    push esi             ; Save current row start

    mov ecx, 315         ; Shift 315 pixels per row (320-5)
    sub ecx, [cursor_offsetx]
 
    
.shift_loop:
    call shift5
    loop .shift_loop
    
    pop esi              ; Restore row start
    add esi, 320         ; Move to end of next row
    dec edx
    jnz .row_loop       ; Continue if more rows to process
    

    pop edx
    pop ecx
    pop eax
    pop edi
    pop esi
    ret




.other_end:

    ;here i can implement the rest of the rows tabbing forward
    push esi
    ;start at the otehr end looping rows backwards.
    mov esi, 63999
 
.all_rows:
    push esi
    mov ecx, 320

.shift:
    cmp ecx, 5
    jle .continue
    
    ;mov si - 5 to si
    call shift5
    
    jmp .next
.continue:
    ;mov si - 1605 to si
    call shift1605
.next:    
    loop .shift


    pop esi              ; Restore row start
    sub esi, 320         ; Move to end of next row
    dec edx
    jnz .all_rows       ; Continue if more rows to process
    

    pop esi
    ;jmp .row_loop


    add edx, 6  ; set the counter for the first row which is 6 rows
    jmp .row_loop





    
shift5:

    mov al, [es:esi-5]   ; Get pixel 5 positions to the left
    mov [es:esi], al     ; Store it
    dec esi

    ret


shift1605:


    mov al, [es:esi-1605]   ; Get pixel 5 positions to the left
    mov [es:esi], al     ; Store it
    dec esi

    ret











;shift the bytes in the input buffer from offset input_size - cursor_left, 
;shifts from back to front.
;shifts thigns right
shift_input_buffer:
    push esi
    push eax
    push ecx
    push edx
    push ebx
    push edi

    push eax

    mov esi, input_buffer_end
    sub esi, 1

    ;si contains end of input buffer


    ;in data file, max size of input buffer is 1000
    mov ecx, 2112

    mov eax, [input_size]
    sub eax, [cursor_left]
   

    sub ecx, eax   ;stop at the input buffer at the inputbuffer size input - left_arrow for if cursor moved
    sub ecx, 1

.shift_loop:

    mov al, [esi - 1]
    mov [esi], al
    dec esi

    cmp ecx, 1
    jne .continue
    
    mov edi, input_buffer
    add edi, [input_size]
    sub edi, [cursor_left]
    ;add di, 1


    pop eax
    mov byte [edi], al
    inc dword [input_size]
    


.continue: 
    loop .shift_loop

    pop edi
    pop ebx
    pop edx
    pop ecx
    pop eax
    pop esi
    ret














; Shift entire video memory (320x200) left
shift_VRAM_left:
    push esi
    push edi
    push eax
    push ecx
    push edx
    push ebx

    mov ebx, 0
    
    mov edx, 200         ; Number of rows (entire screen height)
    sub edx, [cursor_offsety]



    mov eax, [cursor_offsety]
    imul eax, 320
    mov esi, eax         ;start from front


.row_loop:
    push esi             ; Save current row start
    mov ecx, 0         ; Shift 315 pixels per row (320-5)
    inc ebx



.shift_loop:
    inc ecx

    cmp ebx, 6
    jg .no_offset

    cmp ecx, [cursor_offsetx]
    jl .pass_loop

.no_offset:

    cmp ecx, 315
    jl .continue

    call shift1605left

    jmp .c

.continue:
    call shift5left
    jmp .c

.pass_loop:

    inc esi


   

    
.c:
    
    cmp ecx, 320
    jl .shift_loop
    

.next:

    pop esi              ; Restore row start
    add esi, 320         ; Move to end of next row
    dec edx
    jnz .row_loop       ; Continue if more rows to process
    

.end:
    pop ebx
    pop edx
    pop ecx
    pop eax
    pop edi
    pop esi
    ret

    
shift5left:

    mov al, [es:esi + 5]   ; Get pixel 5 positions to the left
    mov [es:esi], al     ; Store it
    inc esi

    ret

shift1605left:


    cmp esi, 62394
    
    jae .other

    mov al, [es:esi + 1605]   ; Get pixel 5 positions to the left
    mov [es:esi], al     ; Store it  
    inc esi
    ret


.other:
    mov al, [bg_color]
    mov byte [es:esi], al
    inc esi
    ret










;shift page_data one byte at a time from the front from the cursor xy position
;moves to the left overwriting the value on the left as well.
;shifts asciis in page_data left
shift_page_data_back:

    push esi
    push eax
    push ecx
    push edx
    push ebx
    push edi

  
    mov esi, page_data
    


    mov eax, [cursor_offsety]
    mov edx, 0
    mov ebx, 6
    div ebx
    imul eax, 64
    add esi, eax


    mov eax, [cursor_offsetx]
    mov edx, 0
    mov ebx, 5
    div ebx 
    add esi, eax


    sub esi, 1


.shifting_loop:
    
    
    cmp esi, page_data_end-1
    je .end

    mov al, [esi + 1]
    mov [esi], al
    inc esi

    jmp .shifting_loop


.end:

    mov byte [esi], 0
    mov byte [esi + input_size - cursor_left], 0
    pop edi
    pop ebx
    pop edx
    pop ecx
    pop eax
    pop esi
    
    ret














;shift the bytes in the input buffer from offset input_size - cursor_left, 
;shifts from front to back, overwrite the first byte
;shifts things left
shift_input_buffer_back:


    push esi
    push eax
    push ecx
    push edx
    push ebx
    push edi


    mov esi, input_buffer
    add esi, [input_size]
    sub esi, [cursor_left]
    sub esi, 1


.shifting_loop:
    
    
    cmp byte [esi + 1], 0
    je .end

    mov al, [esi + 1]
    mov [esi], al
    inc esi
    
    jmp .shifting_loop


.end:


    mov byte [esi], 0

    pop edi
    pop ebx
    pop edx
    pop ecx
    pop eax
    pop esi
    
    ret



;;
;;
;;
;;The Label that runs when keyword new_file() is run
;;
;;
;;
;;What this file is going to be is saved by index page_number * 2304 for offset
;;from 0xCFFFF in memory to 0xFFFFF is defined as a paging space.
;;
;;
;;
;;Im going to make it so the last line is the name of the file,
;;later will try to implement a   open_file(name) to open a file by the name in
;;its first or last row of ascii saved in the 2304 bytes. 






new_file_main:

    ;set file_detection so you can load_file() 
    mov dword [file_detected], 1
    call clear_screen
    call clear_page_data
    call reset_all_params

    cmp dword [load_file], 1
    je .load_file
    
    jmp .top_of_file_loop

.load_file:
    
    push esi
    mov esi, saved_page
    call print_page
    pop esi


    call load_state
    jmp .file_loop
  


.top_of_file_loop:


    ;;this is printing the line number with .
    ;;print row value
    push esi 
    mov esi, [row]
    call print_hex_as_decimal
    pop esi


    
    push eax
    mov al, 46
    call print_char
    call next_char
    pop eax
    

.file_loop:

    
    
    call toggle_cursor_color
    call draw_cursor



    in al, 0x64
    test al, 1
    jz .file_loop


    in al, 0x60
    test al, 0x80
    jnz .key_release



    cmp al, 0x2A ;left shift
    je .shift_press


    cmp al, 0x1D
    je .control_press


    mov ah, al
    movzx ebx, ah


    cmp byte [shift_pressed], 1
    je .use_shift_table

    mov al, [scancode_to_ascii + ebx]
    jmp .next

.use_shift_table:
    mov al, [scancode_to_ascii_left_shift + ebx]
    jmp .next




.shift_press:
    mov byte [shift_pressed], 1    ; Set shift flag
    jmp .file_loop                 ; Don't display anything


.control_press:
    mov byte [cntrl_pressed], 1    ; Set shift flag
    jmp .file_loop                 ; Don't display anything



    
.key_release:
    and al, 0x7F        ; Remove the release bit
    cmp al, 0x2A        ; Left shift release
    je .shift_release

    cmp al, 0x1D
    je .control_release

    cmp al, 0x36        ; Right shift release
    je .shift_release

    jmp .file_loop      ; Ignore other key releases
    
.shift_release:
    mov byte [shift_pressed], 0    ; Clear shift flag
    jmp .file_loop   


.control_release:
    mov byte [cntrl_pressed], 0    ; Clear shift flag
    jmp .file_loop   




.next:


    cmp byte [cntrl_pressed], 1
    je .cntrl_save


    cmp byte ah, 0x1C  ; enter pressed
    je .enter_press
    cmp byte ah, 0x4D   ;right arrow
    je .rightarrow
    cmp byte ah, 0x4B   ;left arrow
    je .leftarrow
    cmp byte al, 0x08   ;backspace
    je .backspace

    jmp .nosaveyet

.cntrl_save:
    cmp byte al, 0x73  ; cntrl s
    je .save_page_and_jump_kernel

    jmp .file_loop




;;SAVE THE PAGE 2112 bytes.
.save_page_and_jump_kernel:


    call move_page_to_memory
    call save_state
    call clear_screen
    call clear_page_data
    call reset_all_params
    mov dword [load_file], 0

    jmp kernel




    ;;ESSENTIALLY BELOW IS THE LIMIT OF THE VALUE IM ENTERING
    ;; THERE IS SPACE HERE TO HAVE A BACK PAGE NEXT PAGE PER new_file()
    ;;ESSENTIALLY, IF x_offset equal or greater 312 and the text limit has
    ;;touched the end of row. and then save_page and continue, then
    ;; when shifting, just shift all the pages.
    ;;although shift_left and shift_right are hardcoded so the only thing you need
    ;; to do is pass variables for the label of a page instead.

.nosaveyet:

    cmp dword [x_offset], 315
    jne .continue
    cmp dword [row], 32
    jne .continue
    jmp .file_loop      ; at last char, don't allow more input


    ;;have jge conditions above,
    ;;then instead of jump .file_loop when at limits
    ;;save page and then
    ;jmp .continue

    ;;then later implement something to shift every page on inputs
    


;handling enter press
.enter_press:
    


    ;;dont allow enter past row limit cause itll go to next page and reset with new_line
    cmp dword [row], 32 ; reset cursor left movement
    je .file_loop


    call draw_blank
    call erase_cursor
    call new_line


    push eax
    push edx
    push ecx
    mov eax, [x_offset]
    mov edx, 0
    mov ecx, 5
    div ecx
    mov dword [input_size], eax
    mov eax, [y_offset]
    mov edx, 0
    mov ecx, 6
    div ecx
    imul eax, 64
    add dword [input_size], eax
    pop ecx
    pop edx
    pop eax


    


    mov dword [cursor_left], 0 ; reset cursor left movement
    call cursor_to_text


    jmp .top_of_file_loop


    


;Hnadling input.
.continue:

    cmp dword [cursor_left], 0
    jne .continue2
    inc dword [input_size]


    ;else
    call print_char
    call next_char







    jmp .continue3




;input if cursor_left>0 meaning that you are inputting wihting the string you entered already
.continue2:

    ;temporarily fixes the bug that if the cursor is at the end of line but 
    ;cursor_left > 0 means that there is no wrapping for line shifts so you must just cut the input off at the end of line
    ;in the case cursor_left > 0 otherwise its fine to take input at that posiition.
    cmp dword [cursor_offsetx], 315
    jge .file_loop

    call shifter_right


.continue3:
    jmp .file_loop




;handling backspace  from end of line
.backspace:

    cmp dword [cursor_left], 0
    jne .backspace2

    ;size of input buffer is none, jump. to the top of taking inputs again
    cmp dword [input_size], 0
    je .file_loop


    ;sub buffer size by 1
    sub dword [input_size], 1

    
    ;call backspace for visually drawing
    ;call backspace
    call draw_blank_at_cursor
    call decrement_position
    call draw_blank_at_cursor
    jmp .file_loop






;backspace if inside of the input buffer meaning cursor_left > 0
.backspace2:

    ;no more backspace, jump to mainloop if the cursor_left has backed enough to be at input_size
    push eax
    mov eax, [cursor_left]
    cmp dword [input_size], eax
    pop eax
    je .file_loop

    call shift_left
    jmp .file_loop






;handling right arrow press for moving through input buffer.
.rightarrow:
    call move_cursor_right
    jmp .file_loop




;handling left arrow press for moving through input buffer.
.leftarrow:
    call move_cursor_left
    jmp .file_loop



.hang:
    jmp .hang



















reset_all_params:
    mov dword [cursor_offsetx], 0
    mov dword [cursor_offsety], 0
    mov dword [x_offset], 0
    mov dword [y_offset], 0
    mov dword [cursor_left], 0
    mov dword [row], 0
    mov dword [input_size], 0
    mov dword [cntrl_pressed], 0
    ret




save_state: 
    mov eax, [cursor_offsetx]
    mov dword [saved_state], eax
    
    mov eax, [cursor_offsety]
    mov dword [saved_state + 4], eax

    mov eax, [x_offset]
    mov dword [saved_state + 8], eax

    mov eax, [y_offset]
    mov dword [saved_state + 12], eax

    mov eax, [cursor_left]
    mov dword [saved_state + 16], eax

    mov eax, [row]
    mov dword [saved_state + 20], eax
    
    mov eax, [input_size]
    mov dword [saved_state + 24], eax

    ret





load_state:
    
    mov eax, [saved_state]
    mov dword [cursor_offsetx], eax
    
    mov eax, [saved_state + 4]
    mov dword [cursor_offsety], eax

    mov eax, [saved_state + 8]
    mov dword [x_offset], eax

    mov eax, [saved_state + 12]
    mov dword [y_offset], eax

    mov eax, [saved_state + 16]
    mov dword [cursor_left], eax

    mov eax, [saved_state + 20]
    mov dword [row], eax
    
    mov eax, [saved_state + 24]
    mov dword [input_size], eax


    ret



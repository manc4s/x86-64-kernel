


;;
;;This file contains printall_colours() keyword comparison,
;;if printall_colours is called, print 255 color optiosn form 0x00 to 0xFF
;;
;;set_bg_colour(imm32) can be input
;;set_text_colour(imm32) can be input
;;
;;  If a user doesnt input printall_colours, will also check for set_bg_colour
;; and will check for set_text_colour, if either are found after parsing by 
;; ex. loops through terms adding to zero terminated buffer, finds '(', moves on to next temr
;; when finds ')' analyzses the first term entered, if its equal to either of the following keywords
;; set_bg_colour or set_text_colour, then it will convert the string in the second term
;; to hex 32 bit, it will compare that value to 255, if less than, then it will move te lower byte
;; into bg color or text color respectively.
;; otherwise, print error color wrong, or if the first term doesnt match, keywords doesnt exist.




check_print_colour_keywords:
    
    push esi
    push edi
    ;compare input with keyword 1 
    mov esi, input_buffer
    mov edi, keyword5
    call compare_string3
    pop esi
    pop edi

    cmp eax, 1
    je .return




    push esi
    mov esi, input_buffer
    call colour_parser
    pop esi

    push esi
    mov esi, val_1_buffer
    call print_string
    call new_line
    mov esi, val_2_buffer
    call print_string
    call new_line
    pop esi


.return:

    ret







;;prints all the colours form 0-255 numbering them
printall_colours:


    push eax
    push ebx
    push esi



.loopuntil255:
    mov al, [hex_byte_to_colour_to_screen]
    mov bl, al

    mov esi, hex_byte_to_colour_to_screen
    call print_hex_as_decimal3

    mov al, '.'
    call print_char
    call next_char

    mov al, bl
    call draw_selected_colour


    inc byte [hex_byte_to_colour_to_screen]
    cmp bl, 254
    jbe .loopuntil255


    

    pop esi
    pop ebx
    pop eax
    ret




;;draws a space using print_char at xoffset yoffset
draw_selected_colour:

    
    mov [bg_color], al
    mov [text_color], al
    
    mov al, 32  ;blank space
    call print_char
    call next_char
    call next_char
    

    mov al, [bg_revert]
    mov [bg_color], al
    mov al, [text_revert]
    mov [text_color], al
    
    ret















colour_parser:
    push ecx
    push esi
    push ebx
    push eax




    push ecx
    push edi
    mov ecx, 10
    mov edi, val_1_buffer
.clear_1:
    mov byte [edi], 0
    inc edi
    loop .clear_1

    mov ecx, 10
    mov edi, val_2_buffer
.clear_2:
    mov byte [edi], 0
    inc edi
    loop .clear_2
    pop edi
    pop ecx


.parser_loop:

    mov byte al, [esi]


    cmp al, 0
    je .end


    cmp al, '('
    jne .not_bracket_open
    inc byte [opcode_recieved]
    mov dword [index_into_term_buffers], 0

    jmp .skip

.not_bracket_open:

    ;;reached the end of term 2
    cmp al, ')'
    je .end



.continue:

    mov ebx, [index_into_term_buffers]
    
    ;;currently the largest instruction possible is 4 bytes of data
    ;;so 0xXXXXXXXX, max size 8 for the buffers that are ssize 10 rn
    ;;only set up for imm32
 
    
    
    cmp byte [opcode_recieved], 0
    je .val1_buffer

    cmp byte [opcode_recieved], 1
    je .val2_buffer


    jmp .skip


    
.val1_buffer:
    mov byte [val_1_buffer + ebx], al
    jmp .end_of_buffers


.val2_buffer:

    ;;hex value cant be more thatn 8 digits for 32 bits
    cmp ebx, 7   ;size larger than 8 its definitely too large for input buffer instructions in x86
    ja .error

    mov byte [val_2_buffer + ebx], al
    

    ;;looking for 0x
    push esi
    push edi
    mov esi, val_2_buffer
    mov edi, hex_prefix
    call compare_string3
    pop edi
    pop esi


    cmp eax, 1
    jne .skip_buffer_reset
    mov dword [index_into_term_buffers], 0 ;reset 3rd term buffer to ignore 0x part


    push ecx
    push edi
    mov ecx, 10
    mov edi, val_2_buffer
    .clear_2_1:
        mov byte [edi], 0
        inc edi
        loop .clear_2_1

    

    pop edi
    pop ecx



    jmp .skip



.skip_buffer_reset:
    
    
    jmp .end_of_buffers








.end_of_buffers:

    inc dword [index_into_term_buffers]
    jmp .skip




.skip:
    inc esi
    jmp .parser_loop


.error:
     ;error
    push esi
    mov esi, error_hexval_notvalid
    call print_string
    pop esi
    call new_line


    push ecx
    push edi
    mov ecx, 10
    mov edi, val_2_buffer
    .clear_2_2:
        mov byte [edi], 0
        inc edi
        loop .clear_2_2



    mov ecx, 10
    mov edi, val_1_buffer
    .clear_1_1:
        mov byte [edi], 0
        inc edi
        loop .clear_1_1

    pop edi
    pop ecx


.end:

    mov dword [index_into_term_buffers], 0
    mov byte [opcode_recieved], 0


    pop eax
    pop ebx
    pop esi
    pop ecx
    ret
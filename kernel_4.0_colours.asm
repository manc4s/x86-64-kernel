


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

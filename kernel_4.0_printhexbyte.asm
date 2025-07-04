



;;
;;printhexbyte
;;
;;prints byte long hex passed through ax
;;ex. ax = 0x75
;;prints to the screen '0','x','7','5'






;;pass the byte long value you want to print to ax before call
printhexbyte:

    push eax
    push ebx
    push ecx



    push esi
    mov esi, hex_prefix
    call print_string
    pop esi
    
    mov bl, al
    shr al, 4

    mov al, [hex_to_string + eax]
    call print_char
    call next_char
    
    
    and bl, 0x0F
    movzx eax, bl
    mov al, [hex_to_string + eax]
    call print_char
    call next_char


    pop ecx
    pop ebx
    pop eax
    ret


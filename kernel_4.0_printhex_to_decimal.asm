;;
;;
;;Runs and prints the hex in eax as a decimal to the screen.
;;example. 0x55 - 85, 0xff - 255, 0x009 - 9




;;esi contains the hex to print
print_hex_as_decimal:

    push eax
    push ebx
    push ecx
    push edx
    push esi


    mov ebx, 1
    mov ecx, 9     ;10^9 for protected mode max 10 digits in decimal, long mode max 20 digits in decimal so 10^19
.10exponent:
    imul ebx, 10
    loop .10exponent



.divide_ten_multiplier:
    
    mov eax, esi
    mov edx, 0
    div ebx
    push edx
    push ebx


    mov al, [hex_to_ascii + eax]  ;eax is result by dividing by 10^n

    ;;value found used to be flipped to 1 when finding the first non zero
    ;;ex 000009 it will not print the zeros unitl 9, but
    ;; 20244 will print 20244
    cmp dword [value_found], 0
    je .check

    call print_char
    call next_char

    jmp .continue

.check:
    cmp al, 48
    je .continue
    
    mov dword [value_found], 1
    call print_char
    call next_char

.continue:
    pop ebx
    pop esi  ;becomes remainder

    cmp ebx, 1
    je .not_another_loop


    mov eax, ebx
    mov edx, 0
    mov ecx, 10
    div ecx
    mov ebx, eax

    jmp .divide_ten_multiplier


.not_another_loop:
   
    cmp dword [value_found], 0
    jne .end

    mov al, [hex_to_ascii]
    call print_char
    call next_char


.end:

    mov dword [value_found], 0 ;reset for next time its called
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

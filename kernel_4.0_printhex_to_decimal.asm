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






print_hex_as_decimal2:

    push eax
    push ebx
    push ecx
    push edx
    push esi

    mov ebx, 1
    mov ecx, 9     ; Start with 10^9
.10exponent:
    imul ebx, 10
    loop .10exponent

.divide_ten_multiplier:

    movzx eax, byte [esi]    ; Load value to convert
    mov edx, 0
    div ebx           ; eax = quotient, edx = remainder
    push edx          ; Save remainder
    push ebx          ; Save divisor

    cmp eax, 10       ; Ensure valid index into hex_to_ascii
    jl .valid_digit
    mov al, '?'       ; Fallback character for invalid index
    jmp .skip_ascii
.valid_digit:
    mov al, [hex_to_ascii + eax]
.skip_ascii:

    cmp dword [value_found], 0
    je .check

    call print_char
    call next_char
    jmp .continue

.check:
    cmp al, 48        ; Is it '0'?
    je .continue

    mov dword [value_found], 1
    call print_char
    call next_char

.continue:
    pop ebx           ; Restore divisor
    pop edx           ; Restore remainder

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
    mov dword [value_found], 0
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret






;;prints only a byte long hex at a position, change size if you want larger
;; hex_to_decimal_3_helper is used so that [esi] is never changed but still keeps the ease of updating the hex 
print_hex_as_decimal3:

    push eax
    push ebx
    push ecx
    push edx
    push esi
    ;movzx eax, byte [esi]
    ;push eax
    ;movzx eax, byte [esi+1]
    ;push eax

    movzx eax, byte [esi]
    ;;hextodecimal3 helper so that i can edit [esi] without affecting the label i want to print out
    mov [hex_to_decimal_3_helper], eax

    mov ebx, 1
    mov ecx, 9     ; Start with 10^9
.10exponent:
    imul ebx, 10
    loop .10exponent

.divide_ten_multiplier:

    movzx eax, byte [hex_to_decimal_3_helper]
    mov edx, 0
    div ebx               ; eax = digit, edx = remainder
    mov [hex_to_decimal_3_helper], edx        ; update value for next digit extraction

    cmp eax, 10
    jl .valid_digit
    mov al, '?'           ; fallback if out of bounds
    jmp .skip_ascii
.valid_digit:
    mov al, [hex_to_ascii + eax]
.skip_ascii:

    cmp dword [value_found], 0
    je .check

    call print_char
    call next_char
    jmp .continue

.check:
    cmp al, 48            ; is '0'
    je .continue

    mov dword [value_found], 1
    call print_char
    call next_char

.continue:
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
    mov dword [value_found], 0
    
    ;pop eax
    ;mov [esi + 1], al
    ;pop eax
    ;mov [esi], al
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
;;string related functions
;;
;;
;;
;;
;;
;;
;;
;;






;;puts 0 in eax if string in esi and edi are not equal
;; 1 if equal
compare_string3:

 
    ;loop through each byte
    mov al, [esi]
    mov bl, [edi]

    cmp al, 0
    jne .next

    cmp bl, 0
    jne .next

    ;they both reach the zero end,ex. to avoid he matching with hello
    jmp .doneloop

.next:
    ;compare bytes
    cmp al, bl
    je .continue

    ;strings are not equal
    mov eax, 0
    ret

.continue:
    
    inc esi
    inc edi
    jmp compare_string3
    

.doneloop:
    ;strings are equal
    mov eax, 1
    ret


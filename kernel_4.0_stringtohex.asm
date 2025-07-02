


;;
;;turn a string to a hex.
;;
;;pass string to esi, ex 0x213F
;;  0x3 createsw a dd 0x3 so it can be called into eax as a dword, its always turned into dwords.
;; but 0xGHT   flags, error_converting as 1
;; accepts up to 8 digits so '12383239',0 zero terminated, any more digits and itl just do the first 8 from right to left



stringtohex:
    push eax
    push ebx
    push esi


    mov byte [error_converting], 0


    ;;esi contains a zero terminated string, assume 0x was parsed off
    ;; looping through something of the sort '0GH4' - error or 'AF67' - creates 0x0000AF67
    mov ebx, 0


.character_loop:

    mov byte al, [esi]
    cmp al, 0
    je .character_loopend

    call ascii_to_hex
    cmp al, 0xff
    je .error_wasfound

    shl ebx, 4
    or bl, al

    

    inc esi
    jmp .character_loop




.character_loopend:
    mov dword [hex_created], ebx



.error_wasfound:


    pop esi
    pop ebx
    pop eax
    ret

















; Converts ASCII '0'-'9', 'a'-'f', 'A'-'F' → hex value (0-15)
; Input: AL = ASCII char
; Output: AL = hex value (0–15), or 0xFF if invalid

ascii_to_hex:
    cmp al, '0'
    jb .invalid
    cmp al, '9'
    jbe .num
    cmp al, 'A'
    jb .lower
    cmp al, 'F'
    jbe .upper
    cmp al, 'a'
    jb .invalid
    cmp al, 'f'
    jbe .lower
    jmp .invalid

.num:
    sub al, '0'
    ret

.upper:
    sub al, 'A'
    add al, 10
    ret

.lower:
    sub al, 'a'
    add al, 10
    ret

.invalid:
    
    mov al, 0xff
    push esi
    mov esi, equal
    call print_string
    pop esi
    call new_line
    mov byte [error_converting], 1
    ret


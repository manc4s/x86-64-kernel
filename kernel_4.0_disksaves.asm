





;;;
;;; File will contain writing to disk via ATA ports 0x1F0 - 0x1F7 in protected mode
;;;





;;
;;Colour saves
;;will save the bg colour and the text colour if changed.
;;saves the LBA129_savedata to sectore 129 (512 bytes) containing the changes 
;;



LBA129_coloursaves:
    push edi
    push eax
    push esi
    push edx
    push ecx
    push es

    ; --- ATA software reset ---
    mov dx, 0x3F6       ; DCR / alt-status port
    mov al, 0x04        ; set SRST (Software Reset) bit
    out dx, al

    xor al, al
    out dx, al          ; clear SRST

    

; --- Wait for BSY=0 + RDY=1 ---
.ready_wait:

    ; --- 400ns delay ---
    in al, dx
    in al, dx
    in al, dx
    in al, dx
    in al, dx
    test al, 0x80    ; BSY
    jnz .ready_wait
    test al, 0x40    ; RDY
    jz .ready_wait



    mov edi, LBA129_savedata


    ; --- Setup ports and issue command ---
    mov dx, 0x1F2
    mov al, 1            ; sector count = 1
    out dx, al

    mov dx, 0x1F3
    mov al, 0x81
    out dx, al

    mov dx, 0x1F4
    mov al, 0 ; LBA mid
    out dx, al

    mov dx, 0x1F5
    mov al, 0
    out dx, al

    mov dx, 0x1F6
    mov al, 0xE0         ; master | LBA mode | high nibble 0000
    out dx, al

    mov dx, 0x1F7
    mov al, 0x20         ; READ SECTOR
    out dx, al




    ;push esi
    ;mov esi, got_to_here1    ;;got to read_sector
    ;call print_string
    ;pop esi
    ;call new_line



    ; --- 400ns delay ---
    in al, dx
    in al, dx
    in al, dx
    in al, dx


.wait_ready:
    in al, dx
    test al, 0x01        ; ERR
    jnz .read_fail
    test al, 0x20        ; DF
    jnz .read_fail
    test al, 0x80        ; BSY
    jnz .delay_and_retry
    test al, 0x08        ; DRQ
    jz .delay_and_retry
    jmp .ready

.delay_and_retry:
    in al, dx
    in al, dx
    in al, dx
    in al, dx

    
    ;push esi
    ;mov esi, got_to_here3
    ;call print_string
    ;pop esi
    ;call new_line
    jmp .wait_ready

.ready:




    
    ;push esi
    ;mov esi, got_to_here2
    ;call print_string
    ;pop esi
    ;call new_line


    mov ax, 0x10
    mov es, ax

    ; --- Read 512 bytes to ES:EDI ---
    mov dx, 0x1F0
    mov cx, 256
    rep insw



    mov ax, 0x20
    mov es, ax
    ;push esi    
    ;mov esi, got_to_here3
    ;call print_string          ;; read correctly
    ;pop esi
    ;call new_line



    pop es
    pop ecx
    pop edx
    pop esi
    pop eax
    pop edi
    ret


.read_fail:

    
    push esi
    mov esi, got_toerror
    call print_string          ;; read correctly
    pop esi
    call new_line


    
    pop es
    pop ecx
    pop edx
    pop esi
    pop eax
    pop edi
    ret







printall_save:
    push eax
    push esi
    push ecx


    mov esi, LBA129_savedata
    mov ecx, 512



.printloop:
    ;mov al, [esi]
    call print_hex_as_decimal3
    inc esi
    loop .printloop



    pop ecx
    pop esi
    pop eax
    ret
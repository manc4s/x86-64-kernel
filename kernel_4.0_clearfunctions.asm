;;drawing and clearing screen data and visuals
;;
;;
;;
;;
;;clear_screen()       ;clears screen visually with [bg_color]
;;clear_page_data()     ;clears ascii glyphs in page_data to page_data_end
;;
;;
;;
;;







;;clears the screen with a color passed to al. 
;;clears visually
clear_screen:
    push edi  ;; preserve
    push ecx

    mov edi, 0                ; Start at offset 0 (row 0)
    mov ecx, 320*200              ; 320 pixels in the first row
    mov al, [bg_revert]    ;selected bg color in data, byte long        ; Color 00011100 (28),
                        ;;revert because if printall_colours is called, bg_colour may be different

.fill_row:
    mov [es:edi], al
    inc edi
    loop .fill_row


    pop ecx
    pop edi
    ret







;;clears the asciis that are on every glyph for 2304  bytes
;;should be 2304
;;not always a visual change if not changing screen visually.
clear_page_data:

    push esi
    push eax
    push ecx

    mov esi, page_data     ; start of buffer
    mov ecx, 2112          ; number of bytes
    xor al, al            ; value to write (0)

.clear_loop:
    mov [esi], al
    inc esi
    loop .clear_loop



    pop ecx
    pop eax
    pop esi
    ret


end:

.hang:
    jmp .hang 









move_page_to_memory:

    push esi ;move from label
    push edi ;move to label
    push ecx
    push es

    mov ax, ds           ; Set ES = DS (your data segment)
    mov es, ax

    cld            
    mov esi, page_data
    mov edi, saved_page                 ; clear direction flag
    mov ecx, 2304
    rep movsb                       ; copy ECX bytes from [ESI] to [EDI]


    pop es
    pop ecx
    pop edi
    pop esi
    ret
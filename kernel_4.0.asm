;;
;;
;;
;;
;; main label
;;
;;
;;
;;
;;


ORG 0x10000


[bits 32]
protected_start:
    ;; Set up segments
    ; Set up segment registers
    mov ax, 0x10     ; data segment selector = index 2 * 8
    mov ds, ax
    mov fs, ax
    mov gs, ax

    mov ax, 0x18
    mov ss, ax

    mov esp, 0x101000    ;; Top of your stack segment

    
    ;track location where VRAM is for 13 hour mode
    mov ax, 0x20
    mov es, ax
    

    call clear_screen
    call clear_page_data
    
    
    ;entered kernel message
    mov esi, entered
    call print_string
    call new_line
    
    
    
    
    
    jmp kernel

    


kernel:



main:
    mov esi, shell_line
    call print_string
    mov dword [input_size], 0
    


.main_loop:

    
    call toggle_cursor_color
    call draw_cursor





    in al, 0x64
    test al, 1
    jz .main_loop


    in al, 0x60
    test al, 0x80
    jnz .key_release


    cmp al, 0x2A ;left shift
    je .shift_press



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
    jmp .main_loop                 ; Don't display anything
    
.key_release:
    and al, 0x7F        ; Remove the release bit
    cmp al, 0x2A        ; Left shift release
    je .shift_release
    cmp al, 0x36        ; Right shift release
    je .shift_release
    jmp .main_loop      ; Ignore other key releases
    
.shift_release:
    mov byte [shift_pressed], 0    ; Clear shift flag
    jmp .main_loop   




.next:

    cmp byte ah, 0x1C  ; enter pressed
    je .enter_press
    cmp byte ah, 0x4D   ;right arrow
    je .rightarrow
    cmp byte ah, 0x4B   ;left arrow
    je .leftarrow
    cmp byte al, 0x08   ;backspace
    je .backspace


    cmp dword [x_offset], 315
    jne .continue
    cmp dword [row], 32
    jne .continue
    jmp .main_loop      ; at last char, don't allow more input









;Hnadling input.
.continue:

    cmp dword [cursor_left], 0
    jne .continue2

    cmp dword [input_size], 999    ;max byte input allowed.
    jge .main_loop


    push ebx
    mov ebx, [input_size]
    mov byte [input_buffer + ebx], al
    mov byte [input_buffer + ebx + 1], 0  ;always zero terminated.
    pop ebx
   
    inc dword [input_size]


    ;else
    call print_char
    call next_char







    jmp .continue3




;input if cursor_left>0 meaning that you are inputting wihting the string you entered already
.continue2:

    ;maks input string, even if you are entering when cursor_left>0.
    cmp dword [input_size], 999
    jge .main_loop

    ;temporarily fixes the bug that if the cursor is at the end of line but 
    ;cursor_left > 0 means that there is no wrapping for line shifts so you must just cut the input off at the end of line
    ;in the case cursor_left > 0 otherwise its fine to take input at that posiition.
    cmp dword [cursor_offsetx], 315
    jge .main_loop


    call shift_right




.continue3:

    jmp .main_loop



.random:
    call clear_screen
    jmp .hang



;handling enter press
.enter_press:
    
    
    call draw_blank
    call erase_cursor
    call new_line


    mov dword [cursor_left], 0 ; reset cursor left movement
    call cursor_to_text



    cmp dword [input_size], 0
    je main

        
    ;; KEYWORD COMPARISONS

    push esi
    push edi
    ;compare input with keyword 1 
    mov esi, input_buffer
    mov edi, keyword1
    call compare_string3
    pop esi
    pop edi

    ;keyword 1 process if =keyword 1
    cmp eax, 1
    je new_file_main



    push esi
    push edi
    ;compare with keyword 2
    mov esi, input_buffer
    mov edi, keyword2
    call compare_string3 
    pop esi
    pop edi

    ;keyword 2 process if =keyword 2
    cmp eax, 1
    jne .noloadfile

    cmp dword [file_detected], 1
    jne .nofilecreated

    mov dword [load_file], 1
    je new_file_main



.nofilecreated:
    ;;print error message if there was no new_file() created but tried to load_file()
    push esi
    mov esi, error_file_not_detected
    call print_string
    pop esi
    call new_line
    jmp .skip_printing_output

.noloadfile:

    push esi
    push edi
    ;compare with keyword 3
    mov esi, input_buffer
    mov edi, keyword3
    call compare_string3 
    pop esi
    pop edi
    
    cmp eax, 1
    jne .keyword4
    call keywords_list
    jmp .skip_printing_output





.keyword4:

    push esi
    push edi
    ;compare with keyword 4
    mov esi, input_buffer
    mov edi, keyword4
    call compare_string3 
    pop esi
    pop edi

    cmp eax, 1
    jne .nokeywords


    ;call the assembler parse and create machine code
    ;;from input_asm to output_machine_code

    ;;testing printhexasdecimal and printhexasdecimal3
    ;push esi
    ;mov esi, [testvalue]
    ;call print_hex_as_decimal
    ;mov esi, testvalue_2
    ;;call print_hex_as_decimal3
    ;pop esi
    ;call new_line

    call myassembler




    ;;print the first 10 hex at output_machine_code as decimal seperated by spaces.
    push ecx
    mov ecx, 0
.test_assembler_output_loop:

    push esi
    mov esi, output_machine_code
    add esi, ecx
    call print_hex_as_decimal3
    pop esi
    call next_char   

    inc ecx
    cmp ecx, 30
    jl .test_assembler_output_loop
    pop ecx


    call new_line
    push ecx
    mov ecx, 0
.test_assembler_output_loop2:
    push esi
    mov esi, output_machine_code
    add esi, ecx
    push eax
    mov al, [esi]
    call printhexbyte
    pop eax
    pop esi
    call next_char   

    inc ecx
    cmp ecx, 15
    jl .test_assembler_output_loop2
    pop ecx

    call new_line

    jmp .skip_printing_output



.nokeywords:


    
    ;call new_line
    push esi
    mov esi, input_buffer
    call print_string
    pop esi
    call new_line









.skip_printing_output:

    jmp main






;handling backspace  from end of line
.backspace:

    cmp dword [cursor_left], 0
    jne .backspace2

    ;size of input buffer is none, jump. to the top of taking inputs again
    cmp dword [input_size], 0
    je .main_loop


    ;sub buffer size by 1
    sub dword [input_size], 1

    


    ;backspace needs to delete from the buffer, so the buffer most recent location will be turned to 0, the end   
    push ebx
    mov ebx, [input_size]
    mov byte [input_buffer + ebx], 0
    pop ebx
    ;------------------------------------------------------------------------------------------

    ;call backspace for visually drawing
    ;call backspace
    call draw_blank_at_cursor
    call decrement_position
    call draw_blank_at_cursor
    jmp .main_loop






;backspace if inside of the input buffer meaning cursor_left > 0
.backspace2:

    ;no more backspace, jump to mainloop if the cursor_left has backed enough to be at input_size
    push eax
    mov eax, [cursor_left]
    cmp dword [input_size], eax
    pop eax
    je .main_loop

    call shift_left
    jmp .main_loop






;handling right arrow press for moving through input buffer.
.rightarrow:
    call move_cursor_right
    jmp .main_loop




;handling left arrow press for moving through input buffer.
.leftarrow:
    call move_cursor_left
    jmp .main_loop




.hang:
    jmp .hang













%include "data_4.0.asm"
%include "kernel_4.0_clearfunctions.asm"
%include "kernel_4.0_drawtextfunctions.asm"
%include "kernel_4.0_cursorfunctions.asm"
%include "kernel_4.0_shiftingfunctions.asm"
%include "kernel_4.0_stringfunctions.asm"
%include "kernel_4.0_newfile.asm"
%include "kernel_4.0_keywords.asm"
%include "kernel_4.0_printhex_to_decimal.asm"
%include "kernel_4.0_assembler.asm"
%include "kernel_4.0_printhexbyte.asm"
%include "kernel_4.0_stringtohex.asm"
































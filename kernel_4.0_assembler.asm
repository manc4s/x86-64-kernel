
;;
;;Callable runtime assembler for x86 assembly 32 bit extended protected mode
;;
;;
;;







myassembler:

    push esi
    mov esi, ea
    call print_string
    pop esi
    call new_line


    



myassemblercontinued:

    push esi
    push edi
    ; Input setup
    mov esi, input_asm        ; ESI = start of input buffer
    call print_string
    call new_line
    mov esi, output_machine_code ; EDI = where we write machine code
    call print_string
    call new_line


    ;;seperator for testing output + visual clarity, delete later
    mov esi, seperator    
    call print_string
    call new_line                                                                                                                                                                                                                                               




    ; setup input and output.
    mov esi, input_asm

    call parser



    pop edi
    pop esi
    ret






parser:
    push ecx
    push esi
    push eax


.parser_loop:

    mov byte al, [esi]


    cmp al, 0
    je .parser_loop_end


    cmp al, ' '
    jne .not_space

    inc byte [opcode_recieved]
    mov dword [index_into_term_buffers], 0

    jmp .skip

.not_space:


    cmp byte [opcode_recieved], 1
    je .check_register_to_memory



    cmp byte [opcode_recieved], 2
    je .check_immediate_value

    jmp .continue


.check_register_to_memory:
    cmp al, '['
    je .register_to_memory
    ;je .skip

    cmp al, ']'
    je .register_to_memory
    ;je .skip

    cmp al, ','
    je .skip


    
    
    


.check_immediate_value:
    
    ;cmp byte [immediate_value], 1
    ;je .continue


    cmp al, '['
    je .register_to_memory2

    cmp al, ']'
    je .register_to_memory2

    push esi
    push edi
    push eax

    mov esi, val_3_buffer
    mov edi, hex_prefix
    call compare_string3
    mov ebx, eax   ;save eax into ebx
    pop eax
    pop edi
    pop esi

    cmp ebx, 1
    je .immediate_found




.continue:

    ;call print_char
    ;call next_char
    ;call new_line

    mov ebx, [index_into_term_buffers]
    
    ;;currently the largest instruction possible is 4 bytes of data
    ;;so 0xXXXXXXXX, max size 8 for the buffers that are ssize 10 rn
    ;;only set up for imm32
    cmp ebx, 7   ;size larger than 8 its definitely too large for input buffer instructions in x86
    ja .error
    
    
    cmp byte [opcode_recieved], 0
    je .val1_buffer

    cmp byte [opcode_recieved], 1
    je .val2_buffer

    cmp byte [opcode_recieved], 2
    je .val3_buffer

    jmp .skip


    
.val1_buffer:
    mov byte [val_1_buffer + ebx], al
    jmp .end_of_buffers
.val2_buffer:
    mov byte [val_2_buffer + ebx], al
    jmp .end_of_buffers
.val3_buffer:
    mov byte [val_3_buffer + ebx], al

.end_of_buffers:

    inc dword [index_into_term_buffers]
    jmp .skip






.register_to_memory:
    mov byte [register_to_memory], 1
    jmp .skip

.register_to_memory2:
    mov byte [register_to_memory2], 1
    jmp .skip

.immediate_found:
    mov byte [immediate_value], 1
    mov dword [index_into_term_buffers], 0 ;reset 3rd term buffer to ignore 0x part
    jmp .continue


.skip:

    inc esi
   

    ;compare the opcode_recieved with 2.
    ;while its 2 it should keep going, once 3 its at the end of first instruction
    cmp byte [opcode_recieved], 3
    je .convert
    ;call convert_instruction_to_machine_code

    jmp .parser_loop

.convert:



    ;;here instead of parser loop end, convert the instruction
    ;;with current 3 buffers,
    ;;process them with convert_instruction_to_machine_code
    ;;reset all buffers, index, and enables
    ;;get next instruction by jumping to top of parser_loop
    ;;for now will just 

    call convert_instruction_to_machine_code



    ;mov byte [opcode_recieved], 0
    ;mov byte [immediate_value], 0
    ;mov byte [register_to_memory], 0
    ;mov dword [index_into_term_buffers], 0
    ; Reset all flags and buffers
    mov byte [opcode_recieved], 0
    mov byte [immediate_value], 0
    mov byte [register_to_memory], 0
    mov byte [register_to_memory2], 0
    mov dword [index_into_term_buffers], 0

    mov ecx, 10
    mov edi, val_1_buffer
    .clear_v1:
        mov byte [edi], 0
        inc edi
        loop .clear_v1

    mov ecx, 10
    mov edi, val_2_buffer
    .clear_v2:
        mov byte [edi], 0
        inc edi
        loop .clear_v2

    mov ecx, 10
    mov edi, val_3_buffer
    .clear_v3:
        mov byte [edi], 0
        inc edi
        loop .clear_v3
    
    
    ;;jmp .parser_loop for all instructions 1 by 1
    ;;jmp end to limit to one instruction ending at zero.
    ;;jmp end might be better, looping through my file, passing one line at a time might be best.
    jmp .parser_loop
    ;jmp .end


.parser_loop_end:
    call convert_instruction_to_machine_code
    jmp .end

.error:
     ;error
    push esi
    mov esi, error_term_large
    call print_string
    pop esi
    call new_line


.end:
    pop eax
    pop esi
    pop ecx
    ret







convert_instruction_to_machine_code:
    
    push esi
    mov esi, register_to_memory
    call print_hex_as_decimal3
    pop esi
    call next_char   

    
    push esi
    mov esi, register_to_memory2
    call print_hex_as_decimal3
    pop esi
    call next_char   

    push esi
    mov esi, immediate_value
    call print_hex_as_decimal3
    pop esi
    call next_char   

    ;;test output
    push esi
    mov esi, instruction_message
    call print_string
    pop esi
    push esi
    mov esi, val_1_buffer
    call print_string
    pop esi
    push eax
    mov al, ','
    call print_char
    call next_char
    pop eax
    push esi
    mov esi, val_2_buffer
    call print_string
    pop esi
    push eax
    mov al, ','
    call print_char
    call next_char
    pop eax
    push esi
    mov esi, val_3_buffer
    call print_string
    pop esi
    call new_line
    call new_line

    push eax
    push esi
    push edi
    push ebx
    push ecx



    movzx ebx, byte [register_to_memory2]
    cmp ebx, 1
    jne .nodoublebrackets
    movzx eax, byte [register_to_memory]
    cmp ebx, eax
    je .twomemoryfound

.nodoublebrackets:
    ;start with first term check.
    mov ebx, 0
.value_1_loop:

    push esi
    mov esi, val_1_buffer
    call print_string
    pop esi


   

    mov esi, val_1_buffer
    
    push ebx
    imul ebx, 4  ;cause each entry in table indexes is 32 bits 'mov', 0
    mov edi, tables_indexes
    add edi, ebx
    pop ebx

    ;mov esi, edi
    ;call print_string

    ;bl i changed in here
    push ebx
    call compare_string3
    pop ebx

    cmp eax, 1
    je .table_index_found
    jmp .index_not_found


.index_not_found:
    inc ebx

    
    cmp ebx, 3
    ja .value_1_opcode_error
    jmp .value_1_loop


.table_index_found:

    ;imul ebx, 4
    ;ebx contains the index into mov, add, sub, cmp table to identify which one
    

    cmp byte [immediate_value], 1      ;r/m , imm32
    jne .no_immediate
    cmp byte [register_to_memory], 1   ;r/m , r
    je .other_case

    ;immediate value to register   r, imm32
    mov eax, [adding_to_machine_code_index]
    mov byte cl, [immediate_value_table + ebx]  ;read the byte of machine code
    mov byte [output_machine_code + eax], cl  ;write the byte of mahcine code
    jmp .value1_processing_end


;;no immediate value found, check if r/m, r
.no_immediate:

    cmp byte [register_to_memory2], 1   ;r/m , r
    jne .continue

    ;;normal r to r/m case
    mov eax, [adding_to_machine_code_index]
    mov byte cl, [opcode_table_r_rm + ebx]  ;read the byte of machine code
    mov byte [output_machine_code + eax], cl  ;write the byte of mahcine code
    jmp .value1_processing_end

;rm, imm32 case
.other_case:

    mov eax, [adding_to_machine_code_index]
    mov byte cl, [other_case_opcode + ebx]  ;read the byte of machine code
    mov byte [output_machine_code + eax], cl  ;write the byte of mahcine code
    jmp .value1_processing_end

;;rm to r case
.continue:
    ;ebx contains index into opcode table
    mov eax, [adding_to_machine_code_index]
    mov byte cl, [opcode_table_rm_r + ebx]  ;read the byte of machine code
    mov byte [output_machine_code + eax], cl  ;write the byte of mahcine code



.value1_processing_end:
    
    ;; increment position in the output_machine_code
    inc dword [adding_to_machine_code_index]





    ;;FIND THE REST OF THE OUTPUT MACHINE CODE WITH THE TERM 2 AND 3 TO CREATE TEH RM BYTE

    ;;newline for testing
    call new_line
    mov ebx, 0
.value_2_loop:

    push esi
    mov esi, val_2_buffer
    call print_string
    pop esi

    mov esi, val_2_buffer
    
    push ebx
    imul ebx, 4  ;cause each entry in table indexes is 32 bits 'mov', 0
    mov edi, register_names
    add edi, ebx
    pop ebx

    ;mov esi, edi
    ;call print_string

    ;bl i changed in here
    push ebx
    call compare_string3
    pop ebx

    cmp eax, 1
    je .register_index_found
    jmp .register_index_not_found


.register_index_not_found:
    inc ebx

    
    cmp ebx, 7     ;;8 values in regiister names
    ja .value_2_opcode_error
    jmp .value_2_loop



.register_index_found:
    
    ;;keep track of r index fo modrm byte
    mov [r_index], ebx




;;newline for testing
    call new_line
    mov ebx, 0
.value_3_loop:

    push esi
    mov esi, val_3_buffer
    call print_string
    pop esi

    mov esi, val_3_buffer
    
    push ebx
    imul ebx, 4  ;cause each entry in table indexes is 32 bits 'mov', 0
    mov edi, register_names
    add edi, ebx
    pop ebx

    ;mov esi, edi
    ;call print_string

    ;bl i changed in here
    push ebx
    call compare_string3
    pop ebx

    cmp eax, 1
    je .register_index_found2
    jmp .register_index_not_found2


.register_index_not_found2:
    inc ebx

    
    cmp ebx, 7     ;;8 values in regiister names
    ja .value_3_opcode_error
    jmp .value_3_loop



.register_index_found2:
    
    ;;keep track of r index fo modrm byte
    mov [r_m_index], ebx
   
    ;;ch is the mod RM byte
    mov cl, 00000000b


.create_modRM_byte:

    cmp byte [immediate_value], 1      ;r/m , imm32
    jne .no_immediate2
    cmp byte [register_to_memory], 1   ;r/m , r
    je .other_case2


    ;;THIS CASE IS DIFFERENT FOR IM32 CHANGE WHEN U CAN INTERPRET HEX VALUES
    ;;
    ;;case im32 to register mod bits are 11
    or cl, 00000011b
    shl cl, 3
    mov ebx, [r_m_index]
    or cl, [register_table + ebx] ;;r/m byte
    shl cl, 3
    mov ebx, [r_index]
    or cl, [register_table + ebx]
    jmp .modrmbyte_processing_end

;;no immediate value found, check if r/m, r
.no_immediate2:

    cmp byte [register_to_memory2], 1  
    jne .continue2


    ;;r, rm
    ;;memory to register
    ;;register goes first then rm
    shl cl, 3
    mov ebx, [r_index]
    or cl, [register_table + ebx] ;;r/m byte
    shl cl, 3
    mov ebx, [r_m_index]
    or cl, [register_table + ebx]
    jmp .modrmbyte_processing_end



;;im 32 case
;rm, imm32 case
.other_case2:   

    ;;immediate value to register or memory have another case here for register to register
    shl cl, 3
    ;;register cl doesnt need to be or'd mod bits are 00
    ;;cl is the same here
    mov ebx, [r_m_index]
    or cl, [register_table + ebx] ;;r/m byte
    shl cl, 3
    mov ebx, [r_index]
    or cl, [register_table + ebx]
    jmp .modrmbyte_processing_end




;;register to register?
;;memory or register to register
;;rm to r
.continue2:

    ;;register to register??
    or cl, 00000011b
    shl cl, 3
    mov ebx, [r_m_index]
    or cl, [register_table + ebx] ;;r/m byte
    shl cl, 3
    mov ebx, [r_index]
    or cl, [register_table + ebx]



  


.modrmbyte_processing_end:
    
    mov eax, [adding_to_machine_code_index]
    mov byte [output_machine_code + eax], cl  ;write the byte of mahcine code

    ;; increment position in the output_machine_code
    inc dword [adding_to_machine_code_index]








    ;;newline for testing
    call new_line


    jmp .end


.value_1_opcode_error:

    ;error
    push esi
    mov esi, value_1_error
    call print_string
    pop esi
    call new_line
    jmp .end



.value_2_opcode_error:

    ;error
    push esi
    mov esi, value_2_error
    call print_string
    pop esi
    call new_line
    jmp .end


.value_3_opcode_error:

    ;error
    push esi
    mov esi, value_3_error
    call print_string
    pop esi
    call new_line
    jmp .end


.twomemoryfound:
    
    ;error
    push esi
    mov esi, error2found
    call print_string
    pop esi
    call new_line
    jmp .end



.end:
    push esi
    mov esi, seperator
    call print_string
    pop esi
    call new_line

    pop ecx
    pop ebx
    pop edi
    pop esi
    pop eax
    ret


entered: db "successfully entered the kernel shell.",0 
shell_line: db "kernel-shell-v3-$", 0


x_offset: dd 0   ;current position
y_offset: dd 0
row: dd 0
cursor_offsetx: dd 0
cursor_offsety: dd 0 



bg_revert: db 0x67
bg_color: db 0x67  ;0xd5 olive green ;

text_revert: db 0x00
text_color: db 0x00  ;0f white



cursor_bg: db 0x0f
cursor_text: db 0x57
cursor_counter: dd 0   ;the ticks
cursor_left: dd 0
cursor_right: dd 0


cursor_bg_1: db 0x0f
cursor_bg_2: db 0x57







;;for testing the print hex as decimal. i have one for dd and one for db
;;but i address one with [testvalue] for dword size and the other with testvalue_2 for byte sized
testvalue: dd 0x66
testvalue_2: db 0x66
;for testing
equal: db "equal", 0
notqual: db"notequal", 0




;;kernel_4.0_assembler stuff below
;testing_labels
ea: db "entered assembler", 0
instruction_message: db "instruction being processed - ", 0

value_1_error: db "errror term 1",0
value_2_error: db "errror term 2",0
value_3_error: db "errror term 3",0
invalid_heximm32: db "invalid hex im32 passed",0
error_term_large: db "error some term too large. make sure hex passed is 32 bit or operand must be corrected.",0
seperator: db "--------------------------------------------------------------",0
error2found: db "two memory locations.",0

;testing assembly
;input_asm:db "mov edi, ebx add eax, [edx] mov eax, ebx",0
;input_asm:db "mov [edawdwi], ebx add [eax], [edx] sub eax, ebx cmp edi, [0x898989], mov 0x1283, [eax] cmp edx, [ebx] mov [eax], 0x123912",0
input_asm: db "mov [eax],  0x123912 mov esi, 0x89 add [ebx], 0x123123 sub [edx], 0x123123 cmp [edi], 0x123123",0

;input_asm:db "mov [eaxa]",0
;input_asm:db "mov eax, 0x821A ",0

adding_to_machine_code_index: dd 0 ; index into output_machine_code location
output_machine_code: times 2000 db 0


;;used int hex to decimal 3 in kernel4.0_printhex_to_decimals
hex_to_decimal_3_helper: dd 0


;;for immediate values i need to keep track of if i need to appedn another dword afterward. if so then the hex passed 
;;in imm32 case will be appended from hex created
;; this is an enable, either 1 do it or 0 dont
write_the_imm32:
    db 0



;enable bytes
opcode_recieved:
    db 0        ;0 1 2, then reset. 

immediate_value: ;true 1 false 0
    db 0        ;if 1 use immediate_value table

register_to_memory:  ; meaning second term has []
    db 0        ;1 ,eams mov r/m, reg
                ;0 means mov reg, r/m

register_to_memory2:
    db 0

error_found:
    db 0



val_1_buffer:
    times 10 db 0

val_2_buffer:
    times 10 db 0

val_3_buffer:
    times 10 db 0

index_into_term_buffers:
    dd 0



hex_prefix:
    db "0x", 0


tables_indexes:
    db "mov", 0
    db "add", 0
    db "sub", 0
    db "cmp", 0

; Opcode Table (Direction: reg←mem or mem←reg)
opcode_table_r_rm:
    db 0x8B    ; mov reg, r/m
    db 0x03    ; add reg, r/m
    db 0x2B    ; sub reg, r/m
    db 0x3B    ; cmp reg, r/m

opcode_table_rm_r:
    db 0x89    ; mov r/m, reg
    db 0x01    ; add r/m, reg
    db 0x29    ; sub r/m, reg
    db 0x39    ; cmp r/m, reg
    

immediate_value_table:
    db 0xB8    ; mov eax, imm32
    db 0x81   ;sub, cmp and add if there is an immediate value all have opcode 0x81
    db 0x81
    db 0x81
    

other_case_opcode: 
    ;immediate address to rm.
    ;is neither r/m, r
    ;and not    r, r/m 
    ;and not    r, imm32
    ;this is the condition for r/m, imm32
    db 0xC7
    db 0x81   ;sub, cmp and add if there is an immediate value all have opcode 0x81
    db 0x81
    db 0x81


;to index register_table
register_names:
    db "eax",0, 
    db "ecx",0, 
    db "edx",0,
    db "ebx",0, 
    db "esp",0, 
    db "ebp",0, 
    db "esi",0, 
    db "edi",0

; Register Table
register_table:
    db 000b    ; eax
    db 001b    ; ecx
    db 010b    ; edx
    db 011b    ; ebx
    db 100b    ; esp
    db 101b    ; ebp
    db 110b    ; esi
    db 111b    ; edi

;;indexes into both tables for term 2 & 3
r_m_index: dd 0
r_index: dd 0
opcode_index: dd 0





;;random colors
light_blue: db 0x67
olive: db 0xd5
yella: db 0x44
white: db 0x0f
pink_red: db 0x57
black: db 0x00



;;kernel_4.0_keywords
keyword1: db "new_file", '(', ')', 0
keyword1_length: dd $ - keyword1 -1

keyword2: db "load_file", '(', ')', 0
keyword2_length: dd $ - keyword2 -1
load_file: dd 0  ;if loading file or not enable in new_file_main check


keyword3: db "keywords", '(', ')', 0
keyword3_length: dd $ - keyword3 -1

keyword4: db "assembler_testing", '(', ')', 0
keyword4_length: dd $ - keyword4 -1
value_found: dd 0   ;looking for first non zero value, 1 when found




;;drawtextfunctions and cursor stuff use this.
;will retrieve ascii from page_data into here
hovering_char: db 0
;1 byte per character 64*33
;2176 or 2174 needed for overflow
page_data: times 2304 db 0      ;should be 2112 but for some reason maybe indexing something, needs 64 bytes so one extra row for safety
page_data_end:



;;kernel_4.0_newfile
file_detected: dd 0    ;;when 1 means a file was created
error_file_not_detected: db "A file was not created. Use new_file() to create one.", 0
saved_page: times 2304 db 0
saved_page_end:
saved_state: times 7 dd 0




;page_number
;will be the index from a specific address in memory to save pages to.
;example all pages are at. 0xCFFFF + offset
;offset = page_number * 2112 (2304 for now until patched)
page_nunber: dd 0     ;;not used
shift_pressed: dd 0 ;0 not pressed, 1 pressed
cntrl_pressed: dd 0 ;0 not 1 yes



;;kernel_4.0_printhexbyte
;;used in printhex as a string ex 0x7f prints as 0x7f to the screen
hex_to_string:
    db '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'

;;kernel_4.0_printhex_to_decimal
;;used in hex to decimal ex 0x65 prints as decimal eqiuvalent ot screen
hex_to_ascii:  ;0x00 - 0x09 to ascii
    db 48, 49, 50, 51, 52, 53, 54, 55, 56, 57




;;string to hex
error_converting:
    db 0

hex_created:
    dd 0









scancode_to_ascii:
    db 0, 0, 49, 50, 51, 52, 53, 54, 55, 56, 57, 48, 45, 61, 8, 0           ; 0x00–0x0F
    db 113, 119, 101, 114, 116, 121, 117, 105, 111, 112, 91, 93, 13, 0      ; 0x10–0x1F
    db 97, 115, 100, 102, 103, 104, 106, 107, 108, 59, 39, 96, 92, 0        ; 0x20–0x2F
    db 122, 120, 99, 118, 98, 110, 109, 44, 46, 47, 0, 42, 0, 32            ; 0x30–0x3F


scancode_to_ascii_left_shift:
    db 0, 0, 33, 64, 35, 36, 37, 94, 38, 42, 40, 41, 95, 43, 8, 0           ; 0x00–0x0F
    db 81, 87, 69, 82, 84, 89, 85, 73, 79, 80, 123, 125, 13, 0              ; 0x10–0x1F
    db 65, 83, 68, 70, 71, 72, 74, 75, 76, 58, 34, 126, 124, 0              ; 0x20–0x2F
    db 90, 88, 67, 86, 66, 78, 77, 60, 62, 63, 0, 42, 0, 32                 ; 0x30–0x3F

;all chars 0-128, 4x6. 
;for 13h mode, custom 4x6 font
alphabet:  

    ;32: Space
    db 0b0000,0b0000,0b0000,0b0000,0b0000,0b0000
    ; 33: !
    db 0b0010,0b0010,0b0010,0b0010,0b0000,0b0010
    ; 34: "
    db 0b0101,0b0101,0b0000,0b0000,0b0000,0b0000
    ; 35: #
    db 0b0101,0b1111,0b0101,0b1111,0b0101,0b0000
    ; 36: $
    db 0b0110,0b1010,0b0110,0b0101,0b0110,0b0000
    ; 37: %
    db 0b1100,0b1101,0b0010,0b1011,0b0011,0b0000
    ; 38: &
    db 0b0110,0b1001,0b0110,0b1001,0b0111,0b0000
    ; 39: '
    db 0b0010,0b0010,0b0000,0b0000,0b0000,0b0000
    ; 40: (
    db 0b0010,0b0100,0b0100,0b0100,0b0010,0b0000
    ; 41: )
    db 0b0100,0b0010,0b0010,0b0010,0b0100,0b0000
    ; 42: *
    db 0b0000,0b0101,0b0010,0b0101,0b0000,0b0000
    ; 43: +
    db 0b0000,0b0010,0b0111,0b0010,0b0000,0b0000
    ; 44: ,
    db 0b0000,0b0000,0b0000,0b0010,0b0100,0b0000
    ; 45: -
    db 0b0000,0b0000,0b0111,0b0000,0b0000,0b0000
    ; 46: .
    db 0b0000,0b0000,0b0000,0b0010,0b0000,0b0000
    ; 47: /
    db 0b0001,0b0010,0b0100,0b1000,0b0000,0b0000
    ; 48: 0
    db 0b0110,0b1001,0b1001,0b1001,0b0110,0b0000
    ; 49: 1
    db 0b0010,0b0110,0b0010,0b0010,0b0111,0b0000
    ; 50: 2
    db 0b0110,0b1001,0b0010,0b0100,0b1111,0b0000
    ; 51: 3
    db 0b0110,0b0001,0b0110,0b0001,0b0110,0b0000
    ; 52: 4
    db 0b0001,0b0011,0b0101,0b1111,0b0001,0b0000
    ; 53: 5
    db 0b1111,0b1000,0b1110,0b0001,0b1110,0b0000
    ; 54: 6
    db 0b0110,0b1000,0b1110,0b1001,0b0110,0b0000
    ; 55: 7
    db 0b1111,0b0001,0b0010,0b0100,0b0100,0b0000
    ; 56: 8
    db 0b0110,0b1001,0b0110,0b1001,0b0110,0b0000
    ; 57: 9
    db 0b0110,0b1001,0b0111,0b0001,0b0110,0b0000
    ; 58: :
    db 0b0000,0b0010,0b0000,0b0010,0b0000,0b0000
    ; 59: ;
    db 0b0000,0b0010,0b0000,0b0010,0b0100,0b0000
    ; 60: <
    db 0b0001,0b0010,0b0100,0b0010,0b0001,0b0000
    ; 61: =
    db 0b0000,0b0111,0b0000,0b0111,0b0000,0b0000
    ; 62: >
    db 0b0100,0b0010,0b0001,0b0010,0b0100,0b0000
    ; 63: ?
    db 0b0110,0b1001,0b0010,0b0000,0b0010,0b0000
    ; 64: @
    db 0b0110, 0b1001, 0b1011, 0b1011, 0b0110, 0b0000
    ; 65: A
    db 0b0110,0b1001,0b1111,0b1001,0b1001,0b0000
    ; 66: B
    db 0b1110,0b1001,0b1110,0b1001,0b1110,0b0000
    ; 67: C
    db 0b0110,0b1001,0b1000,0b1001,0b0110,0b0000
    ; 68: D
    db 0b1110,0b1001,0b1001,0b1001,0b1110,0b0000
    ; 69: E
    db 0b1111,0b1000,0b1110,0b1000,0b1111,0b0000
    ; 70: F
    db 0b1111,0b1000,0b1110,0b1000,0b1000,0b0000
    ; 71: G
    db 0b0110,0b1000,0b1011,0b1001,0b0111,0b0000
    ; 72: H
    db 0b1001,0b1001,0b1111,0b1001,0b1001,0b0000
    ; 73: I
    db 0b0111,0b0010,0b0010,0b0010,0b0111,0b0000
    ; 74: J
    db 0b0001,0b0001,0b0001,0b1001,0b0110,0b0000
    ; 75: K
    db 0b1001,0b1010,0b1100,0b1010,0b1001,0b0000
    ; 76: L
    db 0b1000,0b1000,0b1000,0b1000,0b1111,0b0000
    ; 77: M
    db 0b1001,0b1111,0b1111,0b1001,0b1001,0b0000
    ; 78: N
    db 0b1001,0b1101,0b1111,0b1011,0b1001,0b0000
    ; 79: O
    db 0b0110,0b1001,0b1001,0b1001,0b0110,0b0000
    ; 80: P
    db 0b1110,0b1001,0b1110,0b1000,0b1000,0b0000
    ; 81: Q
    db 0b0110,0b1001,0b1001,0b1011,0b0111,0b0000
    ; 82: R
    db 0b1110,0b1001,0b1110,0b1010,0b1001,0b0000
    ; 83: S
    db 0b0111,0b1000,0b0110,0b0001,0b1110,0b0000
    ; 84: T
    db 0b1111,0b0010,0b0010,0b0010,0b0010,0b0000
    ; 85: U
    db 0b1001,0b1001,0b1001,0b1001,0b0110,0b0000
    ; 86: V
    db 0b1001,0b1001,0b1001,0b0110,0b0100,0b0000
    ; 87: W
    db 0b1001,0b1001,0b1111,0b1111,0b1001,0b0000
    ; 88: X
    db 0b1001,0b0110,0b0100,0b0110,0b1001,0b0000
    ; 89: Y
    db 0b1001,0b0110,0b0010,0b0010,0b0010,0b0000
    ; 90: Z
    db 0b1111,0b0001,0b0110,0b1000,0b1111,0b0000
    ; 91: [
    db 0b0110,0b0100,0b0100,0b0100,0b0110,0b0000
    ; 92: '\'
    db 0b1000,0b0100,0b0010,0b0001,0b0000,0b0000
    ; 93: ]
    db 0b0110,0b0010,0b0010,0b0010,0b0110,0b0000
    ; 94: ^
    db 0b0010,0b0101,0b0000,0b0000,0b0000,0b0000
    ; 95: _
    db 0b0000,0b0000,0b0000,0b0000,0b1111,0b0000
    ; 96: `
    db 0b0100,0b0010,0b0000,0b0000,0b0000,0b0000
    ; 97: a
    db 0b0000,0b0110,0b0001,0b0111,0b0111,0b0000
    ; 98: b
    db 0b1000,0b1110,0b1001,0b1001,0b1110,0b0000
    ; 99: c
    db 0b0000,0b0111,0b1000,0b1000,0b0111,0b0000
    ; 100: d
    db 0b0001,0b0111,0b1001,0b1001,0b0111,0b0000
    ; 101: e
    db 0b0000,0b0111,0b1111,0b1000,0b0111,0b0000
    ; 102: f
    db 0b0011,0b0100,0b1110,0b0100,0b0100,0b0000
    ; 103: g
    db 0b0000,0b0111,0b1001,0b0111,0b0001,0b0111
    ; 104: h
    db 0b1000,0b1110,0b1001,0b1001,0b1001,0b0000
    ; 105: i
    db 0b0010,0b0000,0b0110,0b0010,0b0111,0b0000
    ; 106: j
    db 0b0000,0b0001,0b0000,0b0001,0b0001,0b0111
    ; 107: k
    db 0b1000,0b1010,0b1100,0b1010,0b1001,0b0000
    ; 108: l
    db 0b0110,0b0010,0b0010,0b0010,0b0111,0b0000
    ; 109: m
    db 0b0000,0b1110,0b1111,0b1001,0b1001,0b0000
    ; 110: n
    db 0b0000,0b1110,0b1001,0b1001,0b1001,0b0000
    ; 111: o
    db 0b0000,0b0110,0b1001,0b1001,0b0110,0b0000
    ; 112: p
    db 0b0000,0b1110,0b1001,0b1110,0b1000,0b1000
    ; 113: q
    db 0b0000,0b0111,0b1001,0b0111,0b0001,0b0001
    ; 114: r
    db 0b0000,0b1011,0b1100,0b1000,0b1000,0b0000
    ; 115: s
    db 0b0000,0b0111,0b0100,0b0010,0b0111,0b0000
    ; 116: t
    db 0b0100,0b1110,0b0100,0b0100,0b0011,0b0000
    ; 117: u
    db 0b0000,0b1001,0b1001,0b1001,0b0111,0b0000
    ; 118: v
    db 0b0000,0b1001,0b1001,0b0110,0b0100,0b0000
    ; 119: w
    db 0b0000,0b1001,0b1111,0b1111,0b0110,0b0000
    ; 120: x
    db 0b0000,0b1001,0b0110,0b0110,0b1001,0b0000
    ; 121: y
    db 0b0000,0b1001,0b1001,0b0111,0b0001,0b0111
    ; 122: z
    db 0b0000,0b1110,0b0010,0b0100,0b1110,0b0000
    ; 123: {
    db 0b0011,0b0010,0b1100,0b0010,0b0011,0b0000
    ; 124: |
    db 0b0010,0b0010,0b0010,0b0010,0b0010,0b0000
    ; 125: }
    db 0b1100,0b0100,0b0011,0b0100,0b1100,0b0000
    ; 126: ~
    db 0b0000,0b0101,0b1010,0b0000,0b0000,0b0000
    ; 127: (DEL, blank)
    db 0b1111,0b1111,0b1111,0b1111,0b1111,0b1111









;make space of 128 bytes, be careful of this limit later when shifting the data
input_buffer: times 2112 db 0
input_buffer_end:
input_size: dd 0








; label_names contains all label strings null-terminated
label_names:
    db "entered",0
    db "shell_line",0
    db "x_offset",0
    db "y_offset",0
    db "row",0
    db "cursor_offsetx",0
    db "cursor_offsety",0
    db "bg_revert",0
    db "bg_color",0
    db "text_revert",0
    db "text_color",0
    db "cursor_bg",0
    db "cursor_text",0
    db "cursor_counter",0
    db "cursor_left",0
    db "cursor_right",0
    db "cursor_bg_1",0
    db "cursor_bg_2",0
    db "testvalue",0
    db "testvalue_2",0
    db "equal",0
    db "notqual",0
    db "ea",0
    db "instruction_message",0
    db "value_1_error",0
    db "value_2_error",0
    db "value_3_error",0
    db "error_term_large",0
    db "seperator",0
    db "error2found",0
    db "input_asm",0
    db "adding_to_machine_code_index",0
    db "output_machine_code",0
    db "hex_to_decimal_3_helper",0
    db "opcode_recieved",0
    db "immediate_value",0
    db "register_to_memory",0
    db "register_to_memory2",0
    db "error_found",0
    db "val_1_buffer",0
    db "val_2_buffer",0
    db "val_3_buffer",0
    db "index_into_term_buffers",0
    db "hex_prefix",0
    db "tables_indexes",0
    db "opcode_table_r_rm",0
    db "opcode_table_rm_r",0
    db "immediate_value_table",0
    db "other_case_opcode",0
    db "register_names",0
    db "register_table",0
    db "r_m_index",0
    db "r_index",0
    db "light_blue",0
    db "olive",0
    db "yella",0
    db "white",0
    db "pink_red",0
    db "black",0
    db "keyword1",0
    db "keyword1_length",0
    db "hovering_char",0
    db "page_data",0
    db "page_data_end",0
    db "file_detected",0
    db "error_file_not_detected",0
    db "saved_page",0
    db "saved_page_end",0
    db "saved_state",0
    db "page_nunber",0
    db "shift_pressed",0
    db "cntrl_pressed",0
    db "input_buffer",0
    db "input_buffer_end",0
    db "input_size",0

; label_table holds their addresses in same order
label_table:
    dd entered
    dd shell_line
    dd x_offset
    dd y_offset
    dd row
    dd cursor_offsetx
    dd cursor_offsety
    dd bg_revert
    dd bg_color
    dd text_revert
    dd text_color
    dd cursor_bg
    dd cursor_text
    dd cursor_counter
    dd cursor_left
    dd cursor_right
    dd cursor_bg_1
    dd cursor_bg_2
    dd testvalue
    dd testvalue_2
    dd equal
    dd notqual
    dd ea
    dd instruction_message
    dd value_1_error
    dd value_2_error
    dd value_3_error
    dd error_term_large
    dd seperator
    dd error2found
    dd input_asm
    dd adding_to_machine_code_index
    dd output_machine_code
    dd hex_to_decimal_3_helper
    dd opcode_recieved
    dd immediate_value
    dd register_to_memory
    dd register_to_memory2
    dd error_found
    dd val_1_buffer
    dd val_2_buffer
    dd val_3_buffer
    dd index_into_term_buffers
    dd hex_prefix
    dd tables_indexes
    dd opcode_table_r_rm
    dd opcode_table_rm_r
    dd immediate_value_table
    dd other_case_opcode
    dd register_names
    dd register_table
    dd r_m_index
    dd r_index
    dd light_blue
    dd olive
    dd yella
    dd white
    dd pink_red
    dd black
    dd keyword1
    dd keyword1_length
    dd hovering_char
    dd page_data
    dd page_data_end
    dd file_detected
    dd error_file_not_detected
    dd saved_page
    dd saved_page_end
    dd saved_state
    dd page_nunber
    dd shift_pressed
    dd cntrl_pressed
    dd input_buffer
    dd input_buffer_end
    dd input_size
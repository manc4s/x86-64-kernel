
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



;for testing
equal: db "equal", 0
notqual: db"notequal", 0


;testing_labels
ea: db "entered assembler", 0

epolo: db "errror",0

;testing assembly
;input_asm:db "mov [eaxa], 0x1212 add this here",0
input_asm:db "mov [eaxa]",0
;input_asm:db "mov eax, 0x821A ",0

adding_to_machine_code_index: dd 0 ; index into output_machine_code location
output_machine_code: times 2000 db 0



hex_to_decimal_3_helper: dd 0



;enable bytes
opcode_recieved:
    db 0        ;0 1 2, then reset. 

immediate_value: ;true 1 false 0
    db 0        ;if 1 use immediate_value table

register_to_memory:  ; meaning second term has []
    db 0        ;1 ,eams mov r/m, reg
                ;0 means mov reg, r/m


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

; Mod Table (2 bits)
mod_table:
    db 00b     ; [reg]
    db 01b     ; [reg + disp8]
    db 10b     ; [reg + disp32]
    db 11b     ; reg







light_blue: db 0x67
olive: db 0xd5
yella: db 0x44
white: db 0x0f
pink_red: db 0x57
black: db 0x00




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



;will retrieve ascii from page_data into here
hovering_char: db 0
;1 byte per character 64*33
;2176 or 2174 needed for overflow
page_data: times 2304 db 0      ;should be 2112 but for some reason maybe indexing something, needs 64 bytes so one extra row for safety
page_data_end:



file_detected: dd 0    ;;when 1 means a file was created
error_file_not_detected: db "A file was not created. Use new_file() to create one.", 0
saved_page: times 2304 db 0
saved_page_end:
saved_state: times 7 dd 0




;page_number
;will be the index from a specific address in memory to save pages to.
;example all pages are at. 0xCFFFF + offset
;offset = page_number * 2112 (2304 for now until patched)
page_nunber: dd 0
shift_pressed: dd 0 ;0 not pressed, 1 pressed
cntrl_pressed: dd 0 ;0 not 1 yes




hex_to_ascii:  ;0x00 - 0x09 to ascii
    db 48, 49, 50, 51, 52, 53, 54, 55, 56, 57

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



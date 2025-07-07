





;;;
;;; File will contain writing to disk via ATA ports 0x1F0 - 0x1F7 in protected mode
;;;





;;
;;Colour saves
;;will save the bg colour and the text colour if changed.
;;saves the LBA129_savedata to sectore 129 (512 bytes) containing the changes 
;;

LBA129_write_coloursaves:
    push eax
    push esi
    push edx
    push ecx

    mov esi, LBA129_savedata      ;the 512 data relating to colour to save


    
    ;;STEP 1 for ATA
.waitforBUSYbit:
    in al, 0x1F7        ;;Status byte
    test al, 0x80       ;;check the 7th bit if its 1 or zero goes into z register flag 0x80 - 10000000b

    jnz .waitforBUSYbit  ;BSY 0 or 1. if zero not busy

    ;;BSY is 0



    ;;STEP 2 for ATA
    ;;amount of sectors X passed to al
    mov dx, 0x1F2
    mov al, 1         ;x sectors
    out dx, al        ;output number of sectors to port





    ;;STEP 3 for ATA
    ;;set up LBA 129, 129 decimal is 0x81 hex
    ;;LBA addresses are 28 bits
    ;; LBA mode E highest nibble for LBA mode, last 4 bits
    ;;controlled by ports 0x1f3 - 0x1f6

    inc dx      ;;dx = 0x1f3
    mov al, 0x81
    out dx, al


    inc dx      ;;0x1f4
    mov al, 0x00
    out dx, al


    inc dx      ;;0x1f5
    mov al, 0x00
    out dx, al

    inc dx      ;;0x1f6
    mov al, 0xE0     ;;e is the byte for LBA mode, not included in 28 bit address
    out dx, al




    ;;STEP 4 ISSUE COMMAND READ OR WRITE

    mov dx, 0x1f7
    mov al, 0x30   ;;write
    out dx, al



    ;;STEP 5 DATA REQUEST BIT
.waitforDRQbit:
    ;;wait for the data request bit to be 1 to continue
    in al, dx
    test al, 0x08     ;;00001000 - 0x08 3rd bit is DRQ bit
    jz .waitforDRQbit


    ;;DRQ bit is 1




    ;;STEP 6 LOOP through BYTES AND WRITE
    ;;expects the amount fo bytes defined above to write.

    ;;0x1f0 takes words of data

    mov dx, 0x1f0
    mov cx, 256      ;256 loops, 2 bytes at a time being passed
                    ;;256 * 2 = 512
.write_loop:
    lodsw           ;;moves word from [esi] into ax, increments esi by word
    out dx, ax
    loop .write_loop


    pop ecx
    pop edx
    pop esi
    pop eax

    ret
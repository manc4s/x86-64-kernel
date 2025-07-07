





;;;
;;; File will contain writing to disk via ATA ports 0x1F0 - 0x1F7 in protected mode
;;;





;;
;;Colour saves
;;will save the bg colour and the text colour if changed.
;;saves the LBA129_savedata to sectore 129 (512 bytes) containing the changes 
;;

LBA129_coloursaves:


    ret
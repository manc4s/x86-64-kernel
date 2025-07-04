;;
;;
;;
;;The Label that runs when keyword keyword() is input
;;
;;
;;
;;
;;
;;
;; lists keywords available in the cli










;;hardcoded to print all the keywords
keywords_list:
    
    call new_line

    push esi
    mov esi, keyword1
    call print_string
    call print_comma
    pop esi
    

    push esi
    mov esi, keyword2
    call print_string
    call print_comma
    pop esi

    push esi
    mov esi, keyword3
    call print_string
    call print_comma
    pop esi



    push esi
    mov esi, keyword4
    call print_string
    call print_comma
    pop esi

    
    push esi
    mov esi, keyword5
    call print_string
    call print_comma
    pop esi



    
    push esi
    mov esi, keyword6
    call print_string
    call print_comma
    pop esi




    
    push esi
    mov esi, keyword7
    call print_string
    call print_comma
    pop esi


    call new_line

    call new_line

    ret



print_comma:
    mov al, ','
    call print_char
    call next_char
    ret
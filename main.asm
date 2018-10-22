; Copyright (C) 2018 cmp
; Licensed under the ISC License
; Check the LICENSE file that
; was distributed with this copy.

bits 16             ; x86 considered harmful
org 0x7c00          ; We land here

jmp short start                     ; Jump to the useful bit

error: db "Something happened.", 0x0D, 0x0A, "Something happened.", 0x00

; print_srt
; Prints a 0x00 terminated string
; <- SI - string to print
print_str:
    push si         ; Yes
    push ax
    .loop:
        lodsb           ; Load another character from si
        test al, al     ; Test if al=0
        jz .exit        ; If so, jump to .exit
                        ; Otherwise, continue
        mov ah, 0x0E    ; Calling BIOS print (0x10), ah=0E
        int 0x10        ; Print char from al (BIOS)
        jmp .loop       ; Keep looping
    .exit:
        pop ax
        pop si
        ret             ; Return from function

; halt
; Halts the shit
halt:
    hlt         ; Halt it all
    jmp halt    ; Keep halting

; The DA packet used to load the rest of the "OS"
align 4
da_packet:
db       0x10               ; Packet size
db       0x00               ; ????????
dw       16                 ; Number of sectors
dw       0x7e00             ; Buffer
dw       0x00
dd       0x01               ; Read here ok
dd       0x00               

; Main bit
start:
    xor ax, ax          ; Clear ax
    cli
    jmp 0x0000:boiler_my_plates
    boiler_my_plates:
    mov ss, ax          ; Segment bullshit
    mov ds, ax
    mov es, ax
    mov sp, 0x7bf0      ; Stack shit
    sti

    clc                 ; Clear carry
    mov dl, 0x80        ; The C drive
    mov si, da_packet   ; The DA packet
    mov ah, 0x42        ; CHS BTFO
    int 0x13
    jc short .error     ; Oh, shit...
    jmp shell_main      ; Phew

    .error:
        mov si, error           ; Something happened
        call print_str          ; Something happened

    jmp halt


times 0x0200 - 2 - ($ - $$)  db 0    ; Fill it up
dw 0x0AA55                           ; Boot you son of a bitch

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

intro: db "Ebin-DOS", 0x0D, 0x0A, "Copyright (C) Ebin Corporation", 0x0D, 0x0A, 0x00
shell_ps: db ":DD\> ", 0x00
endl: db 0x0D, 0x0A, 0x00
deletchar: db 0x08, 0x20, 0x08, 0x00
input: times 128 db 0x00
p2: db "' detected to be ebin, aborting.", 0x00
p1: db "'", 0x00
spurdo: db "spurdo", 0x00
absolute_ebin: db ":DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD EBINN", 0x00

; shell_main
; Boots up the shell
shell_main:
    mov al, 0x02        ; Set video mode (clears the screen)
    xor ah, ah
    int 0x10

    mov si, intro       ; Print intro
    call print_str

    mov si, endl        ; Newline
    call print_str
    jmp shell           ; Jump to the shell
    jmp halt            ; (dead) Halt the system

; print_harmful
; Prints the harmful message
print_harmful:
    push si

    mov si, input       ; Put it here
    mov di, spurdo      ; :DDDDD
    call strcmp         ; Compare
    cmp dl, 0x01        ; Same?
    je .ebin            ; YES, EBIN!

    mov si, p1          ; Print the first part of message
    call print_str
    mov si, input       ; Print the input
    call print_str
    mov si, p2          ; Print the second part of the message
    call print_str
    jmp .average_ebin   ; It's ok ebin

    .ebin:
        mov si, absolute_ebin   ; :::::::DDDDDDDDDDDDDDDDDDD
        call print_str          ; EBINN

    .average_ebin:
    mov si, endl        ; Newline
    call print_str
    call clear_input    ; Clear the input string
    pop si
    ret                 ; Return

; strcmp
; Compare string
; <- DS:SI; ES:DI = strings
; -> DL = 0x01 if equal, 0x00 if not
strcmp:
    push ax                         ; save these
    push si
    push di
    .loop:
        lodsb                       ; Load character
        mov ah, byte [es:di]        ; Move a byte from second string
        inc di                      ; Increment pointer
        cmp al, ah                  ; Compare characters from string
        jne .ne                     ; Not equal, get out
        test al, al                 ; We hit 0
        jz .e                       ; They're a match! <3 (gay)
        jmp .loop                   ; We jumped nowhere, continue
    .ne:
        xor dl, dl                  ; Clear dl
        jmp .done                   ; Out
    .e:
        mov dl, 0x01                ; Happy couple, still gay
    .done:
        pop di
        pop si 
        pop ax
        ret

; clear_input
; Clears the input string
clear_input:
    push di
    push cx
    mov di, input       ; Move input to di
    xor al, al          ; Set al to 0
    mov cx, 128         ; Set cx to 128
    cld                 ; Go forwards
    rep stosb           ; Store zeroes until the end
    pop cx
    pop di
    ret                 ; Return

; shell
; Main part of the "shell"
shell:
    push si
    push di
    push cx
    mov si, shell_ps    ; Print the shell prompt
    mov di, input
    mov cx, 127
    call print_str
    .loop_inp:
        xor ah, ah      ; Get char to al
        int 0x16
        cmp al, 0x0D    ; Check for enter
        je .newline     ; If so, it's a newline
        cmp al, 0x08    ; Check for backspace
        je .delet       ; If so, delete last character
        test al, al     ; Check if al was zero (special key)
        jz .loop_inp    ; If so, just keep looping
        mov ah, 0x0E    ; Print the input
        int 0x10
        test cx, cx     ; Check for overflow
        jz .delet       ; If so, do a backspace
        cld             ; Go forwards
        stosb           ; Store our character into input
        dec cx          ; Decrement cx (char stored)
        jmp .loop_inp           ; Keep looping
        .newline:
            mov si, endl        ; 0x0D, 0x0A, 0x00
            call print_str      ; Print the newline
            call print_harmful  ; Print that it's harmful
            pop cx
            pop di
            pop si
            jmp shell           ; Initialize shell again
        .delet:
            cmp cx, 127         ; Check if it's the start of string
            je .loop_inp        ; If so, don't delete anything
            mov si, deletchar   ; 0x08, 0x20, 0x08, 0x00
            call print_str      ; Print the deleting character (wot)
            dec di              ; Decrement the pointer
            xor al, al          ; Store a zero in the input
            stosb
            dec di              ; Decrement again
            inc cx              ; Increment cx (char deleted)
            jmp .loop_inp       ; Keep looping

times 1474560 - ($ - $$) db 0        ; Stuff it up

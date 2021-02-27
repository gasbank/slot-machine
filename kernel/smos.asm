[ORG 0x00]
[BITS 16]

SECTION .text

jmp 0x1000:START

TOTALSECTORCOUNT    equ 10


START:
    mov ax, cs
    mov ds, ax
    mov ax, 0xB800
    mov es, ax

    
    push msgcol1
    push 6
    push 0
    call PRINTMESSAGE
    add sp, 6
    push msgcol2
    push 7
    push 0
    call PRINTMESSAGE
    add sp, 6
    push msgcol3
    push 8
    push 0
    call PRINTMESSAGE
    add sp, 6
    push msgcol4
    push 9
    push 0
    call PRINTMESSAGE
    add sp, 6
    push msgcol5
    push 10
    push 0
    call PRINTMESSAGE
    add sp, 6
    push msgcol6
    push 11
    push 0
    call PRINTMESSAGE
    add sp, 6
    push msgcol7
    push 12
    push 0
    call PRINTMESSAGE
    add sp, 6

    push 0x0000
    call MOVECURSOR
    add sp, 2

    cli
    hlt





PRINTMESSAGE:
    push bp
    mov bp, sp

    push es
    push si
    push di
    push ax
    push cx
    push dx

    mov ax, 0xB800
    mov es, ax

    ; Y 좌표 계산
    mov ax, word[bp+6]
    mov si, 160                 ; 2 x 80 컬럼
    mul si
    mov di, ax

    ; X 좌표 계산
    mov ax, word[bp+4]
    mov si, 2
    mul si
    add di, ax                  ; 최종 위치

    ; 출력할 문자열의 주소
    mov si, word[bp+8]

.MESSAGELOOP:
    mov cl, byte[si]
    cmp cl, 0
    je .MESSAGEEND

    mov byte[es:di], cl
    add si, 1                   ; 다음 글자
    add di, 2                   ; 다음 글자 (비디오 메모리 상)

    jmp .MESSAGELOOP

.MESSAGEEND:
    pop dx
    pop cx
    pop ax
    pop di
    pop si
    pop es
    pop bp
    ret

MOVECURSOR:
    push bp
    mov bp, sp
    pusha

    mov dx, [bp+4]      ; get the argument from the stack. |bp| = 2, |arg| = 2
    mov ah, 0x02        ; set cursor position
    mov bh, 0x00        ; page 0 - doesn't matter, we're not using double-buffering
    int 0x10

    popa
    mov sp, bp
    pop bp
    ret

msgcol1:    db "   _____   __  __    ____     _____", 0
msgcol2:    db "  / ____| |  \/  |  / __ \   / ____|", 0
msgcol3:    db " | (___   | \  / | | |  | | | (___", 0
msgcol4:    db "  \___ \  | |\/| | | |  | |  \___ \", 0
msgcol5:    db "  ____) | | |  | | | |__| |  ____) |", 0
msgcol6:    db " |_____/  |_|  |_|  \____/  |_____/", 0
msgcol7:    db "SLOT MACHINE OPERATING SYSTEM", 0

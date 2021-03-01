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

    push LOGO
    push 6
    push 20
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
    cmp cl, 0                   ; NULL 문자라면 종료처리한다.
    je .MESSAGEEND
    cmp cl, `\n`                ; 개행문자라면 
    je .MESSAGENEWLINE
    
    mov byte[es:di], cl         ; 비디오 메모리에 쓰기
    add si, 1                   ; 다음 글자
    add di, 2                   ; 다음 글자 (비디오 메모리 상)

    jmp .MESSAGELOOP

.MESSAGENEWLINE:
    add si, 1
    push si
    mov ax, word[bp+6]
    add ax, 1
    push ax
    mov ax, word[bp+4]
    push ax
    call PRINTMESSAGE
    add sp, 6
    jmp .MESSAGEEND

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

LOGO:
    db "   _____   __  __    ____     _____", `\n`
    db "  / ____| |  \/  |  / __ \   / ____|", `\n`
    db " | (___   | \  / | | |  | | | (___", `\n`
    db "  \___ \  | |\/| | | |  | |  \___ \", `\n`
    db "  ____) | | |  | | | |__| |  ____) |", `\n`
    db " |_____/  |_|  |_|  \____/  |_____/", `\n`
    db `\n`
    db "   SLOT MACHINE OPERATING SYSTEM", 0

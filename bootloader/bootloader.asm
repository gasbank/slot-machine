bits 16

mov ax, 0x07c0
mov ds, ax
mov ax, 0x07e0
mov ss, ax
mov sp, 0x2000

call clearscreen

push 0x0100
call movecursor
add sp, 2

push msgcol1
call print
add sp, 2

push 0x0200
call movecursor
add sp, 2

push msgcol2
call print
add sp, 2

push 0x0300
call movecursor
add sp, 2

push msgcol3
call print
add sp, 2

push 0x0400
call movecursor
add sp, 2

push msgcol4
call print
add sp, 2

push 0x0500
call movecursor
add sp, 2

push msgcol5
call print
add sp, 2

push 0x0600
call movecursor
add sp, 2

push msgcol6
call print
add sp, 2

push 0x0700
call movecursor
add sp, 2

push msgcol7
call print
add sp, 2

.halt:
cli
hlt

clearscreen:
    push bp
    mov bp, sp
    pusha

    mov ah, 0x07        ; 스크롤하기
    mov al, 0x00        ; 전체 창 지우기
    mov bh, 0x70        ; 검은 바탕 회색 글씨
    mov cx, 0x00        ; 왼쪽 위 구석이 (0,0) 좌표가 되도록
    mov dh, 0x18        ; 18h = 24행
    mov dl, 0x4f        ; 4fh = 79열
    int 0x10            ; 비디오 인터럽트

    popa
    mov sp, bp
    pop bp
    ret

movecursor:
    push bp
    mov bp, sp
    pusha

    mov dx, [bp+4]      ; 함수 인자를 dx에 넣는다.
    mov ah, 0x02        ; 커서 위치 지정
    mov bh, 0x00        ; 페이지 0 지정 (상관 없음. 더블버퍼링 쓰지 않을 것이기 때문)
    int 0x10            ; 비디오 인터럽트

    popa
    mov sp, bp
    pop bp
    ret

print:
    push bp
    mov bp, sp
    pusha

    mov si, [bp+4]
    mov bh, 0x00
    mov bl, 0x00
    mov ah, 0x0e
.char:
    mov al, [si]
    add si, 1
    or al, 0
    je .return
    int 0x10
    jmp .char
.return:
    popa
    mov sp, bp
    pop bp
    ret

msgcol1:
    db "   _____   __  __    ____     _____", 0
msgcol2:
    db "  / ____| |  \/  |  / __ \   / ____|", 0
msgcol3:
    db " | (___   | \  / | | |  | | | (___", 0
msgcol4:
    db "  \___ \  | |\/| | | |  | |  \___ \", 0
msgcol5:
    db "  ____) | | |  | | | |__| |  ____) |", 0
msgcol6:
    db " |_____/  |_|  |_|  \____/  |_____/", 0
msgcol7:
    db "SLOT MACHINE OPERATING SYSTEM", 0

times 510-($-$$) db 0
dw 0xaa55

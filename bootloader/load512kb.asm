TOTALSECTORCOUNT:       dw      1024

SECTORNUMBER:           db      0x02
HEADNUMBER:             db      0x00
TRACKNUMBER:            db      0x00

; 디스크 내용을 복사할 주소는 0x10000 (64KB 지점)
mov si, 0x1000
mov es, si
mov bx, 0x0000

; 읽어들일 총 섹터 숫자 설정 (줄여가면서 반복)
mov di, word[TOTALSECTORCOUNT]

READDATA:
    cmp di, 0
    je READEND
    sub di, 0x1

    ; BIOS Disk I/O
    mov ah, 0x02                        ; Read Sector BIOS 서비스 번호
    mov al, 0x1                         ; 읽을 섹터 수는 한 개
    mov ch, byte [TRACKNUMBER]          ; 읽을 트랙 번호 지정
    mov cl, byte [SECTORNUMBER]         ; 읽을 섹터 번호 지정
    mov dh, byte [HEADNUMBER]           ; 읽을 헤드 번호 지정
    mov dl, 0x00                        ; 읽을 드라이브 번호 지정 (0=Floppy)
    int 0x13                            ; 인터럽트!
    jc HANDLEDISKERROR

    add si, 0x200                       ; 512바이트 읽었으니까 메모리 주소 그만큼 증가
    mov es, si

    ; 섹터 읽었으니까 다음 섹터로
    ; SECTORNUMBER 1증가시키고, 19 미만이면 READDATA 반복
    mov al, byte [SECTORNUMBER]
    add al, 1
    mov byte[SECTORNUMBER], al
    cmp al, 19
    jl READDATA

    ; 섹터 끝까지 읽었으니까 헤드 변경
    ; 헤드는 토글 (0->1, 1->0)
    ; 섹터는 다시 1로
    xor byte[HEADNUMBER], 1
    mov byte[SECTORNUMBER], 1

    ; 지금 상태에서 헤드가 0이란 이야기는 앞뒷면 다 읽었단 뜻이니...
    ; 점프하지 말고 아래로 내려가 트랙 번호 증가
    ; 1이라면 READDATA로 가면 됨
    cmp byte[HEADNUMBER], 0
    jne READDATA

    add byte[TRACKNUMBER], 1
    jmp READDATA

READEND:


HANDLEDISKERROR:




msgcol1:    db "   _____   __  __    ____     _____", 0
msgcol2:    db "  / ____| |  \/  |  / __ \   / ____|", 0
msgcol3:    db " | (___   | \  / | | |  | | | (___", 0
msgcol4:    db "  \___ \  | |\/| | | |  | |  \___ \", 0
msgcol5:    db "  ____) | | |  | | | |__| |  ____) |", 0
msgcol6:    db " |_____/  |_|  |_|  \____/  |_____/", 0
msgcol7:    db "SLOT MACHINE OPERATING SYSTEM", 0

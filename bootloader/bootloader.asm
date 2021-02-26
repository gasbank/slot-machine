[org 0x00]
[bits 16]

SECTION .text

jmp 0x07C0:START


TOTALSECTORCOUNT:       dw      1024


START:
    ; DS 부트로더의 시작 주소를 세그먼트 레지스터 값으로 변환 (0x7C00)
    mov ax, 0x07C0
    mov ds, ax
    ; ES 비디오 메모리를 세그먼트 레지스터 값으로 지정 (0xB8000)
    mov ax, 0xB800
    mov es, ax

    ; 스택 생성
    mov ax, 0x0000
    mov ss, ax
    mov sp, 0xFFFE
    mov bp, 0xFFFE

    ; 화면 지우기
    mov si, 0

.SCREENCLEARLOOP:
    mov byte[es:si], 0                  ; 글자 삭제
    mov byte[es:si+1], 0x0A             ; 글자 글씨색 지정
    add si, 2                           ; 다음 칸
    cmp si, 80 * 25 * 2
    jl .SCREENCLEARLOOP


    ; 화면 상단에 시작 메시지 출력
    push MESSAGE1
    push 0
    push 0
    call PRINTMESSAGE
    add sp, 6
    

RESETDISK:
    mov ax, 0
    mov dl, 0
    int 0x13
    jc HANDLEDISKERROR




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

    ; 로딩 완료
    push LOADINGCOMPLETEMESSAGE
    push 7
    push 20
    call PRINTMESSAGE
    add sp, 6

HANDLEDISKERROR:
    push DISKERRORMESSAGE
    push 7
    push 20
    call PRINTMESSAGE
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





MESSAGE1:   db "Hello!", 0
DISKERRORMESSAGE: db "Disk error", 0
LOADINGCOMPLETEMESSAGE: db "Loading completed.", 0

SECTORNUMBER:           db      0x02
HEADNUMBER:             db      0x00
TRACKNUMBER:            db      0x00

times 510-($-$$) db 0

dw 0xaa55

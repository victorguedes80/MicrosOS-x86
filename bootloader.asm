; Bootloader - boot.asm
; Carrega o kernel e o editor na memória e os executa
org 0x7C00

; Configuração do modo de vídeo
mov ah, 0x0E
mov al, 'B'
int 0x10
mov al, 'O'
int 0x10
mov al, 'O'
int 0x10
mov al, 'T'
int 0x10
mov al, 'L'
int 0x10
mov al, 'O'
int 0x10
mov al, 'A'
int 0x10
mov al, 'D'
int 0x10
mov al, 'E'
int 0x10
mov al, 'R'
int 0x10

; Carregar o kernel (1 setor) para 0x1000
mov bx, 0x1000
mov es, bx
xor bx, bx
mov ah, 0x02
mov al, 1       ; Número de setores para carregar (1 setor = kernel)
mov ch, 0
mov cl, 2       ; LBA do setor inicial
mov dh, 0
mov dl, 0x80    ; Primeiro disco
int 0x13

; Carregar o editor de texto (1 setor) para 0x2000
mov bx, 0x2000
mov es, bx
xor bx, bx
mov ah, 0x02
mov al, 1       ; Número de setores para carregar (1 setor = editor)
mov ch, 0
mov cl, 3       ; LBA do setor inicial (editor começa no setor 3)
mov dh, 0
mov dl, 0x80    ; Primeiro disco
int 0x13

; Pular para o kernel
jmp 0x1000:0

times 510 - ($ - $$) db 0
dw 0xAA55


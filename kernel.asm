; Kernel - kernel.asm
; Shell simples para carregar editor de texto
org 0x1000

; Configuração do modo de vídeo
mov ah, 0x0E
mov al, 'K'
int 0x10
mov al, 'E'
int 0x10
mov al, 'R'
int 0x10
mov al, 'N'
int 0x10
mov al, 'E'
int 0x10
mov al, 'L'
int 0x10


; Loop do shell
shell_loop:
    mov ah, 0x0E
    mov al, '>'
    int 0x10
    mov ah, 0x00
    int 0x16  ; Ler tecla
    cmp al, 'E'  ; Se for 'E', carregar editor de texto
    je load_editor
    jmp shell_loop

load_editor:
    ; Código para carregar e executar o editor de texto
    jmp 0x2000:0x0000


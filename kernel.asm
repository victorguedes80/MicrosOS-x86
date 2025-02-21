bits 16
; kernel.asm
org 0

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x1000
    
    mov ax, 0x1000
    mov ds, ax

    mov si, kernel_msg
    mov cx, kernel_msg_len
    call print_str

    ; Segue para o shell_loop
    call shell_loop

shell_loop:
    ; Exibe o prompt
    mov ah, 0x0E
    mov al, '>'
    int 0x10

    ; Lê a tecla
    mov ah, 0x00
    int 0x16

    ; Verifica se é '1' ou '2'
    cmp al, '1'
    je load_editor
    cmp al, '2'
    je reboot_system

    jmp shell_loop

load_editor:
    ; Salta para o editor (em 0x2000:0x0000)
    jmp 0x2000:0

reboot_system:
    call limpa_tela
    mov ax, 0
    int 0x19
    jmp $

limpa_tela:
; --- Limpa a tela (assumindo 25 linhas x 80 colunas) ---
    mov ah, 06h
    mov al, 0        ; Número de linhas a rolar (0 = limpar toda a janela)
    mov bh, 07h      ; Atributo de cor (ex.: branco em fundo preto)
    mov cx, 0000h    ; Canto superior esquerdo (linha 0, coluna 0)
    mov dx, 184Fh    ; Canto inferior direito (linha 24, coluna 79)
    int 0x10

; --- Posiciona o cursor no canto superior esquerdo ---
    mov ah, 02h
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 0x10

    ret
    
; -----------------------------------------------------------------------------
; Função: print_str
; Imprime a string cujo endereço está em SI e o tamanho em CX.
; -----------------------------------------------------------------------------
print_str:
    pusha
    mov ah, 0x0E        ; Serviço de escrita de caractere no TTY
.char_loop:
    lodsb               ; Carrega byte corrente de SI em AL e incrementa SI
    int 0x10
    loop .char_loop     ; Decrementa CX e repete até zerar
    popa
    ret
; -----------------------------------------------------------
; String e tamanho
; -----------------------------------------------------------
kernel_msg db 'Kernel Iniciado', 0x0D, 0x0A, 'Digite 1 para abrir o Editor', 0x0D, 0x0A, 'Digite 2 para Reiniciar', 0x0D, 0x0A
kernel_msg_len equ $ - kernel_msg


bits 16

; Bootloader - boot.asm
; Carrega o kernel e o editor na memória e os executa
org 0x7C00

; Configuração do modo de vídeo - exibe "BOOTLOADER"
start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x7C00
    


    ; Exibe mensagem inicial utilizando a função print_str
    mov si, welcome_msg
    mov cx, welcome_msg_len
    call print_str


    mov si, bootloader_msg
    mov cx, bootloader_msg_len
    call print_str

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



; -----------------------------------------------------------------------------
; Mensagem de inicialização (string e comprimento)
welcome_msg db 'Bootloader Iniciado...', 0x0D, 0x0A
welcome_msg_len equ $ - welcome_msg

bootloader_msg db 'Carregando o Kernel...', 0x0D, 0x0A
bootloader_msg_len equ $ - bootloader_msg

times 510 - ($ - $$) db 0
dw 0xAA55


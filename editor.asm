bits 16
; Editor de Texto - editor.asm
; Permite inserção e deleção de caracteres com proteção do cabeçalho e tela limpa.
org 0

first_editable_line equ 1   ; Linha 0: cabeçalho; Linha 1: primeira linha editável

start:

    call limpa_tela

    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ss, ax
    mov sp, 0x2000
        
    mov ax, 0x2000
    mov ds, ax

    mov si, editor_msg
    mov cx, editor_msg_len
    call print_str

    ; --- Posiciona o cursor na primeira linha editável (linha 1, coluna 0) ---
    mov ah, 02h
    mov bh, 0
    mov dh, first_editable_line
    mov dl, 0
    int 0x10

; --- Loop principal de leitura e exibição de caracteres ---
type_loop:
    mov ah, 0x00
    int 0x16          ; Ler tecla
    cmp al, 0x08      ; Backspace
    je handle_backspace
    cmp al, 0x1B      ; ESC para sair
    je exit_editor
    cmp al, 0x0D      ; Enter (Carriage Return)
    je handle_enter

    ; Imprimir caractere
    mov ah, 0x0E
    int 0x10
    jmp type_loop

; --- Rotina de Backspace com proteção do cabeçalho ---
handle_backspace:
    ; Obtém a posição atual do cursor (linha em DH, coluna em DL)
    mov ah, 0x03
    mov bh, 0x00
    int 0x10

    ; Se o cursor estiver acima da primeira linha editável, não faz nada.
    cmp dh, first_editable_line
    jb do_nothing

    ; Se estiver na primeira linha editável, permite backspace apenas se não estiver na coluna 0.
    cmp dh, first_editable_line
    je check_first_line

    ; Para linhas abaixo da primeira editável:
    cmp dl, 0
    jne normal_backspace       ; Se não estiver na coluna 0, faz backspace normal

    ; Se estiver na coluna 0, une com a linha anterior:
    dec dh                     ; Move para a linha anterior
    mov dl, 79                 ; Define a última coluna (assumindo 80 colunas, índice 79)
    mov bh, 0x00
    mov ah, 0x02
    int 0x10                  ; Atualiza a posição do cursor
    ; Executa a sequência para apagar o caractere:
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp type_loop

check_first_line:
    cmp dl, 0
    jne normal_backspace       ; Se não estiver na coluna 0, permite o backspace normal
    ; Se estiver na coluna 0 na primeira linha editável, não faz nada para proteger o cabeçalho.
    jmp do_nothing

normal_backspace:
    ; Sequência padrão de backspace:
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp type_loop

do_nothing:
    jmp type_loop

; --- Rotina de tratamento do Enter (CR + LF) ---
handle_enter:
    mov ah, 0x0E
    mov al, 0x0D      ; Carriage Return
    int 0x10
    mov al, 0x0A      ; Line Feed
    int 0x10
    jmp type_loop

exit_editor:
    call limpa_tela
    
    jmp 0x1000:0


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
editor_msg db 'Digite ESC para sair', 0x0D, 0x0A
editor_msg_len equ $ - editor_msg



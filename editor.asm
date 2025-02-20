; Editor de Texto - editor.asm
; Permite inserção e deleção de caracteres
org 0x2000
mov ah, 0x0E
mov al, 'E'
int 0x10
mov al, 'D'
int 0x10
type_loop:
    mov ah, 0x00
    int 0x16  ; Ler tecla
    cmp al, 0x08  ; Backspace
    je handle_backspace
    cmp al, 0x1B  ; ESC para sair
    je exit_editor
    
    ; Imprimir caractere
    mov ah, 0x0E
    int 0x10
    jmp type_loop

handle_backspace:
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp type_loop

exit_editor:
    ret


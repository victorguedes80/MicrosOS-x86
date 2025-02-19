BITS 16           
ORG 0x7C00         

SECTION .data
buffer times 1024 db '$'   ; Buffer para armazenar o texto
posCursor dw 0             ; Posição do cursor no buffer
newline db 0x0D, 0x0A, '$' ; Quebra de linha

SECTION .text
_start:
    ; Configurando o segmento de dados 
    mov ax, 0
    mov ds, ax

    ; Configurando o modo de vídeo
    mov ah, 0x00
    mov al, 0x03
    int 0x10  

    ; Imprimir nova linha inicial
    mov dx, newline
    call print_string
    mov dx, buffer
    call print_string

edit_loop:
    call get_key       ; Capturar tecla pressionada
    cmp al, 0x1B       ; Verificar se for ESC 
    je exit_editor
    cmp al, 0x08       ; Verificar se for BACKSPACE 
    je handle_backspace
    cmp al, 0x0D       ; Verificar se for ENTER 
    je handle_enter
    cmp al, 0x20       ; Verificar se for SPACE 
    je handle_space

    call print_char    ; Exibir caractere na tela
    mov si, [posCursor]
    mov [buffer + si], al  ; Armazena no buffer
    inc word [posCursor]   ; Incrementa posição do cursor
    jmp edit_loop

handle_backspace:
    cmp word [posCursor], 0  ; Ignora se o cursor já estiver no início 
    je edit_loop
    dec word [posCursor]     ; Decrementa posição do cursor
    mov al, ' '              ; Apaga o caractere na tela
    call print_char
    jmp edit_loop

handle_space:
    cmp word [posCursor], 1023  ; Evitar buffer overflow
    jae edit_loop

    mov al, ' '  ; Espaço
    call print_char  ; Exibir espaço na tela

    mov si, [posCursor]
    mov [buffer + si], al  
    inc word [posCursor]    
    jmp edit_loop

handle_enter:
    mov dx, newline
    call print_string
    mov si, [posCursor]
    mov byte [buffer + si], 0x0D  ; Insere 'Enter' no buffer
    inc word [posCursor]
    jmp edit_loop

exit_editor:
    mov dx, buffer
    call print_string

loop_halt:
    hlt                        ; Entra em modo de espera
    jmp loop_halt              ; Loop infinito para evitar falhas


get_key: ; Capturar tecla pressionada
    mov ah, 0x00
    int 0x16
    ret


print_char: ; Exibe um caractere 
    mov ah, 0x0E
    int 0x10
    ret

print_string: ; Exibir uma string
    mov si, dx    
print_loop:
    lodsb         ; Carrega o próximo caractere de [SI] em AL
    cmp al, '$'   
    je print_done ; Se for '$', acaba
    call print_char
    jmp print_loop
print_done:
    ret

times 510-($-$$) db 0   ; Preenche até 510 bytes (tamanho do setor de boot)
dw 0xAA55               ; Assinatura de bootloader (últimos 2 bytes)
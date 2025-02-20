org 0x7c00
bits 32

main:

halt:
    
        hlt
        jmp halt

// $ -> inicio, $$ -> final
// db 0 -> preenche x tamanho com 0 bytes (que no nosso caso é x=510)
times 510-($-$$) db 0
dw 0xaa55 // Finalizar com assinatura de boot
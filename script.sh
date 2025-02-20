#!/bin/bash

# Compilar os arquivos ASM com NASM
echo "Compilando Bootloader..."
nasm -f bin bootloader.asm -o bootloader.bin

echo "Compilando Kernel..."
nasm -f bin kernel.asm -o kernel.bin

echo "Compilando Editor de Texto..."
nasm -f bin editor.asm -o editor.bin

# Criar a imagem do disco (1,44MB - 2880 setores de 512 bytes)
echo "Criando imagem do disco..."
dd if=/dev/zero of=disk.img bs=512 count=2880

# Gravar o Bootloader no primeiro setor do disco
echo "Escrevendo Bootloader na imagem do disco..."
dd if=bootloader.bin of=disk.img bs=512 count=1 conv=notrunc

# Gravar o Kernel no segundo setor do disco
echo "Escrevendo Kernel na imagem do disco..."
dd if=kernel.bin of=disk.img bs=512 seek=1 conv=notrunc

# Gravar o Editor de Texto no terceiro setor do disco
echo "Escrevendo Editor de Texto na imagem do disco..."
dd if=editor.bin of=disk.img bs=512 seek=2 conv=notrunc

# Iniciar o QEMU com a imagem do disco
echo "Iniciando QEMU..."
qemu-system-x86_64 -drive format=raw,file=disk.img


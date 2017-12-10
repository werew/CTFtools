; Most of this template is taken from: https://en.wikibooks.org/wiki/X86_Assembly/NASM_Syntax
;
; nasm -f <format> -g test.asm   # (list formats: nasm -hf (ex: elf32, elf64, ...)
; ld -g test.asm -o test




;******** Some examples of macros *********
; 
; %define newline 0xA
; %define func(a, b) ((a) * (b) + 2)
;
; func (1, 22) ; expands to ((1) * (22) + 2)
;
; %macro print 1  ; macro with one argument
;   push dword %1 ; %1 means first argument
;   call printf
;   add  esp, 4
; %endmacro
;
; print mystring ; will call printf



global _start


section .data
    ; Align to the nearest 2 byte boundary, must be a power of two
    align 2
    ; String, which is just a collection of bytes, 0xA is newline
    message:     db 'Hello, world!',0xA
    strLen:  equ $-message

section .bss


section .text
    _start:

    ; Insert asm here:
    mov     edx, strLen   
    mov     ecx, message
    mov     ebx, 1          
    mov     eax, 4          
    int     0x80 
    

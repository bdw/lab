    .intel_syntax noprefix
    .section __TEXT,__text
    .globl _fib
_fib:
    mov rax, 1
    mov rcx, 1
loop:
    dec rdi
    jl  end
    add rax, rcx
    xchg rcx, rax
    jmp loop
end:
    ret

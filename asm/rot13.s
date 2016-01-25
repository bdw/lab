/* file header */
.intel_syntax noprefix
.section .text

/* our main function, equivalent to sub roman_numeral { */
.globl rot13_encrypt
.type rot13_encrypt @function

rot13_encrypt:
        /* prologue and epilogue */
        push rbp
        mov rbp, rsp
        /* lets make sure we have memory available */
        push rdi
        call strlen@PLT /* count chars */
        inc rax /* add one byte */
        mov rdi, rax /* result becomes argument */
        call malloc@PLT
        pop rdi
        mov rcx, 0 /* set loop variable to 0 */
        xor rdx, rdx
_loop:
        movzx dx, byte ptr [rdi+rcx*1]
        test dx, dx
        jz _end
        /* must be larger than 'A' and smaller than 'z' */
        cmp dx, 'A'
        jl _next
        cmp dx, 'Z'
        jle _uppercase

        cmp dx, 'a'
        jl _next
        cmp dx, 'z'
        jg _next

_lowercase:
        add dx, 13
        cmp dx, 'z'
        jng _next
        sub dx, 26
        jmp _next

_uppercase:
        add dx, 13
        cmp dx, 'Z'
        jle _next
        sub dx, 26

_next:
        mov byte ptr [rax+rcx*1], dl
        inc rcx
        jmp _loop
_end:
        mov byte ptr [rax+rcx*1], 0
        mov rsp, rbp
        pop rbp
        ret

        .intel_syntax noprefix
        .section .text
        .globl get_cont
        .type get_cont @function

get_cont:                            /* get continuation pointer */
        mov rax, qword [rsp-0x8]
        ret

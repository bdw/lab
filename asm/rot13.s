/* file header */
.intel_syntax noprefix
.section text
	

.globl rot13_encrypt
.type rot13_encrypt @function
	/* our main function, equivalent to sub roman_numeral { */
        .globl roman_numeral
        .type  roman_numeral @function
roman_numeral:
        /* function prologue */
        mov rax, 42
        ret

rot13_encrypt:
	/* prologue and epilogue */
        push rbp
        mov rbp, rsp
        
        mov rsp, rbp
        pop rbp
        ret

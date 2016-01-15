.intel_syntax noprefix
.section .text
/* variable declarations */	
numeral:
        .string "IVXLCDM"
        .align 4
value:
        .long 1
        .long 5
        .long 10
        .long 50
        .long 100
        .long 500
        .long 1000
/* our main function, equivalent to sub roman_numeral { */
        .globl roman_numeral
        .type  roman_numeral @function
roman_numeral:
        /* function prologue */
        push rbp
        mov rbp, rsp
        sub rsp, 0x10             /* make space for two 32 bit values (or a single 64 bit value) */
        mov dword ptr [rsp], edi /* save the number we're using on the stack, malloc will kill it  */

        mov edi, 0x10            /* 16 bytes are plenty for roman numerals. (max 4 bytes per order of magnitude, max 3 orders of magnitudes) */
        call malloc@PLT          /* rax now contains the pointer to our buffer */
        mov edi, dword ptr [rsp] /* restore our number */
        mov rdx, 0               /* string index */
        mov rcx, 6               /* lookup array index */
_outer:
        test edi, edi 
        jz _end                 /* if (number == 0) break outer */
        lea r8,  [rip+value]    
        mov r9d,  dword ptr [r8+rcx*4-0x4] /* current value */
        lea r8,  [rip+numeral]	
	mov r10b, byte ptr [r8+rcx*1] /* current numeral */    
_inner:
        cmp edi, r9d
        jl _subtractive /* if (m < values[i]) break inner */
        sub edi, r9d
        mov byte ptr [rax+rdx*1-1], r10b
        inc rdx
        jmp _inner
_subtractive:
        /* add a one-minus-numeral */
        test rcx, rcx /* if (index == 0) break outer */
        jz _end
        mov r11, rcx
        dec r11
        test rcx, 1
        jnz _even
        dec r11 /* r11 = rcx - (rcx & 1 ? 1 : 2) */
_even:
        lea r8, [rip+value]
        mov r12d, dword ptr [r8+r11*4] /* r12d = value[r11] */
        add r12d, edi
        sub r12d, r9d
        jl  _after
_insert:        
	/* edi = edi + r12d - r9d */
        mov edi, r12d
        /* write byte */
        lea r8, [rip+numeral]
        mov r12b, byte ptr [r8+r11*1]
        mov byte ptr [rax+rdx*1], r12b /* append 'subtractive' character */
        inc rdx
        mov byte ptr [rax+rdx*1], r10b /* append 'major' character */
        inc rdx
_after: 
        dec rcx
        jge _outer /* while (--rcx >= 0)  */
_end:
	mov byte ptr [rax+rdx*1], 0 /* add zero to end of string */
        /* function epilogue */
        add rsp, 0x10
        pop rbp
        ret


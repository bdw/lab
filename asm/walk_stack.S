	.section	__TEXT,__text,regular,pure_instructions
#	.macosx_version_min 10, 11
	.intel_syntax noprefix
	.globl	_walk_stack_posix
    .globl walk_stack_posix
walk_stack_posx:    
_walk_stack_posix:
    # rdi = base pointer, rsi = end pointer
	push rbp
    mov rcx, rsp
loop:
    mov rax, qword ptr [rcx+0x8]
    mov rcx, qword ptr [rcx]
    cmp rax, rdi
    jl  loop
    cmp rax, rsi
    jg  loop
done:
    ## rax is now within range by definition
    pop rbp
    ret

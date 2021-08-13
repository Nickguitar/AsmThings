;Nicholas Ferreira - 12/08/21
;Read from stdin and print into stdout

global _start

; =============== DEFINITIONS
READ equ 	0
WRITE equ	1
ARGMAX equ	2097152		     	;$getconf -a | grep ARG_MAX

; ================ MARCOS
%macro exit 0
	mov rax, 60
	mov rdi, 0
	syscall
%endmacro

%macro read 3			    	;read fd, buf, count
	push %1				;fd
	push %2				;buf (addr of mapped memory)
	push %3				;count (from filesize)
	call _read
	add rsp, 24			;clear stack
%endmacro

%macro write 3
	push %1				;fd
	push %2				;buf
	push %3				;count
	call _write
	add rsp, 24			;clear stack
%endmacro

; ================ FUNCTIONS
section .bss				;better save space xD
	buf:
		resb 128		;128 bytes buffer

section .text

	_read:
		push rbp
		mov rbp, rsp
		mov rax, READ
		mov rdx, [rbp+16]	;count (size)
		mov rsi, [rbp+24]	;buf
		mov rdi, [rbp+32]	;fd
		syscall
		leave
		ret

	_write:
		push rbp
		mov rbp, rsp
		mov rax, WRITE
		mov rdx, [rbp+16]	;count
		mov rsi, [rbp+24]	;buf
		mov rdi, [rbp+32]	;fd
		syscall
		leave
		ret


	_start:
		mov rcx, ARGMAX		;maximum argument size
		mov rbx, buf		;128 bytes where stdin will be
	_loop:
		read 0, rbx,128		;fd, buf, size
		push rax		;save number of bytes read
		write 1, rbx, 128	;print
		pop rax			;retrieve number of bytes read
		cmp rax, 0		;if rax==0?
		jnz _notEnd		;if not, it's not the end
		exit			;if so, then it's the end
	_notEnd:
		add rbx, 128		;shift 128 bytes on buff >>
		jmp _loop		;read 128 bytes once again

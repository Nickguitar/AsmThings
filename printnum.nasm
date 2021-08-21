;Nicholas Ferreira - 20/08/21
;Prints numbers (int to string)
;The number is passed with the macro "printint <number>"

global _start

WRITE equ	1
EXIT equ	60

%macro exit 0
	mov rax, 60
	mov rdi, 0
	syscall
%endmacro

%macro write 3
	push %1			;fd
	push %2			;buf
	push %3			;count
	call _write
	add rsp, 24		;clear stack
%endmacro

%macro printint 1
	push %1
	call _movToBuf
%endmacro

section .text
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

_movToBuf:
	push rbp
	mov rbp, rsp
	xor rcx, rcx		;set counter to 0
	mov rax, [rsp+16]	;get arg from stack
	mov rbx, 10		;the number will be divided by 10
	sub rsp, 16		;reserve buf for number
_divLoop:
	xor rdx, rdx		;clear remainder
	div rbx			;divides rax by 10
	cmp rax, 0		;is the quocient 0?
	jnz _continue		;if not, continue
	cmp rdx, 0	  	;if so, is remainder 0?
	jnz _continue		;if not, continue
	jmp _invert		;if so, it's the end
				;go invert the number
_continue:
	add dl, 48		;convert to ascii
	mov [rsp+rcx], dl	;dl has the remainder
		  		;move it to the next byte of buf
	inc rcx 		;increase counter
	jmp _divLoop

_invert:			;rcx = number length
	push rbp		;create a new stack frame to
	mov rbp, rsp		;access the number via rbp

	sub rsp, 16		;buf for reversed number
	mov rdx, rcx		;save number length
_invertLoop:
	mov rax, [rbp+7+rcx]	;rbp = base pointer
				;rbp+8 = 00
				;rbp+8-1 = last digit of number
				;(since it's inverted, it's the first)
				;rbp+8+rcx = previous number

	mov rbx, rsp		;store rsp in rbx so that we can change it
	sub rbx, rcx		;rbx = rsp-rcx
	mov [rbx], al		;mov last digit to [rsp-rcx]
				;in the end, rsp will contain the whole number
	dec rcx
	cmp rcx, 0		;is the current index = 0?
	jnz _invertLoop		 ;if not, continue inverting the number

	mov rax, rdx		;if so, restore number length
	mov rbx, 2		;each number is represented by 2 numbers
				;in the ascii table; so we have to multiply
				;by 2 the size of our number and this is the
				;size it will occupy

	mul rbx			;rax = 2*len(number)
	mov rbx, rax		;rbx = 2*len(number)
	sub rsp, rax		;now rsp contains the number
	mov rcx, rsp		;lets store it's location
	write 1, rcx, rbx	;and print it
	mov rsp, rbp		;remove the new stack frame
	pop rbp			;created in _invert
	leave
	ret

_start:
	printint 7359
	exit

;Nicholas Ferreira - 21/08/21
;FizzBuzz implementation in x64 asm
;
;The real FizzBuzz code starts at 
;"_start". All previous code is the 
;routine to print integer numbers

global _start

section .data
fizz: db "Fizz",10,0
buzz: db "Buzz",10,0
fizzbuzz: db "FizzBuzz",10,0

section .text
%macro print 2
	mov rax, 1
	mov rdi, 1 		;fd
	mov rsi, %1		;buf
	mov rdx, %2		;count
	syscall
%endmacro

%macro exit 0
	mov rax, 60
	mov rdi, 0
	syscall
%endmacro

%macro printint 1
	push %1
	call _movToBuf
%endmacro

;=================== routine to print integers

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
	jnz _invertLoop		;if not, continue inverting the number

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


;=================== end routine



_start:
	mov r9, 100		;max interations
	mov r8, 1		;reset counter

_isFizzBuzz:
	xor rdx, rdx		;reset rdx for div
	mov rax, r8 		;restore counter to rax
	mov rbx, 15 		;divide counter (rax) by 15
	div rbx
	cmp rdx, 0 		;is the remainder 0?
	jnz _isBuzz 		;if not, check if it's buzz
	print fizzbuzz,9	;if is 0, print fizz,
	jmp _chkLoop 		;and check if it's the end

_isBuzz:
	xor rdx, rdx		;reset rdx for div
	mov rax, r8		;restore counter to rax
	mov rbx, 5 		;divide rax by 3
	div rbx
	cmp rdx, 0 		;is the remainder 0?
	jnz _isFizz		;if not, check if it's fizz
	print buzz,5 		;if is 0, print buzz,
	jmp _chkLoop 		;and check if it's the end

_isFizz:
	xor rdx, rdx		;reset rdx for div
	mov rax, r8		;restore counter to rax
	mov rbx, 3 		;divide rax by 3
	div rbx
	cmp rdx, 0 		;is the remainder 0?
	jnz _notFnorB 		;if not, then it's not fizz nor buzz
	print fizz,5		;if is 0, print fizzbuzz,
	jmp _chkLoop 		;and check if it's the end

_notFnorB:
	printint r8		;print the number itself

_chkLoop:
	inc r8	 		;increment counter
	cmp r8, r9 		;is the current <= 100?
	jle _isFizzBuzz		;if not, go back to start
	exit			;if so, exit

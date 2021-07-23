;Nicholas Ferreira - 15/07/21
;Fibonacci sequence is printed in raw hex (01, 01, 02, 03, 05, 08, 0d, 15, 22, 37,...)
;$ ./fibo | xxd -l 100 -c 0
;00000000: 0000 0100 0100 0200 0300 0500 0800 0d00  ................
;00000010: 1500 2200 3700 5900 9000 e900 7901 6202  ..".7.Y.....y.b.
;00000020: db03 3d06 180a 5510 6d1a c22a 2f45 f16f  ..=...U.m..*/E.o
;00000030: 20b5 1125 31da 42ff 73d9 b5d8 28b2 dd8a   ..%1.B.s...(...
;00000040: 053d e2c7 e704 c9cc b0d1 799e 2970 a20e  .=........y.)p..
;00000050: cb7e 6d8d 380c a599 dda5 823f 5fe5 e124  .~m.8......?_..$
;00000060: 400a 212f

global _start
section .text

	_start:
		push 0 ;move 0 to stack (initializer)
		push 1 ;move 1 to stack (initializer)
	fibo:
		pop rdx ;move top of stack to rdx
		pop rax ;move top of stack to rax
		xadd rax, rdx ;exchange and add (temp=rdx+rax; rdx=rax; rax=temp)
		push rax ;sum result goes to stack
		push rdx ;old eax goes to stack

		; print syscall
		mov rax, 1 ;opcode for "write" syscall
		mov rdi, 1 ;first arg for write (stdout)
		mov rsi, rsp ;mov top of stack to rsi, which is rdx
		mov rdx, 2 ;size of buffer to be printed
		syscall ;syscall for write to print rsi
		loop fibo

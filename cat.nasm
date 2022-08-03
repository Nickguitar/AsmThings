;Nicholas Ferreira - 25/07/21
;./cat file
;prints the content of argv[1] on stdout
;
;Comentários em português: n.0x7359.com/?0x5

%define READ	0
%define WRITE	1
%define OPEN 	2
%define FSTAT 	5
%define MMAP	9
%define EXIT	60

global _start

section .text
	_start:
		mov rdi, [rsp+16]	;argv[1]
		mov rax, OPEN           ;open file and return descriptor
		pop rdi			;argv[1]
		mov rsi, 0		;read only
		syscall
		mov r15, rax		;store fd in r15

		mov rax, FSTAT          ;retrieve information about the opened file
		mov rdi, r15		;fd (argv[1])
		sub rsp, 114		;reserved for stat() return
		mov rsi, rsp		;statbuf
		syscall
		mov rbx, [rsp+48]	;the filesize will be at this position on stack

		mov eax, MMAP           ;map memory to store file content
		mov rdi, 0        	;addr
		mov rsi, rbx		;length
		mov rdx, 0x2      	;PROT_WRITE
		mov r10, 0x21       	;MAP_SHARED|MAP_ANONYMOUS
		mov r8, -1        	;fd (ignore)
		mov r9, 0         	;offset (zero, because MAP_ANONYMOUS)
		syscall
		mov rcx, rax		;addr of mapped memory

		mov rax, READ           ;read contents from file
		mov rdi, r15		;fd (from push r8)
		mov rsi, rcx		;buf
		mov rdx, rbx		;count (size)
		syscall

		mov rax, WRITE          ;write file content to stdout
		mov rdi, 1		;fd (stdout)
		mov rdx, rbx		;count
		syscall                 ;rsi has fd

		mov rax, EXIT
		mov rdi, 0
		syscall       

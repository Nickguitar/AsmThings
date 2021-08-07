;Nicholas Ferreira - 07/08/21
;Encrypt file passed via argv[1] with simple XOR
global _start

; =============== DEFINITIONS

READ equ 	0
WRITE equ	1
OPEN equ	2
FSTAT equ	5
MMAP equ	9
EXIT equ	60
TRUNC equ 	1001

; ================ MACROS

%macro exit 0
	mov rax, 60
	mov rdi, 0
	syscall
%endmacro

%macro open 3			;open filepath, flags, perm
	push %1				;filepath
	push %2				;flags(ro)
	push %3				;perm
	call _open
	add rsp, 24			;clear stack
%endmacro

%macro filesize 1		;filesize fd
	mov rdi, %1			;save fd in rdi
	call _filesize
%endmacro

%macro mmap 1			;mmap length
	push 0				;addr (let kernel decide)
	push %1				;length
	push 0x2			;prot (PROT_WRITE)
	push 33				;flags (MAP_SHARED|MAP_ANONYMOUS)
	push -1				;fd (ignore)
	push 0				;offset (0, because MAP_ANONYMOUS)
	call _mmap			;map memory to load its own content
	add rsp, 48			;clear stack
%endmacro

%macro read 3			;read fd, buf, count
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

; ================ DATA

section .data
	usage: db 'Usage: ./cipher [filename]', 0
	error: db '[-] File not found',0
; ================ FUNCTIONS

section .text
	_open:
		push rbp
		mov rbp, rsp
		mov rax, OPEN
		mov rdx, [rbp+16]	;perm
		mov rsi, [rbp+24]	;flags
		mov rdi, [rbp+32]	;filepath
		syscall
		leave
		ret					;result goes in rdi

	_filesize:
		push rbp
		mov rbp, rsp
		sub rsp, 192		;reserved for stat() return
		mov rax, FSTAT
		mov rsi, rsp		;statbuf
		syscall
		mov rax, [rsp+48]	;the filesize will be at this position on stack
		leave
		ret

	_mmap:
		push rbp
		mov rbp, rsp
		mov rax, MMAP
		mov r9, [rbp+16]	;offset
		mov r8, [rbp+24]	;fd
		mov r10, [rbp+32]	;flags
		mov rdx, [rbp+40]	;prot
		mov rsi, [rbp+48]	;length
		mov rdi, [rbp+54]	;addr
		syscall
		leave
		ret

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

	_magic:					;encode/decode
		push rbp
		mov rbp, rsp
		mov rax, [rbp+24]	;mem addr with file contents
		mov rbx, [rbp+32]	;filesize
		add rbx, rax		;addr+filesize
		push rax			;popped at the end

	_encode:
		xor byte [rax], 0x73
		xor byte [rax], 0x59
		cmp rax, rbx		;current position is end?
		jle _encode			;if not, goto next byte
		pop rax				;retrieve addr
		leave
		ret

	_usage:
		write 1, usage, 27

	_exit:
		exit

	_notfound:
		write 1, error, 19
		exit
; ================ MAIN

	_start:
		pop rax				;argc
		cmp rax, 2
		jl _usage			;if less than 2 argv

		mov rax, [rsp+8]	;argv[1]
		push rax			;save argv on stack
		open rax, 0, 0		;path, flags (R/W), perm
		cmp rax, 0			;fd
		jl _notfound		;if fd<0 then exit
		push rax 			;save fd in stack
		filesize rax		;get "file" filesize = n
		cmp rax, 0
		jz _exit			;exit if filesize = 0

		push rax			;save filesize in stack
		mmap rax			;maps n bytes

		mov rcx, [rsp]		;filesize
		mov rbx, [rsp+8]	;fd
		mov rdx, rax
		push rdx			;pointer to allocated memory
		read rbx, rax, rcx
		mov r9, rax			;save number os bytes read

		mov rax, [rsp+24]	;argv[1]
		open rax, 0x1001, 755o
		push rax			;fd from open()
		call _magic			;encode/decode
		pop rbx				;fd
		write rbx, rax, r9
		exit

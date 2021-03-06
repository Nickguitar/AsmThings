;Nicholas Ferreira - 11/08/21
;ROT13 bruteforce
;Prints all 26 ROT variations
;
;TODO: 
; print line numbers
; read from stdin

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

%macro open 3				;open filepath, flags, perm
	push %1				;filepath
	push %2				;flags(ro)
	push %3				;perm
	call _open
	add rsp, 24			;clear stack
%endmacro

%macro filesize 1			;filesize fd
	mov rdi, %1			;save fd in rdi
	call _filesize
%endmacro

%macro mmap 1				;mmap length
	push 0				;addr (let kernel decide)
	push %1				;length
	push 0x2				;prot (PROT_WRITE)
	push 33				;flags (MAP_SHARED|MAP_ANONYMOUS)
	push -1				;fd (ignore)
	push 0				;offset (0, because MAP_ANONYMOUS)
	call _mmap			;map memory to load its own content
	add rsp, 48			;clear stack
%endmacro

%macro read 3				;read fd, buf, count
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
	error: db 'File not found',0
	nl: db 0xA,0
	zero: db '0 ',0
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
		ret			;result goes in rdi

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

	;the code below does something like
	;this (for both upper and lowercase):
	;
	;str = 'string read from file';
	;charset = 'abcdefghijklmnopqrstuvxwyz';
	;i=0;
	;while(i<27){
	;	for(j=0;j<=strlen(str);j++){
	;		if(str[j] == 'z'){
	;			str[j] = 'a';
	;		}else{
	;			str[i] = charset[j+1];
	;		}
	;	i++;
	;	print(str);

	_magic:				;encode/decode
		push rbp
		mov rbp, rsp
		mov rax, [rbp+16]	;mem addr with file contents
		mov rbx, [rbp+24]	;filesize
		push rbx		;save filesize for later
		add rbx, rax		;addr+filesize
		push rax		;popped at the end

		mov rcx, 1		;ROT index
	_checkz:
		cmp byte [rax],0x7A	;check if current char n is z
		jnz _checkZ		;if not, go check if it's a capital z
		mov byte [rax],0x60	;if so, set current char to before 'a'
	_checkZ:
		cmp byte [rax],0x5A	;check if current char is Z
		jnz _checkSpace		;if not, go check if it's a space
		mov byte [rax],0x40	;if so, set current char to before 'A'
	_checkSpace:
		cmp byte [rax],0x20	;check if current byte is 0x20 (space)
		jnz _continue		;if not, continue normally
		jmp _isSpace		;if so, do not add 1
	_continue:
		add byte [rax], 1	;add 1 to char (e.g: a+1 = b)
	_isSpace:
		inc rax			;move char to next position >>
		cmp rax, rbx		;is the current position the end?

		jle _checkz		;if not, goto next byte
		mov rdx, [rsp]		;mov string encoded to rdx
		mov r9, [rsp+8]		;filesize
		push rax		;saving...
		push rcx		;saving...
		push rdx		;saving...
		write 1, rdx, r9	;print the encoded string
		write 1, nl, 2		;print newline
		pop rdx			;retrieving...
		pop rcx			;retrieving...
		pop rax			;retrieving...
		inc rcx			;next index
		mov rax, rdx		;make rax its initial value
		cmp rcx, 25		;25 bc/ original was already printed
		jle _checkz		;if index >=25, repeat
		pop rax			;retrieve addr
		leave
		ret

	_usage:
		write 1, usage, 27

	_exit:
		exit

	_notfound:
		write 1, error, 15
		exit
; ================ MAIN

	_start:
		pop rax			;argc
		cmp rax, 2
		jl _usage		;if argv is less than 2

		mov rax, [rsp+8]	;argv[1]
		push rax		;save argv on stack
		open rax, 0, 0		;path, flags (R/W), perm
		cmp rax, 0		;fd
		jl _notfound		;if fd<0 then exit
		push rax 		;save fd in stack
		filesize rax		;get filesize from fd = n
		cmp rax, 0
		jz _exit		;exit if filesize = 0

		push rax		;save filesize (n) in stack
		mmap rax		;maps n bytes

		mov rcx, [rsp]		;filesize
		mov rbx, [rsp+8]	;fd
		mov rdx, rax		;pointer to allocated memory
		push rdx		;save this pointer in stack
		push rdx
		read rbx, rax, rcx
		mov r9, rax		;save number os bytes read
		pop rdx			;retrieve pointer to memory
		write 1, rdx, rax	;print with index 0
		write 1, nl, 1		;print newline
		call _magic		;encode/decode
		exit

;Nicholas Ferreira - 23/07/21
;Testing syscalls

global _start

%define PATH_MAX 4096   ;chars in a path name including NUL

section .text
	_start:
		mov eax, 89         ;syscall for readlink()
		mov rdi, self       ;"/proc/self/exe"
		mov rsi, rsp        ;buffer (return of mmap syscall, saved on stack)
		mov rdx, PATH_MAX   ;size of buffer
		syscall             ;the filename will go to stack
				    ;rax = numbers of bytes written

		lea rbx, [rsp+rax]  ;rsp+rax = last digit of string
		mov [rbx], byte 0   ;append nullbyte to string (since readlink() doesn't do this)
		mov rdi, rsp        ;string whose size will be calculated must be at rdi

		xor rcx, rcx        ;rcx = 0
		not rcx             ;rcx = -1
		xor al,al           ;value that will be searched for by scasb
		cld                 ;CLears the Direction flag (data goes onwards)
				    ;repne = repeat while not equal
		repne scasb         ;search for the first occurrence of a byte in AL in rdi
		not rcx             ;uninvert rcx
		dec rcx             ;scasb will decrease its value including when it found NUL, so we decrease 1
				    ;rcx = len(path)

		mov eax, 1          ;syscall for write()
		mov rdi, 1          ;write to stdout (i.e. print)
		mov rsi, rsp        ;get filename from stack
		mov rdx, rcx        ;string to be printed
		syscall

		mov eax, 60         ;exit
		mov dil, 0          ;return code
		syscall

section .data
	self: db '/proc/self/exe'

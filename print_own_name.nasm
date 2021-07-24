global _start
section .text
	_start:
		pop rbx       ;argc
		pop rdi       ;argv[0] (path of the executable)
		mov rbx,rdi   ;saving argv to be used in write() 
		not rcx       ;rcx = -1
		cld           ;CLears the Direction flag (data goes onwards)
		repne scasb   ;search for the first occurrence of a byte in AL
		not rcx       ;uninvert rcx
		dec rcx       ;scasb will decrease its value including when it found NUL, so we decrease 1
		              ;rcx = len(path)
		mov eax, 1    ;syscall for write()
		mov rdi, 1    ;stdout
		mov rsi, rbx  ;get filename from rbx
		mov rdx, rcx  ;string to be printed
		syscall

		mov eax, 60   ;exit
		mov dil, 0    ;return code
		syscall 

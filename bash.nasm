;Nicholas Ferreira - 15/07/21
;Testing syscalls

global _start
section .text
	_start:
		mov eax, 59 ;execve syscall offset
		mov rdi, shell ; "/bin/bash"
		mov sil, 0 ;argv
		mov dl, 0 ;envp
		syscall

		mov al, 60 ;syscall number for "exit"
		mov dil, 0
		syscall
section .data
	shell: db '/bin/bash'

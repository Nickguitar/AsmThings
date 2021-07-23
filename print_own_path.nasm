global _start

%define PATH_MAX 4096 ; chars in a path name including nul

section .text
	_start:

		mov eax, 9        ;syscall for mmap (to allocate memory)
		mov rdi, 0        ;kernel chooses the (page-aligned) address at which to create the mapping
		mov rsi, 128      ;length of mapping
		mov rdx, 0x2      ;PROT_WRITE
		mov r10, 33       ;MAP_PRIVATE
		mov r8, -1        ;fd (ignore)
		mov r9, 0         ;offset
		syscall           ;returns mapping address at rax
		push rax          ;save mmap return on stack
				  ;this will be user in readlink()

		mov eax, 89       ;syscall for readlink()
		mov rdi, self     ;"/proc/self/exe"
		mov rsi, [rsp]    ;buffer (return of mmap syscall, saved on stack)
		mov rdx, PATH_MAX ;size of buffer
		syscall           ;filename goes to stack

		mov eax, 1        ;syscall for write()
		mov rdi, 1        ;write to stdout (i.e., print)
		mov rsi, [rsp]    ;get filename from stack
		mov rdx, PATH_MAX
		syscall

		mov eax, 60       ;exit
		mov dil, 0        ;return code
		syscall

section .data
	self: db '/proc/self/exe' 

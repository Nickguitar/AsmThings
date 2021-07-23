;Nicholas Ferreira - 14/07/21
global _start ;set entrypoint at label _start
section .text
  _start:
    ;rax = system call number
    ;rdi = 1st argument
    ;rsi = 2nd argument
    ;rdx = 3rd argument

    ; ssize_t write(int fd, const void *buf, size_t count);
    mov rax, 1 ;syscall number for "write" in unistd_64
    mov rdi, 1 ;first argument, fd. corresponds to stdout
    mov rsi, hello_world ;address where the string is located, refered by it's label in .data
    mov rdx, length ;address where the size of string is located
    syscall ;call "write" with the provided arguments

    ; exit
    mov rax, 60 ;syscall number for "exit"
    mov rdi, 0 ;first argument, value 0
    syscall ;call "exit" with exit status of 0

section .data
	hello_world: db 'Hello world' ; db: define byte
	length: equ $-hello_world ; set "length" to be equal to the current address minus the address of hello_world.
				  ; this difference is exactly the length of the string "Hello world"

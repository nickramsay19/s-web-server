.global	_start

.equ            SYSCALL_SYS_EXIT,        60         # sys_exit = 60 on 64 bit

.text
_start:
    call        main
    movq        %rax,                   %rbx        # move main's return value to the exit code in ebx
    movq        $SYSCALL_SYS_EXIT,      %rax
    syscall

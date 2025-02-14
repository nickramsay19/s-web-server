.global         main

.equ            AF_INET,                2           # IPv4 internet protocols domain
.equ            ADDR,                   0           # 127.0.0.1 in network byte order
.equ            PORT,                   0x901F      # 8080 little-endian

.text
main:
    # prologue
    pushq       %rbp                                # save old base pointer
    movq        %rsp,                   %rbp        # set new base pointer

    call        listen

    movq        $0,                     %rax

    leave                                           # restore %rbp from stack
    ret 

.data
sockaddr_in:
    .word       AF_INET                             # sin_family (AF_INET is usually 2)
    .word       PORT                                # sin_port
    .long       ADDR                                # sin_addr
    .zero       8                                   # sin_zero: 8 bytes of zero padding

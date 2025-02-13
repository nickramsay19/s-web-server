# rdi - 1st arg
# rsi - 2nd arg
# rdx - 3rd arg
# rcx - 4th arg
# r9 - 5th arg
# r10 - 6th arg
# rsp - stack pointer
# rbp - frame pointer

.equ            SYSCALL_READ,           0
.equ            SYSCALL_WRITE,          1
.equ            SYSCALL_CLOSE,          3
.equ            SYSCALL_MMAP,           9
.equ            SYSCALL_MUNMAP,         11
.equ            SYSCALL_SOCKET,         41
.equ            SYSCALL_CONNECT,        42
.equ            SYSCALL_ACCEPT,         43
.equ            SYSCALL_BIND,           49
.equ            SYSCALL_LISTEN,         50
            
.equ            AF_INET,                2           # IPv4 internet protocols domain
.equ            SOCK_STREAM,            1           # reliable, sequenced byte streams
.equ            SOMAXCONN,              255         # maximum backlog queue of web requests
            
.equ            ADDR,                   0           # 127.0.0.1 in network byte order
.equ            PORT,                   0x901F      # 8080 little-endian

.global	listen
.text
listen:
    # prologue
    pushq       %rbp                                # save old base pointer
    movq        %rsp,                   %rbp        # set new base pointer

    # create a socket
    movq        $SYSCALL_SOCKET,        %rax
    movq        $AF_INET,               %rdi        # domain
    movq        $SOCK_STREAM,           %rsi        # socket type
    movq        $0,                     %rdx        # protocol, leave as default
    syscall 
    pushq       %rax    

    # bind the socket to a port 
    movq        $SYSCALL_BIND,          %rax 
    movq        (%rsp),                 %rdi        # sockfd
    lea         sockaddr_in(%rip),      %rsi        # address to bind to information
    movq        $16,                    %rdx        # size of sockaddr_in
    syscall     

    # listen on the socket      
    movq        $SYSCALL_LISTEN,        %rax    
    movq        (%rsp),                 %rdi        # sockfd
    movq        $SOMAXCONN,             %rsi        # backlog
    syscall 

    # allocate space for a response buffer
    #movq        $255,                   %rdi        # 255 bytes
    #call        alloc   
    #pushq       %rax   

accept: 
    # copy data into response buffer  
    leaq        (%rsp),                 %rbx        # get buf from stack
    leaq        (%rbx),                 %rbx        # get the buf pointer address

    movq        %rbx,                   %rdi        # dest
    leaq        stat_ok(%rip),          %rsi        # src
    movq        $16,                    %rcx        # length
    cld                                             # ensure DF is clear (if not already)
    rep movsb 

    #addq        %rcx,                   %rbx  

    #movq        %rbx,                   %rdi
    #leaq        res_header(%rip),       %rsi
    #movq        $64,                    %rcx
    #rep movsb   
    #addq        %rcx,                   %rdi
    #leaq        res_html(%rip),         %rsi
    #movq        $171,                   %rcx
    #rep movsb 

    # accept an incoming connection 
    movq        $SYSCALL_ACCEPT,        %rax
    movq        8(%rsp),                %rdi        # sockfd
    xorq        %rsi,                   %rsi        # addr = NULL
    xorq        %rdx,                   %rdx        # addrlen = NULL
    syscall 
    movq        %rax,                   %rbx        # save the request fd

    

    # write http response   
    movq        $SYSCALL_WRITE,         %rax
    movq        %rbx,                   %rdi        # fildes
    lea         (%rsp),                 %rsi        # buf
    movq        $255,                   %rdx        # nbyte
    syscall 
    cmpq        $0,                     %rax
    jne         close   

    jmp         accept  

close:  
    # close the socket  
    movq        $SYSCALL_CLOSE,         %rax
    movq        (%rsp),                 %rdi
    syscall 

    movq        $723,                   %rax

    # epilogue  
    leave                                           # restore %rbp from stack
    ret 

# memory allocation method
alloc:  
    movq        $SYSCALL_MMAP,          %rax
    movq        %rdi,                   %rsi        # length
    xorq        %rdi,                   %rdi        # addr = NULL
    movq        $3,                     %rdx        # prot = PROT_READ|PROT_WRITE = 1|2
    movq        $0x22,                  %rcx        # flags = MAP_PRIVATE|MAP_ANONYMOUS = 2|0x20
    movq        $-1,                    %r8         # fd = -1
    xorq        %r9,                    %r9         # offset = 0
    syscall
    ret

free:
    mov     $11,    %rax    # munmap syscall
    syscall
    ret

.section .data
sockaddr_in:
    .word       AF_INET                             # sin_family (AF_INET is usually 2)
    .word       PORT                                # sin_port
    .long       ADDR                                # sin_addr
    .zero       8                                   # sin_zero: 8 bytes of zero padding

stat_ok:
    .ascii      "HTTP/1.1 200 OK\n"

res_header:
    .ascii      "Content-Type: text/html; charset=utf-8\n"
    .ascii      "Content-Language: en-US\n\n"

res_html:
    .asciz      "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\"><title>A simple webpage</title></head><body><h1>Simple HTML webpage</h1><p>Hello, world!</p></body></html>\n"

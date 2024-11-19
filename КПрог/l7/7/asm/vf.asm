section .data
src_path db "/home/mikd/asm/cypher_temp", 0
dst_path db "/home/mikd/asm/cypher_temp_enc", 0
buffer times 4096 db 0
key db "12345678901234567890", 0        
key_size dq 0
src_desc dq 0
dst_desc dq 0
time dq 0

section .text
global vigenere_cipher
vigenere_cipher:
    mov [rel key_size], rdi
    mov rcx, rdi
    lea rdi, [rel key]
en_start:
    mov bl, [rsi]
    mov [rdi], bl
    inc rsi
    inc rdi
    loop en_start

    mov rax, 2
    lea rdi, [rel src_path]
    mov rsi, 0               ; O_RDONLY
    mov rdx, 0
    syscall
    test rax, rax
    js file_error
    mov [rel src_desc], rax

    mov rax, 2          
    lea rdi, [rel dst_path] 
    mov rsi, 0x241           ; O_WRONLY | O_CREAT | O_TRUNC (0x1 | 0x40 | 0x200)
    mov rdx, 0o644           ; Режим: Права доступа (rw-r--r--)
    syscall
    test rax, rax
    js file_error
    mov [rel dst_desc], rax 

copy_loop:
    mov rax, 0               ; sys_read
    mov rdi, [rel src_desc]  
    lea rsi, [rel buffer]    
    mov rdx, 4096            
    syscall
    test rax, rax
    jz close_files           
    js file_error
    mov rcx, rax             
    mov [rel time], rcx

    lea rsi, [rel buffer]
    xor rdi, rdi             

cipher_loop:
    xor rbx, rbx
    xor rax, rax
    lea rdx, [rel key]
    add rdx, rdi
    mov bl, byte [rdx]  
    mov al, [rsi]          
    add al, bl
    and al, 0x7F            
    mov [rsi], al
    inc rsi
    inc rdi
    cmp rdi, [rel key_size]
    jne .continue
    xor rdi, rdi
.continue:
    loop cipher_loop
    xor rdi, rdi

en_end_loop:
    mov rcx, [rel time]
    mov rax, 1               ; sys_write
    mov rdi, [rel dst_desc]  
    lea rsi, [rel buffer]    
    mov rdx, rcx             
    syscall
    js file_error
    jmp copy_loop

close_files:    
    mov rax, 3               ; sys_close 
    mov rdi, [rel dst_desc] 
    syscall

    mov rax, 3               ; sys_close 
    mov rdi, [rel src_desc] 
    syscall

    ret

file_error:
    mov rdi, 1
    mov rax, 60
    syscall

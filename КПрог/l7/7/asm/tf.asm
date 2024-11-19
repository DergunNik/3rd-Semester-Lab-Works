global transposition_cipher

section .data
src_path db "/home/mikd/asm/cypher_temp", 0
dst_path db "/home/mikd/asm/cypher_temp_enc", 0
buffer times 64 db ' '
z db 0
new_buffer times 64 db ' '
src_desc dq 0
dst_desc dq 0
column_size dq 0
row_size dq 0
time dq 0

section .text
transposition_cipher:
    mov [rel row_size], rdi    
    mov [rel column_size], rsi

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
    mov rsi, 0x241           ; Флаги: O_WRONLY | O_CREAT | O_TRUNC (0x1 | 0x40 | 0x200)
    mov rdx, 0o644           ; Режим: Права доступа (rw-r--r--)
    syscall
    test rax, rax
    js file_error
    mov [rel dst_desc], rax

copy_loop:
;    mov rcx, 64
;    lea rsi, [rel buffer]
;space_loop:
;    mov byte [rsi], ' '
;    inc rsi
;    loop space_loop

    mov rax, 0               ; sys_read
    mov rdi, [rel src_desc]  
    lea rsi, [rel buffer]    
    mov rdx, 64            
    syscall
    test rax, rax
    jz close_files           
    js file_error
    mov rcx, rax             
    mov [rel time], rcx

    mov rcx, [rel row_size]
    lea rdi, [rel new_buffer]
    mov rbx, 0
outer_loop:

        lea rsi, [rel buffer]
        add rsi, rbx

        push rcx
        mov rcx, [rel column_size]
inner_loop:

            mov al, byte [rsi]
            mov [rdi], al
            inc rdi
            add rsi, [rel row_size]

        loop inner_loop
        pop rcx

        inc rbx

    loop outer_loop
    xor rdi, rdi  
    
end_loop:
    mov rcx, [rel time]
    mov rax, 1               ; sys_write
    mov rdi, [rel dst_desc]  
    lea rsi, [rel new_buffer]    
    mov rdx, 64;;;;rcx             
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

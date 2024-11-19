global rand_d

section .text
rand_d:
    rdrand rax            
    and rax, rdi        
    inc rax         
    ret

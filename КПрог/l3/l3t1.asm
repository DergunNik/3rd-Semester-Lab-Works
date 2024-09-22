        .model tiny
        .code
        
main    proc
        org 100h                      
        mov ah, 09h
        mov dx, offset str1   
        int 21h
        call nl
        mov dx, offset str2   
        int 21h
        call nl
        mov dx, offset str3   
        int 21h 
        ret
main    endp    
        
nl      proc
        push ax
        mov ah, 02h
        mov dl, 0ah
        int 21h
        mov dl, 0dh
        int 21h
        pop ax             
        ret    
nl      endp
                               
                                      
        .data
str1    db "first string", '$'
str2    db "2econd string", '$'
str3    db "third string", '$'

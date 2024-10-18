.model tiny

.code
        org 100h

main    proc
        jmp start

start:
        push ds
        push cs
        pop ds

        push ax
        push dx
        mov ah, 09h
        lea dx, [_Hello]
        int 21h
        pop dx
        pop ax
 
        sub ax, bx
        
        pop ds
        retf
main    endp

        _Hello           db      'sub.exe overlay!',0Dh, 0Ah, '$'
        _CrLf            db      0Dh, 0Ah, '$'

end     main

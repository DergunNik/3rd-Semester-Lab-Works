        .model tiny
        .code        
        
        
diff_to macro label1, label2, result_reg 
        push ax
        push bx
        mov ax, [label1]  
        mov bx, [label2]  
        sub ax, bx      
        mov result_reg, ax
        pop bx
        pop ax 
endm    

          
main    proc
start:      
        lea dx, hello_m
        mov ah, 09h
        int 21h
        call new_line
        mov str, 200
        mov ah, 0ah
        mov dx, offset str
        int 21h                   
        mov al, ' '
        mov di, offset str + 2 
        mov bl, 0
        mov cx, 200    
        
sp_check:
        repe scasb
        dec di
        inc cx
        cmp [di], 0dh 
        je cnt_end
        inc bl
        
word_skip:
        cmp [di], ' '
        je sp_check
        cmp [di], 0dh
        je cnt_end
        inc di
        dec cx
        jmp word_skip   
           
cnt_end:
        cmp bl, 0 ; bl contains words number
        jne preloop                       
        lea dx, e_str_m
        call printl
        call new_line
        jmp start
        
preloop:
        cmp bl, 1
        je results 
        dec bl
        mov [w_cntr], bl
        
outer_loop:
        mov ch, 0
        mov cl, [w_cntr]        
        mov dx, 0 ; sets flag
        mov di, offset str + 2 
        
inner_loop:       
        call cmp_ws
        cmp ax, 1
        jne inl1 ; calls find_ws
        mov dx, 1
        call w_swap
inl1:   
        mov di, [beg_fst]
        call find_ws
        mov di, [end_fst]
        loop inner_loop         
         
        cmp dx, 1
        je outer_loop
        
results:
        lea dx, res_str
        call printl
        lea di, str
        add di, 2 
        mov si, offset str
        add si, 1
        mov al, [si]
        mov ah, 0
        add di, ax
        mov al, '$'
        stosb      
        
        call new_line
        mov si, offset str + 2
        mov ah, 06h
        mov di, offset str
        inc di             
        mov cl, [di]
        mov ch, 0
print_c:
        mov dl, [si]
        inc si
        int 21h
        loop print_c
              
        ;lea dx, str
        ;add dx, 2
        ;call printl
        ret      
        
main    endp               
            
            
find_ws proc ; set beg_fst ... end_snd for words positions 
             ; reg di should be pointed to the current str pos
             ; doesn't contain any checks
        push ax   
        push cx
        mov cx,204
        mov al, ' '
        repe scasb
        dec di
        mov offset beg_fst, di 
        repne scasb           
        dec di
        mov offset end_fst, di
        repe scasb
        dec di
        mov offset beg_snd, di
        
f_word_skip:
        cmp [di], ' '
        je f_cont
        cmp [di], 0dh
        je f_cont
        inc di
        jmp f_word_skip
            
f_cont:
        mov offset end_snd, di 
        pop cx
        pop ax    
        ret
find_ws endp 


cmp_ws  proc ; return result in ax: 
             ; 1 (first is bigger), -1(second is greater), 0 (strings are the same size)
        push bx
        push cx
        push dx
        push si
        push di
        call find_ws
        mov si, [beg_fst]
        mov di, [beg_snd]
        diff_to end_fst, beg_fst, cx
        diff_to end_snd, beg_snd, dx        
        cmp cx, dx  
        jae str_comp
        mov cx, dx
         
str_comp:         
        repe cmpsb          
        ja first_is_greater
        jb second_is_greater               
        mov ax, 0 ; are equal         
        jmp done

first_is_greater:
        mov ax, 1           
        jmp done

second_is_greater:
        mov ax, -1          

done:
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        ret
cmp_ws  endp
       
new_line proc
        push ax
        push dx
        mov ah, 02h
        mov dl, 0ah
        int 21h
        mov dl, 0dh
        int 21h
        pop dx
        pop ax
        ret
new_line endp  
        
printl  proc ; requires string pointer in dx
        push ax
        call new_line
        mov ah, 09h
        int 21h 
        pop ax                 
        ret
printl  endp
      
      
w_swap  proc ; swap words using find_ws
        push di
        push si
        push cx
        lea di, buf
        mov si, [beg_snd]
        diff_to end_snd, beg_snd, cx
        rep movsb            
        diff_to beg_snd, end_fst, cx
        mov al, ' '
        rep stosb
        mov si, [beg_fst]  
        diff_to end_fst, beg_fst, cx
        rep movsb
        diff_to end_snd, beg_fst, cx
        mov di, [beg_fst]
        lea si, buf
        rep movsb
        pop cx
        pop si
        pop di
        ret
w_swap  endp
           
                                     
        .data
size    equ 200
str     db 202 dup (?)
flag    db ? ; 0 or 1
beg_fst dw ?
end_fst dw ?
beg_snd dw ?
end_snd dw ?  
w_cntr  db 0
hello_m db "Enter a string to sort$"
e_str_m db "The string can't be empty!$"
res_str db "Sorted string:$"
buf     db ?

        end
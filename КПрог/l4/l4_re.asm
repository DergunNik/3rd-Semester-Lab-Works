        .model tiny
        .code
        org  100h
        rows equ 5
        columns equ 6
        
main    proc
        lea dx, entr_str
        call printl    
        
main_loop:
        lea dx, wrong_in_str
        call printl
        call read_in_buf
        call new_line
        call manage_input
        cmp bx, 0
        je fail
        cmp bx, 1
        je find_mins
        
nmbr_entr:
        lea dx, num_in_str
        call printl
        call read_in_buf
        call new_line
        call check_number
        cmp bx, 0
        je fail
        mov bx, 0
        mov dl, [indexes + 1]
        mov dh, 0
        add bx, dx
        add bx, dx
        mov dl, [indexes]
        mov ax, columns * 2
        mul dx
        add bx, ax ; final index
        mov dx, [number] 
        mov si, offset matrix
        add si, bx
        mov [si], dx
        jmp done
        
done:
        lea dx, done_str
        call printl
        jmp main_loop
        
fail:
        lea dx, fail_str
        call printl
        jmp main_loop 
        
find_mins:
        mov cx, 0 ; outer cntr  
        
mins_loop_o:                        
        mov dx, 0 ; inner cntr
        mov ax, 0 ; sum h
        mov bx, 0 ; sum l
        
mins_loop_i:                    
        mov si, offset matrix
        push ax
        push dx
        mov ax, columns * 2 
        mul dx
        add si, ax 
        mov ax, cx
        mov dx, 2
        mul dx
        add si, ax
        pop dx     
        pop ax
        add bx, [si]
        ;add bx, [offset matrix + cx * 2 + dx * columns * 2]
        adc ax, 0    
        inc dx
        cmp dx, rows
        jb mins_loop_i
        
        mov si, offset sums
        push ax
        push dx
        mov ax, cx
        mov dx, 4
        mul dx
        add si, ax     
        pop dx     
        pop ax
        mov [si], bx
        add si, 2
        mov [si], ax
        ;mov [offset sums + cx * 4], bx
        ;mov [offset sums + cx * 4 + 2], ax
        inc cx
        cmp cx, columns   
        jb mins_loop_o
        
        mov dx, 0 ; min sum
        mov cx, 1
        
cmp_min:
        call set_sdi_main
        mov ax, [si]
        cmp ax, [di]                    
        ;mov ax, [offset sums + cx * 4 + 2] | si high byte
        ;cmp ax, [offset sums + dx * 4 + 2] | di
        jge not_new_min
        jmp new_min
not_new_min:
        sub si, 2 
        sub di, 2
        mov ax, [si]
        cmp ax, [di]
        ;mov ax, [offset sums + cx * 4] ; low byte
        ;cmp ax, [offset sums + dx * 4]
        jge cmp_end
new_min:                      
        mov dx, cx   
cmp_end:
        inc cx
        cmp cx, columns
        jb cmp_min        
        ; now dx contains one of the min sum
        
        mov cx, 0
        mov bx, 0 ; offset for mins array

cmp_with_min:
        call set_sdi_main
        mov ax, [di]
        cmp ax, [si]
        ;mov ax, [offset sums + dx * 4 + 2] | di high byte
        ;cmp ax, [offset sums + cx * 4 + 2] | si
        jne not_equal
        sub si, 2 
        sub di, 2
        mov ax, [di]
        cmp ax, [si]
        ;mov ax, [offset sums + dx * 4] ; low byte
        ;cmp ax, [offset sums + cx * 4]
        jne not_equal
        mov si, offset mins
        add si, bx
        mov [si], cl
        ;mov [offset mins + di], cx
        inc bx   
not_equal:             
        inc cx
        cmp cx, columns
        jb cmp_with_min
        
        lea dx, res_str
        call printl
        
        mov cx, 0
res_out_loop:
        mov si, offset mins
        add si, cx
        mov dl, [si]
        ;mov dl, [offset mins + cx] 
        cmp dl, -1
        je m_ret
        mov ax, '0'
        add ax, [si]
        mov dl, al
        ;mov dl, '0' + [offset mins + cx]         
        inc cx
        mov ah, 02h
        int 21h
        mov dl, ','
        int 21h
        mov dl, ' '
        int 21h
        jmp res_out_loop

m_ret:  
        ret
main    endp
    

set_sdi_main proc ; si = offset sums + cx * 4 + 2
                  ; di = offset sums + dx * 4 + 2       
        push ax
        push dx
        mov si, offset sums + 2
        mov di, si
        mov ax, dx
        mov dx, 4
        mul dx
        add di, ax
        mov ax, cx
        mov dx, 4
        mul dx
        add si, ax
        pop dx
        pop ax
        ret
set_sdi_main endp    


skip_spaces proc ; di must be pointed to the str
        push cx
        push ax
        mov cx, -1
        mov al, ' '
        repe scasb        
        dec di
        pop ax
        pop cx
        ret
skip_spaces endp


manage_input proc; return in bx if the input in buf is correct
                ; 0 - wrong input, 1 - E input, 2 - indexes
        push di
        push dx
        
        lea di, buf + 2
        call skip_spaces
        cmp [di], 'E'
        mov dh, 1
        mov bx, 1
        je check_ending
        
        mov dh, 0
        cmp [di], '0' ; indexes check
        jb wrong_in
        cmp [di], '0' + rows - 1
        ja wrong_in
        mov dl, [di]
        sub dl, '0'
        mov offset indexes, dl
        inc di 
        call skip_spaces
        cmp [di], '0'
        jb wrong_in
        cmp [di], '0' + columns - 1
        ja wrong_in 
        mov dl, [di]              
        sub dl, '0'
        mov offset indexes + 1, dl
check_ending:
        inc di
        call skip_spaces
        cmp [di], 0dh
        jne wrong_in
        cmp dh, 1
        je mi_ret
        mov bx, 2 
        jmp mi_ret; indexes are all right        
        
wrong_in:
        mov bx, 0

mi_ret:
        pop dx
        pop di
        ret     
manage_input endp           
          

check_number proc; return in bx if the number in buf is correct (1 or 0)
                 ; write number in dw number
        push cx
        push si
        push di
        push dx
        push ax
                 
        lea di, buf + 2
        call skip_spaces
        mov si, di
        cmp [si], '-' 
        mov dl, 0 ; dl shows if the number is negative
        jne pos_num_in
        mov dl, 1
        inc si 
pos_num_in:
        push si
        mov cx, 0 ; cntr for num chars
        
cnt_chars:            
        cmp [si], 0dh 
        je end_of_num
        cmp [si], ' '
        je space_check 
        cmp [si], '0'
        jb wrong_num_si
        cmp [si], '9'
        ja wrong_num_si
        inc si
        inc cx 
        jmp cnt_chars 
        
space_check:
        cmp cx, 0
        je wrong_num_si
        mov di, si
        call skip_spaces
        mov si, di
        cmp [si], 0dh 
        je end_of_num
        jmp wrong_num_si
               
end_of_num:
        pop si
        cmp cx, 0
        je wrong_num
        cmp cx, 5
        ja wrong_num
        je max_check
        
parse_to_hex:
        push dx
        mov ax, si
        add ax, cx
        dec ax
        mov si, ax 
        mov ax, 0
        mov di, 1
        mov bx, 0 ; result
parse_loop:
        mov ax, [si]
        mov ah, 0
        sub ax, '0'
        mul di
        add bx, ax
        mov ax, di
        push bx
        mov bx, 10
        mul bx
        pop bx
        mov di, ax
        dec si
        loop parse_loop
        pop dx
        cmp dl, 1
        push dx
        je mk_neg
        jmp save_num 
        
mk_neg:        
        not bx
        add bx, 1
        jmp save_num
        
max_check:
        push cx
        lea di, max_nmbr_str 
        push si
        repe cmpsb
        pop si
        pop cx
        ja wrong_num        
        jmp parse_to_hex
        
save_num:
        pop dx
        mov [number], bx
        mov bx, 1
        jmp cn_ret

wrong_num_si:
        pop si                
wrong_num:
        mov bx, 0
        
cn_ret:
        pop ax
        pop dx
        pop di
        pop si
        pop cx
        ret        
check_number endp
                         

read_in_buf proc 
        push dx
        push ax
        lea dx, buf
        mov ah, 0ah
        int 21h
        pop ax
        pop dx
        ret
read_in_buf endp   
   
                         
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
        mov ah, 09h
        int 21h 
        pop ax
        call new_line                 
        ret
printl  endp
                         
                         
        .data
matrix  dw 30 dup(0)                                                                                 
num_in_str db "Enter integer decimal numbers in [-32767, 32767] range.$"
entr_str db "Enter 5x6 matrix elements (indexes in format 'row column' (0..4, 0..5) and then integer decimal numbers in [-32767, 32767] range) or enter E to fill the remaining elements with zeros.", 10, 13,"Program is returning columns numbers with minimal elements sum.$"
wrong_in_str db "Input must be indexes in format 'row column' (0..4, 0..5) or character E.$"
res_str db "Next columns have minimal elements sum:$" 
max_nmbr_str db "32767"
buf     db 7,?, "$$$$$$$"
done_str db "Recorded.$"
fail_str db "Failed.$"
indexes db ?,?
number dw 0
sums dw 12 dup(0)
mins db 6 dup(-1)
mins_end db -1
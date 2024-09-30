.model small          
.stack 100h            
.code

fopen   macro
        data_to_ds
        ;lea dx, file_path
        mov dx, path_ptr
        es_to_ds
        mov ah, 3Dh
        mov al, 00h
        int 21h
        jc file_err
        data_to_ds
        mov descriptor, ax
        mov ax, ds
        mov es, ax
        
endm

fclose  macro ; bx contatins file descriptor
        mov ah, 3Eh 
        int 21h
endm

data_to_ds macro
        push ax
        mov ax, @data       
        mov ds, ax
        pop ax
endm

es_to_ds macro
        push ax
        mov ax, es
        mov ds, ax
        pop ax
endm

main    proc
        data_to_ds          

        mov ah, 62h        
        int 21h            
        mov es, bx         
        
        mov al, es:[80h]    
        or al, al           
        jz _no_args          
    
        ; argc parse
        mov cx, -1 
        mov di, 81h
        mov bx, es
        mov ds, bx
find_param:
        mov al, ' ' 
        repz scasb 
        dec di 
        push di

        data_to_ds 
        inc byte ptr argc 
        mov ax, es 
        mov ds, ax 
        
        mov si, di 
scan_params:
        lodsb 
        cmp al, 0Dh 
        je params_ended 
        cmp al, 20h 
        jne scan_params  
        dec si  
        mov byte ptr [si], 0 
        mov di, si 
        inc di
        jmp short find_param 
params_ended:
        dec si

        data_to_ds 
        mov ah, 2
        cmp ah, argc
        je file_work
        mov ah, 3
        cmp ah, argc
        jne _wrong_args_num
        pop di
        cmp byte ptr es:[di], 0Dh
        jne _wrong_args_num
        jmp file_work

_no_args:
        jmp no_args

file_work:
        mov ax, es 
        mov ds, ax 
        pop si
        call check_number
        cmp bx, 1
        jne bad_size
        data_to_ds
        mov num_ptr, si
        pop si
        mov path_ptr, si
        
        fopen
        call contract_func
        or ax, ax
        jz skip_output
        call print_result
skip_output:
        fclose

        jmp main_ret

_wrong_args_num:
        jmp wrong_args_num

file_err:
        cmp ax, 02h
        je file_not_found
        cmp ax, 03h
        je path_not_found
        cmp ax, 05h
        je access_denied
        
        lea dx, msg_other_file_err
        jmp print_err

path_not_found:
        lea dx, msg_path_not_found
        jmp print_err

file_not_found:
        lea dx, msg_file_not_found
        jmp print_err

access_denied:
        lea dx, msg_access_denied
        jmp print_err

bad_size:
        lea dx, msg_bad_size
        jmp print_err

no_args:
        lea dx, msg_no_args
        jmp print_err

wrong_args_num:
        lea dx, msg_wrong_num_args

print_err:
        mov ax, @data       
        mov ds, ax
        call printl

main_ret:
        mov ah, 4Ch
        int 21h
main    endp

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
                                
printl  proc ; requires string pointer in ds:dx
        push ax
        mov ah, 09h
        int 21h 
        pop ax
        call new_line                 
        ret
printl  endp

check_number proc; return in bx if the number is correct (1 or 0)
                 ; write number in dw required_size
        push cx
        push si
        push di
        push dx
        push ax

        push si         
        mov cx, 0 ; cntr for num chars
        
cnt_chars:            
        cmp byte ptr es:[si], 0dh 
        je end_of_num
        cmp byte ptr es:[si], ' '
        je end_of_num 
        cmp byte ptr es:[si], '0'
        jb wrong_num_si
        cmp byte ptr es:[si], '9'
        ja wrong_num_si
        inc si
        inc cx 
        jmp cnt_chars 
               
end_of_num:
        pop si
        cmp cx, 0
        je wrong_num
        cmp cx, 5
        ja wrong_num
        jne parse_to_hex

max_check:
        push cx
        lea di, max_nmbr_str
        push es 
        mov ax, @data       
        mov es, ax
        push si
        repe cmpsb
        pop si
        pop es
        pop cx
        ja wrong_num        
        
parse_to_hex:
        mov ax, si
        add ax, cx
        dec ax
        mov si, ax 
        mov ax, 0
        mov di, 1
        mov bx, 0 ; result

parse_loop:
        mov al, byte ptr es:[si]
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
        
save_num:
        data_to_ds ;;;;;;;;;;;;;;
        mov [required_size], bx
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

contract_func proc ; return in ax if reading has finished without error
                   ; 1 - no error, 0 - was error
        push bx
        push cx
        push dx
        push si
        push di
        push bp
        push es
        push ds

        data_to_ds
        mov ax, ds
        mov es, ax
        xor si, si
        xor bp, bp ; not ended flag 
        mov str_beg_ptr, offset buf

fread_loop:
        push bx
        mov bx, descriptor
        mov ah, 3Fh            
        lea dx, buf
        mov cx, buf_size      
        int 21h
        pop bx
        jc _fread_error        
        or ax, ax             
        jz _manage_fe
        mov cx, ax           
        lea di, buf 

        ;check reminder from prev buf line
        or bp, bp
        jnz has_rem
        mov si, 0   
has_rem:
        mov bp, 0

parse_buffer:
        mov al, 0Ah
        repne scasb        
        dec di
        cmp es:[di], al
        je manage_nl       

manage_be:
        inc di
        mov bp, 1
        sub di, str_beg_ptr
        add si, di
        add di, str_beg_ptr
        mov word ptr str_beg_ptr, offset buf
        jmp fread_loop

_fread_error:
        jmp fread_error

_fread_loop:
        jmp fread_loop

_func_ret:
        jmp func_ret

_manage_fe:
        jmp manage_fe

manage_nl:
        inc di
        sub di, str_beg_ptr
        add si, di
        add di, str_beg_ptr

        ;dec si ; to remove 0Dh from the end
        sub si, 2
        cmp si, [required_size]
        jae isnt_required_size
        inc word ptr [str_cntr]
isnt_required_size:
        xor si, si

        mov bp, 0
        mov word ptr str_beg_ptr, offset buf
        or cx, cx
        jz _fread_loop
        mov word ptr str_beg_ptr, di
        jmp parse_buffer

manage_fe:
        ;check reminder from prev buf line
        or bp, bp
        jnz _has_rem
        mov si, 0   
_has_rem:
        mov bp, 0
        
        cmp si, [required_size]
        jae func_ret
        inc word ptr [str_cntr]
        jmp func_ret

fread_error:
        xor ax, ax
        lea dx, msg_fread_err
        call printl
        jmp func_ret_only
        
func_ret:
        mov ax, 1
func_ret_only:
        pop ds
        pop es
        pop bp
        pop di
        pop si
        pop dx
        pop cx
        pop bx
        ret
contract_func endp

print_result proc
        push ax
        push bx
        push cx
        push dx
        push di

        mov ax, str_cntr       
        lea di, buffer + 5      
        mov byte ptr [di], '$'  

convert_loop:
        xor dx, dx             
        mov bx, 10          
        div bx                  
        add dl, '0'             
        dec di                
        mov [di], dl         
        or ax, ax               
        jnz convert_loop       

        lea dx, [di]      
        mov ah, 09h          
        int 21h

        call new_line

        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret
print_result endp

.data
        newline db 0Dh, 0Ah, "$"  
        msg_no_args db "No arguments provided.$"
        msg_wrong_num_args  db  "Wrong number of arguments provided.$"
        argc db 0
        num_ptr dw ?
        path_ptr dw ?
        required_size dw ?
        max_nmbr_str db "65535"
        msg_bad_size db "String size must be an integer from 0 to 65535.$"
        buf_size equ 50
        buf db buf_size dup ('7')
        msg_file_not_found db "File not found.$"
        msg_path_not_found db "Path not found.$"
        msg_access_denied db "Access denied.$"
        msg_other_file_err db "Filer error.$"
        msg_fread_err db "File reading error.$"
        str_cntr dw 0
        buffer db 6 dup (?)
        descriptor dw ?
        str_beg_ptr dw ?
end main

.model small

.stack 200h

ExecOverlayRec  struc
        wStartSeg       dw      ?
        wReloFactor     dw      ?
ExecOverlayRec  ends

.data
        overlay_addr dw 0, 0
        newline db 0Dh, 0Ah, "$"  
        bad_args_provided db "Bad cmd args provided.$"
        mem_er_msg db "Error with memory management.$"     
        max_nmbr_str db "32767"
        div_by_zero_msg db "Division by zero is prohibited.$"
        overlay_err_msg db "Error with overlay.$"
        overflow_err_msg db "Integer overflow has happend.$"
        cmd_args db 138 dup (0Dh), '$'
        left dw ?
        buffer db 6 dup (?)
        buffer_ db 256 dup ('$')
        last_op db 0
        first_op db 0
        mul_path db "mul.exe", 0
        sum_path db "sum.exe", 0
        sub_path db "sub.exe", 0
        div_path db "div.exe", 0
        cmd_args_size db ?
        prev_op db 0
        op db ?
        fnum dw ?
        snum dw ?
        res dw -1
        overlay_seg dw ?
        overlay_offset dw ?
        code_seg dw ?        
        block dd 0, 0
        asErrResizeMem  db      "Resize memory block error", '$'
        asErrReleaseMem db      "Release memory block error", '$'
        asErrAllocMem   db      "Allocate memory block error", '$'
        asErrExec       db      "Exec failed", '$'
.data?
        pars            ExecOverlayRec  <?>
        entry           dd      ?               ; entry point for overlay
        stkseg          dw      ?               ; save SS register
        stkptr          dw      ?               ; save SP register

.code

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

sk_sp_r proc
sk_sp:
        lodsb
        dec si
        cmp al, ' '
        jne sk_sp_ret
        dec si
        jmp sk_sp
sk_sp_ret:
        ret
sk_sp_r endp

mng_mem proc
        mov ax, es
        mov bx, seg zseg
        sub bx, ax
        mov ah, 4ah
        int 21h
        jnc resize_mem_ok
        mov ah, 09h
        lea dx, [asErrResizeMem]
        int 21h
        mov ah, 4Ch
        int 21h
resize_mem_ok:
        ret
mng_mem endp

; result in res variable
; bx = 1 if there was an overflow
load_overlay proc
        mov al, prev_op
        xor ah, ah
        cmp al, op
        je overlay_call
        cmp al, 0
        je overlay_alloc

        ; release memory
        mov ah, 49h
        mov bx, [pars].wStartSeg
        mov es, bx
        int 21h

overlay_alloc:
                                        ; allocate memory for overlay
        mov bx, 1000h                   ; get 64 KB (4096 paragraphs)
        mov ah, 48h                     ; function 48h = allocate block
        int 21h                         ; transfer to MS-DOS
        jnc alloc_ok                    ; jump if allocation failed
        mov ah, 09h
        lea dx, [asErrAllocMem]
        int 21h 
        mov ah, 4Ch
        int 21h
        alloc_ok:
 
        mov [pars].wStartSeg, ax        ; set load address for overlay
        mov [pars].wReloFactor, ax      ; set relocation segment for overlay
 
        mov word ptr [entry+2], ax      ; set segment of entry point
        mov word ptr [entry], 100h
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov [stkseg], ss                ; save root's stack pointer
        mov [stkptr], sp
        mov ax, ds                      ; set ES = DS
        mov es, ax
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov al, op
        mov dx, offset mul_path
        cmp al, 1
        je path_is_found
        mov dx, offset sum_path
        cmp al, 2
        je path_is_found
        mov dx, offset sub_path
        cmp al, 3
        je path_is_found
        mov dx, offset div_path
path_is_found:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        mov bx, offset pars             ; ES:BX = parameter block
        mov ax, 4b03h                   ; function 4bh, subfunction 03h
        int 21h                         ; transfer to MS-DOS
 
        mov ax, _DATA                   ; make our data segment
        mov ds, ax                      ; addressable again
        mov es, ax
 
        cli                             ; (for bug in some early 8088s)
        mov ss, [stkseg]                ; restore stack pointer
        mov sp, [stkptr]
        sti                             ; (for bug in some early 8088s)
 
        jnc exec_ok                     ; jump if EXEC failed
        mov ah, 09h
        lea dx, [asErrExec]
        int 21h
        mov ah, 4Ch
        int 21h
        exec_ok:
        
overlay_call:
                                        ; otherwise EXEC succeeded...
        xor dx, dx
        mov ax, fnum
        mov bx, snum
        push ds                         ; save our data segment
        call dword ptr[entry]           ; now call the overlay
        pop ds                          ; restore our data segment

        mov bl, op
        mov prev_op, bl

use_results:
        mov res, ax
        ret
load_overlay endp

main proc
        mov ax, @data
        mov ds, ax
        call mng_mem
        ; now there is free space to allocate
        
        call copy_cmd_args    

        mov ah, 62h        
        int 21h            
        mov es, bx 
        mov al, es:[80h]    
        or al, al           
        jz no_args__

        ;cmd arg check
        data_to_ds
        mov ax, ds
        mov es, ax
        mov cx, -1
        lea si, cmd_args
        mov dx, -1 ; what was the last variable
find_param:
        mov di, si
        mov al, ' ' 
        repe scasb 
        dec di 

        mov si, di
        lodsb
        dec si
        cmp al, 0Dh 
        je params_ended
        cmp al, '-'
        jne not_minus
        inc si
        lodsb
        sub si, 2
        cmp al, ' '
        je operator_ch
        jmp num_ch

no_args__:
        jmp no_args_

not_minus:
        cmp al, '0'
        jae num_ch
        
operator_ch:
        cmp dx, 1
        je wrong_args
        cmp dx, -1
        je wrong_args
        mov dx, 1
        mov first_op, 1
        call check_operator
        cmp bx, -1
        je wrong_args
        jmp find_param

num_ch: 
        cmp dx, 2
        je wrong_args
        mov dx, 2
        call check_num
        cmp bx, -1
        je wrong_args
        jmp find_param

no_args_:
        jmp no_args

wrong_args:
        lea dx, bad_args_provided
        call printl
        mov ah, 4Ch
        int 21h

params_ended:
        cmp first_op, 0
        je wrong_args

        lea si, cmd_args

find_op_h:
        lodsb
        dec si
        mov bx, 1
        cmp al, '*'
        je find_fnum
        mov bx, 4
        cmp al, '/'
        je find_fnum
        cmp al, 0Dh
        je find_op_l_
        inc si
        jmp find_op_h

params_ended_:
        jmp params_ended

find_op_l_:
        lea si, cmd_args

find_op_l:
        lodsb
        dec si
        mov bx, 2
        cmp al, '+'
        je find_fnum
        mov bx, 3
        cmp al, '-'
        je find_fnum
        cmp al, 0Dh
        je results_
        inc si
        jmp find_op_l

find_fnum:
        mov op, bl
        mov byte ptr es:[si], ' '
        push si
        call sk_sp_r
sp_sk_1:
        lodsb
        dec si
        cmp al, ' '
        jne num_sk_1
        dec si
        jmp sp_sk_1

num_sk_1:
        lodsb
        dec si
        cmp al, ' '
        je fn_read
        dec si
        jmp num_sk_1

results_:
        jmp results
params_ended__:
        jmp params_ended

fn_read:
        inc si
        mov left, si
        call read_num
        mov fnum, bx
        pop si

        ;find_snum
        push si
        mov di, si
        call skip_spaces
        mov si, di
        call read_num
        pop si
        mov snum, bx

        ;calc
        mov al, op
        cmp al, 4 ;'/'
        jne div_check_skip
        xor ax, ax
        cmp snum, ax
        jne div_check_skip
        lea dx, div_by_zero_msg
        call printl
        mov ah, 4Ch
        int 21h

div_check_skip:
        ; load overlay
        call load_overlay
        call write_num
        jmp params_ended__

results:
        call print_result

no_args:
        mov ah, 4Ch
        int 21h
main endp

print_cmd_line proc
        push ax
        push dx

        lea dx, cmd_args
        mov ah, 09h
        int 21h

        pop dx
        pop ax
        ret
print_cmd_line endp

; return bx = -1 if args are bad
; bx: 1 2 3 4 == * + - /
; set si to the first after char
check_operator proc
        push ax
        xor bx, bx
        lodsb
        dec si

        inc bx
        cmp al, '*'
        je good_op_in
        inc bx
        cmp al, '+'
        je good_op_in
        inc bx
        cmp al, '-'
        je good_op_in
        inc bx
        cmp al, '/'
        je good_op_in

bad_op_in:
        mov bx, -1
        pop ax
        ret

good_op_in:
        inc si
        cmp byte ptr es:[si], ' '
        jne bad_op_in

        pop ax
        ret
check_operator endp

; return bx = -1 if args are bad
; rewrite num in memory hexademically
; set si to the first after char
check_num proc; return in bx if the number in buf is correct (1 or 0)
        push cx
        push di
        push dx
        push ax
        
        mov dl, 0 ; dl shows if the number is negative
        cmp byte ptr es:[si], '-' 
        jne pos_num_in
        mov dl, 1
        inc si 
pos_num_in:
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
        je max_check
        jmp pre_end
max_check:                    
        push cx 
        push si
        push di
        mov di, si
        lea si, max_nmbr_str 
        repe cmpsb
        pop di
        pop si
        pop cx
        jbe wrong_num        
        jmp pre_end

pre_end:
        mov bx, 0
        add si, cx
        jmp cn_ret

wrong_num_si:
        pop si

wrong_num:
        mov bx, -1

cn_ret:
        pop ax
        pop dx
        pop di
        pop cx
        ret        
check_num endp

; fill prev num space by spaces
; save number in bx
read_num proc
        push cx
        push di
        push dx
        push ax
        
        mov dl, 0 ; dl shows if the number is negative
        cmp byte ptr es:[si], '-' 
        jne pos_num_in_r
        mov dl, 1
        inc si
pos_num_in_r:
        push si
        mov cx, 0 ; cntr for num chars

cnt_chars_r:            
        cmp byte ptr es:[si], 0dh 
        je end_of_num_r
        cmp byte ptr es:[si], ' '
        je end_of_num_r
        inc si
        inc cx 
        jmp cnt_chars_r 

end_of_num_r:
        pop si
        
;parse_to_hex_r:
        push dx
        push si ; for
        push cx ;   rewriting
        mov ax, si
        add ax, cx
        dec ax
        mov si, ax 
        mov ax, 0
        mov di, 1
        mov bx, 0 ; result
parse_loop_r:
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
        loop parse_loop_r

        pop cx
        pop si
        pop dx
        cmp dl, 1
        push dx
        push si
        push cx
        je mk_neg_r
        jmp save_num_r
        
mk_neg_r:        
        not bx
        add bx, 1

save_num_r:
        pop cx
        pop si
        pop dx
        add cl, dl

        push si
        push cx
space_paste_r:
        mov byte ptr es:[si], ' '
        inc si
        loop space_paste_r
        pop cx
        pop si

pre_end_r:
        pop ax
        pop dx
        pop di
        pop cx
        ret
read_num endp

write_num proc
        push dx
        push di
        push cx               
        mov ax, res
        
        mov cx, 0           

        lea di, buffer_
convert_loop_w:
        xor dx, dx
        mov bx, 10
        div bx
        add dl, '0'
        mov es:[di], dl
        inc di
        inc cx              
        or ax, ax
        jnz convert_loop_w
        
        mov ax, res
        jge neg_res_skip
        mov byte ptr es:[di], '-'
        inc di
        inc cx
neg_res_skip:

        dec di               
        mov si, left

write_loop:
        mov al, es:[di]
        mov byte ptr es:[si], al
        dec di
        inc si
        loop write_loop      

        pop cx                
        pop di
        pop dx
        ret
write_num endp

print_result proc
        push dx
        push di
        push cx              
        
        mov ax, res
        cmp ax, 0
        jge _neg_res_skip1
        neg ax
_neg_res_skip1:

        mov cx, 0            

        lea di, buffer
_convert_loop_w:
        xor dx, dx
        mov bx, 10
        div bx
        add dl, '0'
        mov es:[di], dl
        inc di
        inc cx              
        or ax, ax
        jnz _convert_loop_w
        
        mov ax, res
        cmp ax, 0
        jge _neg_res_skip2
        mov byte ptr es:[di], '-'
        inc di
        inc cx
_neg_res_skip2:

        dec di               
        lea si, buffer_

_write_loop:
        mov al, es:[di]
        mov byte ptr es:[si], al
        dec di
        inc si
        loop _write_loop   
        mov byte ptr es:[si], '$'   

        lea dx, buffer_
        mov ah, 09h
        int 21h

        pop cx                
        pop di
        pop dx
        ret
print_result endp

copy_cmd_args proc
        mov ah, 62h        
        int 21h            
        mov ds, bx 
        mov ax, @data
        mov es, ax

        mov si, 80h
        mov cl, ds:[si]
        xor ch, ch
        inc si
        lea di, cmd_args

        or cx, cx
        jz skip_copy
        rep movsb
skip_copy:
        ret
copy_cmd_args endp

zseg segment
zseg ends 

end main
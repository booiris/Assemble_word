.386

.model flat,stdcall
option casemap:none

includelib msvcrt.lib

printf PROTO C :dword, :vararg
scanf PROTO C :dword, :vararg

.data

id_input dword 22,21,20
id_len dword 3
key dword 0,0,0,0,0,0,0,0,0,0,0,2,2,3,3,0,3,0,0,1,1,0,1,1,1,1,1,0


.data?

str_input byte 1000 dup (?) 
sta_op dword 10000 dup (?)
sta_num dword 10000 dup (?)
temp_out real8 ?
now_state dword ?

.const 
str_out_ans byte '%f', 0
str_out_int byte '%d', 0
str_pop_error byte 'pop error',0ah, 0
str_r_error byte ') error',0ah, 0
str_pre_error byte '+- error',0ah, 0
str_op_error byte 'operation error',0ah, 0

.code

_push PROC uses esi, p_stack, item 
    mov esi, p_stack
    mov ecx, [esi]
    inc ecx
    mov eax, item
    mov [esi+4*ecx], eax
    mov [esi], ecx
    ret
_push ENDP

_top PROC uses esi, p_stack
    mov esi, p_stack
    mov eax, [esi]
    .if eax == 0
        mov eax, 0
        jmp done
    .endif
    mov eax, [esi+4*eax]
    done:
        ret
_top ENDP

_pop PROC uses esi, p_stack
    mov esi, p_stack
    mov eax, [esi]
    .if eax == 0
        invoke printf, offset str_pop_error
        jmp done
    .endif
    dec eax
    mov [esi], eax
    done:
        ret
_pop ENDP

_getnum PROC uses esi, now_index
    LOCAL temp:dword
    mov esi, now_index
    mov eax, [esi-4]
    mov temp, eax
    fild temp
    .if now_state == -1
        mov now_state, 0
        fchs
    .endif
    fstp temp 
    invoke _push, offset sta_num, temp
    ret
_getnum ENDP

_getpr PROC uses esi, operation
    mov esi, offset key
    mov eax, operation
    mov eax, [esi+4*eax]
    ret
_getpr ENDP

_cal_op PROC 
    LOCAL n1:dword, n2:dword
    invoke _top,offset sta_op
    mov edx, eax
    invoke _pop,offset sta_op

    invoke _top,offset sta_num
    mov n1, eax
    invoke _pop,offset sta_num

    .if edx >= 19
        fld n1
        .if edx == 22   
            fsin
        .elseif edx == 23
            fcos
        .elseif edx == 24
            fptan
        .elseif edx == 25
            fpatan
        .elseif edx == 26
            fstp n1
            fld1 
            fld n1
            fyl2x
        .endif
    .elseif edx >= 11 && edx < 19
        invoke _top,offset sta_num
        mov n2, eax
        invoke _pop,offset sta_num
        fld n2
        fld n1
        .if edx == 11
            fadd
        .elseif edx == 12
            fsub
        .elseif edx == 13
            fmul
        .elseif edx == 14
            fdiv
        .elseif edx == 16
            fstp n1
            fstp n2
            fld n1
            fld n2
            fprem
        .endif
    .else
        invoke printf, offset str_op_error
    .endif
    fstp n1
    invoke _push,offset sta_num, n1
    ret
_cal_op ENDP

_cal PROC 
    LOCAL index:dword, temp:dword, now_pr:dword, now_w:dword
    finit
    mov sta_op, 0
    invoke _push, offset sta_op, 19
    mov sta_num, 0
    mov now_state, 0
    mov eax, id_len
    mov index, eax
    mov esi, offset id_input

    .while index != 0
        mov eax, [esi]
        mov now_w, eax
        add esi, 4
        .if now_state == 0 && (eax == 11 || eax == 12)
            mov ecx, [esi]
            .if ecx < 1 || ecx > 10
                invoke printf, offset str_pre_error
            .endif
            .if eax == 11
                mov now_state, -1
            .else 
                mov now_state, 1
            .endif
        .elseif eax >= 1 && eax <= 10
            invoke _getnum, esi
            mov now_state, 2
        .elseif eax == 21
            fldpi 
            fstp temp
            invoke _push,offset sta_num, temp
            mov now_state, 2
        .elseif eax == 20
            mov now_state, 2
            mov now_pr, 1
            .while 1
                invoke _top,offset sta_op
                invoke _getpr, eax
                .break .if now_pr >= eax
                call _cal_op
            .endw
            invoke _top,offset sta_op
            invoke _getpr, eax
            .if eax == 0
                invoke printf, offset str_r_error
            .else
                call _cal_op
            .endif
        .else
            mov now_state, 0
            invoke _getpr, eax
            mov now_pr, eax
            .while 1
                invoke _top,offset sta_op
                invoke _getpr, eax
                .break .if now_pr >= eax
                call _cal_op
            .endw
            invoke _top,offset sta_op
            invoke _getpr, eax
            .if now_pr == eax
                call _cal_op
            .endif
            invoke _push,offset sta_op, now_w
        .endif

        dec index
    .endw

    invoke _top,offset sta_num
    mov temp, eax
    fld temp
    fstp temp_out
    invoke printf, offset str_out_ans, temp_out

    ret

_cal ENDP

start:
    call _cal
    ret
end start

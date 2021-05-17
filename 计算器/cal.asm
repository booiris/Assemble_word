.386

.model flat,stdcall
option casemap:none

include		windows.inc
include		gdi32.inc
includelib	gdi32.lib
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib

includelib msvcrt.lib

printf PROTO C :dword, :vararg
scanf PROTO C :dword, :vararg
sscanf PROTO C :dword, :dword, :vararg

.data

.data?

h_instance dword ?
h_main_window dword ?
h_express dword ?
h_ans dword ?
str_express byte 20000 dup (?)
id_express dword 10000 dup (?)
express_len dword ?
id_len dword ?
str_ans_int byte 10 dup (?)
str_ans_float byte 5 dup (?)
str_ans byte 15 dup (?)
map dword 35 dup (?)

str_input_num byte 50 dup(?)
input_num_len dword ?
float_flag dword ?
sta_op dword 10000 dup (?)
sta_num dword 10000 dup (?)
temp_out real8 ?
error dword ?

.const

key dword 0,0,0,0,0,0,0,0,0,0,0,2,2,3,3,0,3,0,0,1,1,0,1,1,1,1,1,5
pow_num dword 1000.0

str_edit_dll byte 'RichEd20.dll', 0
str_edit_class_name byte 'RichEdit20A', 0
str_button byte 'button', 0
str_button_text_add byte '+', 0
str_button_text_sub byte '-', 0
str_button_text_mul byte '*', 0
str_button_text_mod byte '%', 0
str_button_text_div byte '/', 0
str_button_text_num_0 byte '0', 0
str_button_text_num_1 byte '1', 0
str_button_text_num_2 byte '2', 0
str_button_text_num_3 byte '3', 0
str_button_text_num_4 byte '4', 0
str_button_text_num_5 byte '5', 0
str_button_text_num_6 byte '6', 0
str_button_text_num_7 byte '7', 0
str_button_text_num_8 byte '8', 0
str_button_text_num_9 byte '9', 0
str_button_text_point byte '.', 0
str_button_text_sin byte 'sin(', 0
str_button_text_cos byte 'cos(', 0
str_button_text_tan byte 'tan(', 0
str_button_text_arctan byte 'arctan(', 0
str_button_text_pi byte 'PI', 0
str_button_text_log byte 'log2(', 0
str_button_text_l byte '(', 0
str_button_text_r byte ')', 0
str_button_text_back byte '<-', 0
str_button_text_clear byte 'Clear', 0
str_button_text_cal byte '=', 0
str_class_name byte 'main_window_class', 0
str_main_caption byte '¼ÆËãÆ÷', 0
str_font	db	'ËÎÌå',0

str_out_ans byte '%d', 0
str_in_float byte '%lf', 0
str_out_int byte '%d', 0
str_pop_error byte 'pop error',0ah, 0
str_r_error byte ') error',0ah, 0
str_pre_error byte '+- error',0ah, 0
str_op_error byte 'operation error',0ah, 0
str_point_error byte 'point error',0ah, 0
str_error byte 'error', 0ah, 0

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
        mov error, 1
        jmp done
    .endif
    dec eax
    mov [esi], eax
    done:
        ret
_pop ENDP

_getnum PROC uses esi
    LOCAL temp:dword
    mov esi, offset str_input_num
    invoke sscanf, esi, offset str_in_float, offset temp_out
    fld temp_out
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
            fstp n1
        .elseif edx == 25
            fld1
            fpatan
        .elseif edx == 26
            fstp n1
            fld1 
            fld n1
            fyl2x
        .elseif edx == 27
            fchs
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
        mov error, 1
    .endif
    fstp n1
    invoke _push,offset sta_num, n1
    ret
_cal_op ENDP

_cal PROC 
    LOCAL index:dword, temp:dword, now_pr:dword, now_w:dword, father:dword
    finit

    mov esi, offset id_express
    mov ecx, id_len
    mov dword ptr [esi+4*ecx], 20

    mov error, 0
    mov sta_op, 0
    invoke _push, offset sta_op, 19
    mov sta_num, 0
    mov eax, id_len
    inc eax
    mov index, eax
    mov float_flag, 0
    mov input_num_len, 0
    mov esi, offset id_express
    mov father, 0

    .while index != 0
        mov eax, [esi]
        mov now_w, eax
        add esi, 4
        .if input_num_len == 0 && father != 20 && (eax == 11 || eax == 12)
            invoke _push, offset sta_op, 27
        .elseif eax == 15
            .if float_flag == 0
                mov float_flag, 1
                mov edi, offset str_input_num
                mov ecx, input_num_len
                mov byte ptr [edi+ecx], '.'
                inc input_num_len
            .else
                mov error, 1
            .endif
        .elseif eax >= 1 && eax <= 10
            mov edi, offset str_input_num
            mov ecx, input_num_len
            .if eax == 10
                xor eax, eax
            .endif
            add eax, '0'
            mov [edi+ecx], al
            inc input_num_len
        .else
            .if input_num_len != 0
                mov edi, offset str_input_num
                mov ecx, input_num_len
                mov byte ptr [edi+ecx], 0
                call _getnum
                mov input_num_len, 0
                mov float_flag, 0
                mov eax, now_w
            .endif
            .if eax == 21
                fldpi 
                fstp temp
                invoke _push,offset sta_num, temp
            .elseif eax == 20
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
                    mov error, 1
                .else
                    call _cal_op
                    .while 1
                        invoke _top,offset sta_op
                        .break .if eax != 27
                        call _cal_op
                    .endw
                .endif
            .else
                invoke _getpr, eax
                mov now_pr, eax
                .while 1
                    invoke _top,offset sta_op
                    invoke _getpr, eax
                    .break .if now_pr >= eax || now_pr == 1
                    call _cal_op
                .endw
                invoke _top,offset sta_op
                invoke _getpr, eax
                .if now_pr == eax && eax != 1
                    call _cal_op
                .endif
                invoke _push,offset sta_op, now_w
            .endif
        .endif

        mov eax, now_w
        mov father, eax
        dec index
    .endw

    invoke _top,offset sta_num
    mov temp, eax
    invoke _pop,offset sta_num
    fld temp
    fmul pow_num
    ftst
    FSTSW ax
    and ax, 0100h
    .if ax != 0
        mov index, -1
        fchs
    .endif
    fistp temp
    mov eax, temp
    mov ebx, 1000
    xor edx, edx
    div ebx
    push edx
    invoke wsprintf,offset str_ans_int,offset str_out_ans,eax
    pop edx
    invoke wsprintf,offset str_ans_float,offset str_out_ans,edx

    mov esi, offset str_ans 
    .if index == -1
        mov byte ptr [esi], '-'
        inc esi
    .endif
    invoke	lstrcpy, esi, offset str_ans_int
    invoke lstrlen, offset str_ans_int
    add esi, eax
    mov byte ptr [esi], '.'
    inc esi
    invoke	lstrcpy, esi, offset str_ans_float
    
    FSTSW ax
    and ax, 004dh
    mov esi, offset sta_op
    mov ecx, [esi]
    mov esi, offset sta_num
    mov edx, [esi]

    .if error == 1 || ax != 0 || ecx != 0 || edx != 0
        invoke SetWindowText, h_ans, offset str_error
    .else
        invoke SetWindowText, h_ans, offset str_ans
    .endif

    ret

_cal ENDP

_input PROC uses esi edi, p_input

    mov edi, offset str_express
    add edi, express_len
    mov esi, p_input
    invoke lstrlen, esi
    mov ecx, eax

    main_loop:
        mov al, [esi]
        mov [edi], al
        inc express_len
        inc esi
        inc edi
        loop main_loop

    mov byte ptr [edi], 0

    invoke SetWindowText, h_express, offset str_express

    invoke SendMessage, h_express, EM_SETSEL, -1, -1

    ret
_input ENDP

_init PROC
    LOCAL st_cf:CHARFORMAT
    LOCAL st_rc:RECT

    invoke CreateWindowEx, NULL, offset str_button, offset str_button_text_num_1, WS_CHILD or WS_VISIBLE, 10, 250, 58, 48, h_main_window, 1, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_2 ,WS_CHILD or WS_VISIBLE, 70, 250, 58, 48, h_main_window, 2, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_3 ,WS_CHILD or WS_VISIBLE, 130, 250, 58, 48, h_main_window, 3, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_4 ,WS_CHILD or WS_VISIBLE, 10, 300, 58, 48, h_main_window, 4, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_5 ,WS_CHILD or WS_VISIBLE, 70, 300, 58, 48, h_main_window, 5, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_6 ,WS_CHILD or WS_VISIBLE, 130, 300, 58, 48, h_main_window, 6, h_instance, NULL
    
    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_7 ,WS_CHILD or WS_VISIBLE, 10, 350, 58, 48, h_main_window, 7, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_8 ,WS_CHILD or WS_VISIBLE, 70, 350, 58, 48, h_main_window, 8, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_9 ,WS_CHILD or WS_VISIBLE, 130, 350, 58, 48, h_main_window, 9, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_0 ,WS_CHILD or WS_VISIBLE, 70, 400, 58, 48, h_main_window, 10, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_add ,WS_CHILD or WS_VISIBLE, 190, 250, 58, 98, h_main_window, 11, h_instance, NULL
    
    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_sub ,WS_CHILD or WS_VISIBLE, 190, 350, 58, 98, h_main_window, 12, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_mul ,WS_CHILD or WS_VISIBLE, 250, 250, 58, 98, h_main_window, 13, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_div ,WS_CHILD or WS_VISIBLE, 250, 350, 58, 98, h_main_window, 14, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_point, WS_CHILD or WS_VISIBLE, 130, 400, 58, 48, h_main_window, 15, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_mod, WS_CHILD or WS_VISIBLE, 250,150, 58, 98, h_main_window, 16, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_l, WS_CHILD or WS_VISIBLE, 130,150, 58, 98, h_main_window, 19, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_r, WS_CHILD or WS_VISIBLE, 190,150, 58, 98, h_main_window, 20, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_pi ,WS_CHILD or WS_VISIBLE, 10, 400, 58, 48, h_main_window, 21, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_sin, WS_CHILD or WS_VISIBLE, 310,
    250, 58, 98, h_main_window, 22, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_cos, WS_CHILD or WS_VISIBLE, 310,
    350, 58, 98, h_main_window, 23, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_tan, WS_CHILD or WS_VISIBLE, 370,
    250, 58, 98, h_main_window, 24, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_arctan, WS_CHILD or WS_VISIBLE, 370,350, 58, 98, h_main_window, 25, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_log, WS_CHILD or WS_VISIBLE, 310,150, 58, 98, h_main_window, 26, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_back, WS_CHILD or WS_VISIBLE, 370,150, 58, 98, h_main_window, 27, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_clear, WS_CHILD or WS_VISIBLE, 430,150, 58, 98, h_main_window, 28, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_cal, WS_CHILD or WS_VISIBLE, 430,
    250, 58, 198, h_main_window, 29, h_instance, NULL


    invoke CreateWindowEx, NULL ,offset str_edit_class_name, NULL, WS_CHILD or WS_VISIBLE or WS_BORDER or WS_HSCROLL or ES_NOHIDESEL, 10, 5, 480, 90, h_main_window, 40, h_instance, NULL
    mov h_express, eax
    invoke SendMessage, h_express, EM_SETREADONLY, 1, 0

    invoke CreateWindowEx, NULL ,offset str_edit_class_name, offset str_ans, WS_CHILD or WS_VISIBLE or WS_BORDER or ES_NOHIDESEL or ES_RIGHT, 10, 100, 480, 40, h_main_window, 41, h_instance, NULL
    mov h_ans, eax
    invoke SendMessage, h_ans, EM_SETREADONLY, 1, 0

    invoke RtlZeroMemory, addr st_cf, sizeof st_cf
    invoke RtlZeroMemory, addr st_rc, sizeof st_rc
    mov st_cf.cbSize, sizeof st_cf
    mov st_cf.yHeight, 16 * 20
    mov st_cf.dwMask, CFM_FACE or CFM_SIZE or CFM_BOLD
    invoke	lstrcpy,addr st_cf.szFaceName,addr str_font

    invoke SendMessage, h_express, EM_SETCHARFORMAT, 0 ,addr st_cf
    invoke SendMessage, h_express, EM_SETLANGOPTIONS, 0, 0

    invoke SendMessage, h_express, EM_GETRECT, 0 ,addr st_rc
    add st_rc.top, 20
    invoke SendMessage, h_express, EM_SETRECT, 0, addr st_rc

    mov st_cf.yHeight, 12 * 20

    invoke SendMessage, h_ans, EM_SETCHARFORMAT, 0 ,addr st_cf
    invoke SendMessage, h_ans, EM_SETLANGOPTIONS, 0, 0

    invoke SendMessage, h_ans, EM_GETRECT, 0 ,addr st_rc
    add st_rc.top, 8
    sub st_rc.right, 30
    invoke SendMessage, h_ans, EM_SETRECT, 0, addr st_rc



    ret
_init ENDP

_back PROC uses esi
    dec id_len
    cmp id_len, -1
    jz done
    mov esi, offset id_express
    mov eax, id_len
    mov eax, [esi+4*eax]
    mov esi, offset map
    mov eax, [esi+4*eax]
    invoke lstrlen, eax
    mov ecx, eax
    mov esi, offset str_express
    main_loop:
        dec express_len
        mov eax, express_len
        mov byte ptr [esi+eax],0
        loop main_loop
    invoke SetWindowText, h_express, offset str_express
    invoke SetWindowText, h_ans, NULL

    invoke SendMessage, h_express, EM_SETSEL, -1, -1
    done:
        ret
_back ENDP

_check_btn PROC uses esi edi

    .if cx >= 1 && cx <= 26
        mov esi, offset map
        xor eax,eax
        mov ax, cx
        mov edi ,offset id_express
        mov ecx, id_len
        mov [edi+4*ecx], eax
        mov esi, [esi+4*eax]
        invoke _input, esi
        inc id_len
    .elseif cx == 27
        call _back
    .elseif cx == 28
        mov esi ,offset str_express
        mov byte ptr [esi], 0
        mov express_len, 0
        mov id_len, 0
        invoke SetWindowText, h_express, esi
        invoke SetWindowText, h_ans, NULL
    .elseif cx == 29
        call _cal
    .endif
    ret
_check_btn ENDP

_proc_main_window PROC uses ebx edi esi, h_window, u_msg, wParam, lParam
    mov eax, u_msg

    .if eax == WM_CREATE
        push h_window
        pop h_main_window
        call _init
    
    .elseif eax == WM_COMMAND
        mov eax, wParam
        mov ecx, wParam
        shr eax, 16

        .if ax == BN_CLICKED
            call _check_btn
        .endif

    .elseif eax == WM_CLOSE
        invoke DestroyWindow, h_window
        invoke PostQuitMessage, NULL
    
    .else
        invoke DefWindowProc, h_window, u_msg, wParam, lParam
        ret
    .endif

    xor eax, eax
    ret

_proc_main_window ENDP

_main_window PROC 
    LOCAL st_window_class:WNDCLASSEX
    LOCAL st_msg:MSG
    LOCAL h_edit:dword

    mov esi,offset map
    mov [esi+4], offset str_button_text_num_1
    mov [esi+8], offset str_button_text_num_2
    mov [esi+12], offset str_button_text_num_3
    mov [esi+16], offset str_button_text_num_4
    mov [esi+20], offset str_button_text_num_5
    mov [esi+24], offset str_button_text_num_6
    mov [esi+28], offset str_button_text_num_7
    mov [esi+32], offset str_button_text_num_8
    mov [esi+36], offset str_button_text_num_9
    mov [esi+40], offset str_button_text_num_0
    mov [esi+44], offset str_button_text_add
    mov [esi+48], offset str_button_text_sub
    mov [esi+52], offset str_button_text_mul
    mov [esi+56], offset str_button_text_div
    mov [esi+60], offset str_button_text_point
    mov [esi+64], offset str_button_text_mod
    mov [esi+76], offset str_button_text_l
    mov [esi+80], offset str_button_text_r
    mov [esi+84], offset str_button_text_pi
    mov [esi+88], offset str_button_text_sin
    mov [esi+92], offset str_button_text_cos
    mov [esi+96], offset str_button_text_tan
    mov [esi+100], offset str_button_text_arctan
    mov [esi+104], offset str_button_text_log
    mov [esi+108], offset str_button_text_back
    mov [esi+112], offset str_button_text_clear
    mov [esi+116], offset str_button_text_cal

    invoke LoadLibrary, offset str_edit_dll
    mov h_edit, eax
    invoke GetModuleHandle, NULL
    mov h_instance, eax
    invoke RtlZeroMemory, addr st_window_class, sizeof st_window_class

    invoke LoadCursor, 0, IDC_ARROW
    mov st_window_class.hCursor, eax
    push h_instance
    pop st_window_class.hInstance
    mov st_window_class.cbSize, sizeof WNDCLASSEX
    mov st_window_class.style, CS_HREDRAW or CS_VREDRAW
    mov st_window_class.lpfnWndProc, offset _proc_main_window
    mov st_window_class.hbrBackground, COLOR_WINDOW+1
    mov st_window_class.lpszClassName, offset str_class_name
    invoke RegisterClassEx, addr st_window_class

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset str_class_name, offset str_main_caption, WS_OVERLAPPEDWINDOW xor WS_SIZEBOX, CW_USEDEFAULT, CW_USEDEFAULT, 515, 500, NULL, NULL, h_instance, NULL
    mov h_main_window, eax
    invoke ShowWindow, h_main_window, SW_SHOWNORMAL
    invoke UpdateWindow, h_main_window

    .while TRUE
        invoke GetMessage, addr st_msg, NULL, 0, 0
        .break .if eax == 0
        invoke TranslateMessage, addr st_msg
        invoke DispatchMessage, addr st_msg
    .endw

    invoke FreeLibrary, h_edit
    
    ret
_main_window ENDP

start:
    call _main_window 
    invoke ExitProcess, NULL
    ret
end start
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
str_ans byte 100 dup (?)
map dword 35 dup (?)

.const

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
str_main_caption byte '计算器', 0
str_font	db	'宋体',0

.code


_cal PROC
        ; TODO 计算主要函数
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

    invoke CreateWindowEx, NULL ,offset str_edit_class_name, offset str_ans, WS_CHILD or WS_VISIBLE or WS_BORDER or ES_NOHIDESEL, 10, 100, 480, 40, h_main_window, 41, h_instance, NULL
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
        shl eax, 16

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
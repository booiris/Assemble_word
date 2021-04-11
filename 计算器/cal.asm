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

h_instance dword ?
h_main_window dword ?
h_express dword ?
h_ans dword ?


str_text_temp_ans byte '123132313', 0

.data?
 
str_input byte 10 dup (?)
input_len dword ?
str_express byte 100000 dup (?)
express_len dword ?
str_ans byte 100000 dup (?)

.const

str_operation byte '1234567890+-*/.%^!()', 0
str_edit_dll byte 'RichEd20.dll', 0
str_edit_class_name byte 'RichEdit20A', 0
str_edit_class byte 'edit', 0
str_button byte 'button', 0
str_button_text_add byte '+', 0
str_button_text_sub byte '-', 0
str_button_text_mul byte '*', 0
str_button_text_mod byte 'mod', 0
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
str_button_text_exp byte 'x^y', 0
str_button_text_fact byte 'x!', 0
str_button_text_l byte '(', 0
str_button_text_r byte ')', 0
str_class_name byte 'main_window_class', 0
str_main_caption byte '计算器', 0

.code

_cal PROC
        ; TODO 计算主要函数
_cal ENDP


_input PROC uses esi edi

    mov edi, offset str_express
    add edi, express_len
    mov esi, offset str_input
    mov ecx, input_len

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

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_pi ,WS_CHILD or WS_VISIBLE, 10, 400, 58, 48, h_main_window, 21, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_point, WS_CHILD or WS_VISIBLE, 130,
    400, 58, 48, h_main_window, 15, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_mod, WS_CHILD or WS_VISIBLE, 430,
    250, 58, 198, h_main_window, 16, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_sin, WS_CHILD or WS_VISIBLE, 310,
    250, 58, 98, h_main_window, 22, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_cos, WS_CHILD or WS_VISIBLE, 310,
    350, 58, 98, h_main_window, 23, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_tan, WS_CHILD or WS_VISIBLE, 370,
    250, 58, 98, h_main_window, 24, h_instance, NULL

    invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_arctan, WS_CHILD or WS_VISIBLE, 370,
    350, 58, 98, h_main_window, 25, h_instance, NULL

    invoke CreateWindowEx, NULL ,offset str_edit_class_name, NULL, WS_CHILD or WS_VISIBLE or WS_BORDER or WS_HSCROLL or ES_NOHIDESEL, 10, 20, 200, 50, h_main_window, 40, h_instance, NULL
    mov h_express, eax
    invoke SendMessage, h_express, EM_SETREADONLY, 1, 0

    invoke CreateWindowEx, NULL ,offset str_edit_class, offset str_text_temp_ans, WS_CHILD or WS_VISIBLE or WS_BORDER, 10, 120, 200, 50, h_main_window, 41, h_instance, NULL
    mov h_ans, eax
    invoke SendMessage, h_ans, EM_SETREADONLY, 1, 0

    ret
_init ENDP

_check_btn PROC uses esi edi
    mov esi, offset str_input
    .if cx >= 1 && cx <= 20
        mov input_len, 1
        mov edi, offset str_operation
        xor eax, eax
        mov ax, cx
        mov al, [edi+eax-1]
        mov [esi], al
        call _input
    .elseif cx == 21
        mov input_len, 2
        invoke lstrcpy, esi, offset str_button_text_pi
        call _input
    .elseif cx == 22
        mov input_len, 4
        invoke lstrcpy, esi, offset str_button_text_sin
        call _input
    .elseif cx == 23
        mov input_len, 4
        invoke lstrcpy, esi, offset str_button_text_cos
        call _input
    .elseif cx  == 24
        mov input_len, 4
        invoke lstrcpy, esi, offset str_button_text_tan
        call _input
    .elseif cx == 25
        mov input_len, 7
        invoke lstrcpy, esi, offset str_button_text_arctan
        call _input
    .elseif cx == 26
        mov input_len, 4
        invoke lstrcpy, esi, offset str_button_text_log
        call _input
    .elseif cx == 27

    .elseif cx == 28

    .elseif cx == 29

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

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset str_class_name, offset str_main_caption, WS_OVERLAPPEDWINDOW xor WS_SIZEBOX, CW_USEDEFAULT, CW_USEDEFAULT, 600, 500, NULL, NULL, h_instance, NULL
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
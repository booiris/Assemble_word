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
h_edit_express dword ?
h_edit_ans dword ?


str_text_temp byte '1+2+23*5', 0
str_text_temp_ans byte '123132313', 0

.data?

str_text_express byte 100000 dup (?)
str_text_ans byte 100000 dup (?)

.const

str_edit byte 'edit', 0
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
str_button_text_sin byte 'sin', 0
str_button_text_cos byte 'cos', 0
str_button_text_tan byte 'tan', 0
str_button_text_arctan byte 'atan', 0
str_button_text_pi byte 'PI', 0
str_button_text_l byte '(', 0
str_button_text_r byte ')', 0
str_class_name byte 'main_window_class', 0
str_main_caption byte '计算器', 0
str_text byte 'a12312214', 0

.code

_cal PROC C
        ; TODO 计算主要函数
_cal ENDP

_proc_main_window PROC uses ebx edi esi, h_window, u_msg, w_param, l_param
    LOCAL st_ps:PAINTSTRUCT
    LOCAL st_rect:RECT
    LOCAL h_dc

    mov eax, u_msg

    .if eax == WM_PAINT
        invoke BeginPaint, h_window, addr st_ps
        mov h_dc ,eax

        invoke GetClientRect, h_window, addr st_rect
        invoke DrawText, h_dc, addr str_text, -1, addr st_rect, DT_SINGLELINE or DT_CENTER or DT_VCENTER

        invoke EndPaint, h_window, addr st_ps

    .elseif eax == WM_CREATE
        invoke CreateWindowEx, NULL, offset str_button, offset str_button_text_num_1, WS_CHILD or WS_VISIBLE, 10, 250, 58, 48, h_window, 1, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_2 ,WS_CHILD or WS_VISIBLE, 70, 250, 58, 48, h_window, 2, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_3 ,WS_CHILD or WS_VISIBLE, 130, 250, 58, 48, h_window, 3, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_4 ,WS_CHILD or WS_VISIBLE, 10, 300, 58, 48, h_window, 4, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_5 ,WS_CHILD or WS_VISIBLE, 70, 300, 58, 48, h_window, 5, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_6 ,WS_CHILD or WS_VISIBLE, 130, 300, 58, 48, h_window, 6, h_instance, NULL
        
        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_7 ,WS_CHILD or WS_VISIBLE, 10, 350, 58, 48, h_window, 7, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_8 ,WS_CHILD or WS_VISIBLE, 70, 350, 58, 48, h_window, 8, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_9 ,WS_CHILD or WS_VISIBLE, 130, 350, 58, 48, h_window, 9, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_num_0 ,WS_CHILD or WS_VISIBLE, 70, 400, 58, 48, h_window, 10, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_add ,WS_CHILD or WS_VISIBLE, 190, 250, 58, 98, h_window, 11, h_instance, NULL
        
        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_sub ,WS_CHILD or WS_VISIBLE, 190, 350, 58, 98, h_window, 12, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_mul ,WS_CHILD or WS_VISIBLE, 250, 250, 58, 98, h_window, 13, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_div ,WS_CHILD or WS_VISIBLE, 250, 350, 58, 98, h_window, 14, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_pi ,WS_CHILD or WS_VISIBLE, 10, 400, 58, 48, h_window, 15, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_point, WS_CHILD or WS_VISIBLE, 130,
        400, 58, 48, h_window, 16, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_mod, WS_CHILD or WS_VISIBLE, 430,
        250, 58, 198, h_window, 17, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_sin, WS_CHILD or WS_VISIBLE, 310,
        250, 58, 98, h_window, 18, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_cos, WS_CHILD or WS_VISIBLE, 310,
        350, 58, 98, h_window, 19, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_tan, WS_CHILD or WS_VISIBLE, 370,
        250, 58, 98, h_window, 20, h_instance, NULL

        invoke CreateWindowEx, NULL, offset str_button , offset str_button_text_arctan, WS_CHILD or WS_VISIBLE, 370,
        350, 58, 98, h_window, 21, h_instance, NULL

        invoke CreateWindowEx, NULL ,offset str_edit, offset str_text_temp, WS_CHILD or WS_VISIBLE, 10, 20, 200, 50, h_window, 22, h_instance, NULL
        mov h_edit_express, eax

        invoke CreateWindowEx, NULL ,offset str_edit, offset str_text_temp_ans, WS_CHILD or WS_VISIBLE, 10, 120, 200, 50, h_window, 23, h_instance, NULL
        mov h_edit_ans, eax


    .elseif eax == WM_CLOSE
        invoke DestroyWindow, h_main_window
        invoke PostQuitMessage, NULL
    
    .else
        invoke DefWindowProc, h_window, u_msg, w_param, l_param
        ret
    .endif

    xor eax, eax
    ret

_proc_main_window ENDP

_main_window PROC 
    LOCAL st_window_class:WNDCLASSEX
    LOCAL st_msg:MSG

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

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset str_class_name, offset str_main_caption, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 600, 500, NULL, NULL, h_instance, NULL
    mov h_main_window, eax
    invoke ShowWindow, h_main_window, SW_SHOWNORMAL
    invoke UpdateWindow, h_main_window

    .while TRUE
        invoke GetMessage, addr st_msg, NULL, 0, 0
        .break .if eax == 0
        invoke TranslateMessage, addr st_msg
        invoke DispatchMessage, addr st_msg
    .endw
    
    ret
_main_window ENDP

start:
    call _main_window 
    invoke ExitProcess, NULL
    ret
end start
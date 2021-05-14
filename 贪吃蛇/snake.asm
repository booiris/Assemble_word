.386

.model flat,stdcall
option casemap:none

include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		Gdi32.inc
includelib	Gdi32.lib
include     winmm.inc
includelib  winmm.lib

includelib msvcrt.lib

ICO_MAIN equ 100
back_ground equ 100
snake_head equ 101
snake_body equ 102
snake_tail equ 103
apple      equ 104
apple_mask equ 105
key_s equ 53h
key_w equ 57h
key_a equ 41h
key_d equ 44h
key_up equ 26h
key_down equ 28h
key_left equ 25h
key_right equ 27h
window_x_len equ 24
window_y_len equ 14
cell_size equ 50
buffer_size equ 50

public h_dc_buffer, h_dc_snake_body, h_dc_snake_head, speed,h_dc_bmp,h_dc_snake_tail,h_dc_apple,h_dc_apple_mask

printf PROTO C :dword, :vararg
_draw_head PROTO, :dword, :dword, :dword, :dword, :dword
_draw_body PROTO, :dword, :dword, :dword, :dword, :dword
_draw_tail PROTO, :dword, :dword, :dword, :dword, :dword
_draw_apple PROTO, :dword, :dword, :dword

.data

player1_x dword 0
player1_y dword 10
speed dword 1
player1_x_dir dword 1
player1_y_dir dword 0
fps dword 5
now_window_state dword 1
buffer_cnt dword 0
create_buffer dword 1
buffer_index dword 0

.const

out_format_int byte '%d', 20h,0

str_main_caption byte 'Ã∞≥‘…ﬂ', 0
str_class_name byte 'main_window_class', 0
str_status_class_name byte 'status_class', 0

; invoke MessageBox, h_window_m ain, NULL, NULL, MB_OK

.data?

h_instance dword ?
h_window_main dword ?
h_window_player1 dword ?
h_window_player2 dword ?
h_window_status dword ?
h_dc_background dword ?
h_dc_background_size dword ?
h_dc_snake_head dword ?
h_dc_snake_body dword ?
h_dc_snake_tail dword ?
h_dc_apple dword ?
h_dc_apple_mask dword ?
h_dc_bmp dword ?
h_dc_bmp_size dword ?

h_dc_buffer dword buffer_size dup (?)
h_dc_buffer_size dword buffer_size dup(?)

mp1 dword window_x_len*window_y_len dup (?)
mp2 dword window_x_len*window_y_len dup (?)

state  dword window_x_len*window_y_len dup (?)

.code

_create_background PROC
    local h_dc, h_bmp_background, @cnt
    local h_bmp
    
    invoke GetDC, h_window_main
    mov h_dc, eax
    invoke	CreateCompatibleDC, h_dc
	mov	h_dc_background, eax
    invoke CreateCompatibleBitmap, h_dc, 1200, 700
    mov h_dc_background_size, eax

    invoke	SelectObject,h_dc_background,h_dc_background_size 

    mov @cnt, 0
    mov esi, offset h_dc_buffer
    mov edi, offset h_dc_buffer_size
    .while @cnt != buffer_size
        invoke	CreateCompatibleDC, h_dc
        mov	[esi], eax
        invoke CreateCompatibleBitmap, h_dc, 1200, 700
        mov [edi], eax
        invoke	SelectObject,[esi],[edi]
        invoke SetStretchBltMode,[esi],HALFTONE
        add esi, 4
        add edi, 4
        inc @cnt
    .endw

    invoke	CreateCompatibleDC, h_dc
	mov	h_dc_snake_head, eax
    invoke	CreateCompatibleDC, h_dc
	mov	h_dc_snake_body, eax
    invoke	CreateCompatibleDC, h_dc
	mov	h_dc_bmp, eax
    invoke  CreateCompatibleDC, h_dc
    mov h_dc_snake_tail, eax

    invoke CreateCompatibleBitmap, h_dc,1200,700
    mov h_dc_bmp_size, eax
    invoke	SelectObject,h_dc_bmp,h_dc_bmp_size
    invoke SetStretchBltMode,h_dc_bmp,COLORONCOLOR

    invoke	LoadBitmap,h_instance, back_ground
	mov	h_bmp,eax
    invoke	CreatePatternBrush,h_bmp
    push	eax
    invoke	SelectObject,h_dc_background,eax
    invoke	PatBlt,h_dc_background,0,0,1200, 700,PATCOPY
    pop	eax
    invoke	DeleteObject,eax    
    invoke	DeleteObject,h_bmp

    invoke	LoadBitmap,h_instance,snake_head
    mov	h_bmp,eax
    invoke SelectObject,h_dc_snake_head, h_bmp
    invoke	DeleteObject,h_bmp

    invoke LoadBitmap,h_instance, snake_body
    mov h_bmp, eax
    invoke SelectObject,h_dc_snake_body, h_bmp
    invoke	DeleteObject,h_bmp

    invoke LoadBitmap,h_instance, snake_tail
    mov h_bmp, eax
    invoke SelectObject,h_dc_snake_tail, h_bmp
    invoke	DeleteObject,h_bmp

    invoke  CreateCompatibleDC, h_dc
    mov h_dc_apple, eax
    invoke LoadBitmap,h_instance, apple
    mov h_bmp, eax
    invoke SelectObject,h_dc_apple, h_bmp
    invoke	DeleteObject,h_bmp

    invoke  CreateCompatibleDC, h_dc
    mov h_dc_apple_mask, eax
    invoke LoadBitmap,h_instance, apple_mask
    mov h_bmp, eax
    invoke SelectObject,h_dc_apple_mask, h_bmp
    invoke	DeleteObject,h_bmp

    mov eax, player1_x
    imul eax, window_x_len
    add eax, player1_y
    mov mp1[4*eax], 1
    mov state[4*eax], 2
    dec eax
    mov mp1[4*eax], 2
    mov state[4*eax], 2
    dec eax
    mov mp1[4*eax], 2
    mov state[4*eax], 2
    dec eax
    mov mp1[4*eax], 3
    mov state[4*eax], 2

    dec eax
    mov mp1[4*eax], 8
    mov state[4*eax], 2

    invoke ReleaseDC,h_window_main,h_dc 
    ret 
_create_background ENDP


_draw_window PROC 
    local h_dc

    .while buffer_cnt == 0
    .endw

    invoke GetDC, h_window_main
    mov	h_dc,eax

    mov eax, buffer_index
    invoke	BitBlt,h_dc,0,0,1200,700,\
        h_dc_buffer[4*eax],0,0,SRCCOPY

    invoke ReleaseDC,h_window_main,h_dc 

    dec buffer_cnt
    inc buffer_index
    .if buffer_index == buffer_size
        mov buffer_index, 0
        ret
    .endif

    invoke timeSetEvent,fps,1,_draw_window,NULL,TIME_ONESHOT

    ret
_draw_window ENDP

_create_buffer PROC 
    local @cnt,@index

    .while create_buffer == 1
        .while buffer_cnt != 0
        .endw

        mov @cnt, 0
        .while @cnt < buffer_size
            mov esi, @cnt
            invoke	BitBlt,h_dc_buffer[4*esi],0,0,1200,700,h_dc_background,0,0,SRCCOPY

            ; µ˜”√––Œ™‘ÀÀ„∫Ø ˝£¨‘≠¿¥µÿÕº£¨∏¸–¬µÿÕº£¨◊¥Ã¨Õº

            mov @index, 0
            .while @index < window_x_len*window_y_len
                xor edx,edx
                mov eax, @index
                mov ecx, window_x_len
                div ecx
                mov esi, eax
                mov edi, edx
                mov edx, @index
                mov ecx, mp1[4*edx]
                .if ecx == 1
                    invoke _draw_head, 1, esi, edi,state[4*edx],@cnt ;ª≠1∫≈…ﬂÕ∑
                .elseif ecx == 2
                    invoke _draw_body, 1, esi, edi,state[4*edx],@cnt ;ª≠1∫≈…ﬂ…Ì
                .elseif ecx == 3
                    invoke _draw_tail, 1, esi, edi,state[4*edx],@cnt ;ª≠1∫≈…ﬂŒ≤
                .elseif ecx == 4
                    ; invoke _draw_body, 1, esi, edi,state[4*edx],@cnt ;ª≠2∫≈…ﬂÕ∑
                .elseif ecx == 5
                    ; invoke _draw_body, 1, esi, edi,state[4*edx],@cnt ;ª≠2∫≈…ﬂ…Ì
                .elseif ecx == 6
                    ; invoke _draw_body, 1, esi, edi,state[4*edx],@cnt ;ª≠2∫≈…ﬂŒ≤
                .elseif ecx == 7
                    ; invoke _draw_body, 1, esi, edi,state[4*edx],@cnt ;ª≠«Ω
                .elseif ecx == 8
                    invoke _draw_apple, esi, edi,@cnt ;ª≠∆ªπ˚
                .endif 
                inc @index
            .endw

            ; ∏¸–¬µÿÕº

            inc buffer_cnt
            inc @cnt
        .endw

    .endw
    ret
_create_buffer ENDP

_init PROC
    call _create_background
    invoke CreateThread, NULL, 0,_create_buffer ,NULL,0,NULL
    invoke timeSetEvent,fps,1,_draw_window,NULL,TIME_ONESHOT
    ret
_init ENDP

_check_operation PROC 
    .if eax == key_w && player1_y_dir != 1
        mov player1_x_dir, 0
        mov player1_y_dir, -1
    .elseif eax == key_s && player1_y_dir != -1
        mov player1_x_dir, 0
        mov player1_y_dir, 1
    .elseif eax == key_a && player1_x_dir != 1
        mov player1_x_dir, -1
        mov player1_y_dir, 0
    .elseif eax == key_d && player1_x_dir != -1
        mov player1_x_dir, 1
        mov player1_y_dir, 0
    
    .endif
    ret
_check_operation ENDP

_close PROC 
    local @cnt
    mov @cnt, 0
    mov esi, offset h_dc_buffer
    mov edi, offset h_dc_buffer_size
    .while @cnt != buffer_size
        invoke DeleteDC, [esi]
        invoke DeleteObject, [edi]
        add esi, 4
        add edi, 4
        inc @cnt
    .endw

    invoke DeleteDC, h_dc_background
    invoke DeleteDC, h_dc_snake_head
    invoke DeleteDC, h_dc_snake_body
    invoke DeleteDC, h_dc_snake_tail
    invoke DeleteDC, h_dc_bmp
    invoke DeleteObject, h_dc_background_size
    invoke DeleteObject, h_dc_bmp_size
    ret
_close ENDP

_proc_main_window PROC uses ebx edi esi, h_window, u_msg, wParam, lParam
    local st_ps:PAINTSTRUCT
    local h_dc

    mov eax, u_msg

    .if eax == WM_CREATE
        push h_window
        pop h_window_main
        call _init
    
    ; .elseif	eax ==	WM_PAINT
    ;     invoke	BeginPaint,h_window,addr st_ps
    ;     mov	h_dc,eax

    ;     mov	eax,st_ps.rcPaint.right
    ;     sub	eax,st_ps.rcPaint.left
    ;     mov	ecx,st_ps.rcPaint.bottom
    ;     sub	ecx,st_ps.rcPaint.top

    ;     invoke	BitBlt,h_dc,st_ps.rcPaint.left,st_ps.rcPaint.top,eax,ecx,\
    ;         h_dc_main_window_1,st_ps.rcPaint.left,st_ps.rcPaint.top,SRCCOPY
    ;     invoke	EndPaint,h_window,addr st_ps
    ; .elseif eax == WM_MOVING
    .elseif eax == WM_KEYDOWN
        mov eax, wParam
        call _check_operation
    .elseif eax == WM_CLOSE
        mov create_buffer, 0
        call _close
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

    invoke	GetModuleHandle,NULL
    mov	h_instance,eax

    invoke	RtlZeroMemory,addr st_window_class,sizeof st_window_class
    invoke	LoadIcon,h_instance,ICO_MAIN
    mov	st_window_class.hIcon,eax
    mov	st_window_class.hIconSm,eax
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

    invoke CreateWindowEx, 0, offset str_class_name, offset str_main_caption, WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX xor WS_BORDER, 220, 50, 1200, 700, NULL, NULL, h_instance, NULL
    mov h_window_main, eax
    invoke ShowWindow, h_window_main, SW_SHOWNORMAL
    invoke UpdateWindow, h_window_main

    ; invoke	RtlZeroMemory,addr st_window_class,sizeof st_window_class
    ; invoke LoadCursor, 0, IDC_ARROW
    ; mov st_window_class.hCursor, eax
    ; push h_instance
    ; pop st_window_class.hInstance
    ; mov st_window_class.cbSize, sizeof WNDCLASSEX
    ; mov st_window_class.style, CS_HREDRAW or CS_VREDRAW
    ; mov st_window_class.lpfnWndProc, offset _proc_status_window
    ; mov st_window_class.hbrBackground, COLOR_WINDOW+1
    ; mov st_window_class.lpszClassName, offset str_status_class_name
    ; invoke RegisterClassEx, addr st_window_class


    ; invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset str_class_name, 0, WS_POPUP , 1, 10, 500, 650, h_window_main,0, h_instance, NULL
    ; mov h_window_status, eax
    ; invoke ShowWindow, h_window_status, SW_SHOWNORMAL
    ; invoke UpdateWindow, h_window_status

    ; invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset str_class_name, 0, WS_POPUP , 500, 10, 500, 650, h_window_main,0, h_instance, NULL
    ; mov h_window_status, eax
    ; invoke ShowWindow, h_window_status, SW_SHOWNORMAL
    ; invoke UpdateWindow, h_window_status

    
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
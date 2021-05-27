.386

.model flat,stdcall
option casemap:none

include define.inc
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

public h_dc_buffer, h_dc_player1_body, h_dc_player1_head, speed,h_dc_bmp,h_dc_player1_tail,h_dc_apple,h_dc_apple_mask,h_dc_grass,h_dc_emoji,h_dc_player2_body,h_dc_player2_head,h_dc_player2_tail,h_dc_wall,h_dc_large,h_dc_fast,h_dc_large_mask

.data

speed dword 1
player1_dir dword 2
player1_now_dir dword 2
player2_dir dword 4
player2_now_dir dword 4
fps dword 4
now_window_state dword 1
buffer_cnt dword 0
create_buffer dword 1
buffer_index dword 0
is_show dword 0

.const

out_format_int byte '%d', 20h,0

str_main_caption byte '̰����', 0
str_class_name byte 'main_window_class', 0
str_status_class_name byte 'status_class', 0

; invoke MessageBox, h_window_m ain, NULL, NULL, MB_OK

.data?

h_instance dword ?
h_window_main dword ?
h_dc_background dword ?
h_dc_player1_head dword ?
h_dc_player1_body dword ?
h_dc_player1_tail dword ?
h_dc_player2_head dword ?
h_dc_player2_body dword ?
h_dc_player2_tail dword ?
h_dc_apple dword ?
h_dc_apple_mask dword ?
h_dc_wall dword ?
h_dc_grass dword ?
h_dc_emoji dword ?
h_dc_large dword ?
h_dc_large_mask dword ?
h_dc_fast dword ?
h_dc_bmp dword ?
h_dc_bmp_size dword ?
h_dc_time dword ?

h_dc_buffer dword buffer_size dup (?)
h_dc_buffer_size dword buffer_size dup(?)


.code

printf PROTO C :dword, :vararg
_draw_item PROTO, :draw_struct,:dword
_draw_map PROTO, :dword,:dword                        ;player1�ķ���
_build_map PROTO
extern draw_list:draw_struct,draw_list_size:dword

_create_background PROC
    local h_dc, h_bmp_background, @cnt
    local h_bmp
    
    invoke GetDC, h_window_main
    mov h_dc, eax
    invoke	CreateCompatibleDC, h_dc
	mov	h_dc_background, eax

    mov @cnt, 0
    mov esi, offset h_dc_buffer
    mov edi, offset h_dc_buffer_size
    .while @cnt != buffer_size
        invoke	CreateCompatibleDC, h_dc
        mov	[esi], eax
        invoke CreateCompatibleBitmap, h_dc, 1200, 729
        mov [edi], eax
        invoke	SelectObject,[esi],[edi]
        invoke SetStretchBltMode,[esi],HALFTONE
        add esi, 4
        add edi, 4
        inc @cnt
    .endw

    invoke	CreateCompatibleDC, h_dc
	mov	h_dc_player1_head, eax
    invoke	CreateCompatibleDC, h_dc
	mov	h_dc_player1_body, eax
    invoke	CreateCompatibleDC, h_dc
	mov	h_dc_bmp, eax
    invoke  CreateCompatibleDC, h_dc
    mov h_dc_player1_tail, eax

    invoke CreateCompatibleBitmap, h_dc,1200,729
    mov h_dc_bmp_size, eax
    invoke	SelectObject,h_dc_bmp,h_dc_bmp_size
    invoke SetStretchBltMode,h_dc_bmp,COLORONCOLOR

    invoke	LoadBitmap,h_instance, back_ground
	mov	h_bmp,eax
    invoke SelectObject,h_dc_background, h_bmp 
    invoke	DeleteObject,h_bmp

    invoke	LoadBitmap,h_instance,player1_head
    mov	h_bmp,eax
    invoke SelectObject,h_dc_player1_head, h_bmp
    invoke	DeleteObject,h_bmp

    invoke LoadBitmap,h_instance, player1_body
    mov h_bmp, eax
    invoke SelectObject,h_dc_player1_body, h_bmp
    invoke	DeleteObject,h_bmp

    invoke LoadBitmap,h_instance, player1_tail
    mov h_bmp, eax
    invoke SelectObject,h_dc_player1_tail, h_bmp
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

    invoke  CreateCompatibleDC, h_dc
    mov h_dc_grass, eax
    invoke LoadBitmap,h_instance, grass
    mov h_bmp, eax
    invoke SelectObject,h_dc_grass, h_bmp
    invoke	DeleteObject,h_bmp

    invoke  CreateCompatibleDC, h_dc
    mov h_dc_emoji, eax
    invoke LoadBitmap,h_instance, emoji
    mov h_bmp, eax
    invoke SelectObject,h_dc_emoji, h_bmp
    invoke	DeleteObject,h_bmp

    invoke  CreateCompatibleDC, h_dc
    mov h_dc_player2_head, eax
    invoke LoadBitmap,h_instance, player2_head
    mov h_bmp, eax
    invoke SelectObject,h_dc_player2_head, h_bmp
    invoke	DeleteObject,h_bmp

    invoke  CreateCompatibleDC, h_dc
    mov h_dc_player2_body, eax
    invoke LoadBitmap,h_instance, player2_body
    mov h_bmp, eax
    invoke SelectObject,h_dc_player2_body, h_bmp
    invoke	DeleteObject,h_bmp

    invoke  CreateCompatibleDC, h_dc
    mov h_dc_player2_tail, eax
    invoke LoadBitmap,h_instance, player2_tail
    mov h_bmp, eax
    invoke SelectObject,h_dc_player2_tail, h_bmp
    invoke	DeleteObject,h_bmp

    invoke  CreateCompatibleDC, h_dc
    mov h_dc_wall, eax
    invoke LoadBitmap,h_instance, wall
    mov h_bmp, eax
    invoke SelectObject,h_dc_wall, h_bmp
    invoke	DeleteObject,h_bmp

    invoke  CreateCompatibleDC, h_dc
    mov h_dc_fast, eax
    invoke LoadBitmap,h_instance, fast
    mov h_bmp, eax
    invoke SelectObject,h_dc_fast, h_bmp
    invoke	DeleteObject,h_bmp

    invoke  CreateCompatibleDC, h_dc
    mov h_dc_large, eax
    invoke LoadBitmap,h_instance, large
    mov h_bmp, eax
    invoke SelectObject,h_dc_large, h_bmp
    invoke	DeleteObject,h_bmp

    invoke  CreateCompatibleDC, h_dc
    mov h_dc_large_mask, eax
    invoke LoadBitmap,h_instance, large_mask
    mov h_bmp, eax
    invoke SelectObject,h_dc_large_mask, h_bmp
    invoke	DeleteObject,h_bmp

    invoke ReleaseDC,h_window_main,h_dc 
    invoke _build_map
    ret 
_create_background ENDP


_set_show PROC 
    mov is_show, 1
    ret
_set_show ENDP

_draw_window PROC 
    local h_dc

    main_loop:
        cmp create_buffer, 0
        jz main_loop_end

        .while buffer_cnt == 0 || (!is_show)
        .endw

        invoke GetDC, h_window_main
        mov	h_dc,eax

        mov eax, buffer_index
        invoke	BitBlt,h_dc,0,0,1200,729,\
            h_dc_buffer[4*eax],0,0,SRCCOPY

        invoke ReleaseDC,h_window_main,h_dc 

        dec buffer_cnt
        inc buffer_index
        .if buffer_index == buffer_size
            mov buffer_index, 0
        .endif

        mov is_show, 0
        jmp main_loop

    main_loop_end:
        ret
_draw_window ENDP

_create_buffer PROC 
    local @cnt

    main_loop:
        cmp create_buffer, 0
        jz main_loop_end
        .while buffer_cnt != 0
        .endw

        invoke _draw_map, player1_dir, player2_dir
        mov eax, player1_dir 
        mov player1_now_dir, eax
        mov eax, player2_dir 
        mov player2_now_dir, eax

        mov @cnt, 0
        .while @cnt < buffer_size

            mov esi, @cnt
            invoke	BitBlt,h_dc_buffer[4*esi],0,0,1200,729,h_dc_background,0,0,SRCCOPY
            mov ecx, 4
            draw_loop:
                push ecx
                mov edi, ecx
                mov ecx, draw_list_size
                draw_list_loop:
                    push ecx
                    dec ecx
                    imul ecx, 24
                    .if draw_list[ecx].prio == edi
                        invoke _draw_item, draw_list[ecx], @cnt
                    .endif
                    pop ecx
                    loop draw_list_loop
                pop ecx
                loop draw_loop
            inc buffer_cnt
            inc @cnt
        .endw
        jmp main_loop
    
    main_loop_end:
        ret
_create_buffer ENDP

_init PROC
    call _create_background
    invoke CreateThread, NULL, 0,_draw_window ,NULL,0,NULL
    invoke CreateThread, NULL, 0,_create_buffer ,NULL,0,NULL
    invoke timeSetEvent,fps,0,_set_show,NULL,TIME_PERIODIC
    mov h_dc_time, eax
    ret
_init ENDP

_check_operation PROC 
    .if eax == key_w && player1_now_dir != 3
        mov player1_dir, 1
    .elseif eax == key_s &&  player1_now_dir != 1
        mov player1_dir, 3
    .elseif eax == key_a &&  player1_now_dir != 2
        mov player1_dir, 4
    .elseif eax == key_d &&  player1_now_dir != 4
        mov player1_dir, 2
    .elseif eax == key_up && player2_now_dir != 3
        mov player2_dir, 1
    .elseif eax == key_down &&  player2_now_dir != 1
        mov player2_dir, 3
    .elseif eax == key_left &&  player2_now_dir != 2
        mov player2_dir, 4
    .elseif eax == key_right &&  player2_now_dir != 4
        mov player2_dir, 2
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

    invoke timeKillEvent, h_dc_time
    invoke DeleteDC, h_dc_background
    invoke DeleteDC, h_dc_player1_head
    invoke DeleteDC, h_dc_player1_body
    invoke DeleteDC, h_dc_player1_tail
    invoke DeleteDC, h_dc_bmp
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

    invoke CreateWindowEx, 0, offset str_class_name, offset str_main_caption, WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX xor WS_BORDER, 220, 50, 1200, 729, NULL, NULL, h_instance, NULL
    mov h_window_main, eax
    invoke ShowWindow, h_window_main, SW_SHOWNORMAL
    invoke UpdateWindow, h_window_main

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
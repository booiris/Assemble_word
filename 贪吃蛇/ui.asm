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

includelib msvcrt.lib

ICO_MAIN equ 100
back_ground equ 100
snake_head equ 101

.data

now_x dword 10

.const

str_main_caption byte 'Ì°³ÔÉß', 0
str_class_name byte 'main_window_class', 0
str_status_class_name byte 'status_class', 0


.data?

h_instance dword ?
h_window_main dword ?
h_main_cursor dword ?
h_window_player1 dword ?
h_window_player2 dword ?
h_window_status dword ?
h_dc_back dword ?
h_bmp_back dword ? ;TODOÉ¾³ý¾ä±ú£¬ÊÍ·Å¶ÔÏó
h_dc_copy dword ?
h_dc_snake_head dword ?

.code

_create_background PROC
    local h_dc, h_back
    local h_bmp_snake_head,h_bmp_head
    
    invoke GetDC, h_window_main
    mov h_dc, eax
    invoke	CreateCompatibleDC, h_dc
	mov	h_dc_back, eax
    invoke CreateCompatibleBitmap, h_dc, 1100, 650
    mov h_bmp_back, eax

    invoke	CreateCompatibleDC, h_dc
	mov	h_dc_snake_head, eax
    invoke	CreateCompatibleDC, h_dc
	mov	h_dc_copy, eax
    invoke CreateCompatibleBitmap, h_dc, 1100, 650
    mov h_bmp_snake_head, eax

    invoke ReleaseDC,h_window_main,h_dc 

    invoke	LoadBitmap,h_instance, back_ground
	mov	h_back,eax
    invoke	LoadBitmap,h_instance,snake_head
    mov	h_bmp_head,eax

    invoke	SelectObject,h_dc_back,h_bmp_back 
    invoke	SelectObject,h_dc_snake_head, h_bmp_snake_head
    invoke  SelectObject, h_dc_copy, h_bmp_head

    invoke	CreatePatternBrush,h_back
    push	eax
    invoke	SelectObject,h_dc_back,eax
    invoke	PatBlt,h_dc_back,0,0,1100, 650,PATCOPY
    pop	eax
    invoke	DeleteObject,eax    

    invoke SetStretchBltMode,h_dc_snake_head,HALFTONE
    invoke SetStretchBltMode,h_dc_copy,HALFTONE
    invoke	BitBlt,h_dc_snake_head,0,0,1100,650,h_dc_back,0,0,SRCCOPY
    ; invoke StretchBlt,h_dc_snake_head,now_x,100,62, 40,h_dc_copy,0,0,268,162,SRCCOPY

    invoke	DeleteObject,h_bmp_snake_head
    invoke	DeleteObject,h_bmp_head
    invoke  DeleteObject, h_back
    
    ret 
_create_background ENDP

    
_Drawsnake PROC 
    invoke	BitBlt,h_dc_snake_head,0,0,1100,650,h_dc_back,0,0,SRCCOPY
    add now_x, 5
    invoke	StretchBlt,h_dc_snake_head,now_x,100,62, 40,h_dc_copy,0,0,268,162,SRCCOPY

    ret
_Drawsnake ENDP

_init PROC
    call _create_background
    invoke	SetTimer,h_window_main,1,30,NULL
    ret
_init ENDP

_proc_main_window PROC uses ebx edi esi, h_window, u_msg, wParam, lParam
    local st_ps:PAINTSTRUCT
    local h_dc

    mov eax, u_msg

    .if eax == WM_CREATE
        push h_window
        pop h_window_main
        call _init
    .elseif	eax ==	WM_TIMER
        invoke	_Drawsnake
        invoke	InvalidateRect,h_window,NULL,FALSE
    
    .elseif	eax ==	WM_PAINT
        invoke	BeginPaint,h_window,addr st_ps
        mov	h_dc,eax

        mov	eax,st_ps.rcPaint.right
        sub	eax,st_ps.rcPaint.left
        mov	ecx,st_ps.rcPaint.bottom
        sub	ecx,st_ps.rcPaint.top

        invoke	BitBlt,h_dc,st_ps.rcPaint.left,st_ps.rcPaint.top,eax,ecx,\
            h_dc_snake_head,st_ps.rcPaint.left,st_ps.rcPaint.top,SRCCOPY
        invoke	EndPaint,h_window,addr st_ps

    ; .elseif eax == WM_MOVING

    .elseif eax == WM_CLOSE
        invoke	KillTimer,h_window_main,1
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

    invoke CreateWindowEx, 0, offset str_class_name, offset str_main_caption, WS_CAPTION or WS_SYSMENU or WS_MINIMIZEBOX xor WS_BORDER, 220, 50, 1100, 660, NULL, NULL, h_instance, NULL
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
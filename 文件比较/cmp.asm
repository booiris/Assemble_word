.386
.model flat, stdcall
option casemap :none

include windows.inc
include user32.inc
includelib user32.lib 
include kernel32.inc
includelib kernel32.lib 
include comdlg32.inc
includelib comdlg32.lib 

ICO_MAIN	equ	1000

.data?
h_instance dword ?
h_main_window dword ?
h_window_edit dword ?
h_old_window_edit dword ?
h_file dword ?
str_file_name byte MAX_PATH dup(?)

.data

.const
str_class_name byte 'compare_window', 0
str_caption_main byte '文件比较', 0
str_edit_dll byte 'RichEd20.dll', 0
str_edit_class_name byte 'RichEdit20A', 0
str_filter byte 'Text Files(*.txt)',0,'*.txt',0
		byte	'All Files(*.*)',0,'*.*',0,0

str_default_ext byte 'txt', 0
str_err_openfile byte '无法打开文件!', 0
str_font byte '微软雅黑', 0

szButton	db	'button',0
szButtonText	db	'&OK',0


.code

_proc_edit_menu PROC uses ebx edi esi h_window,u_msg,wParam,lParam
    LOCAL @st_pos:POINT
    mov eax, u_msg
    .if eax == WM_RBUTTONDOWN
        invoke GetCursorPos,addr @st_pos
        invoke TrackPopupMenu,hSubMenu,TPM_LEFTALIGN or TPM_LEFTBUTTON,@st_pos.x,@st_pos.y,NULL,hWinMain,NULL
    .endif
    invoke CallWindowProc,h_old_window_edit,h_window,u_msg,wParam,lParam
    ret
_proc_edit ENDP

_init PROC
    LOCAL st_cf:CHARFORMAT

    invoke	CreateWindowEx,NULL,\
				offset szButton,offset szButtonText,\
				WS_CHILD or WS_VISIBLE,\
				100,100,65,22,\
				h_main_window,1,h_instance,NULL

    invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset str_edit_class_name, NULL, WS_CHILD or WS_VISIBLE or WS_VSCROLL or WS_HSCROLL or ES_MULTILINE or ES_NOHIDESEL, 0, 0, 498, 600, h_main_window, 0, h_instance, NULL
    mov h_window_edit, eax

    invoke SetWindowLong, h_window_edit, GWL_WNDPROC, addr _proc_edit
    mov h_old_window_edit, eax

    invoke RtlZeroMemory, addr st_cf, sizeof st_cf
    mov st_cf.cbSize, sizeof CHARFORMAT
    mov st_cf.yHeight, 13 * 20
    mov st_cf.dwMask, CFM_FACE or CFM_SIZE or CFM_BOLD
    invoke lstrcpy, addr st_cf.szFaceName, addr str_font
    invoke SendMessage, h_window_edit, EM_SETCHARFORMAT, 0 ,addr st_cf
    invoke SendMessage, h_window_edit, EM_EXLIMITTEXT,0 ,-1
    ret
_init ENDP

_quit PROC
    invoke	DestroyWindow,h_main_window
	invoke	PostQuitMessage,NULL
    ret 
_quit ENDP

_proc_main_window PROC uses ebx edi esi h_window,u_msg,wParam,lParam
    
    mov	eax,u_msg
    .if eax ==  WM_CREATE
        push h_window
        pop h_main_window
        call _init
    .elseif eax == WM_SIZE
        ; TODO 自适应大小
    .elseif eax == WM_ACTIVATE
        mov eax, wParam
        .if (ax == WA_CLICKACTIVE) || (ax == WA_ACTIVE)
            invoke SetFocus, h_window_edit
        .endif
    .elseif eax == WM_COMMAND
        xor eax, eax
    .elseif eax == WM_CLOSE
        call _quit
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
    ; invoke LoadIcon, h_instance, ICO_MAIN
    ; mov st_window_class.hIcon, eax
    ; mov	st_window_class.hIconSm,eax
    invoke	LoadCursor,0,IDC_ARROW
    mov	st_window_class.hCursor,eax
    push h_instance
    pop	st_window_class.hInstance
    mov	st_window_class.cbSize,sizeof WNDCLASSEX
    mov	st_window_class.style,CS_HREDRAW or CS_VREDRAW
    mov	st_window_class.lpfnWndProc,offset _proc_main_window
    mov	st_window_class.hbrBackground,COLOR_BTNFACE+1
    mov	st_window_class.lpszClassName,offset str_class_name
    invoke RegisterClassEx, addr st_window_class

    invoke CreateWindowEx, WS_EX_OVERLAPPEDWINDOW, offset str_class_name, offset str_caption_main, WS_OVERLAPPEDWINDOW xor WS_SIZEBOX, 100, 100, 1000, 600, NULL, NULL, h_instance, NULL
    mov h_main_window, eax
    invoke ShowWindow, h_main_window, SW_SHOWNORMAL
    invoke UpdateWindow, h_main_window

    .while TRUE
        invoke GetMessage, addr st_msg, NULL, 0 , 0
        .break .if eax == 0
        invoke	TranslateMessage,addr st_msg
		invoke	DispatchMessage,addr st_msg
    .endw
    invoke FreeLibrary, h_edit

    ret
_main_window ENDP

start:
    call _main_window
    invoke ExitProcess, NULL

end start
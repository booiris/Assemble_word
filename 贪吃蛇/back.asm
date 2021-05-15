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

window_x_len equ 24
window_y_len equ 14

public draw_list,draw_list_size,_build_map,_draw_map

.data?

draw_struct STRUCT
    x dword ?
    y dword ?
    prio dword ?
    item dword ?
    state dword ?
draw_struct ENDS

map dword window_x_len*window_y_len dup (?)

draw_list draw_struct 500 dup ({})
draw_list_size dword ?

.code

_create_apple PROC 

    ret
_create_apple ENDP

_draw_map PROC player1_dir:dword


    ret
_draw_map ENDP

_build_map PROC uses edi
    
    ret
_build_map ENDP


end
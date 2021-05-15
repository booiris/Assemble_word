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

snake_head equ 101
snake_body equ 102
snake_tail equ 103
apple      equ 104
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
    local @index:dword

    mov draw_list_size, 0
    mov esi, offset draw_list

    mov @index,0 
    .while @index < window_x_len*window_y_len
        xor edx,edx
        mov eax, @index
        mov ecx, window_x_len
        div ecx ; eax xֵ, edx yֵ
        inc @index
        mov eax, map[eax][edx]
        .if eax == snake_head
        .elseif eax == snake_body
        .elseif eax == snake_tail
        .endif
    
    .endw

    ret
_draw_map ENDP

_create_draw_item PROC uses eax,x:dword,y:dword,prio:dword,item:dword,state:dword
    assume esi:ptr draw_struct
    mov eax, x
    mov [esi].x, eax
    mov eax, y
    mov [esi].y, eax
    mov eax, prio
    mov [esi].prio, eax
    mov eax, item
    mov [esi].item, eax
    mov eax, state
    mov [esi].state, eax
    add esi, 20
    inc draw_list_size
    assume esi:nothing
    ret 
_create_draw_item ENDP
    

_build_map PROC uses esi
    mov draw_list_size, 0
    mov esi, offset draw_list

    mov eax, 5*window_x_len+10
    mov map[4*eax], snake_head
    invoke _create_draw_item, 5,10,1,snake_head,0

    dec eax
    mov map[4*eax], snake_body 
    invoke _create_draw_item, 5,9,1,snake_body,0
    

    dec eax 
    mov map[4*eax], snake_tail
    invoke _create_draw_item, 5,8,1,snake_tail,0

    dec eax
    mov map[4*eax], apple
    invoke _create_draw_item, 5,7,1,apple,0

    ret
_build_map ENDP


end
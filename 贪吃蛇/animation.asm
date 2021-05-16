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
include     Msimg32.inc
includelib  Msimg32.lib

includelib msvcrt.lib

snake_head equ 101
snake_body equ 102
snake_tail equ 103
apple      equ 104
wall       equ 106
grass      equ 107
window_x_len equ 24
window_y_len equ 14
cell_size equ 50

printf PROTO C :dword, :vararg
public _draw_item

extern h_dc_buffer:dword,h_dc_snake_body:dword, h_dc_snake_head:dword, speed:dword,h_dc_bmp:dword,h_dc_snake_tail:dword,h_dc_apple:dword,h_dc_apple_mask:dword,h_dc_grass:dword

.data?
draw_struct STRUCT
    x dword ?
    y dword ?
    prio dword ?
    item dword ?
    state dword ?
draw_struct ENDS

.const 
out_format_int byte '%d', 20h,0

.code

_draw_head PROC uses esi, player:dword, index_x:dword, index_y:dword, dir:dword, frame_time:dword
    local @player_x,@player_y, @dis, @head_size
    mov @head_size, cell_size
    mov ecx, index_x
    imul ecx, cell_size
    mov @player_x, ecx
    mov ecx, index_y
    imul ecx, cell_size
    mov @player_y, ecx
    mov ecx, speed
    imul ecx, frame_time
    .if dir == 1
        neg ecx
        add @player_x, ecx
    .elseif dir == 2
        add @player_y, ecx
    .elseif dir == 3
        add @player_x, ecx
    .elseif dir == 4
        neg ecx
        add @player_y, ecx
    .endif

    mov esi, frame_time
    invoke StretchBlt,h_dc_bmp,0,0,@head_size, @head_size,h_dc_snake_head,0,0,136,136,SRCCOPY
    mov eax, 0ffffffh
    invoke TransparentBlt,h_dc_buffer[4*esi],@player_y,@player_x,@head_size, @head_size,h_dc_bmp,0,0,@head_size,@head_size,eax
    ret
_draw_head ENDP

_draw_body PROC uses esi,player:dword, index_x:dword, index_y:dword, dir:dword, frame_time:dword
    local @player_x,@player_y, @dis, @body_size
    mov @body_size, cell_size
    mov ecx, index_x
    imul ecx, cell_size
    mov @player_x, ecx
    mov ecx, index_y
    imul ecx, cell_size
    mov @player_y, ecx
    mov ecx, speed
    imul ecx, frame_time
    .if dir == 1
        neg ecx
        add @player_x, ecx
    .elseif dir == 2
        add @player_y, ecx
    .elseif dir == 3
        add @player_x, ecx
    .elseif dir == 4
        neg ecx
        add @player_y, ecx
    .endif

    mov esi, frame_time
    invoke StretchBlt,h_dc_bmp,0,0,@body_size, @body_size,h_dc_snake_body,0,0,136,136,SRCCOPY
    mov eax, 0ffffffh
    invoke TransparentBlt,h_dc_buffer[4*esi],@player_y,@player_x,@body_size, @body_size,h_dc_bmp,0,0,@body_size,@body_size,eax
    ret
_draw_body ENDP

_draw_tail PROC uses esi,player:dword, index_x:dword, index_y:dword, dir:dword, frame_time:dword
    local @player_x,@player_y, @dis, @tail_size, @bmp_x
    mov @tail_size, cell_size
    mov ecx, index_x
    imul ecx, cell_size
    mov @player_x, ecx
    mov ecx, index_y
    imul ecx, cell_size
    mov @player_y, ecx
    mov ecx, speed
    imul ecx, frame_time
    .if dir == 1
        mov @bmp_x, 0
        neg ecx
        add @player_x, ecx
    .elseif dir == 2
        mov @bmp_x, 100
        add @player_y, ecx
    .elseif dir == 3
        mov @bmp_x, 200
        add @player_x, ecx
    .elseif dir == 4
        mov @bmp_x, 300
        neg ecx
        add @player_y, ecx
    .elseif dir == 5
        mov @bmp_x, 0
    .elseif dir == 6
        mov @bmp_x, 100
    .elseif dir == 7
        mov @bmp_x, 200
    .elseif dir == 8
        mov @bmp_x, 300
    .endif

    mov esi, frame_time
    invoke StretchBlt,h_dc_bmp,0,0,@tail_size, @tail_size,h_dc_snake_tail,@bmp_x,0,100,100,SRCCOPY
    mov eax, 0ffffffh
    invoke TransparentBlt,h_dc_buffer[4*esi],@player_y,@player_x,@tail_size, @tail_size,h_dc_bmp,0,0,@tail_size,@tail_size,eax
    ret
_draw_tail ENDP

_draw_apple PROC uses esi,index_x:dword, index_y:dword, frame_time:dword
    local @apple_size,@apple_x,@apple_y
    mov @apple_size, cell_size
    mov eax, index_x
    imul eax, cell_size
    mov @apple_x, eax
    mov eax, index_y
    imul eax, cell_size
    mov @apple_y, eax

    xor edx,edx
    mov eax, frame_time
    mov ecx, 50
    div ecx
    mov eax, edx

    xor edx,edx
    mov ecx, 10
    div ecx
    
    .if eax > 3
        mov ecx, 6
        sub ecx, eax
        mov eax, ecx
    .endif
    add @apple_x,eax
    add @apple_y,eax
    sal eax, 1
    sub @apple_size,eax

    mov esi, frame_time
    invoke StretchBlt,h_dc_buffer[4*esi],@apple_y,@apple_x,@apple_size, @apple_size,h_dc_apple_mask,0,0,64,64,SRCAND
    invoke StretchBlt,h_dc_buffer[4*esi],@apple_y,@apple_x,@apple_size, @apple_size,h_dc_apple,0,0,64,64,SRCPAINT
    ret
_draw_apple ENDP

_draw_wall PROC uses esi, index_x:dword, index_y:dword, frame_time:dword
    ret
_draw_wall ENDP

_draw_emoji PROC uses esi,index_x:dword, index_y:dword, frame_time:dword 
    ret
_draw_emoji ENDP

_draw_grass PROC uses esi,index_x:dword, index_y:dword,frame_time:dword
    local @grass_size,@grass_x,@grass_y
    mov @grass_size, cell_size
    mov eax, index_x
    imul eax, cell_size
    mov @grass_x, eax
    mov eax, index_y
    imul eax, cell_size
    mov @grass_y, eax
    mov esi, frame_time
    invoke StretchBlt,h_dc_bmp,0,0,@grass_size, @grass_size,h_dc_grass,0,0,128,128,SRCCOPY
    mov eax, 0ffffffh
    invoke TransparentBlt,h_dc_buffer[4*esi],@grass_y,@grass_x,@grass_size, @grass_size,h_dc_bmp,0,0,@grass_size,@grass_size,eax
    ret
_draw_grass ENDP

_draw_item PROC item:draw_struct,frame_time:dword
    ; invoke printf, offset out_format_int, item.item
    .if item.item == snake_head
        invoke _draw_head,1,item.x,item.y,item.state,frame_time
    .elseif item.item == snake_body
        invoke _draw_body,1,item.x,item.y,item.state,frame_time
    .elseif item.item == snake_tail
        invoke _draw_tail,1,item.x,item.y,item.state,frame_time
    .elseif item.item == apple
        invoke _draw_apple,item.x,item.y,frame_time
    .elseif item.item == wall 
        invoke _draw_wall,item.x,item.y,frame_time 
    .elseif item.item == grass 
        invoke _draw_grass,item.x,item.y,frame_time
    .endif
    ret
_draw_item ENDP

end
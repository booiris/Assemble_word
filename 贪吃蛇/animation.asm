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

cell_size equ 40

public _draw_head, _draw_body

extern h_dc_buffer:dword, h_dc_snake_head_mask:dword, h_dc_snake_body:dword, h_dc_snake_head:dword, speed:dword

.code

_draw_head PROC uses esi, player:dword, index_x:dword, index_y:dword, dir:dword, frame_time:dword
    local @player_x,@player_y, @dis
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
    invoke	StretchBlt,h_dc_buffer[4*esi],@player_y,@player_x,cell_size, cell_size,h_dc_snake_head_mask,0,0,136,136,SRCAND
    mov esi, frame_time
    invoke	StretchBlt,h_dc_buffer[4*esi],@player_y,@player_x,cell_size, cell_size,h_dc_snake_head,0,0,136,136,SRCPAINT
    ret
_draw_head ENDP

_draw_body PROC player:dword, index_x:dword, index_y:dword, dir:dword, frame_time:dword
    local @player_x,@player_y, @dis
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
    invoke	StretchBlt,h_dc_buffer[4*esi],@player_y,@player_x,cell_size, cell_size,h_dc_snake_head_mask,0,0,136,136,SRCAND
    mov esi, frame_time
    invoke	StretchBlt,h_dc_buffer[4*esi],@player_y,@player_x,cell_size, cell_size,h_dc_snake_body,0,0,136,136,SRCPAINT
    ret
_draw_body ENDP

end
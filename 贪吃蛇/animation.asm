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

cell_size equ 50

printf PROTO C :dword, :vararg
public _draw_head, _draw_body,_draw_tail,_draw_apple

extern h_dc_buffer:dword,h_dc_snake_body:dword, h_dc_snake_head:dword, speed:dword,h_dc_bmp:dword,h_dc_snake_tail:dword,h_dc_apple:dword,h_dc_apple_mask:dword

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

_draw_body PROC player:dword, index_x:dword, index_y:dword, dir:dword, frame_time:dword
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

_draw_tail PROC player:dword, index_x:dword, index_y:dword, dir:dword, frame_time:dword
    local @player_x,@player_y, @dis, @tail_size
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
    invoke StretchBlt,h_dc_bmp,0,0,@tail_size, @tail_size,h_dc_snake_tail,0,0,136,136,SRCCOPY
    mov eax, 0ffffffh
    invoke TransparentBlt,h_dc_buffer[4*esi],@player_y,@player_x,@tail_size, @tail_size,h_dc_bmp,0,0,@tail_size,@tail_size,eax
    ret
_draw_tail ENDP

_draw_apple PROC index_x:dword, index_y:dword, frame_time:dword
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
    mov ecx, 18
    div ecx
    
    .if eax > 3
        mov ecx, 4
        sub ecx, eax
        mov eax, ecx
    .endif
    add @apple_x,eax
    add @apple_y,eax
    sal eax, 1
    sub @apple_size,eax

    invoke printf, offset out_format_int, index_x
    invoke printf, offset out_format_int, index_y
    invoke printf, offset out_format_int, @apple_size

    mov esi, frame_time
    invoke StretchBlt,h_dc_buffer[4*esi],@apple_y,@apple_x,@apple_size, @apple_size,h_dc_apple_mask,0,0,200,200,SRCAND
    invoke StretchBlt,h_dc_buffer[4*esi],@apple_y,@apple_x,@apple_size, @apple_size,h_dc_apple,0,0,200,200,SRCPAINT
    ret
_draw_apple ENDP

end
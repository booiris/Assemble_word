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

printf PROTO C :dword, :vararg
public draw_list,draw_list_size,_build_map,_draw_map

.data 
map dword window_x_len*window_y_len dup (0)
const_map dword window_x_len*window_y_len dup (0)

.const
out_format_int byte '%d', 20h,0

.data?

draw_struct STRUCT ;绘制的消息
    x dword ?
    y dword ?
    prio dword ?    ;绘制的优先级，蛇头比蛇身和蛇尾优先级高，蛇身比蛇尾优先级高，优先级 1,2,3,4，1最大
    item dword ?    ;绘制的物体
    state dword ?   ;绘制物体的状态，现在只有方向状态，但等以后可能加入死亡动画等等，会加入蛇的正在死亡状态等等
draw_struct ENDS

point_struct STRUCT ;原来只是队列存位置不够，加了方向和部位
    pos dword ?
    dir dword ?
    part dword ?
point_struct ENDS

draw_list draw_struct 500 dup ({})
draw_list_size dword ?

player1_list point_struct 500 dup ({})
player1_size dword ?

player2_list point_struct 500 dup ({})
player2_size dword ?

.code
 ; 现在的绘图原理是这样的：
 ; 后端运算完后，将每一个物体塞入一个队列，前端从队列中取出物体绘制
 ; 比如蛇头位于 x,y,方向是向左,就把x,y,物体蛇头标志，方向信息塞入队列，前端就可以根据这些信息绘制图像

 ; 窗口调用 _draw_map 函数，在 _draw_map 函数中，根据蛇的移动变化调用 _create_draw_item函数将物体信息塞入队列

 ; create_draw_item 创建消息，输入值为物体的位置，优先级，绘制的物体和状态

_create_draw_item PROC uses eax edx ecx,pos:dword,prio:dword,item:dword,state:dword
   
    local x,y
    xor edx,edx
    mov eax, pos
    mov ecx, window_x_len
    div ecx
    mov x,eax
    mov y,edx
    mov ecx, draw_list_size
    imul ecx, 20
    mov eax, x
    mov draw_list[ecx].x, eax
    mov eax, y
    mov draw_list[ecx].y, eax
    mov eax, prio
    mov draw_list[ecx].prio, eax
    mov eax, item
    mov draw_list[ecx].item, eax
    mov eax, state
    mov draw_list[ecx].state, eax
    inc draw_list_size
    ret 
_create_draw_item ENDP

random proc uses edx ecx,value:dword
	;随机范围为0~value
	invoke	GetTickCount
	xor		edx,edx
	mov		ecx,value
	div		ecx
	mov		eax,edx
	ret
random endp

_create_apple PROC uses eax
get_random:
    invoke random, window_y_len*window_x_len
    .if map[4*eax] != 0
        jmp get_random
    .else
        mov map[4*eax], apple
    .endif
    ret
_create_apple ENDP

_get_nxt_pos PROC uses edx ebx, now_pos:dword,dir:dword
    local now_x, now_y:dword
    mov eax, now_pos
    mov ebx, window_x_len
    xor edx, edx
    div ebx
    mov now_y, eax
    mov now_x, edx
    mov eax, now_pos
    .if dir == 1                    ; 上
        .if now_y == 0
            add eax, window_x_len * window_y_len
        .endif
        sub eax, window_x_len
    .elseif dir == 2                ; 右
        .if now_x == window_x_len - 1
            sub eax, window_x_len
        .endif
        add eax, 1
    .elseif dir == 3                ; 下
        .if now_y == window_y_len - 1
            sub eax, window_x_len * window_y_len
        .endif
        add eax, window_x_len
    .elseif dir == 4                ; 左
        .if now_x == 0
            add eax, window_x_len
        .endif
        sub eax, 1
    .endif
    ret
_get_nxt_pos ENDP

; _get_nxt_pos PROC uses edx ebx, now_pos:dword,dir:dword
;     mov eax, now_pos
;     .if dir == 1                    ; 上
;         sub eax, window_x_len
;     .elseif dir == 2                ; 右
;         add eax, 1
;     .elseif dir == 3                ; 下
;         add eax, window_x_len
;     .elseif dir == 4                ; 左
;         sub eax, 1
;     .endif
;     ret
; _get_nxt_pos ENDP

_draw_map PROC player1_dir:dword
    local @index:dword,father_dir,father_pos

    mov draw_list_size, 0

    mov eax, player1_dir
    mov player1_list[0].dir, eax
    invoke _get_nxt_pos, player1_list[0].pos,player1_dir

    ; 蛇头会碰到苹果
    .if map[4*eax] == apple

        ; 产生新苹果
        invoke _create_apple

        mov ecx, 0
        .while ecx != player1_size
            push ecx
            imul ecx,12
            .if player1_list[ecx].part == player1_head 
                invoke _create_draw_item, player1_list[ecx].pos, 1, emoji, 0
                mov eax, 2
            .elseif player1_list[ecx].part == player1_body 
                mov eax, 3
            .elseif player1_list[ecx].part == player1_tail
                mov player1_list[ecx].part, player1_body
                mov eax, player1_list[ecx].pos
                mov father_pos, eax
                mov eax, 3
            .endif

            invoke _create_draw_item, player1_list[ecx].pos, eax, player1_list[ecx].part, player1_list[ecx].dir
            mov eax, player1_list[ecx].pos
            mov map[4*eax], 0
            invoke _get_nxt_pos, player1_list[ecx].pos,player1_list[ecx].dir
            mov edx, eax ; edx存储下一个位置
            mov eax, player1_list[ecx].part
            mov map[4*edx], eax
            mov player1_list[ecx].pos, edx
            mov edx, player1_list[ecx].dir
            .if ecx != 0
                mov eax, father_dir
                mov player1_list[ecx].dir, eax
            .endif 
            mov father_dir, edx
            pop ecx
            inc ecx
        .endw

        ; 添加尾巴
        mov ecx, player1_size
        imul ecx, 12
        mov eax, father_dir
        mov player1_list[ecx].dir, eax
        mov eax, father_pos
        mov player1_list[ecx].pos, eax
        mov player1_list[ecx].part, player1_tail
        inc player1_size
        add father_dir, 4
        invoke _create_draw_item, father_pos, 4, player1_tail, father_dir
        mov eax, father_pos
        mov map[4*edx], player1_tail

    ; 蛇没吃到苹果
    .else
        mov ecx, 0
        .while ecx != player1_size
            push ecx
            imul ecx,12
            .if player1_list[ecx].part == player1_head 
                mov eax, 2
            .elseif player1_list[ecx].part == player1_body 
                mov eax, 3
            .elseif player1_list[ecx].part == player1_tail
                mov eax, 4
            .endif
            
            invoke _create_draw_item, player1_list[ecx].pos, eax, player1_list[ecx].part, player1_list[ecx].dir
            mov eax, player1_list[ecx].pos
            mov map[4*eax],0
            invoke _get_nxt_pos, player1_list[ecx].pos,player1_list[ecx].dir
            mov edx, eax ; edx存储下一个位置
            mov eax, player1_list[ecx].part
            mov map[4*edx], eax
            mov player1_list[ecx].pos, edx
            mov edx, player1_list[ecx].dir
            .if ecx != 0
                mov eax, father_dir
                mov player1_list[ecx].dir, eax
            .endif 
            mov father_dir, edx
            pop ecx
            inc ecx
        .endw
    .endif

    mov @index,0 
    ; 绘制场景中的墙，苹果等
    .while @index < window_x_len * window_y_len
        mov eax, @index 
        mov ecx, map[4*eax]
        .if ecx == apple 
            invoke _create_draw_item, @index,3,apple,0
        .elseif ecx == wall
            invoke _create_draw_item, @index,3,wall,0
        .endif
        inc @index
    .endw

    mov @index, 0
    .while @index < window_x_len * window_y_len
        mov eax, @index 
        mov ecx, const_map[4*eax]
        .if ecx == grass
             invoke _create_draw_item, @index,1,grass,0
        .endif
        inc @index
    .endw

    ret
_draw_map ENDP
    

_build_map PROC uses esi
    ; 初始化地图

    mov eax, 5*window_x_len+10
    mov ecx, player1_size
    imul ecx, 12
    mov player1_list[ecx].dir,  2
    mov player1_list[ecx].pos,  eax
    mov player1_list[ecx].part,  player1_head
    inc player1_size

    dec eax
    mov map[4*eax], player1_body 
    mov ecx, player1_size
    imul ecx, 12
    mov player1_list[ecx].dir,  2
    mov player1_list[ecx].pos,  eax
    mov player1_list[ecx].part,  player1_body
    inc player1_size

    dec eax 
    mov map[4*eax], player1_tail
    mov ecx, player1_size
    imul ecx, 12
    mov player1_list[ecx].dir,  2
    mov player1_list[ecx].pos,  eax
    mov player1_list[ecx].part,  player1_tail
    inc player1_size

    dec eax
    mov map[4*eax], apple

    mov eax, 9*window_x_len+10
    mov map[4*eax], apple
    mov eax, 1*window_x_len+12
    mov map[4*eax], apple
    mov eax, 3*window_x_len+15
    mov map[4*eax], apple
    mov eax, 7*window_x_len+18
    mov map[4*eax], apple

    mov eax, 9*window_x_len+10
    mov const_map[4*eax], grass
    mov eax, 9*window_x_len+11
    mov const_map[4*eax], grass
    mov eax, 9*window_x_len+12
    mov const_map[4*eax], grass
    mov eax, 9*window_x_len+13
    mov const_map[4*eax], grass
    mov eax, 10*window_x_len+10
    mov const_map[4*eax], grass
    mov eax, 10*window_x_len+11
    mov const_map[4*eax], grass
    mov eax, 10*window_x_len+12
    mov const_map[4*eax], grass
    mov eax, 10*window_x_len+13
    mov const_map[4*eax], grass

    ret
_build_map ENDP


end
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
public draw_list,draw_list_size,_build_map,_draw_map,player1_size,player2_size

extern fps:dword, player1_reverse:dword, player2_reverse:dword,is_end:dword

.data 
map dword window_x_len*window_y_len dup (0)
const_map dword window_x_len*window_y_len dup (0)

.const
out_format_int byte '%d', 20h,0

.data?
point_struct STRUCT ;ԭ��ֻ�Ƕ��д�λ�ò��������˷���Ͳ�λ
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
 ; ���ڵĻ�ͼԭ���������ģ�
 ; ���������󣬽�ÿһ����������һ�����У�ǰ�˴Ӷ�����ȡ���������
 ; ������ͷλ�� x,y,����������,�Ͱ�x,y,������ͷ��־��������Ϣ������У�ǰ�˾Ϳ��Ը�����Щ��Ϣ����ͼ��

 ; ���ڵ��� _draw_map �������� _draw_map �����У������ߵ��ƶ��仯���� _create_draw_item������������Ϣ�������

 ; create_draw_item ������Ϣ������ֵΪ�����λ�ã����ȼ�,���Ƶ������״̬

_create_draw_item PROC uses eax edx ecx,pos:dword,prio:dword,item:dword,state:dword,player:dword
    local x,y
    xor edx,edx
    mov eax, pos
    mov ecx, window_x_len
    div ecx
    mov x,eax
    mov y,edx
    mov ecx, draw_list_size
    imul ecx, 24
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
    mov eax, player
    mov draw_list[ecx].player, eax
    inc draw_list_size
    ret 
_create_draw_item ENDP

random proc uses edx ecx,value:dword
	;�����ΧΪ0~value
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

_create_fast PROC uses eax
get_random:
    invoke random, window_y_len*window_x_len
    .if map[4*eax] != 0
        jmp get_random
    .else
        mov map[4*eax], fast
    .endif
    ret
_create_fast ENDP

_create_dizzy PROC uses eax
get_random:
    invoke random, window_y_len*window_x_len
    .if map[4*eax] != 0
        jmp get_random
    .else
        mov map[4*eax], dizzy
    .endif
    ret
_create_dizzy ENDP

_create_large PROC uses eax
get_random:
    invoke random, window_y_len*window_x_len
    .if map[4*eax] != 0
        jmp get_random
    .else
        mov map[4*eax], large
    .endif
    ret
_create_large ENDP


_get_nxt_pos PROC uses edx ebx, now_pos:dword,dir:dword
    local now_x, now_y:dword
    mov eax, now_pos
    mov ebx, window_x_len
    xor edx, edx
    div ebx
    mov now_y, eax
    mov now_x, edx
    mov eax, now_pos
    .if dir == 1                    ; ��
        .if now_y == 0
            add eax, window_x_len * window_y_len
        .endif
        sub eax, window_x_len
    .elseif dir == 2                ; ��
        .if now_x == window_x_len - 1
            sub eax, window_x_len
        .endif
        add eax, 1
    .elseif dir == 3                ; ��
        .if now_y == window_y_len - 1
            sub eax, window_x_len * window_y_len
        .endif
        add eax, window_x_len
    .elseif dir == 4                ; ��
        .if now_x == 0
            add eax, window_x_len
        .endif
        sub eax, 1
    .endif
    ret
_get_nxt_pos ENDP

_judge_win PROC uses esi edi, player1_dir:dword,player2_dir:dword
	;0����Ӯδ����1��1��ʤ��2��2��ʤ��3��ƽ��
	local pos_head1, pos_head2

	assume esi:ptr point_struct
	mov esi, offset player1_list
	mov edi, offset player1_size
	mov ecx, 0
    .while ecx != [edi] 
        push ecx
        imul ecx,12
        mov eax, [esi+ecx].part
		mov edx, [esi+ecx].pos
        .if  eax == player1_head 
			mov pos_head1,edx
			.break
		.endif
		pop ecx
        inc ecx
    .endw

	mov esi, offset player2_list
	mov edi, offset player2_size
	mov ecx, 0
    .while ecx != [edi] 
        push ecx
        imul ecx,12
        mov eax, [esi+ecx].part
		mov edx, [esi+ecx].pos
        .if  eax == player2_head 
			mov pos_head2,edx
			.break
		.endif
		pop ecx
        inc ecx
    .endw

	mov eax, pos_head1
	mov ebx, pos_head2
	.if eax == ebx
		mov ecx, player1_size
		mov edx, player2_size
		.if ecx == edx
			mov edx, 5
		.elseif ecx < edx
			mov edx, 4
		.else
			mov edx, 3
		.endif
		jmp LJ_End
	.endif

	mov eax, 0
	mov ebx, 0

	mov esi, offset player1_list
	mov edi, offset player1_size
	mov ecx, 0
	.while ecx != [edi] 
		push ecx
		imul ecx,12
		mov edx, [esi+ecx].pos
		.if  edx == pos_head2 
			mov eax, 1
			.break
		.endif
		pop ecx
		inc ecx
	.endw

	mov esi, offset player2_list
	mov edi, offset player2_size
	mov ecx, 0
	.while ecx != [edi] 
		push ecx
		imul ecx,12
		mov edx, [esi+ecx].pos
		.if  edx == pos_head1 
			mov ebx, 1
			.break
		.endif
		pop ecx
		inc ecx
	.endw


	.if eax == 0
		.if ebx == 0
			mov edx, 0
		.else
			mov edx, 2
		.endif
	.else
		.if ebx == 0
			mov edx, 1
		.else
			mov ecx, player1_size
			mov edx, player2_size
			.if ecx == edx
				mov edx, 5
			.elseif ecx < edx
				mov edx, 2
			.else
				mov edx, 1
			.endif
		.endif
	.endif

LJ_End:
	mov eax, edx
    .if eax == 5
        invoke _create_draw_item, pos_head1, 1, emoji, 1, 1
        invoke _create_draw_item, pos_head2, 1, emoji, 1, 2
    .elseif eax == 1 || eax == 3
        invoke _create_draw_item, pos_head2, 1, emoji, 1, 2
    .elseif eax == 2 || eax == 4
        invoke _create_draw_item, pos_head1, 1, emoji, 1, 1
    .endif
	ret
_judge_win ENDP

_draw_snake PROC uses esi edi, player:dword,enemy:dword, dir:dword
    local father_dir,father_pos,snake_head,snake_body,snake_tail,reverse

    assume esi:ptr point_struct
    .if player == 1
        mov snake_head, player1_head
        mov snake_body, player1_body
        mov snake_tail, player1_tail
        mov eax, player1_reverse
        mov reverse, eax
        mov esi , offset player1_list
        mov edi, offset player1_size
    .else 
        mov snake_head, player2_head
        mov snake_body, player2_body
        mov snake_tail, player2_tail
        mov eax, player2_reverse
        mov reverse, eax
        mov esi , offset player2_list
        mov edi, offset player2_size
    .endif

    .if reverse != 0
        invoke _create_draw_item, [esi].pos, 1, emoji, 2, player
    .endif

    mov eax, dir
    mov [esi].dir, eax  ; �ı�ͷ�ķ���
    invoke _get_nxt_pos, [esi].pos,dir

    ; ײǽ�Ĳ�����ͷ����������ǰ�����߳�����
    .if map[4*eax] == wall
        
        ; ��һ�����У���ֹ���Ƚ���1ʱ��ͷ���޸ĳ���β
        mov ecx,2
        .if [edi] > ecx
            mov ecx,[edi]
            sub ecx,2
            imul ecx,12
            mov eax,snake_tail
            mov [esi+ecx].part,eax  ; ���һ������Ĳ�λ������Ϊ��β
            mov edx,[esi+ecx].pos
            mov map[4*edx],eax ; �޸�����β����λ�õ�map
        .endif

        mov ecx,[edi]
        dec ecx
        imul ecx,12
        mov edx,[esi+ecx].pos
        mov map[4*edx],0  ; �޸�ԭ��β����λ�õ�map
        dec dword ptr [edi] ; ȥ��ԭ��β

        ; �����һ������ is_end ��Ϊ0��1Ϊ1������ 2Ϊ 2��Ӯ��3Ϊƽ��
        .if dword ptr [edi] == 1
            .if player == 1
                mov is_end, 2
            .else
                mov is_end, 1
            .endif
        .endif

        invoke _create_draw_item, [esi].pos, 2, [esi].part, 5,player ; ��������ͷ��dir=5����ײ��ǽ��Ķ���
        invoke _create_draw_item, [esi].pos, 1, emoji, 1, player

        mov ecx, 1 
        .while ecx != [edi] ; ��������λ
            push ecx
            imul ecx,12
            mov eax, [esi+ecx].part
            .if eax == snake_body
                mov eax, 3
            .elseif eax == snake_tail
                mov eax, 4
            .endif
            invoke _create_draw_item, [esi+ecx].pos, eax, [esi+ecx].part, [esi+ecx].dir,player
            pop ecx
            inc ecx
        .endw

    ; ��ͷ������ƻ��
    .elseif map[4*eax] == apple
        ; ������ƻ��
        invoke _create_apple
        mov ecx, 0
        .while ecx != [edi] ; �����ߵ�ÿһ��
            push ecx
            imul ecx,12
            mov eax, [esi+ecx].part
            .if  eax == snake_head 
                invoke _create_draw_item, [esi+ecx].pos, 1, emoji, 0, player
                mov eax,1
                .if [edi] == eax ; ����Ϊ1ʱ��������β����������
                    mov eax, [esi+ecx].pos
                    mov father_pos, eax ; ��¼��ͷ��λ�ã���������β��
                .endif
                mov eax, 2
            .elseif eax == snake_body 
                mov eax, 3
            .elseif eax == snake_tail
                mov eax, snake_body
                mov [esi+ecx].part, eax ; β�͵Ĳ�λ���Ա������
                mov eax, [esi+ecx].pos
                mov father_pos, eax ; ��¼β�͵�λ�ã���������β��
                mov eax, 3
            .endif

            invoke _create_draw_item, [esi+ecx].pos, eax, [esi+ecx].part, [esi+ecx].dir,player
            mov eax, [esi+ecx].pos
            mov map[4*eax], 0
            invoke _get_nxt_pos, [esi+ecx].pos,[esi+ecx].dir
            mov edx, eax ; edx�洢��һ��λ��
            mov eax, [esi+ecx].part
            mov map[4*edx], eax 
            mov [esi+ecx].pos, edx  ; �޸�ÿһ���λ��
            mov edx, [esi+ecx].dir
            .if ecx != 0 
                mov eax, father_dir
                mov [esi+ecx].dir, eax ; ��ͷ��ķ����Ϊfather(ǰһ��)�ķ���
            .endif 
            mov father_dir, edx
            pop ecx
            inc ecx
        .endw

        ; ���β��
        mov ecx, [edi]
        imul ecx, 12
        mov eax, father_dir
        mov [esi+ecx].dir, eax
        mov eax, father_pos
        mov [esi+ecx].pos, eax
        mov eax, snake_tail
        mov [esi+ecx].part, eax
        inc dword ptr [edi]
        add father_dir, 4
        invoke _create_draw_item, father_pos, 4, snake_tail, father_dir,player
        mov eax, father_pos
        mov eax,snake_tail
        mov map[4*edx], eax

    ; ��û�Ե�ƻ��
    .else

        .if map[4*eax] == fast ; �Ե����ٵ���
            sub fps,2000
            .if fps > 2000
                invoke _create_fast
            .endif
        .endif

        .if map[4*eax] == dizzy ; �Ե�ѣ�ε���
            .if player == 1
                add player2_reverse, 20
            .else
                add player1_reverse, 20
            .endif
            invoke _create_dizzy
        .endif

        .if map[4*eax] == large ; �Ե�������
            invoke _create_draw_item, 0,4,large_eat,0,player
            invoke _create_large
        .endif

        mov ecx, 0
        .while ecx != [edi]
            push ecx
            imul ecx,12
            mov eax, [esi+ecx].part
            .if eax == snake_head
                mov eax, 2
            .elseif eax == snake_body
                mov eax, 3
            .elseif eax == snake_tail
                mov eax, 4
            .endif
            
            invoke _create_draw_item, [esi+ecx].pos, eax, [esi+ecx].part, [esi+ecx].dir,player
            mov eax, [esi+ecx].pos
            mov map[4*eax],0
            invoke _get_nxt_pos, [esi+ecx].pos,[esi+ecx].dir
            mov edx, eax ; edx�洢��һ��λ��
            mov eax, [esi+ecx].part 
            mov map[4*edx], eax
            mov [esi+ecx].pos, edx
            mov edx, [esi+ecx].dir
            .if ecx != 0
                mov eax, father_dir
                mov [esi+ecx].dir, eax
            .endif 
            mov father_dir, edx
            pop ecx
            inc ecx
        .endw
    .endif
    assume esi:nothing
    ret
_draw_snake ENDP 

_draw_map PROC player1_dir:dword,player2_dir:dword
    local @index:dword

    mov draw_list_size, 0

    invoke _draw_snake, 1,2,player1_dir
    invoke _draw_snake, 2,1,player2_dir

    mov @index,0 
    ; ���Ƴ����е�ǽ��ƻ����
    .while @index < window_x_len * window_y_len
        mov eax, @index 
        mov ecx, map[4*eax]
        .if ecx == apple 
            invoke _create_draw_item, @index,3,apple,0,0
        .elseif ecx == wall
            invoke _create_draw_item, @index,4,wall,0,0
        .elseif ecx == fast
            invoke _create_draw_item, @index,3,fast,0,0
        .elseif ecx == dizzy
            invoke _create_draw_item, @index,3,dizzy,0,0
        .elseif ecx == large
            invoke _create_draw_item, @index,3,large,0,0
        .endif
        inc @index
    .endw

    mov @index, 0
    .while @index < window_x_len * window_y_len
        mov eax, @index 
        mov ecx, const_map[4*eax]
        .if ecx == grass
             invoke _create_draw_item, @index,1,grass,0,0
        .endif
        inc @index
    .endw

	invoke _judge_win, player1_dir, player2_dir
    .if is_end == 0
	    mov is_end, eax
    .endif

    ret
_draw_map ENDP
    

_build_map PROC uses esi
    ; ��ʼ����ͼ
    ; ��
    mov eax, 12*window_x_len+10
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

    mov eax, 12*window_x_len+20
    mov ecx, player2_size
    imul ecx, 12
    mov player2_list[ecx].dir,  4
    mov player2_list[ecx].pos,  eax
    mov player2_list[ecx].part,  player2_head
    inc player2_size

    inc eax
    mov map[4*eax], player2_body 
    mov ecx, player2_size
    imul ecx, 12
    mov player2_list[ecx].dir,  4
    mov player2_list[ecx].pos,  eax
    mov player2_list[ecx].part,  player2_body
    inc player2_size

    inc eax 
    mov map[4*eax], player2_tail
    mov ecx, player2_size
    imul ecx, 12
    mov player2_list[ecx].dir,  4
    mov player2_list[ecx].pos,  eax
    mov player2_list[ecx].part,  player2_tail
    inc player2_size


    ; ǽ
    mov ecx, 2*window_x_len+4
    .while ecx <= 2*window_x_len+19
        mov map[4*ecx], wall
        inc ecx
    .endw

    mov ecx, 3*window_x_len+4
    .while ecx <= 9*window_x_len+4
        mov map[4*ecx], wall
        add ecx,window_x_len
    .endw

    mov ecx, 3*window_x_len+19
    .while ecx <= 9*window_x_len+19
        mov map[4*ecx], wall
        add ecx,window_x_len
    .endw

    
    ; ����
    invoke _create_fast
    invoke _create_dizzy
    invoke _create_large
    
    ; ƻ��
    invoke _create_apple
    invoke _create_apple
    invoke _create_apple
    invoke _create_apple
    
    ; ��
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
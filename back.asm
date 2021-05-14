.386
.model flat,stdcall
option casemap:none


includelib  msvcrt.lib
include		windows.inc
include		user32.inc
includelib	user32.lib
include		kernel32.inc
includelib	kernel32.lib
include		Gdi32.inc
includelib	Gdi32.lib
include     winmm.inc
includelib  winmm.lib

time	PROTO C :dword
printf  PROTO C	:dword, :VARARG
system	PROTO C	:dword
time	PROTO C :dword
srand	PROTO C :dword
rand	PROTO C
Sleep	PROTO, dwMilliseconds : DWORD

.data
timeInt dd	10		;ÿ�����ƶ���ʱ����
listLen dd	40
list	db	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0	;����˳��
blk		db	' ',0
ent		db	' ',0ah,0
item	db	'*',0
fmt		db	'%d',0ah,0
los		db	'You lose',0ah,0
cls		db	'cls',0
map		db	1000 dup(0)	;����ã�0�գ�1ǽ��2��ͷ��3����4ʳ��
body	dw	100 dup(?)	;0β��len-1��ͷ
len		dd	2	;body����
dir		db	1	;0��1�ң�2�ϣ�3��
n		db	20	;����
m		db	40	;����
N		dw	256

.code
start:
		invoke	time, 0
		invoke	srand, eax
		mov		ecx,len
		mov		edi,0
		mov		ax,0a0ah		;ah��al��,��ʼλ��
init1:	mov		body[2*edi],ax	;��ʼ������
		push	edi
		call	toidx
		mov		map[di],3
		pop		edi
		inc		edi
		inc		ah
		loop	init1

		xor		ax,ax
init2:	call	toidx			;��ʼ�����ұ߽�
		mov		map[di],1
		push	ax
		add		ah,m
		dec		ah
		call	toidx
		mov		map[di],1
		pop		ax
		inc		al
		cmp		al,n
		jl		init2

		xor		ax,ax
init3:	call	toidx		;��ʼ�����±߽�
		mov		map[di],1
		push	ax
		add		al,n
		dec		al
		call	toidx
		mov		map[di],1
		pop		ax
		inc		ah
		cmp		ah,m
		jl		init3
							;����Ϊ��ʼ��
		call	genFood
		call	outmap
		mov		ecx, 0
L0:		
		push	ecx
		invoke	Sleep, timeInt	
		pop		ecx
		mov		al, list[ecx]
		push	ecx
		call	go
		pop		ecx
		cmp		dx, 1
		je		LOSE
		push	ecx
		call	outmap
		pop		ecx
		inc		ecx
		cmp		ecx, listLen
		jl		L0

FIN:	
		ret
LOSE:	invoke	printf,offset los
		ret


;******************�������岿��************************

outmap:					;�ػ滭��--��ı��eax������ֵ
		push	eax
		invoke	system,offset cls
		xor		eax,eax

		jmp		cmp1
lop1:	xor		ah,ah
		jmp		cmp2
lop2:	call	toidx
		cmp		map[di],0
		jne		p1
		push	ax
		invoke	printf,offset blk
		pop		ax
		jmp		p2
p1:		push	ax
		invoke	printf,offset item
		pop		ax
p2:		inc		ah
cmp2:	cmp		ah,m
		jl		lop2
		push	ax
		invoke	printf,offset ent
		pop		ax
		inc		al
cmp1:	cmp		al,n
		jl		lop1
		
		pop		eax
		ret

toidx:					;תΪmapƫ��--�������Ϊax��diΪ����ֵ,��������
		push	ax
		push	dx

		xor		dx,dx
		mov		dl,ah
		mul		m
		add		ax,dx
		mov		di,ax

		pop		dx
		pop		ax
		ret

randp:					;�������λ��--����ֵ��ax�����мĴ�������ı�
		invoke	rand
		call	modN
		div		n
		mov		al,ah
		xor		ah,ah
		push	ax	;��λ��

		xor		eax,eax
		invoke	rand
		call	modN
		div		m	;��λ��
		pop		dx
		mov		al,dl
		call	toidx
		cmp		map[di],0
		jne		randp
		ret
modN:					;ʹax��mod256
		xor		dx,dx
		div		N
		mov		ax,dx
		xor		dx,dx
		ret

genFood:				;����ʳ��--ax����ʳ��λ�ã������Ĵ�������ı�
		call	randp
		call	toidx
		mov		map[di],4
		ret

go:						;��һ������--��������al,Ϊ����  ����ֵ��dx,0�ɹ���1ʧ��
		push	ax
		mov		ebx, len
		dec		ebx
		mov		dx, body[2*ebx]
		cmp		al, 0
		je		left
		cmp		al, 1
		je		right
		cmp		al, 2
		je		up
		cmp		al, 3
		je		down	;dx��������ͷλ��
left:
		mov		dir, 0
		dec		dh
		jmp		moveExit
right:
		mov		dir, 1
		inc		dh
		jmp		moveExit
up:
		mov		dir, 2
		dec		dl
		jmp		moveExit
down:
		mov		dir, 3
		inc		dl
		jmp		moveExit
moveExit:
		mov		ax, dx
		call	toidx		;����ax����ͷ���� di��ƫ��
		cmp		map[di], 0
		je		goNormal
		cmp		map[di], 1
		je		goFail
		cmp		map[di], 2
		je		goFail
		cmp		map[di], 3
		je		goFail
		cmp		map[di], 4
		je		goSuccess
goFail:										;ײ��ǽ������
		pop		ax
		mov		dx, 1
		ret

goSuccess:									;�Ե�ʳ��
		mov		map[di], 2		;�޸���ͷmap
		mov		ebx, len
		mov		body[2*ebx], ax	;�޸���ͷbody
		dec		ebx
		mov		ax, body[2*ebx]
		call	toidx	
		mov		map[di], 3		;�޸�mԭͷmap
		inc		len
		call	genFood
		pop		ax
		mov		dx, 0

		ret

goNormal:									;��ͨ�ƶ�
		mov		map[di], 2		;�޸���ͷmap
		mov		ebx, len
		mov		body[2*ebx], ax	;�޸���ͷbody
		dec		ebx
		mov		ax, body[2*ebx]
		call	toidx		
		mov		map[di], 3		;�޸�mԭͷmap
		mov		ebx, 0
		mov		ax, body[2*ebx]
		call	toidx
		mov		map[di], 0		;�޸�β��map
		mov		esi, 2
L1:		mov		ax, body[2*ebx+esi]	;ѭ���ƶ�body
		mov		body[2*ebx], ax
		inc		ebx
		cmp		ebx, len
		jl		L1		
		pop		ax
		mov		dx, 0
		
		ret

end		start

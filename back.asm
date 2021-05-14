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
timeInt dd	10		;每两次移动的时间间隔
listLen dd	40
list	db	1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0	;动的顺序
blk		db	' ',0
ent		db	' ',0ah,0
item	db	'*',0
fmt		db	'%d',0ah,0
los		db	'You lose',0ah,0
cls		db	'cls',0
map		db	1000 dup(0)	;输出用，0空，1墙，2蛇头，3蛇身，4食物
body	dw	100 dup(?)	;0尾，len-1是头
len		dd	2	;body长度
dir		db	1	;0左，1右，2上，3下
n		db	20	;行数
m		db	40	;列数
N		dw	256

.code
start:
		invoke	time, 0
		invoke	srand, eax
		mov		ecx,len
		mov		edi,0
		mov		ax,0a0ah		;ah列al行,初始位置
init1:	mov		body[2*edi],ax	;初始化蛇身
		push	edi
		call	toidx
		mov		map[di],3
		pop		edi
		inc		edi
		inc		ah
		loop	init1

		xor		ax,ax
init2:	call	toidx			;初始化左右边界
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
init3:	call	toidx		;初始化上下边界
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
							;以上为初始化
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


;******************函数定义部分************************

outmap:					;重绘画面--会改变除eax外所有值
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

toidx:					;转为map偏移--传入参数为ax；di为返回值,其他不变
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

randp:					;随机产生位置--返回值在ax，所有寄存器都会改变
		invoke	rand
		call	modN
		div		n
		mov		al,ah
		xor		ah,ah
		push	ax	;行位置

		xor		eax,eax
		invoke	rand
		call	modN
		div		m	;列位置
		pop		dx
		mov		al,dl
		call	toidx
		cmp		map[di],0
		jne		randp
		ret
modN:					;使ax数mod256
		xor		dx,dx
		div		N
		mov		ax,dx
		xor		dx,dx
		ret

genFood:				;产生食物--ax保存食物位置，其他寄存器都会改变
		call	randp
		call	toidx
		mov		map[di],4
		ret

go:						;动一步函数--参数传入al,为方向  返回值在dx,0成功，1失败
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
		je		down	;dx保存了蛇头位置
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
		call	toidx		;现在ax是新头坐标 di是偏移
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
goFail:										;撞到墙或身体
		pop		ax
		mov		dx, 1
		ret

goSuccess:									;吃到食物
		mov		map[di], 2		;修改新头map
		mov		ebx, len
		mov		body[2*ebx], ax	;修改新头body
		dec		ebx
		mov		ax, body[2*ebx]
		call	toidx	
		mov		map[di], 3		;修改m原头map
		inc		len
		call	genFood
		pop		ax
		mov		dx, 0

		ret

goNormal:									;普通移动
		mov		map[di], 2		;修改新头map
		mov		ebx, len
		mov		body[2*ebx], ax	;修改新头body
		dec		ebx
		mov		ax, body[2*ebx]
		call	toidx		
		mov		map[di], 3		;修改m原头map
		mov		ebx, 0
		mov		ax, body[2*ebx]
		call	toidx
		mov		map[di], 0		;修改尾部map
		mov		esi, 2
L1:		mov		ax, body[2*ebx+esi]	;循环移动body
		mov		body[2*ebx], ax
		inc		ebx
		cmp		ebx, len
		jl		L1		
		pop		ax
		mov		dx, 0
		
		ret

end		start

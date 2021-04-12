.386
.MODEL flat, stdcall
option casemap:none

includelib msvcrt.lib
printf PROTO C :ptr sbyte, :VARARG

.DATA
szMsg sbyte '%d' ,0ah,0
asd byte '12345', 0

.CODE
main proc
	invoke printf,offset szMsg, sizeof asd
	ret
main endp
end main
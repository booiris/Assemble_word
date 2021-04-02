.386
.MODEL flat, stdcall
option casemap:none

includelib msvcrt.lib
printf PROTO C :ptr sbyte, :VARARG

.DATA
szMsg sbyte 'Hello' ,0ah,0


.CODE
main proc
	invoke printf,offset szMsg
	ret
main endp
end main
.386
.model flat, stdcall
option casemap:none

includelib msvcrt.lib
printf PROTO C :ptr sbyte, :VARARG

.data
szMsg sbyte 'Hello' ,0ah,0


.code
main proc
	invoke printf,offset szMsg
	ret
main endp
end main
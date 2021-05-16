.386
.MODEL flat, stdcall
option casemap:none

includelib msvcrt.lib
printf PROTO C :ptr sbyte, :VARARG

.DATA
buf1 db 123
buf2 dd buf1
l1 equ $-buf2
out_format_int byte '%d', 20h,0

.CODE
main proc
	invoke printf,offset out_format_int, l1
	ret
main endp
end main
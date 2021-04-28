.386
.MODEL flat, stdcall
option casemap:none

includelib msvcrt.lib
printf PROTO C :ptr sbyte, :VARARG

.DATA
szMsg sbyte '%d' ,0ah,0
asd byte '12345', 0
arr dword 1,2,3,4,5,6,7
aaaa dword 1
bbbb dword 2

.CODE
main proc
    mov eax , aaaa
    sub bbbb,10
    mov cl,12
	invoke printf,offset szMsg, eax
main endp
end main
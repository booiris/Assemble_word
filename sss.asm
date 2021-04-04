.386
.model flat,stdcall
option casemap:NONE
includelib msvcrt.lib
printf proto c :dword,:vararg
.DATA
fact dword ?
N = 2
szfmt byte '%d = %d', 0ah, 0
.code
start:
    mov ecx,N
    mov eax,1
    e10: 
        imul eax,ecx
        loop e10
    mov fact,eax
    invoke printf, offset szfmt,N,fact
    ret
end start
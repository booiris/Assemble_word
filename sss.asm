.386
.model flat,stdcall
option casemap:NONE
MessageBoxA PROTO :dword, :dword, :dword, :dword
MessageBox equ <MessageBoxA>
includelib user32.lib
NULL equ 0
MB_OK equ 0
.stack 4096
.DATA
SzTitle byte 'Hi',0
szMsg byte 'asdfasf',0
.CODE
start:

    invoke MessageBox,NULL,offset szMsg,offset SzTitle,MB_OK
    ret
end start
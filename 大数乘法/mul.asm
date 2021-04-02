.386
.MODEL flat, stdcall
option casemap:none

includelib msvcrt.lib

printf PROTO C :dword, :vararg
scanf PROTO C :dword, :vararg


.data
in_msg_n byte '输入数字长度', 0ah, 0
in_msg_num byte '输入数字', 0ah, 0

in_format_n byte '%d', 0
in_format_num byte '%s', 0

out_format_n byte '%d', 0ah, 0
out_format_num byte '%s', 0ah, 0

n1 dword ?
num1_str dword ?
n2 dword ?
num2_str dword ?

.code
start:
    invoke printf, offset in_msg_n
    invoke scanf, offset in_format_n, offset n1

    invoke printf, offset in_msg_num
    invoke scanf, offset in_format_num, offset num1_str

    invoke printf, offset in_msg_n
    invoke scanf, offset in_format_n, offset n2

    invoke printf, offset in_msg_num
    invoke scanf, offset in_format_num, offset num2_str

    # TODO 写完添加暂停 
    ret
end start
.386
.MODEL flat, stdcall
option casemap:none

includelib msvcrt.lib

printf PROTO C :dword, :vararg
scanf PROTO C :dword, :vararg


.data
in_msg_num byte '输入数字', 0ah, 0

in_format_n byte '%d', 0
in_format_num byte '%s', 0

out_format_int byte '%d', 0ah, 0
out_format_num_str byte '%s', 0ah, 0
out_format_float byte '%f', 0ah, 0 

n1 dword ?
num1_str dword ?
n2 dword ?
num2_str dword ?
flag sbyte 1

cp STRUCT
    x dword 0.0
    y dword 0.0
cp ENDS

num1 cp 1000 dup({})
num2 cp 1000 dup({})

.code

int_to_float PROC C int_num:dword ;由于输入是0-9，可以打表，但为了学习，还是写一写这个函数
    mov edx, int_num
    xor eax, eax
    test edx, edx ; 判断 edx 是否为0
    jz done
    jns pos ;正数
    ; 下面是负数的处理
    or eax, 80000000h ;如果判断得到负数，符号位置1
    neg edx ;补码取负数
    pos:
        bsr ecx, edx ;从最高位向最低位搜索，读取第一个1
        sub ecx, 23 ;由于只能保存23位有效数字，得把第一个1后23位移到浮点数有效位上，计算偏移量
        ror edx, cl 
        ;这里一个trick x-23如果是负数的话，相当于右移32+x-23位，又由于256-32整除32,所以相当于右移256+x-23位
        and edx, 007fffffh ; 前9位置0
        or eax, edx         ; 得到有效部分的数
        add ecx, 150   ; 计算指数部分大小，由于指数为移码，所以加上127再加上之前减去的23
        shl ecx, 23 ; 左移23位，移到浮点数的指数部分
        or eax, ecx
    done:
        ret
int_to_float ENDP

changenum PROC C ,str_p:dword,num_p:dword
    LOCAL n:dword
    mov n, 0
    mov esi, str_p
    mov edi, num_p
    arr_loop:
        xor edx, edx
        mov dl, [esi]
        cmp dl, 0
        je arr_loop_break
        cmp dl, '-'
        je negtive
        sub edx, '0'
        invoke int_to_float, edx
        mov [edi], eax
        inc esi
        inc n
        add edi, 8
        jmp arr_loop
    arr_loop_break:
        mov eax, 1
    check_2_pow:
        cmp eax, n
        jge done
        sal eax, 1
        jmp check_2_pow
    negtive:
        inc esi
        neg flag
        jmp arr_loop
    done:
        ret
    
changenum ENDP

outputnum PROC C num_len:dword,num_p:dword
    LOCAL t4:real4,t8:real8
    finit
    mov edi, num_p
    mov ecx, num_len
    arr_loop:
        push ecx
        mov eax, [edi]
        mov t4, eax
        fld t4
        fstp t8
        invoke printf, offset out_format_float, t8
        add edi, 8
        pop ecx
        loop arr_loop
    ret
outputnum ENDP

fft PROC C 

fft ENDP



start:

    invoke printf, offset in_msg_num
    invoke scanf, offset in_format_num, offset num1_str

    invoke printf,offset out_format_num_str,offset num1_str
    
    invoke changenum, offset num1_str, offset num1
    mov n1, eax
    invoke printf, offset out_format_int, n1
    invoke outputnum, n1, offset num1
    invoke printf, offset out_format_int, flag

    invoke printf, offset in_msg_num
    invoke scanf, offset in_format_num, offset num2_str

    invoke printf,offset out_format_num_str,offset num2_str
    
    invoke changenum, offset num2_str, offset num2
    mov n2, eax
    invoke printf, offset out_format_int, n2
    invoke outputnum, n2, offset num2
    invoke printf, offset out_format_int, flag

    ; invoke fft, n1, offset num1, f
    ; invoke fft, n2, offset num2



    ; TODO 写完添加暂停 
    ret
end start
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
in_format_char byte '%c', 0

out_format_int byte '%d', 0
out_format_num_str byte '%s', 0ah, 0
out_format_float byte '%.2f', 20h, 0 
out_format_enter byte 0ah, 0
out_format_negtive byte '-', 0

flag dword 1
two real4 2.0

.data?

cp STRUCT
    x dword ?
    y dword ?
cp ENDS

n1 dword ?
num1_str byte 4105 dup(?)
n2 dword ?
num2_str byte 4105 dup(?)

tttt byte ?

num1 cp 8200 dup({})
num2 cp 8200 dup({})
temp_num cp 8200 dup({})

ans dword 8200 dup(?)
ans_len dword ?

.code

reverse_input PROC C str_p:dword
    mov esi, str_p
    mov ecx, 0
    main_loop:
        mov eax, [esi]
        cmp eax, 0
        jz loop_end
        inc ecx
        inc esi
        jmp main_loop
    loop_end:
        mov esi, str_p
        mov ebx, 0
    loop1:
        mov al, [esi+ebx]
        mov dl, [esi+ecx-1]
        mov [esi+ecx-1], al
        mov [esi+ebx], dl
        inc ebx
        dec ecx
        cmp ecx, ebx
        jle loop1_end
        jmp loop1
    loop1_end:
        ret


reverse_input ENDP

int_to_float PROC C int_num:dword 
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
        je done
        cmp dl, '-'
        je negtive
        sub edx, '0'
        invoke int_to_float, edx
        mov [edi], eax
        mov eax, 0
        mov [edi+4], eax
        inc esi
        inc n
        add edi, 8
        jmp arr_loop
    negtive:
        neg flag
        inc esi
        jmp arr_loop
    done:
        mov eax, n
        ret
changenum ENDP    
    
get_maxn PROC C nn1:dword,nn2:dword
    mov ecx, nn1
    add ecx, nn2
    mov eax, 1
    main_loop:
        cmp eax, ecx
        jge done 
        sal eax, 1
        jmp main_loop
    done:
        ret
get_maxn ENDP

cp_mul PROC C cp1:cp, cp2:cp
    LOCAL temp:cp
    fld cp1.x
    fmul cp2.x
    fld cp1.y
    fmul cp2.y
    fsubp st(1),st(0)
    fstp temp.x

    fld cp1.x
    fmul cp2.y
    fld cp1.y
    fmul cp2.x
    faddp st(1),st(0)
    fstp temp.y

    fld temp.x
    fld temp.y
    ret
cp_mul ENDP

fft PROC C num_len:dword, num_p:dword, inv:dword
    LOCAL mid:dword,temp_cp:cp,max_n:real4,float_inv:real4,t1:cp,t2:cp
    cmp num_len, 1
    je done
    mov esi, num_p
    mov eax, num_len
    sar eax, 1
    mov mid, eax
    mov ecx, eax
    mov edx, 0
    mov edi, offset temp_num
    mov esi, num_p
    temp_init:
        push edx
        mov ebx, edx ;edx i, ebx 2*i
        sal ebx, 1
        mov eax, [esi+8*ebx]
        mov [edi+8*edx], eax
        mov eax, [esi+8*ebx+4]
        mov [edi+8*edx+4], eax

        add edx, mid
        add ebx, 1
        mov eax, [esi+8*ebx]
        mov [edi+8*edx], eax
        mov eax, [esi+8*ebx+4]
        mov [edi+8*edx+4], eax

        pop edx
        inc edx
        loop temp_init

    mov ecx, num_len
    temp_1_copy:
        mov eax, [edi+8*ecx-8]
        mov [esi+8*ecx-8],eax
        mov eax, [edi+8*ecx-4]
        mov [esi+8*ecx-4],eax
        loop temp_1_copy

    invoke fft, mid, num_p , inv
    mov eax, mid
    sal eax, 3
    mov esi, num_p
    add esi, eax 
    invoke fft, mid, esi, inv

    invoke int_to_float, num_len
    mov max_n, eax
    invoke int_to_float, inv
    mov float_inv, eax

    mov edi, offset temp_num
    mov esi, num_p
    mov edx, 0
    finit
    fldz
    main_loop:
        ; fpu 栈顶为i
        fldpi

        fmul st(0),st(1)

        fld two

        fmulp st(1),st(0)
        fdiv max_n

        fld st(0)

        fcos
        fstp temp_cp.x

        fsin
        fmul float_inv
        fstp temp_cp.y

        mov ebx, edx
        add ebx, mid
        mov eax, [esi+8*ebx]
        mov t1.x, eax
        mov eax, [esi+8*ebx+4]
        mov t1.y, eax

        invoke cp_mul, temp_cp, t1
        fstp t2.y
        fstp t2.x

        mov eax, [esi+8*edx]
        mov t1.x, eax
        mov eax, [esi+8*edx+4]
        mov t1.y, eax

        fld t1.x
        fadd t2.x
        fstp temp_cp.x
        mov eax, temp_cp.x
        mov [edi+8*edx], eax
        fld t1.y
        fadd t2.y
        fstp temp_cp.y
        mov eax, temp_cp.y
        mov [edi+8*edx+4], eax

        fld t1.x
        fsub t2.x
        fstp temp_cp.x
        mov eax, temp_cp.x
        mov [edi+8*ebx], eax
        fld t1.y
        fsub t2.y
        fstp temp_cp.y
        mov eax, temp_cp.y
        mov [edi+8*ebx+4], eax
        inc edx
        
        fld1
        faddp st(1),st(0)

        cmp edx, mid
        jz main_loop_break
        jmp main_loop

    main_loop_break:
        fstp max_n
        mov ecx, num_len
    temp_2_copy:
        mov eax, [edi+8*ecx-8]
        mov [esi+8*ecx-8],eax

        mov eax, [edi+8*ecx-4]
        mov [esi+8*ecx-4],eax
        loop temp_2_copy 

    done:
        ret

fft ENDP

output_ans PROC C 
    cmp flag,0
    jg nonegtive
    invoke printf, offset out_format_negtive

    nonegtive:
        mov edi, offset ans
        mov ecx, ans_len
        arr_loop:
            push ecx
            mov eax, [edi+4*ecx-4]
            invoke printf, offset out_format_int, eax
            pop ecx
            loop arr_loop
        invoke printf, offset out_format_enter
        ret
output_ans ENDP

mat_mul PROC C num_len:dword
    LOCAL temp1:cp,temp2:cp
    mov esi, offset num1
    mov edi, offset num2
    mov ecx, num_len

    main_loop:
        mov eax, [esi]
        mov temp1.x, eax
        mov eax, [esi+4]
        mov temp1.y, eax

        mov eax, [edi]
        mov temp2.x, eax
        mov eax, [edi+4]
        mov temp2.y, eax

        invoke cp_mul, temp1, temp2
        fstp temp1.y
        fstp temp1.x

        mov eax, temp1.x
        mov [esi], eax
        mov eax, temp1.y
        mov [esi+4], eax

        add esi, 8
        add edi, 8

        loop main_loop

    ret

mat_mul ENDP


get_ans PROC C num_len:dword
    LOCAL temp:dword, n:dword
    mov ecx, num_len
    mov edi, offset ans
    mov esi, offset num1
    loop1:
        push ecx
        mov eax, [esi]
        mov temp, eax
        fld temp

        invoke int_to_float, num_len
        mov temp, eax
        fdiv temp
        fistp temp
        mov eax, temp
        mov [edi], eax

        add edi, 4
        add esi, 8
        pop ecx
        loop loop1

    mov esi, offset ans
    mov ebx, 10
    mov ecx, num_len
    loop3:
        xor edx,edx
        mov eax, [esi]
        div ebx
        mov [esi], edx
        add [esi+4], eax
        add esi, 4
        loop loop3
    mov ecx, num_len
    mov esi, offset ans
    loop4:
        mov eax, [esi+4*ecx-4]
        cmp eax, 0
        jnz loop4_end
        dec ecx
        cmp ecx, 0
        jz zero_end
        jmp loop4
    loop4_end:
        mov ans_len, ecx
        jmp done
    zero_end:
        mov ans_len, 1
        jmp done
    done:
        ret

get_ans ENDP

start:
    invoke printf, offset in_msg_num
    invoke scanf, offset in_format_num, offset num1_str

    invoke reverse_input, offset num1_str

    invoke changenum, offset num1_str, offset num1
    mov n1, eax

    invoke printf, offset in_msg_num
    invoke scanf, offset in_format_num, offset num2_str

    invoke reverse_input, offset num2_str
    
    invoke changenum, offset num2_str, offset num2
    mov n2, eax

    invoke get_maxn, n1, n2
    mov n1, eax

    invoke fft, n1, offset num1, 1
    invoke fft, n1, offset num2, 1
        
    invoke mat_mul, n1

    invoke fft, n1, offset num1, -1

    invoke get_ans, n1
    invoke output_ans

    invoke scanf, offset in_format_char, offset tttt
    invoke scanf, offset in_format_char, offset tttt

    ret
end start
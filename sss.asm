stack segment stack
    db 64 dup (?)
stack ends
data segment
    buff db 50,?,50 dup(?)
    nam0 db 'What is your name ?$'
    bkc0 db 'What is your background color ?$'
    bkc1 db '->(input RGB:0-7):$'
    fc0  db 'What is your font color ?$'
    fc1  db '->(input RGB:0-7):$'
    tw0  db 'Do you like twinkle ?$'
    tw1  db '->(like:1  dislike:0): $'
    hel0 db 'Hello!$'
    hel1 db 'Welcome to MASM!$'
    arro db '->$'
data ends
code segment
assume cs:code,ds:data,ss:stack
start: mov ax,data
       mov ds,ax             ;使ds指向data数据段
       
       mov ah,6              ;初始化屏幕
       mov al,0
       mov ch,0
       mov cl,0
       mov dh,24
.386
.model flat, stdcall
option casemap:none

GetModuleHandleA proto stdcall :dword
LoadCursorA proto stdcall :dword, :dword
RegisterClassExA proto stdcall :dword
CreateWindowExA proto stdcall :dword, :dword, :dword, :dword, :dword, :dword, :dword, :dword, :dword, :dword, :dword, :dword
LoadIconA proto stdcall :dword, :dword
ShowWindow proto stdcall :dword, :dword
UpdateWindow proto stdcall :dword
GetMessageA proto stdcall :dword, :dword, :dword, :dword
TranslateMessage  proto stdcall :dword
DispatchMessageA  proto stdcall :dword
DefWindowProcA proto stdcall :dword, :dword, :dword, :dword
PostQuitMessage proto stdcall :dword
ExitProcess proto      :dword


WinMain proto :dword, :dword, :dword, :dword
MessageBoxA proto stdcall :dword, :dword, :dword, :dword
GetCommandLineA proto stdcall
SetFocus proto stdcall :dword
SetWindowTextA proto stdcall :dword, :dword
GetWindowTextA proto stdcall :dword, :dword, :dword
DestroyWindow proto stdcall :dword
SendMessageA proto stdcall :dword, :dword, :dword, :dword
wsprintfA proto c :VARARG
StrToIntA proto stdcall :dword
SetTimer proto stdcall :dword, :dword, :dword, :dword
KillTimer proto stdcall :dword, :dword

HINSTANCE typedef dword
LPSTR     typedef dword
HWND      typedef dword
UINT      typedef dword
WPARAM    typedef dword
LPARAM    typedef dword

POINT struct
    x  dword ?
    y  dword ?
POINT ends


MSG struct
    hwnd      dword      ?
    message   dword      ?
    wParam    dword      ?
    lParam    dword      ?
    time      dword      ?
    pt        POINT      <>
MSG ends


WNDCLASSEXA struct
    cbSize            dword      ?
    style             dword      ?
    lpfnWndProc       dword      ?
    cbClsExtra        dword      ?
    cbWndExtra        dword      ?
    hInstance         dword      ?
    hIcon             dword      ?
    hCursor           dword      ?
    hbrBackground     dword      ?
    lpszMenuName      dword      ?
    lpszClassName     dword      ?
    hIconSm           dword      ?
WNDCLASSEXA ends


.data
    ClassName         db "SimpleWinClass", 0
    AppName           db "打字练习", 0
    StartBtnCN        db "button", 0
    StartBtnTxt       db "开始", 0
    EditClassName     db "edit", 0
    StaticCN          db "static", 0
    StaticText        db "等待输入...", 0
    StaticText2       db "请输入任意键开始练习", 0
    StaticText3       db "结束了，输入任意键继续练习", 0
    FormatTime        db "用时：%02d:%02d.%d", 0
    FormatSpeed       db "速度：%d KPM", 0
    FormatText        db "%s%c", 0
    FormatLength      db "(%d)", 0
    FormatAcc         db "正确率：%d%%", 0
    Acc               dd 0
    TextBuffer        db 10240 dup(0)
    TmpBuffer         db 1024 dup(0)
    StrLen            dd 0
    time              dd 0
    timing            db 0
    Text              db "Two households, both alike in dignity. In fair Verona, where we lay our scene. From ancient grudge break to new mutiny. Where civil blood makes civil hands unclean.", 0
    TextInd           db 0
    SingleText        dw 128 dup(0)
    TextPtr           dd 0
    TextLen           db 0

.data?
    hInstance HINSTANCE ?
    CommandLine LPSTR ?
    hwndSelf	dword ?       ; 窗口句柄
    hwndStartBtn HWND ?       ; 开始按钮句柄
    hwndStatic HWND ?         ; 显示框句柄
    hwndStatic2 HWND ?        ; 显示框 2 句柄
    hwndTimeStatic HWND ?     ; 时间显示框句柄
    hwndSpeedStatic HWND ?    ; 速度显示框句柄
    hwndAccStatic HWND ?      ; 正确率显示框句柄
  
.const 
WM_DESTROY	equ 2h 		
WM_KEYDOWN  equ 100h
WM_CHAR		equ 102h
WM_TIMER	equ 113h
VK_ESCAPE   equ 1Bh
VK_BACK     equ 08h

IDI_APPLICATION equ 32512
IDC_ARROW	equ 32512 	
SW_SHOWNORMAL	equ 1 		
CS_HREDRAW      equ 2h		
CS_VREDRAW      equ 1h  	
CS_GLOBALCLASS  equ 4000h	 
				
COLOR_BACKGROUND  	equ 3	
CW_USEDEFAULT           equ 80000000h  

WS_OVERLAPPED           equ 0h
WS_CAPTION              equ 0C00000h
WS_SYSMENU              equ 80000h
WS_THICKFRAME           equ 40000h
WS_MINIMIZEBOX          equ 20000h
WS_MAXIMIZEBOX          equ 10000h      

WS_OVERLAPPEDWINDOW     equ WS_OVERLAPPED OR WS_CAPTION OR WS_SYSMENU OR WS_THICKFRAME OR WS_MINIMIZEBOX OR WS_MAXIMIZEBOX

StartBtnID          equ 1
TimeStaticID        equ 2
SpeedStaticID       equ 3
AccStaticID         equ 4
TextStaticID        equ 5
LabelStaticID       equ 6
SW_SHOWDEFAULT      equ 10
WS_EX_CLIENTEDGE    equ 00020000h
WS_CHILD            equ 40000000h
WS_VISIBLE          equ 10000000h
WS_BORDER           equ 800000h
BS_DEFPUSHBUTTON    equ 1h
ES_LEFT             equ 0h
WM_CREATE           equ 1h
WM_COMMAND          equ 111h
ES_AUTOHSCROLL      equ 80h
BN_CLICKED          equ 0
COLOR_BTNFACE       equ 15
SS_LEFT			    equ 0h
SS_CENTER           equ 1h
MB_OK               equ 0

.code
start:
    invoke GetModuleHandleA, 0
    mov    hInstance, eax
    invoke GetCommandLineA
    mov CommandLine, eax
    invoke WinMain, hInstance, 0, CommandLine, SW_SHOWDEFAULT
    invoke ExitProcess, eax

    WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:dword
        LOCAL wc:WNDCLASSEXA
        LOCAL msg:MSG
        LOCAL hwnd:HWND

        mov   wc.cbSize, SIZEOF WNDCLASSEXA
        mov   wc.style, CS_HREDRAW or CS_VREDRAW
        mov   wc.lpfnWndProc, OFFSET WndProc
        mov   wc.cbClsExtra, 0
        mov   wc.cbWndExtra, 0
        push  hInst
        pop   wc.hInstance
        mov   wc.hbrBackground, COLOR_BTNFACE+1
        mov   wc.lpszMenuName, 0
        mov   wc.lpszClassName, OFFSET ClassName

        invoke LoadIconA, 0, IDI_APPLICATION
        mov   wc.hIcon, eax
        mov   wc.hIconSm, eax
        invoke LoadCursorA, 0, IDC_ARROW
        mov   wc.hCursor, eax
        invoke RegisterClassExA, addr wc
        invoke CreateWindowExA, WS_EX_CLIENTEDGE, ADDR ClassName,\
                            ADDR AppName, WS_OVERLAPPEDWINDOW,\
                            600, 300, 1024, 700, 0, 0, hInst, 0
        mov hwnd, eax
        mov hwndSelf, eax
        invoke ShowWindow, hwnd, SW_SHOWNORMAL
        invoke UpdateWindow, hwnd
        .WHILE 1
            invoke GetMessageA, ADDR msg, 0, 0, 0
            .BREAK .if (!eax)
            invoke TranslateMessage, ADDR msg
            invoke DispatchMessageA, ADDR msg
        .ENDW
        mov     eax, msg.wParam
        ret
    WinMain endp

    WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
        .if uMsg==WM_DESTROY                ; 窗口关闭
                invoke PostQuitMessage, 0
        .elseif uMsg==WM_CREATE             ; 窗口创建
            ; 创建时间显示框
            invoke CreateWindowExA, 0, ADDR StaticCN, 0,\
                            WS_CHILD or WS_VISIBLE or SS_LEFT,\
                            50, 50, 150, 20, hWnd, TimeStaticID, hInstance, 0
            mov  hwndTimeStatic, eax        ; 保存时间显示框句柄
            ; 创建实时打字速度显示框
            invoke CreateWindowExA, 0, ADDR StaticCN, addr StaticText,\
                            WS_CHILD or WS_VISIBLE or SS_LEFT,\
                            200, 50, 150, 20, hWnd, SpeedStaticID, hInstance, 0
            mov hwndSpeedStatic, eax        ; 保存实时打字速度显示框句柄
            ; 创建实时正确率显示框
            invoke CreateWindowExA, 0, ADDR StaticCN, addr StaticText,\
                            WS_CHILD or WS_VISIBLE or SS_LEFT,\
                            350, 50, 150, 20, hWnd, AccStaticID, hInstance, 0
            mov hwndAccStatic, eax          ; 保存实时正确率显示框句柄
            ; 创建文本显示框
            invoke CreateWindowExA, WS_EX_CLIENTEDGE, ADDR StaticCN, ADDR StaticText,\
                            WS_CHILD or WS_VISIBLE or SS_LEFT,\
                            50, 350, 900, 200, hWnd, TextStaticID, hInstance, 0
            mov  hwndStatic, eax            ; 保存文本显示框句柄
            ; 创建文本显示框 2
            invoke CreateWindowExA, WS_EX_CLIENTEDGE, ADDR StaticCN, ADDR StaticText2,\
                            WS_CHILD or WS_VISIBLE or SS_LEFT,\
                            50, 100, 900, 200, hWnd, LabelStaticID, hInstance, 0
            mov  hwndStatic2, eax           ; 保存文本显示框句柄
            call PrintTime                  ; 打印时间
        .elseif uMsg == WM_COMMAND          ; 按钮消息
            mov eax, wParam                 ; 获取消息参数
            .if lParam!=0                   ; 如果是子窗口消息
                .if ax==StartBtnID          ; 如果是清除按钮
                    shr eax, 16             ; 取高16位
                    .if ax==BN_CLICKED      ; 如果是按下按钮
                        call ClearText
                        call PrintTime
                        call NextText
                    .endif
                .endif
            .endif
        .elseif uMsg==WM_CHAR               ; 如果是键盘输入消息
            mov eax, wParam                 ; 获取键盘输入
            .if eax == VK_BACK              ; 如果是退格键，则删除一个字符
                .if StrLen > 0h	            ; 如果不是第一个字符
                    dec StrLen              ; 减少字符长度
                    mov edi, StrLen         ; 设置指针
                    mov TextBuffer[edi], 0  ; 清空字符
                    invoke SetWindowTextA, hwndStatic, addr TextBuffer
                .endif
                call CalcAcc
            .elseif eax == VK_ESCAPE        ; 如果是 Esc 键，则停止计时
                call ClearText
                invoke SetWindowTextA, hwndStatic, addr StaticText3
                invoke SetWindowTextA, hwndStatic2, addr StaticText3
            .ELSE                           ; 如果是其他键，则添加一个字符
                .if timing == 0h            ; 如果没有计时
                    mov timing, 1h          ; 设置计时
                    ; 创建计时器，每 0.1 秒刷新一次
                    invoke SetTimer, hWnd, 1h, 100, 0h
                    call PrintTime          ; 打印时间
                    call NextText
                .ELSE
                    invoke wsprintfA, addr TextBuffer, addr FormatText, addr TextBuffer, eax
                .endif
                invoke SetWindowTextA, hwndStatic, addr TextBuffer
                inc StrLen                  ; 增加字符长度
                call CalcAcc
            .endif
        .elseif uMsg==WM_TIMER              ; 如果是计时器消息
            mov eax, wParam                 ; 获取计时器参数
            .if eax==1h                     ; 如果是计时器1
                inc time                    ; 增加时间
                call PrintTime              ; 显示时间
            .endif
        .ELSE
            invoke DefWindowProcA, hWnd, uMsg, wParam, lParam
            ret
        .endif
        xor    eax, eax
        ret
    WndProc endp

    ClearText proc                          ; 初始化计时器与输入框
        mov time, 0h                        ; 初始化计时器时间
        mov timing, 0h                      ; 初始化是否计时变量
        invoke KillTimer, hwndSelf, 1h      ; 停止计时器
        mov TextBuffer, 0h                  ; 清空文字框缓冲区
        mov StrLen, 0h                      ; 清空文字框长度
        invoke SetFocus, hwndSelf           ; 设置焦点
        invoke SetWindowTextA, hwndStatic, addr StaticText
        invoke SetWindowTextA, hwndStatic2, addr StaticText2
        ret
    ClearText endp

    NextText proc
        .if TextPtr == 0                   ; 若为程序首次启动，设置指针位置为 Text 的偏移地址
            lea eax, Text                  ; 通过 eax 转赋 Text 的偏移地址
            mov TextPtr, eax               
        .endif
        mov esi, TextPtr                   ; 将 esi 赋值为本次练习句子的开头位置的偏移地址
        lea edi, SingleText                ; 获取SingleText 的偏移地址，用于复制字符串
        .while 1                           ; 通过循环，逐字将 Text 内的文本复制给 SingleText
            mov al, [esi]                  ; 通过ax转赋字符
            mov [edi], al                   
            inc esi
            inc edi
            mov al, '.'                    ; 若遇到英文句号，则认为到达句子末尾
            .if [esi] == al
                mov [edi], al              ; 将句号补在 SingleText末尾
                mov al, 0                  ; 给 SingleText 添加字符串结束标志
                inc edi
                mov [edi], al
                lea edx, SingleText        ; 通过 SingleText 的偏移地址和当前 edi 的偏移地址计算字符串长度
                sub edi, edx
                mov dword ptr TextLen, edi
                .if TextInd == 3           ; 若到了全文末尾则置0，从头开始循环
                    mov al, 0
                    mov TextInd, al
                    lea eax, Text
                    mov TextPtr, eax
                .ELSE
                    add esi, 2             ; 若没有到文章结尾，则需要让指针跳过句号和空格
                    inc TextInd
                    mov TextPtr, esi
                .endif
                .break
            .endif
        .endw
        invoke SetWindowTextA, hwndStatic2, addr SingleText
        ret
    NextText endp

    CalcAcc proc
        invoke GetWindowTextA, hwndStatic, addr TmpBuffer, 512
        lea esi, TmpBuffer
        lea edi, SingleText
        mov eax, 0
        .WHILE 1
            mov dl, [esi]
            mov dh, [edi]
            .if dl == dh
                inc eax
            .endif
            inc esi
            inc edi
            mov dl, [esi]
            mov dh, [edi]
            .break .if dl == 0
            .break .if dh == 0
        .ENDW
        mov ecx, 100
        mul ecx
        mov ecx, dword ptr TextLen
        div ecx
        .if eax == 100
            call ClearText
            invoke SetWindowTextA, hwndStatic, addr StaticText3
            invoke SetWindowTextA, hwndStatic2, addr StaticText3
            mov eax, 100
        .endif
        invoke wsprintfA, addr TmpBuffer, addr FormatAcc, eax
        invoke SetWindowTextA, hwndAccStatic, addr TmpBuffer
        ret
    CalcAcc endp

    PrintTime proc
        ; 更新用时 [time / 10 / 60]:[time / 10 % 60].[time % 10]
        mov edx, 0
        mov eax, time
        mov ecx, 10
        div ecx                             ; edx:eax / ecx = eax ... edx
        push edx
        mov edx, 0
        mov ecx, 60
        div ecx
        pop ecx
        invoke wsprintfA, addr TmpBuffer, addr FormatTime, eax, edx, ecx
        invoke SetWindowTextA, hwndTimeStatic, addr TmpBuffer
        ; 更新速度 [StrLen / (time / 10) * 60] KPM
        mov eax, StrLen
        mov ecx, 600
        mul ecx
        .if time != 0
            ; 防止除数为 0
            mov ecx, time
            div ecx
        .endif
        invoke wsprintfA, addr TmpBuffer, addr FormatSpeed, eax
        invoke SetWindowTextA, hwndSpeedStatic, addr TmpBuffer
        ret
    PrintTime endp
end start
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
    AppName           db "????????", 0
    StartBtnCN        db "button", 0
    StartBtnTxt       db "????", 0
    EditClassName     db "edit", 0
    StaticCN          db "static", 0
    StaticText        db "????????...", 0
    StaticText2       db "????????????????????", 0
    StaticText3       db "??????????????????????????", 0
    FormatTime        db "??????%02d:%02d.%d", 0
    FormatSpeed       db "??????%d KPM", 0
    FormatText        db "%s%c", 0
    FormatLength      db "(%d)", 0
    FormatAcc         db "????????%d%%", 0
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
    hwndSelf	dword ?       ; ????????
    hwndStartBtn HWND ?       ; ????????????
    hwndStatic HWND ?         ; ??????????
    hwndStatic2 HWND ?        ; ?????? 2 ????
    hwndTimeStatic HWND ?     ; ??????????????
    hwndSpeedStatic HWND ?    ; ??????????????
    hwndAccStatic HWND ?      ; ????????????????
  
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
        .if uMsg==WM_DESTROY                ; ????????
                invoke PostQuitMessage, 0
        .elseif uMsg==WM_CREATE             ; ????????
            ; ??????????????
            invoke CreateWindowExA, 0, ADDR StaticCN, 0,\
                            WS_CHILD or WS_VISIBLE or SS_LEFT,\
                            50, 50, 150, 20, hWnd, TimeStaticID, hInstance, 0
            mov  hwndTimeStatic, eax        ; ??????????????????
            ; ??????????????????????
            invoke CreateWindowExA, 0, ADDR StaticCN, addr StaticText,\
                            WS_CHILD or WS_VISIBLE or SS_LEFT,\
                            200, 50, 150, 20, hWnd, SpeedStaticID, hInstance, 0
            mov hwndSpeedStatic, eax        ; ??????????????????????????
            ; ????????????????????
            invoke CreateWindowExA, 0, ADDR StaticCN, addr StaticText,\
                            WS_CHILD or WS_VISIBLE or SS_LEFT,\
                            350, 50, 150, 20, hWnd, AccStaticID, hInstance, 0
            mov hwndAccStatic, eax          ; ????????????????????????
            ; ??????????????
            invoke CreateWindowExA, WS_EX_CLIENTEDGE, ADDR StaticCN, ADDR StaticText,\
                            WS_CHILD or WS_VISIBLE or SS_LEFT,\
                            50, 350, 900, 200, hWnd, TextStaticID, hInstance, 0
            mov  hwndStatic, eax            ; ??????????????????
            ; ?????????????? 2
            invoke CreateWindowExA, WS_EX_CLIENTEDGE, ADDR StaticCN, ADDR StaticText2,\
                            WS_CHILD or WS_VISIBLE or SS_LEFT,\
                            50, 100, 900, 200, hWnd, LabelStaticID, hInstance, 0
            mov  hwndStatic2, eax           ; ??????????????????
            call PrintTime                  ; ????????
        .elseif uMsg == WM_COMMAND          ; ????????
            mov eax, wParam                 ; ????????????
            .if lParam!=0                   ; ????????????????
                .if ax==StartBtnID          ; ??????????????
                    shr eax, 16             ; ????16??
                    .if ax==BN_CLICKED      ; ??????????????
                        call ClearText
                        call PrintTime
                        call NextText
                    .endif
                .endif
            .endif
        .elseif uMsg==WM_CHAR               ; ??????????????????
            mov eax, wParam                 ; ????????????
            .if eax == VK_BACK              ; ????????????????????????????
                .if StrLen > 0h	            ; ??????????????????
                    dec StrLen              ; ????????????
                    mov edi, StrLen         ; ????????
                    mov TextBuffer[edi], 0  ; ????????
                    invoke SetWindowTextA, hwndStatic, addr TextBuffer
                .endif
                call CalcAcc
            .elseif eax == VK_ESCAPE        ; ?????? Esc ??????????????
                call ClearText
                invoke SetWindowTextA, hwndStatic, addr StaticText3
                invoke SetWindowTextA, hwndStatic2, addr StaticText3
            .ELSE                           ; ????????????????????????????
                .if timing == 0h            ; ????????????
                    mov timing, 1h          ; ????????
                    ; ?????????????? 0.1 ??????????
                    invoke SetTimer, hWnd, 1h, 100, 0h
                    call PrintTime          ; ????????
                    call NextText
                .ELSE
                    invoke wsprintfA, addr TextBuffer, addr FormatText, addr TextBuffer, eax
                .endif
                invoke SetWindowTextA, hwndStatic, addr TextBuffer
                inc StrLen                  ; ????????????
                call CalcAcc
            .endif
        .elseif uMsg==WM_TIMER              ; ????????????????
            mov eax, wParam                 ; ??????????????
            .if eax==1h                     ; ????????????1
                inc time                    ; ????????
                call PrintTime              ; ????????
            .endif
        .ELSE
            invoke DefWindowProcA, hWnd, uMsg, wParam, lParam
            ret
        .endif
        xor    eax, eax
        ret
    WndProc endp

    ClearText proc                          ; ????????????????????
        mov time, 0h                        ; ????????????????
        mov timing, 0h                      ; ??????????????????
        invoke KillTimer, hwndSelf, 1h      ; ??????????
        mov TextBuffer, 0h                  ; ????????????????
        mov StrLen, 0h                      ; ??????????????
        invoke SetFocus, hwndSelf           ; ????????
        invoke SetWindowTextA, hwndStatic, addr StaticText
        invoke SetWindowTextA, hwndStatic2, addr StaticText2
        ret
    ClearText endp

    NextText proc
        .if TextPtr == 0                   ; ???????????????????????????????? Text ??????????
            lea eax, Text                  ; ???? eax ???? Text ??????????
            mov TextPtr, eax               
        .endif
        mov esi, TextPtr                   ; ?? esi ??????????????????????????????????????
        lea edi, SingleText                ; ????SingleText ??????????????????????????
        .while 1                           ; ???????????????? Text ?????????????? SingleText
            mov al, [esi]                  ; ????ax????????
            mov [edi], al                   
            inc esi
            inc edi
            mov al, '.'                    ; ??????????????????????????????????
            .if [esi] == al
                mov [edi], al              ; ?????????? SingleText????
                mov al, 0                  ; ?? SingleText ??????????????????
                inc edi
                mov [edi], al
                lea edx, SingleText        ; ???? SingleText ???????????????? edi ????????????????????????
                sub edi, edx
                mov dword ptr TextLen, edi
                .if TextInd == 3           ; ??????????????????0??????????????
                    mov al, 0
                    mov TextInd, al
                    lea eax, Text
                    mov TextPtr, eax
                .ELSE
                    add esi, 2             ; ????????????????????????????????????????????
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
        ; ???????? [time / 10 / 60]:[time / 10 % 60].[time % 10]
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
        ; ???????? [StrLen / (time / 10) * 60] KPM
        mov eax, StrLen
        mov ecx, 600
        mul ecx
        .if time != 0
            ; ?????????? 0
            mov ecx, time
            div ecx
        .endif
        invoke wsprintfA, addr TmpBuffer, addr FormatSpeed, eax
        invoke SetWindowTextA, hwndSpeedStatic, addr TmpBuffer
        ret
    PrintTime endp
end start
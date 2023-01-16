;ml /Zi /c /coff  %1.asm
;link /subsystem:console %1.obj
.586p
.model flat,stdcall
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\masm32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib C:\Users\Zhang\source\repos\bg7jws\Cpp-study\libkmp\kmp.lib

kmp proto:dword,:dword,:dword
extern	szFmt:byte
extern	buffer:byte
extern	foundmark:dword
extern	dwBytesPtn:dword
extern	array:dword
.data
szMsg0	byte 0dh,0ah,'Please input the Text string, it should be longer than 2 characters.',0dh,0ah,0
messageSize0	db ($-szMsg0)
szMsg1	byte 'Invalid text, too short!',0dh,0ah,0
messageSize1	db ($-szMsg1)
szMsg2	byte 'Search pattern: ',0dh,0ah,0
messageSize2	db ($-szMsg2)
szMsg3	byte 'Prefix table:',0dh,0ah,0
messageSize3	db ($-szMsg3)
szMsg4	byte 0dh,0ah,'The search pattern could not find in the text.',0dh,0ah,0
messageSize4	db ($-szMsg4)
szMsg5	byte 0dh,0ah,'First position(index starting from 0):',0
messageSize5	db ($-szMsg5)
ConsoleHandle	dword ?
dwBytesWrite	dword ?
dwBytesText		dword ?
hStdOut			dword ?
hStdIn			dword ?
szText			byte 256 dup(0)
szSearchString	byte 12 dup(0)

.code
start:
	invoke	GetStdHandle, STD_OUTPUT_HANDLE		;��ȡ��׼���������handle					
		mov hStdOut,eax
	invoke	GetStdHandle, STD_INPUT_HANDLE
		mov hStdIn,eax

	invoke StdOut, addr szMsg0	
	invoke	ReadConsole, hStdIn, addr szText, sizeof szText, addr dwBytesText, NULL	
		sub dwBytesText,2						;����̨����text,�����ֽ���������β��0
		mov ebx,dwBytesText
		mov byte ptr szText[ebx],0
	.if dwBytesText < 2							;�ж��ַ������Ƿ����2��������ʾ������Ϣ
		invoke	WriteConsole, hStdOut, addr szMsg1, messageSize1, addr dwBytesWrite, NULL
		jmp leave_prog
	.endif

	invoke	StdOut, addr szMsg2					
	invoke	ReadConsole, hStdIn, addr szSearchString, sizeof szSearchString, addr dwBytesPtn, NULL
		sub dwBytesPtn,2						;����̨��ȡpattern��
		mov ebx,dwBytesPtn
		mov byte ptr szSearchString[ebx],0
;����̨��ʾ����ƥ���̧ͷ����һ����ʾ����ƥ��������λ��к���ʾ���ҽ��
	invoke StdOut, addr szMsg3
	push offset array
	push offset szSearchString
	push offset szText
	call kmp
	push eax			;invoke	kmp, addr szText, addr szSearchString,addr array
	;---------------------------------------------
	mov esi,0			;��ʾ����ƥ���
	.repeat	
		mov ebx,dword ptr [array+4*esi]
		push ebx
		push offset szFmt
		push offset buffer
		call wsprintf
		add esp,0ch
		invoke	StdOut, addr buffer
		inc esi
	.until (esi==dwBytesPtn)
	;---------------------------------------------
	.if foundmark == 0
		invoke StdOut, addr szMsg4
		jmp leave_prog
	.endif
	pop eax
	invoke	wsprintf, addr buffer, addr szFmt, eax	 
	invoke	StdOut, addr szMsg5
	invoke	StdOut, addr buffer				;��ʾ���ҽ��
;��������˳�
JMP start	;try more for debug
leave_prog:
	invoke ExitProcess, 0
;------------------------------------------------------------------------------------------
end	start
.386
.model flat,stdcall
.stack 200h
option casemap:none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\masm32.lib
.data
Message1	db "Hello World!",0
MessageCap	db "Caption",0
.code
start:
invoke MessageBox,0,addr Message1,addr MessageCap,MB_OK
invoke ExitProcess,0
end start


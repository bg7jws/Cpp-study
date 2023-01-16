;\masm32\bin\ml /c kmplib1.asm
;\masm32\bin\link /lib kmplib1.obj /out:kmp.lib
.386
.model flat,stdcall
option casemap :none
include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\masm32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\masm32.lib
public	szFmt				;display format string
public	buffer				;save used with wsprintf
public	foundmark			;1 for found,0 for not found
public	dwBytesPtn			;counter for bytes in pattern(search string)
public	array				;array for pattern
kmp		proto :dword,:dword,:dword

.data
szFmt		byte '%d',0
buffer		byte 2 dup(0)	;buffer for wsprintf, 3 bytes enough
array		dw   20 dup(0)
foundmark	dd ?
dwBytesPtn	dd ?

.code
;------------------------------------------------------------------------------------------
kmp	proc Text:dword, SearchString:dword, arrayaddr:dword
	mov ecx, [ebp+12]		;ecx =  address of search string
	mov edx, [ebp+8]		;edx = address of text
	xor esi, esi			;si=0
	mov edi, 1				;di = 1	
	mov dword ptr [array],0	;initial array first as 0
prefix:
	mov ah, [ecx+esi]		;ah = search_string[esi]	ah=first char
	mov al, [ecx+edi]		;al = search_string[edi]	al=second char
	cmp al, 0				;if al == 0					string end?
	je search				; continue with search		yes begin search
	cmp al, ah				; if al == ah				al=ah?
	je equal				;yes jmp to equal
	jmp nequal				;no jmp to neequal
equal:						;array[edi] = ++esi
	inc esi
	mov dword ptr [array+4*edi], esi					;esi save in array[edi], array������edi�±�
	inc edi												;edi move 1 char
	jmp prefix											;continue find prefix
nequal:													;esi=0; array[edi] = esi
	xor esi, esi										;һ����������ͬ�ģ�esi����
	mov ah, [ecx+esi]
	cmp ah, al											;��ǰ�ַ��ٴκ͵�һ���ַ��Ƚ�
	jne next											;��ͬ��jmp next
	inc esi												;��ͬ��esi move 1 char
next:
	mov dword ptr [array+4*edi], esi					;����equal�е�ͬ������
	inc edi												;edi move 1 char
	jmp prefix											;continue find prefix
;ֱ������00��ǰ׺������������ʱ��ǰ׺���б����������ͬ��esi����Ҫ�ٻ��ݵ�ƫ����
;����AAABC array �����ˣ�0��1��2��0��0��˫�ֵĸ�ʽ
search:
	xor esi, esi										;initial source char begin from 0
	xor edi, edi										;initial text target char begin from 0
search_loop:
	mov ah, [ecx+esi]								;search string the esi char save in ah
	mov al, [edx+edi]								;text sting the edi char save in al
	cmp ah, 0										;search string end?
	je found										;found success
	cmp al, 0										;text string end?
	je notfound										;not found
	cmp ah, al										;compare
	je pair											;pair to continue next esi and next edi
	jmp unpair										;unpair move esi and edi base on kmp algorithm
pair:												;pair to continue next esi and next edi
	inc edi
	inc esi
	jmp search_loop
unpair:												;edi++;esi = array[esi]s	
	cmp esi, 0										;search string �е�һ���Ͳ�ƥ��ʱ��edi+1, esi���Ǵ�0��ʼ��esi����0����
	je next_u
	dec esi											;search string�ڶ���֮��Ų�ƥ��ʱ,���ݲ���ƥ�����search string �� esiƫ��ֵ
	push dword ptr [array+4*esi]							
	pop esi											
	jmp search_loop									;continue search
next_u:												;search string �е�һ���Ͳ�ƥ��ʱ��edi+1, esi���Ǵ�0��ʼ��esi����0����
	inc edi
	jmp search_loop
found:
	mov foundmark,1									;pair success, edi-esi=begin of text pair address
	sub edi, esi
	jmp goend										;ready for return
notfound:
	mov edi, 0										;set notfound mark
goend:
	;mov esi,0
	;.repeat	
	;	mov ebx,dword ptr [array+4*esi]
	;	invoke	wsprintf, addr buffer, addr szFmt, ebx
	;	invoke	StdOut, addr buffer
	;	inc esi
	;.until (esi==dwBytesPtn)
	mov eax, edi	;return value in eax<-edi		;edi�б������ƥ��ɹ����text���ַ�ƫ�Ƶ�ַ,save in eax ready for kmp return
	ret
kmp endp
end
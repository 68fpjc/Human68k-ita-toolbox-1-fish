* isatty.s
* Itagaki Fumihiko 02-Jan-90  Create.

.include doscall.h

.text

****************************************************************
* isatty - is a tty
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   �u���b�N�E�f�o�C�X�Ȃ�� 0
*             �L�����N�^�E�f�o�C�X�Ȃ�� 0x80
*
*      CCR    TST.L D0
*****************************************************************
.xdef isatty

isatty:
		move.w	d0,-(a7)
		clr.w	-(a7)
		DOS	_IOCTRL
		addq.l	#4,a7
		and.l	#$80,d0
		rts

.end

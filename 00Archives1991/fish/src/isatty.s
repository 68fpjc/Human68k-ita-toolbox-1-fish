* isatty.s
* Itagaki Fumihiko 02-Jan-90  Create.

.include doscall.h

.text

****************************************************************
* isatty - is character device
*
* CALL
*      D0.W   file handle
*
* RETURN
*      D0.L   ���ʃo�C�g�� 0 �Ȃ�΃u���b�N�f�o�C�X
*             0x80 �Ȃ�΃L�����N�^�f�o�C�X
*             ��ʂ͔j��
*
*      CCR    TST.B D0
*****************************************************************
.xdef isatty

isatty:
		move.w	d0,-(a7)
		clr.w	-(a7)
		DOS	_IOCTRL
		addq.l	#4,a7
		and.b	#$80,d0
		rts

.end

* strechr.s
* Itagaki Fumihiko 23-Sep-90  Create.

.xref _strchr

.text

****************************************************************
* strechr - �����񂩂炠�镶����T���o��
*           �������A�����񒆂� \ �ɑ��������͖�������
*
* CALL
*      A0     ��������w���|�C���^
*
*      D0.W   ��������
*             �V�t�gJIS�R�[�h�܂��� ANK�R�[�h
*             ANK�R�[�h�͏�ʃo�C�g�� 0 �Ƃ���
*
* RETURN
*      A0     �ŏ��Ɍ��������������ʒu���w���D
*             ����������������Ȃ������ꍇ�ɂ́C�Ō��NUL�������w��
*
*      CCR    TST.B (A0)
*****************************************************************
.xdef strechr

strechr:
		movem.l	d1,-(a7)
		moveq	#1,d1
		bsr	_strchr
		movem.l	(a7)+,d1
		rts

.end

* _strchr.s
* Itagaki Fumihiko 23-Sep-90  Create.

.xref scanchar2

.text

****************************************************************
* _strchr - �����񂩂炠�镶����T���o��
*
* CALL
*      A0     ��������w���|�C���^
*
*      D0.W   ��������
*             �V�t�gJIS�R�[�h�܂��� ANK�R�[�h
*             ANK�R�[�h�͏�ʃo�C�g�� 0 �Ƃ���
*
*      D1.B   1 �Ȃ�� �����񒆂� \ �̎��̕����͖�������
*
* RETURN
*      A0     �ŏ��Ɍ��������������ʒu���w��
*             ����������������Ȃ������ꍇ�ɂ́C�Ō��NUL�������w��
*
*      CCR    TST.B (A0)
*****************************************************************
.xdef _strchr

_strchr:
		movem.l	d2/a1,-(a7)
		move.w	d0,d2
_strchr_loop:
		movea.l	a0,a1
		bsr	scanchar2
		beq	_strchr_eos

		cmp.w	d2,d0
		beq	_strchr_found

		tst.b	d1
		beq	_strchr_loop

		cmp.w	#'\',d0
		bne	_strchr_loop

		bsr	scanchar2
		bne	_strchr_loop
_strchr_eos:
		lea	-1(a0),a1
_strchr_found:
		movea.l	a1,a0
		move.w	d2,d0
		tst.b	(a0)
		movem.l	(a7)+,d2/a1
		rts

.end

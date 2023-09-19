* jstrchr.s
* Itagaki Fumihiko 23-Sep-90  Create.

.xref scanchar2

.text

****************************************************************
* jstrchr - �V�t�gJIS�R�[�h���܂ޕ����񂩂當����T���o��
*
* CALL
*      A0     ������̐擪�A�h���X
*
*      D0.W   ��������
*             �V�t�gJIS�R�[�h�܂��� ANK�R�[�h�i��ʃo�C�g�� 0�j
*
* RETURN
*      A0     �ŏ��Ɍ��������������ʒu���w��
*             ����������������Ȃ������ꍇ�ɂ́C�Ō��NUL�������w��
*
*      CCR    TST.B (A0)
*****************************************************************
.xdef jstrchr

jstrchr:
		movem.l	d0-d1/a1,-(a7)
		move.w	d0,d1
jstrchr_loop:
		movea.l	a0,a1
		bsr	scanchar2
		beq	jstrchr_eos

		cmp.w	d1,d0
		bne	jstrchr_loop

		bra	jstrchr_found

jstrchr_eos:
		lea	-1(a0),a1
jstrchr_found:
		movea.l	a1,a0
		movem.l	(a7)+,d0-d1/a1
		tst.b	(a0)
		rts

.end

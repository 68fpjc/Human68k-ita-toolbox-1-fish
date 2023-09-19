* findsvar.s
* Itagaki Fumihiko 24-Sep-90  Create.

.xref atou
.xref for1str
.xref find_shellvar

.text

****************************************************************
sub1:
		moveq	#0,d1
		moveq	#0,d2
		bsr	find_shellvar
		beq	sub1_done			*  �ϐ������� ; return 0

		moveq	#1,d2
		addq.l	#2,a0
		tst.w	(a0)+
		beq	sub1_done			*  �P�ꂪ���� ; return 1

		moveq	#2,d2
		bsr	for1str
		tst.b	(a0)
sub1_done:
		rts
****************************************************************
sub2:
		moveq	#3,d2
		bsr	atou
		bmi	sub2_done			*  �����Ŏn�܂��Ă��Ȃ� ; return 3

		moveq	#4,d2
		tst.b	(a0)
		bne	sub2_done			*  �����̌�ɕ��������� ; return 4

		moveq	#5,d2
		cmp.w	d2,d2
sub2_done:
		rts
****************************************************************
* svartou - �V�F���ϐ���T���A�ŏ��̗v�f�𐔒l�ɕϊ�����
*           ������
*
* CALL
*      A0     �ϐ������w��
*
* RETURN
*      D0.L    0 : �ϐ�������...D1:=0
*              1 : �v�f������...D1:=0
*              2 : �v�f���󕶎���...D1:=0
*              3 : �P�ꂪ�����Ŏn�܂��Ă��Ȃ�...D1:=0
*              4 : �����ȊO�̕���������
*              5 : ����
*             -1 : �I�[�o�[�t���[����
*
*      D1.L   �l
*
*      CCR    TST.L D0
****************************************************************
.xdef svartou

svartou:
		movem.l	d2/a0,-(a7)
		bsr	sub1
		beq	svartou_return

		bsr	sub2
		bne	svartou_return

		tst.l	d0
		beq	sub2_done

		moveq	#-1,d2				*  �I�[�o�[�t���[ ; return -1
svartou_return:
		move.l	d2,d0
		movem.l	(a7)+,d2/a0
		rts
****************************************************************
* svartol - �V�F���ϐ���T���A�ŏ��̗v�f�𐔒l�ɕϊ�����
*           �����t��
*
* CALL
*      A0     �ϐ������w��
*
* RETURN
*      D0.L    0 : �ϐ�������...D1:=0
*              1 : �v�f������...D1:=0
*              2 : �v�f���󕶎���...D1:=0
*              3 : �P�ꂪ�����܂��͕����Ŏn�܂��Ă��Ȃ�...D1:=0
*              4 : �����ȊO�̕���������
*              5 : ����
*             -1 : �I�[�o�[�t���[����
*
*      D1.L   �l
*             �I�[�o�[�t���[�̏ꍇ�ɂ������r�b�g��������\�킷
*
*      CCR    TST.L D0
****************************************************************
.xdef svartol

svartol:
		movem.l	d2-d3/a0,-(a7)
		bsr	sub1
		beq	svartol_return

		moveq	#-1,d3
		cmpi.b	#'-',(a0)
		beq	svartol_skip_sign

		moveq	#1,d3
		cmpi.b	#'+',(a0)
		bne	svartol_atou
svartol_skip_sign:
		addq.l	#1,a0
svartol_atou:
		bsr	sub2
		bne	svartol_return

		tst.l	d0
		bne	svartol_overflow		*  �I�[�o�[�t���[

		tst.l	d1
		bpl	svartol_1
svartol_overflow:
		bclr	#31,d1
		moveq	#-1,d2
svartol_1:
		tst.l	d3
		bpl	svartol_return

		neg.l	d1
svartol_return:
		move.l	d2,d0
		movem.l	(a7)+,d2-d3/a0
		rts
****************************************************************
.end

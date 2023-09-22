* findsvar.s
* Itagaki Fumihiko 24-Sep-90  Create.

.text

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
*              2 : �P�ꂪ�����Ŏn�܂��Ă��Ȃ�...D1:=0
*              3 : �����ȊO�̕���������
*              4 : ����
*             -1 : �I�[�o�[�t���[����
*
*      D1.L   �l
*
*      CCR    TST.L D0
****************************************************************
.xdef svartou

svartou:
		movem.l	d2/a0,-(a7)
		moveq	#0,d1
		moveq	#0,d2
		bsr	find_shellvar
		beq	svartou_return		* �ϐ������� ; return 0

		moveq	#1,d2
		addq.l	#2,a0
		tst.w	(a0)+
		beq	svartou_return		* �P�ꂪ���� ; return 1

		bsr	for1str
		moveq	#2,d2
		bsr	atou
		bmi	svartou_return		* �����Ŏn�܂��Ă��Ȃ� ; return 2

		moveq	#3,d2
		tst.b	(a0)
		bne	svartou_return		* �����̌�ɕ��������� ; return 3

		moveq	#-1,d2
		tst.l	d0
		bne	svartou_return		* �I�[�o�[�t���[���� ; return -1

		moveq	#4,d2
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
*              2 : �P�ꂪ�����Ŏn�܂��Ă��Ȃ�...D1:=0
*              3 : �����ȊO�̕���������
*              4 : ����
*             -1 : �I�[�o�[�t���[����
*
*      D1.L   �l
*
*      CCR    TST.L D0
****************************************************************
.xdef svartol

svartol:
		move.l	d2,-(a7)
		moveq	#-1,d2
		cmpi.b	#'-',(a0)
		beq	svartol_forward

		moveq	#0,d2
		cmpi.b	#'+',(a0)
		bne	svartol_svartou
svartol_forward:
		addq.l	#1,a0
svartol_svartou:
		bsr	svartou
		cmp.l	#3,d0
		blt	svartol_done

		tst.b	d2
		bpl	svartol_done

		neg.l	d1
		bmi	svartol_done

		moveq	#-1,d0
svartol_done:
		move.l	(a7)+,d2
		tst.l	d0
		rts

.end

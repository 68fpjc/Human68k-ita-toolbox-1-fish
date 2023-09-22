* printu.s
* Itagaki Fumihiko 22-Dec-90  Create.

itoawork = -12

.text

****************************************************************
* printu - �����������O�E���[�h�l�������t���o�͂���
*
* CALL
*      D0.L   �l
*      D2.W   ���Ȃ��Ƃ��\�����錅���D
*      D3.B   0�ȊO�Ȃ��' '��'0'�Ŗ��߂�
*      A1     ������̏o�͂��s�Ȃ��T�u�E���[�`���̃G���g���[�E�A�h���X
*             �i���̃T�u�E���[�`���ɑ΂�������̃A�h���X��A0�ɗ^���ČĂяo���j
*
* RETURN
*      D0.L   �o�͂���������
*****************************************************************
.xdef printu

printu:
		link	a6,#itoawork
		movem.l	d1/a0,-(a7)
		lea	itoawork(a6),a0
		bsr	utoa
		moveq	#10,d1
		sub.w	d2,d1
		bcs	printu_head_ok
printu_find_head:
		move.b	(a0),d0
		bsr	isspace
		bne	printu_head_ok

		addq.l	#1,a0
		dbra	d1,printu_find_head
printu_head_ok:
		tst.b	d3
		beq	printu_fill_ok

		bsr	zerofill
printu_fill_ok:
		jsr	(a1)
		bsr	strlen
		movem.l	(a7)+,d1/a0
		unlk	a6
		rts

.end

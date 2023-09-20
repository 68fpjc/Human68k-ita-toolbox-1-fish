* var.s
* Itagaki Fumihiko 26-Oct-91  Create.

.include ../src/var.h

.xref atou
.xref strlen
.xref strcmp
.xref strmove
.xref strfor1
.xref memmovi
.xref wordlistlen
.xref start_output
.xref end_output
.xref putc
.xref cputs
.xref put_tab
.xref put_newline
.xref echo
.xref free
.xref xfree
.xref xmalloc

.xref shellvar_top


.text

****************************************************************
* varsize - �ϐ��̃T�C�Y�����߂�i�w�b�_�̕��͊܂܂Ȃ��j
*
* CALL
*      A0     �ϐ��̃w�b�_�̃A�h���X
*
* RETURN
*      D0.L   �T�C�Y
****************************************************************
.xdef varsize

varsize:
		move.l	a0,-(a7)
		move.w	var_nwords(a0),d0
		addq.w	#1,d0
		lea	var_body(a0),a0
		bsr	wordlistlen
		movea.l	(a7)+,a0
		rts
****************************************************************
* freevar - �ϐ����X�g�����ׂĉ������
*
* CALL
*      A0     �ϐ����X�g�̍�
*
* RETURN
*      none
****************************************************************
.xdef freevar

freevar:
		movem.l	d0/a0,-(a7)
freevar_loop:
		move.l	a0,d0
		beq	freevar_done

		movea.l	var_next(a0),a0
		bsr	free
		bra	freevar_loop

freevar_done:
		movem.l	(a7)+,d0/a0
		rts
****************************************************************
* dupvar - �ϐ��𕡐�����
*
* CALL
*      A4     source BSS top
*      A5     destination BSS top
*      D0.W   ���̃|�C���^��BSS�I�t�Z�b�g
*
* RETURN
*      D0.L   �����Ȃ� (A5,D0.W)�D�r���Ń��������s�������Ȃ�� -1
*      CCR    TST.L D0
****************************************************************
.xdef dupvar

dupvar:
		movem.l	d1-d3/a0-a3,-(a7)
		move.w	d0,d3
		movea.l	(a4,d3.w),a2			*  A2 : source
		moveq	#0,d2				*  D2 : �����������X�g�̍�
dupvar_loop:
		cmpa.l	#0,a2
		beq	dupvar_done

		movea.l	a2,a0
		bsr	varsize
		move.l	d0,d1				*  D1.L : varsize
		add.l	#VAR_HEADER_SIZE,d0
		jsr	xmalloc
		beq	dupvar_fail

		movea.l	d0,a0
		tst.l	d2
		beq	dupvar_first

		move.l	a0,var_next(a3)
		bra	dupvar_1

dupvar_first:
		move.l	a0,d2
dupvar_1:
		movea.l	a0,a3
		clr.l	var_next(a3)
		move.w	var_nwords(a2),var_nwords(a3)
		lea	var_body(a2),a1
		lea	var_body(a3),a0
		move.l	d1,d0
		bsr	memmovi
		movea.l	var_next(a2),a2
		bra	dupvar_loop

dupvar_fail:
		movea.l	d2,a0
		bsr	freevar
		moveq	#-1,d0
		bra	dupvar_return

dupvar_done:
		move.l	d2,(a5,d3.w)
		move.l	d2,d0
dupvar_return:
		movem.l	(a7)+,d1-d3/a0-a3
		rts
****************************************************************
* findvar - �ϐ���T��
*
* CALL
*      A0     �ϐ����X�g�̍�
*      A1     �T���ϐ������w��
*
* RETURN
*      A0     �ϐ������������I�ɑO���Ɉʒu����Ō�̕ϐ��̃A�h���X
*             ���邢�� 0
*
*      D0.L   ���������ϐ��̃A�h���X
*             ������Ȃ���� 0
*
*      CCR    TST.L D0
****************************************************************
.xdef findvar

findvar:
		move.l	a2,-(a7)
		suba.l	a2,a2
findvar_loop:
		cmpa.l	#0,a0
		beq	not_found

		lea	var_body(a0),a0
		bsr	strcmp
		lea	-var_body(a0),a0
		beq	match
		bhi	not_found

		movea.l	a0,a2
		movea.l	var_next(a2),a0
		bra	findvar_loop

match:
		move.l	a0,d0
findvar_done:
		movea.l	a2,a0
		movea.l	(a7)+,a2
		rts

not_found:
		moveq	#0,d0
		bra	findvar_done
****************************************************************
* find_shellvar - �V�F���ϐ���T��
*
* CALL
*      A0     �T���ϐ������w��
*
* RETURN
*      A0     ���������ꍇ�F���������ϐ��̐擪�A�h���X
*             ������Ȃ������ꍇ�F�ϐ������������I�Ɍ���ł���ŏ��̕ϐ��̐擪�A�h���X
*                                   ���邢�͏I�[�̃A�h���X
*
*      D0.L   ������� A0 �Ɠ����l
*             ������Ȃ���� 0
*
*      CCR    TST.L D0
****************************************************************
.xdef find_shellvar

find_shellvar:
		move.l	a1,-(a7)
		movea.l	a0,a1
		movea.l	shellvar_top(a5),a0
		bsr	findvar
		movea.l	(a7)+,a1
		rts
****************************************************************
* get_shellvar - �V�F���ϐ��𓾂�
*
* CALL
*      A0     �ϐ����̐擪�A�h���X
*
* RETURN
*      A0     �ϐ��̒l�̐擪�A�h���X�i��������΁j
*      D0.L   �l�̒P�ꐔ�i�ϐ���������� 0�j
****************************************************************
****************************************************************
* get_var_value - �ϐ��̒l�𓾂�
*
* CALL
*      D0.L   �ϐ��̐擪�A�h���X
*
* RETURN
*      A0     �ϐ��̒l�̐擪�A�h���X
*      D0.L   �l�̒P�ꐔ
****************************************************************
.xdef get_shellvar
.xdef get_var_value

get_shellvar:
		bsr	find_shellvar
		beq	get_shellvar_return
get_var_value:
		movea.l	d0,a0
		moveq	#0,d0
		move.w	var_nwords(a0),d0
		lea	var_body(a0),a0
		bsr	strfor1
		tst.l	d0
get_shellvar_return:
		rts
****************************************************************
* allocvar - �ϐ��m�[�h���m�ۂ���
*
* CALL
*      A1     �ϐ����̐擪�A�h���X
*      A2     �l�̒P����т̐擪�A�h���X
*      D1.W   �l�̒P�ꐔ
*
* RETURN
*      A0     �j��
*      A3     �m�ۂ����ϐ��m�[�h�̐擪�A�h���X�D�m�ۂł��Ȃ������Ȃ� 0
*      D0.L   A3 �Ɠ���
*      D2.L   �j��
*      CCR    TST.L D0
****************************************************************
.xdef allocvar

allocvar:
		movea.l	a2,a0
		move.w	d1,d0
		bsr	wordlistlen
		move.l	d0,d2				*  D2.L : �V�ϐ��̒l�̃T�C�Y
		movea.l	a1,a0
		bsr	strlen
		add.l	d2,d0
		add.l	#1+VAR_HEADER_SIZE,d0		*  D0.L : �V�ϐ��S�̂̃T�C�Y
		jsr	xmalloc
		movea.l	d0,a3				*  A3 : �V�ϐ��̐擪���w��
		rts
****************************************************************
* entervar - �ϐ���o�^����
*
* CALL
*      A0     �e�ϐ��̃A�h���X�i������� 0�j
*      D0.L   ���ϐ��̃A�h���X�i������� 0�j
*      A1     �ϐ����̐擪�A�h���X
*      A2     �l�̒P����т̐擪�A�h���X
*      D1.W   �l�̒P�ꐔ
*      D2.L   �l�̃T�C�Y
*      A3     �V�ϐ��̃A�h���X
*      A4     �ϐ����X�g�̍��̃A�h���X
*
* RETURN
*      D0.L   �V�ϐ��̃A�h���X
*      CCR    TST.L D0
****************************************************************
.xdef entervar

entervar:
		movem.l	d3-d4/a0-a1/a4,-(a7)
		move.l	d0,d4				*  D4.L : �����������ϐ��̃A�h���X
		*
		*  A4 �ɐe�̎q�ւ̃|�C���^�̃A�h���X���Z�b�g����
		*
		move.l	a0,d3
		beq	no_prev

		lea	var_next(a0),a4
no_prev:
		*
		*  D3.L �ɐV�ϐ��̎q�ƂȂ�ϐ��̃A�h���X���Z�b�g����
		*
		tst.l	d4
		beq	new

		movea.l	d4,a0
		move.l	var_next(a0),d3
		bra	set_next_done

new:
		move.l	(a4),d3
set_next_done:
		move.l	d3,var_next(a3)			*  �V�ϐ��̎q�|�C���^���Z�b�g����
		move.w	d1,var_nwords(a3)		*  �l�̒P�ꐔ���Z�b�g����
		lea	var_body(a3),a0
		bsr	strmove				*  �ϐ������Z�b�g����
		movea.l	a2,a1
		move.l	d2,d0
		bsr	memmovi				*  �l�̒P����т��Z�b�g����

		move.l	a3,(a4)				*  �V�ϐ��������N����
		move.l	d4,d0				*  ���ϐ���
		bsr	xfree				*  �������

		move.l	a3,d0				*  �V�ϐ��̃A�h���X��Ԃ�
		movem.l	(a7)+,d3-d4/a0-a1/a4
		rts
****************************************************************
* setvar - �ϐ����`����
*
* CALL
*      A0     �ϐ����X�g�̍��̃A�h���X
*      A1     �ϐ����̐擪�A�h���X
*      A2     �l�̒P����т̐擪�A�h���X
*      D0.W   �l�̒P�ꐔ
*
* RETURN
*      D0.L   �Z�b�g�����ϐ��̐擪�A�h���X�D
*             �������̈悪����Ȃ����߃Z�b�g�ł��Ȃ������Ȃ�� 0�D
*      CCR    TST.L D0
*
* NOTE
*      �Z�b�g����l�̌���т̃A�h���X���ϐ��̌��݂̒l��
*      �ꕔ�ʂł���Ƃ��ɂ��A���������삷��B
****************************************************************
.xdef setvar

setvar:
		movem.l	d1-d2/a0/a3-a4,-(a7)
		move.w	d0,d1				*  D1.W : �V�ϐ��̒l�̌ꐔ
		movea.l	a0,a4				*  A4 : �ϐ����X�g�̍��̃A�h���X
		bsr	allocvar			*  A3 : �V�ϐ��̃A�h���X
		beq	setvar_return

		movea.l	(a4),a0
		bsr	findvar
		bsr	entervar
setvar_return:
		movem.l	(a7)+,d1-d2/a0/a3-a4
		rts
****************************************************************
* print_var_value - �ϐ��̒l��\������
*
* CALL
*      D0.L   �ϐ��̐擪�A�h���X
*
* RETURN
*      ����
****************************************************************
.xdef print_var_value

print_var_value:
		movem.l	d0/a0-a1,-(a7)
		bsr	get_var_value
		lea	cputs(pc),a1
		bsr	echo
		movem.l	(a7)+,d0/a0-a1
		rts
****************************************************************
* printvar - �ϐ���\������
*
* CALL
*      A3     �ϐ��̈�̐擪�A�h���X���i�[���Ă���|�C���^�̃A�h���X
*      D0.B   ��0 : ������ ( ) ��p���Ȃ�
*
* RETURN
*      D0.L   0
*      CCR    TST.L D0
****************************************************************
.xdef printvar

printvar:
		movem.l	d1-d2/a0-a1,-(a7)
		move.b	d0,d2
		movea.l	(a3),a1
		bsr	start_output
printvar_loop:
		cmpa.l	#0,a1
		beq	printvar_done

		lea	var_body(a1),a0
		bsr	cputs			*  �ϐ�����\������
		bsr	put_tab			*  �����^�u��\������
		tst.b	d2
		bne	printvar_value_1

		move.w	var_nwords(a1),d1
		subq.w	#1,d1
		beq	printvar_value_1

		moveq	#'(',d0			* ( ��
		bsr	putc			* �\������
printvar_value_1:
		move.l	a1,d0
		bsr	print_var_value
		tst.b	d2
		bne	printvar_value_2

		tst.w	d1
		beq	printvar_value_2

		moveq	#')',d0			* ) ��
		bsr	putc			* �\������
printvar_value_2:
		bsr	put_newline		*  ���s����
		movea.l	var_next(a1),a1		*  ���̕ϐ��̃|�C���^
		bra	printvar_loop		*  �J��Ԃ�

printvar_done:
		bsr	end_output
		movem.l	(a7)+,d1-d2/a0-a1
return_0:
		moveq	#0,d0
		rts
****************************************************************
svartou_sub1:
		moveq	#0,d1
		moveq	#0,d2
		bsr	find_shellvar
		beq	svartou_sub1_done		*  �ϐ������� ; return 0

		moveq	#1,d2
		bsr	get_var_value
		beq	svartou_sub1_done		*  �P�ꂪ���� ; return 1

		moveq	#2,d2				*  �P�ꂪ��   ; return 2
		tst.b	(a0)
svartou_sub1_done:
		rts
****************************************************************
svartou_sub2:
		moveq	#3,d2
		bsr	atou
		bmi	svartou_sub2_done		*  �����Ŏn�܂��Ă��Ȃ� ; return 3

		moveq	#4,d2
		tst.b	(a0)
		bne	svartou_sub2_done		*  �����̌�ɕ��������� ; return 4

		moveq	#5,d2
		cmp.w	d2,d2
svartou_sub2_done:
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
		bsr	svartou_sub1
		beq	svartou_return

		bsr	svartou_sub2
		bne	svartou_return

		tst.l	d0
		beq	svartou_return

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
		bsr	svartou_sub1
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
		bsr	svartou_sub2
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

* b_alloc.s
* This contains built-in command 'alloc'.
*
* Itagaki Fumihiko 06-May-91  Create.

.xref utoa
.xref putc
.xref nputs
.xref printfs
.xref printfi
.xref mulul
.xref divul
.xref strazbot
.xref too_many_args
.xref msg_environment
.xref msg_directory_stack
.xref msg_key_macro_space
.xref msg_shellvar_space
.xref msg_alias_space

.xref envwork
.xref dstack
.xref keymacro
.xref shellvar
.xref alias
.if 0
.xref history
.endif

.text

****************************************************************
*  Name
*       alloc - �������g�p�󋵂�񍐂���
*
*  Synopsis
*       alloc
*            �������g�p�󋵂�񍐂���
****************************************************************
.xdef cmd_alloc

cmd_alloc:
		tst.w	d0
		bne	too_many_args

		lea	msg_header,a0
		bsr	nputs
		*
		*  ��
		*
		movea.l	envwork(a5),a1
		lea	4(a1),a0
		bsr	strazbot
		addq.l	#1,a0
		move.l	a0,d6
		sub.l	a1,d6			*  D6: �g�p��
		lea	msg_environment,a0
		bsr	report_1
		*
		*  �V�F���ϐ�
		*
		movea.l	shellvar(a5),a1
		lea	msg_shellvar_space,a0
		bsr	report_3
		*
		*  �ʖ�
		*
		movea.l	alias(a5),a1
		lea	msg_alias_space,a0
		bsr	report_3
		*
		*  �L�[�E�}�N��
		*
		movea.l	keymacro(a5),a1
		lea	msg_key_macro_space,a0
		bsr	report_2
		*
		*  �f�B���N�g���E�X�^�b�N
		*
		movea.l	dstack(a5),a1
		lea	msg_directory_stack,a0
		bsr	report_2
		*
		*  ����
		*
.if 0
		movea.l	history(a5),a1
		lea	msg_history,a0
		bsr	report_3
.endif
		moveq	#0,d0
		rts


report_3:
		move.l	4(a1),d6
		addq.l	#2,d6
		bra	report_1

report_2:
		move.l	4(a1),d6
report_1:
		move.l	(a1),d7
		lea	putc(pc),a1
		moveq	#24,d1
		moveq	#1,d2
		bsr	printfs
		lea	utoa(pc),a0
		moveq	#0,d2
		moveq	#' ',d3
		move.l	d7,d0
		moveq	#10,d1
		bsr	printfi
		move.l	d6,d0
		bsr	printfi
		move.l	d7,d0
		sub.l	d6,d0
		moveq	#10,d1
		bsr	printfi
		move.l	d6,d0
		moveq	#100,d1
		bsr	mulul
		move.l	d7,d1
		bsr	divul
		moveq	#5,d1
		bsr	printfi
		lea	msg_percent,a0
		bra	nputs
****************************************************************
.data

msg_header:	dc.b	'�u���b�N                    �m�ۗ�    �g�p��      ��� �g�p��',0
msg_percent:	dc.b	'%',0
.if 0
msg_history:	dc.b	'�������X�g',0
.endif

.end

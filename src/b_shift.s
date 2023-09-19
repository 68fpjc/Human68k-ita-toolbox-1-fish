* b_shift.s
* This contains built-in command 'shift'.
*
* Itagaki Fumihiko 30-Oct-90  Create.

.xref strfor1
.xref find_shellvar
.xref set_svar
.xref undefined
.xref too_many_args
.xref command_error
.xref word_argv

.text

****************************************************************
*  Name
*       shift - �V�F���ϐ����V�t�g����
*
*  Synopsis
*       shift
*            argv ���V�t�g����
*
*       shift var
*            var ���V�t�g����
****************************************************************
.xdef cmd_shift

cmd_shift:
		cmp.w	#1,d0
		bhi	too_many_args
		beq	shift_var

		lea	word_argv,a0
shift_var:
		movea.l	a0,a2				* A2 : �ϐ���
		bsr	find_shellvar
		exg	a0,a2				* A0 : �ϐ���   A2 : var ptr
		beq	undefined

		move.w	2(a2),d0			* D0.W : ���̕ϐ��̗v�f��
		beq	no_more_words

		exg	a0,a2
		addq.l	#4,a0
		bsr	strfor1
		bsr	strfor1
		subq.w	#1,d0
		movea.l	a0,a1
		movea.l	a2,a0
		moveq	#1,d1				* export ����
		bra	set_svar

no_more_words:
		lea	msg_no_more_words,a0
		bra	command_error
****************************************************************
.data

msg_no_more_words:	dc.b	'�P��͂�������܂���',0

.end

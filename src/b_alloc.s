* b_alloc.s
* This contains built-in command 'alloc'.
*
* Itagaki Fumihiko 06-May-91  Create.

.include ../src/extmalloc.h

.xref utoa
.xref start_output
.xref end_output
.xref putc
.xref nputs
.xref printu
.xref mulul
.xref divul
.xref too_many_args

.xref lake_top

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

		bsr	start_output
		lea	msg_header,a0
		bsr	nputs

		move.l	lake_top(a5),d0
		bra	lake_entry

lake_loop:
		move.l	next_lake_ptr(a4),d0
lake_entry:
		beq	done

		move.l	d0,a4
		move.l	lake_size(a4),d7		*  D7 : ���� lake �̃T�C�Y
		move.l	d7,d6
		tst.w	head_pool+next_pool_offset(a4)
		beq	pool_end

		moveq	#0,d6
		lea	head_pool(a4),a1
		move.l	a1,a0
pool_loop:
		cmp.l	a1,a0
		bne	free_skip

		move.w	next_free_offset(a0),d0
		lea	(a0,d0.w),a0
free_skip:
		move.w	next_pool_offset(a1),d0
		lea	(a1,d0.w),a1
		moveq	#0,d0
		move.w	next_pool_offset(a1),d0
		beq	pool_end

		cmpa.l	a1,a0
		beq	pool_loop			*  free pool

		add.l	d0,d6
		bra	pool_loop

pool_end:
		moveq	#0,d1				*  �E�l�߂�
		moveq	#' ',d2				*  pad�̓X�y�[�X��
		moveq	#10,d3				*  ���Ȃ��Ƃ�10�����̕���
		moveq	#1,d4				*  ���Ȃ��Ƃ�1���̐�����
		move.l	d7,d0
		bsr	printu
		move.l	d6,d0
		bsr	printu
		move.l	d7,d0
		sub.l	d6,d0
		bsr	printu
		move.l	d6,d0
		moveq	#100,d1
		bsr	mulul
		move.l	d7,d1
		bsr	divul
		moveq	#0,d1				*  �E�l�߂�
		moveq	#5,d3				*  ���Ȃ��Ƃ� 5�����̕���
		bsr	printu
		lea	msg_percent,a0
		bsr	nputs
		bra	lake_loop

done:
		bsr	end_output
		moveq	#0,d0
		rts
****************************************************************
.data

msg_header:	dc.b	'    �m�ۗ�    �g�p��      ��� �g�p��',0
msg_percent:	dc.b	'%',0

.end

* quote.s
* Itagaki Fumihiko 22-Jul-90  Create.

.include ../src/fish.h

.xref issjis
.xref strcpy

.text

****************************************************************
* isquoted
*
* CALL
*      A0     string
*
* RETURN
*      D0.B   ��������΃N�I�[�g�L�����N�^�D�N�I�[�g����Ă��Ȃ����0
*      CCR    TST.L D0
*****************************************************************
.xdef isquoted

isquoted:
		move.l	a0,-(a7)
isquoted_loop:
		move.b	(a0)+,d0
		beq	isquoted_return

		bsr	issjis
		beq	isquoted_sjis

		cmp.b	#'"',d0
		beq	isquoted_return

		cmp.b	#"'",d0
		beq	isquoted_return

		cmp.b	#'\',d0
		beq	isquoted_return

		bra	isquoted_loop

isquoted_sjis:
		move.b	(a0)+,d0
		bne	isquoted_loop
isquoted_return:
		movea.l	(a7)+,a0
		tst.b	d0
		rts
****************************************************************
* hide_escape - ������� \ ���O��
*
* CALL
*      A0     string
*
* RETURN
*      none
*****************************************************************
.xdef hide_escape

hide_escape:
		movem.l	d0/a0-a1,-(a7)
		movea.l	a0,a1
hide_escape_loop:
		move.b	(a0)+,d0
		cmp.b	#'\',d0
		bne	hide_escape_char

		move.b	(a0)+,d0
hide_escape_char:
		bsr	issjis
		bne	hide_escape_dup1

		move.b	d0,(a1)+
		move.b	(a0)+,d0
hide_escape_dup1:
		move.b	d0,(a1)+
		bne	hide_escape_loop

		movem.l	(a7)+,d0/a0-a1
		rts
****************************************************************
* strip_quotes_sub - ������̃N�I�[�g���O��
*
* CALL
*      A0     buffer�istring �Əd�Ȃ��Ă��Ă��ǂ��j
*      A1     string�i������MAXWORDLEN�ȓ��ł��邱�Ɓj
*
* RETURN
*      A0     buffer �Ɋi�[���� NUL �̎����w��
*      A1     string �� NUL �̎����w��
*      A2, D0.L, D1.L  �j��
*****************************************************************
wordbuf = -(((MAXWORDLEN+1)+1)>>1<<1)

strip_quotes_sub:
		link	a6,#wordbuf
		exg	a0,a2
		lea	wordbuf(a6),a0
		bsr	strcpy
		adda.l	d0,a1
		addq.l	#1,a1
		exg	a0,a2
		moveq	#0,d1
strip_quotes_loop:
		move.b	(a2)+,d0
		bsr	issjis
		beq	strip_quotes_dup2

		tst.b	d1
		beq	strip_quotes_check_quotation

		cmp.b	d1,d0
		bne	strip_quotes_dup
strip_quotes_quote:
		eor.b	d0,d1
		bra	strip_quotes_loop

strip_quotes_check_quotation:
		cmp.b	#'"',d0
		beq	strip_quotes_quote

		cmp.b	#"'",d0
		beq	strip_quotes_quote

		cmp.b	#'\',d0
		bne	strip_quotes_dup

		move.b	(a2)+,d0
		bsr	issjis
		bne	strip_quotes_dup
strip_quotes_dup2:
		move.b	d0,(a0)+
		move.b	(a2)+,d0
strip_quotes_dup:
		move.b	d0,(a0)+
		bne	strip_quotes_loop

		unlk	a6
		rts
****************************************************************
* strip_quotes - strip quotes
*
* CALL
*      A0     string
*
* RETURN
*      none.
*****************************************************************
.xdef strip_quotes

strip_quotes:
		movem.l	d0-d1/a0-a2,-(a7)
		movea.l	a0,a1
		bsr	strip_quotes_sub
		movem.l	(a7)+,d0-d1/a0-a2
		rts
****************************************************************
* strip_quotes_list - �P����т̊e�P��̃N�I�[�g�����ƃG�X�P�[�v�������O��
*
* CALL
*      A0     �P����т̐擪�A�h���X�i�����̓��e�����ڏ�����������j
*      D0.W   �P�ꐔ
*
* RETURN
*      ����
*****************************************************************
.xdef strip_quotes_list

strip_quotes_list:
		movem.l	d0-d2/a0-a2,-(a7)
		move.w	d0,d2
		movea.l	a0,a1
		bra	strip_quotes_list_next

strip_quotes_list_loop:
		bsr	strip_quotes_sub
strip_quotes_list_next:
		dbra	d2,strip_quotes_list_loop

		clr.b	(a0)
		movem.l	(a7)+,d0-d2/a0-a2
		rts
****************************************************************
* escape_quoted - ' ����� " ���O���A�N�I�[�g����Ă��镶���� \ �ŃG�X�P�[�v����
*                 �������G�X�P�[�v���Ă��� \ �͊O��
*
* CALL
*      A0     string (may be contains ', ", and/or \)
*      A1     buffer (it will be contains \)
*
* RETURN
*      none
*
* NOTE
*      �ň��̏ꍇ���l����ƁCbuffer �ɂ� string �̒����~�Q�{�P�̑傫�����K�v�D
*      �����ł̓`�F�b�N���Ă��Ȃ��D
****************************************************************
.xdef escape_quoted

escape_quoted:
		movem.l	d0-d1/a0-a1,-(a7)
		moveq	#0,d1
escape_quoted_loop:
		move.b	(a0)+,d0
		bsr	issjis
		beq	escape_quoted_dup2

		tst.b	d1
		beq	escape_quoted_check_quotation

		cmp.b	d1,d0
		bne	escape_quoted_escape
escape_quoted_quotation_found:
		eor.b	d0,d1
		bra	escape_quoted_loop

escape_quoted_check_quotation:
		cmp.b	#'"',d0
		beq	escape_quoted_quotation_found

		cmp.b	#"'",d0
		beq	escape_quoted_quotation_found

		cmp.b	#'\',d0
		bne	escape_quoted_dup

		move.b	(a0)+,d0
		bsr	issjis
		beq	escape_quoted_dup2
escape_quoted_escape:
		move.b	#'\',(a1)+
		bra	escape_quoted_dup

escape_quoted_dup2:
		move.b	d0,(a1)+
		move.b	(a0)+,d0
escape_quoted_dup:
		move.b	d0,(a1)+
		bne	escape_quoted_loop

		movem.l	(a7)+,d0-d1/a0-a1
		rts
****************************************************************

.end

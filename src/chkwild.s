* chkwild.s
* Itagaki Fumihiko 02-Sep-90  Create.

.xref issjis

.text

****************************************************************
* check_wildcard - ��Ƀ��C���h�J�[�h���܂܂�Ă��邩�ǂ������ׂ�
*
* CALL
*      A0     �� (may be contains ", ', and/or \)
*
* DESCRIPTION
*      ��Ƀ��C���h�J�[�h���܂܂�Ă��邩�ǂ������ׁA���������
*      �ŏ��Ɍ����������C���h�J�[�h������Ԃ��A������� 0 ��
*      �Ԃ��B
*
* RETURN
*      D0.L   ���ʃo�C�g�͍ŏ��Ɍ����������C���h�J�[�h����
*      CCR    TST.L D0
****************************************************************
.xdef check_wildcard

check_wildcard:
		movem.l	d1/a0,-(a7)
		moveq	#0,d1
check_wildcard_loop:
		move.b	(a0)+,d0
		beq	no_wildcard

		bsr	issjis
		beq	check_wildcard_skip1

		tst.b	d1
		beq	check_wildcard_1

		cmp.b	d1,d0
		bne	check_wildcard_loop
check_wildcard_quote:
		eor.b	d0,d1
		bra	check_wildcard_loop

check_wildcard_1:
		cmp.b	#'*',d0
		beq	check_wildcard_done

		cmp.b	#'?',d0
		beq	check_wildcard_done

		cmp.b	#'[',d0
		beq	check_wildcard_done

		cmp.b	#'"',d0
		beq	check_wildcard_quote

		cmp.b	#"'",d0
		beq	check_wildcard_quote

		cmp.b	#'\',d0
		bne	check_wildcard_loop

		move.b	(a0)+,d0
		beq	no_wildcard

		bsr	issjis
		bne	check_wildcard_loop
check_wildcard_skip1:
		move.b	(a0)+,d0
		bne	check_wildcard_loop
no_wildcard:
		moveq	#0,d0
		bra	check_wild_return

check_wildcard_done:
		moveq	#-1,d1
		move.b	d0,d1
		exg	d0,d1
check_wild_return:
		movem.l	(a7)+,d1/a0
		tst.l	d0
		rts

.end

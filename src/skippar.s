* skippar.s
* Itagaki Fumihiko 10-Nov-90  Create.

.xref strfor1

.text

****************************************************************
* skip_paren - ���݈ʒu�� ( �ɑΉ����� ) �̈ʒu��Ԃ�
*
* CALL
*      A0     �P����т̐擪�A�h���X
*      D0.W   �P�ꐔ
*
* RETURN
*      A0     �Ή����� ) �̃A�h���X
*      D0.W   �Ή����� ) �ȍ~�̒P�ꐔ
*      CCR    TST.W D0
*****************************************************************
.xdef skip_paren

skip_paren:
		tst.w	d0
		beq	skip_paren_return

		bra	next
loop:
		cmpi.b	#')',(a0)
		bne	not_close_paren

		tst.b	1(a0)
		beq	skip_paren_return

not_close_paren:
		cmpi.b	#'(',(a0)
		bne	next

		tst.b	1(a0)
		bne	next

		bsr	skip_paren
		beq	skip_paren_return
next:
		bsr	strfor1
		subq.w	#1,d0
		bne	loop
skip_paren_return:
		tst.w	d0
		rts

.end

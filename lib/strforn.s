* strforn.s
* Itagaki Fumihiko 18-Aug-91  Create.

.xref strfor1

****************************************************************
* strforn - �������n�X�L�b�v����
*
* CALL
*      A0     ��������т̐擪�A�h���X
*
* RETURN
*      A0     n�X�L�b�v�����A�h���X
*****************************************************************
.xdef strforn

strforn:
		tst.w	d0
		beq	strforn_done

		move.w	d0,-(a7)
		subq.w	#1,d0
strforn_loop:
		jsr	strfor1
		dbra	d0,strforn_loop

		move.w	(a7)+,d0
strforn_done:
		rts

.end

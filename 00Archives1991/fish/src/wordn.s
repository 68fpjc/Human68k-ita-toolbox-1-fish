* wordn.s
* Itagaki Fumihiko 14-Jul-90  Create.

.text

****************************************************************
* wordn - find n'th word
*
* CALL
*      A0     string
*      D0     n
*
* RETURN
*      A0     word point
*      D0     destroyed
*****************************************************************
.xdef wordn
wordn:
		move.l	d1,-(a7)
		move.l	d0,d1
loop:
		bsr	skip_space
		tst.l	d1
		beq	done

		tst.b	(a0)			* �����ꂪ�����Ȃ��
		beq	done			* ��߂�

		bsr	find_space
		subq.l	#1,d1			* n��
		bra	loop			* �J��Ԃ�
done:
		move.l	(a7)+,d1
		rts

.end

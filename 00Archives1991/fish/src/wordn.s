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

		tst.b	(a0)			* もう語が無いならば
		beq	done			* やめる

		bsr	find_space
		subq.l	#1,d1			* n回
		bra	loop			* 繰り返す
done:
		move.l	(a7)+,d1
		rts

.end

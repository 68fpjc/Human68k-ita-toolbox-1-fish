* findsl.s
* Itagaki Fumihiko 27-Mar-93  Create.

.xref issjis

.text

****************************************************************
* find_slashes - / か \ を探す
*
* CALL
*      A0     文字列
*
* RETURN
*      A0     最初の / か \ か NUL の位置
*      D0.B   最初の / か \ か NUL
*      CCR    TST.B D0
*****************************************************************
.xdef find_slashes

find_slashes:
		move.b	(a0)+,d0
		beq	done

		cmp.b	#'/',d0
		beq	done

		cmp.b	#'\',d0
		beq	done

		jsr	issjis
		bne	find_slashes

		move.b	(a0)+,d0
		bne	find_slashes
done:
		subq.l	#1,a0
		tst.b	d0
		rts

.end

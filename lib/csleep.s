* csleep.s
* Itagaki Fumihiko 23-Feb-92  Create.

.include iocscall.h

.xref divul

.text
*****************************************************************
* csleep - 指定の時間停止する
*
* CALL
*      D0.L   停止時間（単位1/100秒）
*
* RETRUN
*      none
*****************************************************************
.xdef csleep

csleep:
		movem.l	d0-d3,-(a7)
		move.l	#24*60*60*100,d1
		jsr	divul
		move.l	d1,d2
		move.l	d0,d3
		IOCS	_ONTIME
		add.l	d0,d2
		bcc	csleep_1

		sub.l	#24*60*60*100,d2
		addq.l	#1,d3
csleep_1:
		add.l	d1,d3
csleep_wait:
		IOCS	_ONTIME
		cmp.l	d3,d1
		bhi	csleep_return
		blo	csleep_wait

		cmp.l	d2,d0
		blo	csleep_wait
csleep_return:
		movem.l	(a7)+,d0-d3
		rts

.end

* setvar.s
* Itagaki Fumihiko 26-Sep-90  Create.

.xref strlen
.xref strmove
.xref memmove_inc
.xref memmove_dec
.xref wordlistlen
.xref find_var

.text

****************************************************************
* set_var - 変数を定義する
*
* CALL
*      A0     変数領域の先頭アドレス
*      A1     変数名の先頭アドレス
*      A2     値の語並びの先頭アドレス
*      D0.W   値の語数
*
* RETURN
*      D0.L   0:成功  1:領域が足りない
*      CCR    TST.L D0
*
* NOTE
*      セットする値の語並びのアドレスが変数の現在の値の
*      一部位であるときにも、正しく動作する。
****************************************************************
.xdef set_var

set_var:
		movem.l	d1-d7/a0-a1/a3-a4,-(a7)
		movea.l	a0,a3			* A3 : 変数領域の先頭アドレス
		move.w	d0,d1			* D1.W : 値の語数
		movea.l	a2,a0			* A0 = 値
		bsr	wordlistlen
		move.l	d0,d2			* D2.L = 語並びのバイト数
		movea.l	a1,a0			* A0 = 変数名
		bsr	strlen
		addq.l	#1,d0
		add.l	d2,d0
		bsr	calc_var_size
		move.l	d0,d3			* D3.L = 変数に必要なバイト数

		movea.l	a3,a4
		adda.l	4(a3),a4		* A4 = 変数領域の現在の終端アドレス

		move.l	(a3),d4
		sub.l	4(a3),d4
		subq.l	#2,d4			* D4.L = 現在の変数領域の余裕

		movea.l	a3,a0
		bsr	find_var
		move.l	d0,d5
		beq	do_insert

		moveq	#0,d5
		move.w	(a0),d5
do_insert:
		move.l	a0,d0
		add.l	d5,d0			* D0 = A0 + D5 ... 次の変数のアドレス
		move.l	a4,d6
		sub.l	d0,d6			* D6 = A4 - D0 ... 次の変数の先頭から終端までのバイト数
		move.l	d5,d7
		sub.l	d3,d7			* D7 = D5 - D3 ... 減少バイト数
		beq	do_put
		bmi	reset_expand

		* バイト数減少

		bsr	put
		suba.l	d7,a4			* A4 = 再設定後の終端アドレス
		movea.l	d0,a1
		movea.l	d0,a0
		suba.l	d7,a0
		move.l	d6,d0
		bsr	memmove_inc
		bra	insert_done

reset_expand:
		* バイト数増加

		add.l	d5,d4
		sub.l	d3,d4			* D4.L = 再設定後の余裕
		blo	nospace

		movem.l	a0-a1,-(a7)
		movea.l	a4,a1
		suba.l	d7,a4			* A4 = 再設定後の終端アドレス
		movea.l	a4,a0
		move.l	d6,d0
		bsr	memmove_dec
		movem.l	(a7)+,a0-a1
do_put:
		bsr	put
insert_done:
		move.w	d3,-2(a0,d3.w)		* この変数が占めるバイト数
		clr.w	(a4)			* 変数群の終端
		suba.l	a3,a4
		move.l	a4,4(a3)		* 変数群の終端アドレスの先頭からのオフセット
		moveq	#0,d0			* return 0 : 成功
set_var_return:
		movem.l	(a7)+,d1-d7/a0-a1/a3-a4
		rts

nospace:
		moveq	#1,d0
		bra	set_var_return
****************************************************************
put:
		movem.l	d0/a0-a1,-(a7)
		move.w	d3,(a0)+		* この変数が占めるバイト数
		move.w	d1,(a0)+		* この変数の語数
		bsr	strmove			* 変数名
		movea.l	a2,a1
		move.l	d2,d0
		bsr	memmove_inc		* 語並び
		movem.l	(a7)+,d0/a0-a1
		rts
****************************************************************
.xdef calc_var_size

calc_var_size:
		btst	#0,d0
		beq	calc_var_size_1

		addq.l	#1,d0
calc_var_size_1:
		addq.l	#6,d0
		rts
****************************************************************

.end

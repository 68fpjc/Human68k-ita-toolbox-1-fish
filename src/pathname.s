* pathname.s
* Itagaki Fumihiko 14-Aug-90  Create.
*
* This contains pathname controll routines.

.xref toupper
.xref cat_pathname
.xref fish_getenv
.xref get_var_value

.text

*****************************************************************
* scan_drive_name - パス名からドライブ番号を取り出す
*
* CALL
*      A0     パス名
*
* RETURN
*      D0.B   大文字にしたドライブ番号（もしあれば）
*      CCR    ドライブ名があれば Z
*****************************************************************
.xdef scan_drive_name

scan_drive_name:
		move.b	(a0),d0
		beq	scan_drive_name_none

		cmpi.b	#':',1(a0)
		bne	scan_drive_name_return

		bsr	toupper
		cmp.b	d0,d0
scan_drive_name_return:
		rts

scan_drive_name_none:
		subq.b	#1,d0
		rts
*****************************************************************
* make_sys_pathname - システム・ファイルのパス名を生成する
*
* CALL
*      A0     結果を格納するバッファ（MAXPATH+1バイト必要）
*      A1     $SYSROOT下のパス名
*
* RETURN
*      CCR    エラーならば MI
*****************************************************************
.xdef make_sys_pathname

make_sys_pathname:
		movem.l	d0/a0-a3,-(a7)
		movea.l	a1,a2
		movea.l	a0,a3
		lea	word_sysroot,a0
		bsr	fish_getenv
		lea	str_nul,a1
		beq	make_sys_pathname_1

		bsr	get_var_value
		movea.l	a0,a1
make_sys_pathname_1:
		movea.l	a3,a0
		bsr	cat_pathname
		movem.l	(a7)+,d0/a0-a3
		rts
*****************************************************************
.data

word_sysroot:		dc.b	'SYSROOT'
str_nul:		dc.b	0
*****************************************************************

.end

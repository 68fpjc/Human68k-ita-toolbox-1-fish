* pathname.s
* Itagaki Fumihiko 14-Aug-90  Create.
*
* This contains pathname controll routines.

.xref toupper
.xref cat_pathname
.xref fish_getenv
.xref get_var_value

.xref flag_refersysroot


.text

*****************************************************************
* scan_drive_name - �p�X������h���C�u�ԍ������o��
*
* CALL
*      A0     �p�X��
*
* RETURN
*      D0.B   �啶���ɂ����h���C�u�ԍ��i��������΁j
*      CCR    �h���C�u��������� Z
*****************************************************************
.xdef scan_drive_name

scan_drive_name:
		move.b	(a0),d0
		beq	scan_drive_name_none

		cmpi.b	#':',1(a0)
		bne	scan_drive_name_return

		jsr	toupper
		cmp.b	d0,d0
scan_drive_name_return:
		rts

scan_drive_name_none:
		subq.b	#1,d0
		rts
*****************************************************************
* make_sys_pathname - �V�X�e���E�t�@�C���̃p�X���𐶐�����
*
* CALL
*      A0     ���ʂ��i�[����o�b�t�@�iMAXPATH+1�o�C�g�K�v�j
*      A1     $SYSROOT���̃p�X��
*
* RETURN
*      CCR    �G���[�Ȃ�� MI
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
* isfullpathx - �p�X�����h���C�u�����܂ރt���p�X���ł��邩
*               �ǂ�������������
*
* CALL
*      A0     �p�X���̐擪�A�h���X
*
* RETURN
*      CCR    �t���p�X���Ȃ�� EQ
*****************************************************************
.xdef isfullpathx
.xdef isfullpath

isfullpathx:
		tst.b	flag_refersysroot(a5)
		beq	isfullpath

		cmpi.b	#'/',(a0)
		bne	isfullpath

		cmp.b	d0,d0
		rts

isfullpath:
		tst.b	(a0)
		beq	isfullpath_false

		cmpi.b	#':',1(a0)
		bne	isfullpath_return

		cmpi.b	#'/',2(a0)
		beq	isfullpath_return

		cmpi.b	#'\',2(a0)
isfullpath_return:
		rts

isfullpath_false:
		cmpi.b	#1,(a0)
		bra	isfullpath_return
*****************************************************************
.data

word_sysroot:		dc.b	'SYSROOT'
str_nul:		dc.b	0
*****************************************************************

.end

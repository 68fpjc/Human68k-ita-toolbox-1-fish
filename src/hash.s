* hash.s
* Itagaki Fumihiko 19-Nov-90  Create.

.include doscall.h
.include limits.h
.include stat.h

.if 0
.xref toupper
.endif
.xref utoa
.xref strlen
.xref strfor1
.xref memmovi
.xref putc
.xref puts
.xref nputs
.xref printu
.xref mulul
.xref divul
.xref word_path
.xref find_shellvar
.xref get_var_value
.xref is_builtin_dir
.xref isfullpath
.xref dos_allfile
.xref cat_pathname
.xref drvchkp
.xref builtin_table
.xref too_many_args

.xref hash_hits
.xref hash_misses
.xref hash_flag
.xref hash_table

.text

****************************************************************
* hash - filename hash function
*
* CALL
*      A0     filename
*
* RETURN
*      D0.L   key
****************************************************************
.xdef hash

hash:
.if	1
* NEW
		movem.l	d1-d2/a0,-(a7)
		moveq	#0,d1			* D1 : hashval
		move.w	#7,d2			* 8�����܂�
hash_loop:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq	hash_done

		cmp.b	#'.',d0
		beq	hash_done

		or.b	#$20,d0
		mulu	#241,d0
		add.l	d0,d1
		dbra	d2,hash_loop
hash_done:
		move.l	d1,d0
		movem.l	(a7)+,d1-d2/a0
.else
* OLD
		movem.l	d1-d4/a0,-(a7)
		moveq	#0,d2			* D2 : hashval
 		move.l	#4999,d3		* D3 : base
		move.w	#7,d4			* 8�����܂�
hash_loop:
		moveq	#0,d0
		move.b	(a0)+,d0
		beq	hash_done

		cmp.b	#'.',d0
		beq	hash_done

		*  hashval += ch * base;

		move.l	d3,d1
		bsr	toupper
		bsr	mulul
		add.l	d0,d2

		*  base = base * 2017 + 1;

		move.l	d3,d0
		move.l	#2017,d1
		bsr	mulul
		move.l	d0,d3

		dbra	d4,hash_loop
hash_done:
		move.l	d2,d0
		movem.l	(a7)+,d1-d4/a0
.endif
		and.l	#$3ff,d0
		rts
****************************************************************
* rehash
*
* CALL
*      none
*
* RETURN
*      none
****************************************************************
.xdef rehash

searchnamebuf = -(((MAXHEAD+4+1)+1)>>1<<1)		*  +4 : "/*.*"
files_buf = searchnamebuf-STATBUFSIZE

rehash:
		link	a6,#files_buf
		movem.l	d0-d2/a0-a4,-(a7)
	*
	*  �n�b�V���\���N���A����
	*
		lea	hash_table(a5),a4
		move.w	#1023,d0
rehash_clear_loop:
		clr.b	(a4,d0.w)
		dbra	d0,rehash_clear_loop
	*
	*  �V�F���ϐ� path �̊e�v�f�������f�B���N�g���̓��e���n�b�V������
	*
		lea	word_path,a0
		bsr	find_shellvar
		beq	rehash_done

		bsr	get_var_value
		move.w	d0,d1				*  D1.W : $#path
		movea.l	a0,a1				*  A1 : $path �|�C���^
		moveq	#0,d2				*  D2.B : �C���f�b�N�X
		bra	rehash_start

rehash_loop:
		tst.b	(a1)
		beq	rehash_next

		movea.l	a1,a0
		bsr	is_builtin_dir
		beq	rehash_builtin

		bsr	isfullpath
		bne	rehash_next
****************
		movea.l	a1,a0
		bsr	strlen
		cmp.l	#MAXHEAD,d0
		bhi	rehash_continue

		lea	searchnamebuf(a6),a0
		lea	dos_allfile,a2
		bsr	cat_pathname
		bmi	rehash_continue

		bsr	drvchkp
		bmi	rehash_continue

		movea.l	a1,a3

		move.w	#MODEVAL_ALL,-(a7)
		move.l	a0,-(a7)
		pea	files_buf(a6)
		DOS	_FILES
		lea	10(a7),a7
rehash_real_directory_loop:
		tst.l	d0
		bmi	rehash_real_directory_done

		move.b	files_buf+ST_MODE(a6),d0
		and.b	#MODEVAL_DIR|MODEVAL_VOL,d0
		bne	rehash_real_directory_next

		*  ����ȏ�̌����́A�x���Ȃ�̂ŁA���Ȃ��B

		lea	files_buf+ST_NAME(a6),a0
		bsr	hash
		bset.b	d2,(a4,d0.l)
rehash_real_directory_next:
		pea	files_buf(a6)
		DOS	_NFILES
		addq.l	#4,a7
		bra	rehash_real_directory_loop

rehash_real_directory_done:
		movea.l	a3,a1
		bra	rehash_continue
****************
rehash_builtin:
		lea	builtin_table,a2
rehash_builtin_loop:
		move.l	(a2),d0
		beq	rehash_next

		movea.l	d0,a0
		bsr	hash
		bset.b	d2,(a4,d0.l)
		lea	10(a2),a2
		bra	rehash_builtin_loop
****************
rehash_next:
		movea.l	a1,a0
		bsr	strfor1
		movea.l	a0,a1
rehash_continue:
		addq.w	#1,d2
rehash_start:
		dbra	d1,rehash_loop
rehash_done:
		movem.l	(a7)+,d0-d2/a0-a4
		unlk	a6
		st	hash_flag(a5)
		rts
****************************************************************
.xdef cmd_rehash

cmd_rehash:
		tst.w	d0
		bne	too_many_args

		bsr	rehash
		moveq	#0,d0
		rts
****************************************************************
.xdef cmd_unhash

cmd_unhash:
		tst.w	d0
		bne	too_many_args

		sf	hash_flag(a5)
		moveq	#0,d0
		rts
****************************************************************
.xdef cmd_hashstat

cmd_hashstat:
		tst.w	d0
		bne	too_many_args

		moveq	#0,d1				*  �E�l�߂�
		moveq	#' ',d2				*  pad�͋󔒂�
		moveq	#1,d3				*  ���Ȃ��Ƃ� 1�����̕���
		moveq	#1,d4				*  ���Ȃ��Ƃ� 1���̐�����
		lea	msg_status,a0
		bsr	puts
		lea	msg_on,a0
		tst.b	hash_flag(a5)
		bne	put_status

		lea	msg_off,a0
put_status:
		bsr	puts
		lea	msg_hits,a0
		bsr	puts
		move.l	hash_hits(a5),d0
		bsr	printu
		lea	msg_misses,a0
		bsr	puts
		move.l	hash_misses(a5),d0
		bsr	printu
		lea	msg_ratio,a0
		bsr	puts

		move.l	hash_hits(a5),d0
		beq	cmd_hashstat_2

		move.l	#100,d1
		bsr	mulul
		move.l	hash_hits(a5),d1
		add.l	hash_misses(a5),d1
		bsr	divul
cmd_hashstat_2:
		moveq	#0,d1				*  �E�l�߂�
		bsr	printu
		lea	msg_percent,a0
		bsr	nputs
cmd_hashstat_done:
		moveq	#0,d0
		rts
****************************************************************
.data

msg_status:	dc.b	'���: ',0
msg_on:		dc.b	'on',0
msg_off:	dc.b	'off',0
msg_hits:	dc.b	', �q�b�g: ',0
msg_misses:	dc.b	'��, �~�X: ',0
msg_ratio:	dc.b	'��, �q�b�g��: ',0
msg_percent:	dc.b	'%',0

.end

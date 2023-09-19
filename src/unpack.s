* unpack.s
* Itagaki Fumihiko 23-Sep-90  Create.

.include limits.h
.include pwd.h
.include ../src/fish.h

.xref iscsym
.xref atou
.xref qstrchr
.xref strfor1
.xref memmovi
.xref no_close_brace
.xref open_passwd
.xref fgetpwnam
.xref close_tmpfd
.xref getcwd
.xref get_dstack_d0
.xref word_home
.xref find_shellvar
.xref get_var_value
.xref copyhead
.xref strlen
.xref pre_perror
.xref enputs
.xref too_long_word
.xref too_long_line
.xref too_many_words
.xref dstack_not_deep

.xref tmpline

.xref tmpfd

.text

****************************************************************
* unpack1 - unpack_word �̍ċA����
*
* CALL
*      A0     �W�J�����̈ʒu���w��
*      A1     �W�J����o�b�t�@�̈ʒu���w��
*      A2     �������́C�W�J������̐擪���w��
*      D6.W   �W�J����o�b�t�@�̎c��e��
*      D7.W   �W�J������̌��x
*
* RETURN
*      D0.L    0  ����
*             -1  �W�J�������x�𒴂���
*             -2  �o�b�t�@�̗e�ʂ𒴂���
*             -4  } �������i���b�Z�[�W���\�������j
*
*      D1.W   �W�J������������������
*             D1>D7 �ƂȂ�悤�Ȃ�� D0.L �� 1 ���Z�b�g���ď����𒆎~����
*
*      D6.W   �W�J����o�b�t�@�̎c��e��
*      A1     �o�b�t�@�̎��̊i�[�ʒu
*      A0     �j��
*      CCR    TST.L D0
*
* NOTE
*      �������ɍċA����D�X�^�b�N�ɒ��ӁI
****************************************************************
unpack1:
		move.l	a0,-(a7)
		moveq	#'{',d0
		bsr	qstrchr
		move.l	a0,d0
		movea.l	(a7)+,a0
		sub.l	a0,d0
		sub.w	d0,d6
		bcs	unpack1_buffer_over

		exg	a0,a1
		bsr	memmovi
		exg	a0,a1
		tst.b	(a0)+
		bne	after_brace

		subq.w	#1,d6
		bcs	unpack1_buffer_over

		clr.b	(a1)+
		addq.w	#1,d1
		moveq	#0,d0
		rts

unpack1_buffer_over:
		moveq	#-2,d0
		rts

after_brace:
		movem.l	d2-d3/a2-a3,-(a7)
		move.l	a1,d2
		sub.l	a2,d2
		movea.l	a0,a3
		moveq	#'}',d0
		bsr	qstrchr
		exg	a0,a3
		move.l	a3,d3
		tst.b	(a3)
		beq	exp_brace_no_close_brace

		addq.l	#1,d3
exp_brace_1:
		move.l	a0,-(a7)
		move.b	(a3),d0
		move.w	d0,-(a7)
		clr.b	(a3)
		moveq	#',',d0
		bsr	qstrchr
		move.w	(a7)+,d0
		move.b	d0,(a3)
		move.l	a0,d0
		movea.l	(a7)+,a0
		sub.l	a0,d0
		sub.w	d0,d6
		bcs	exp_brace_buffer_over

		exg	a0,a1
		bsr	memmovi
		exg	a0,a1

		move.l	a0,-(a7)
		movea.l	d3,a0
		bsr	unpack1
		movea.l	(a7)+,a0
		bne	exp_brace_return

		cmpa.l	a3,a0
		beq	exp_brace_done

		cmp.w	d7,d1
		bhs	exp_brace_too_many

		sub.w	d2,d6
		bcs	exp_brace_buffer_over

		addq.l	#1,a0
		move.l	a0,-(a7)
		movea.l	a1,a0
		movea.l	a2,a1
		move.l	d2,d0
		movea.l	a0,a2
		bsr	memmovi
		movea.l	a0,a1
		movea.l	(a7)+,a0
		bra	exp_brace_1

exp_brace_done:
		tst.b	(a0)
		beq	exp_brace_return

		addq.l	#1,a0
exp_brace_return:
		movem.l	(a7)+,d2-d3/a2-a3
		tst.l	d0
		rts

exp_brace_too_many:
		moveq	#-1,d0
		bra	exp_brace_return

exp_brace_buffer_over:
		moveq	#-2,d0
		bra	exp_brace_return

exp_brace_no_close_brace:
		bsr	no_close_brace
		moveq	#-4,d0
		bra	exp_brace_return
****************************************************************
* unpack_word - {} �̏ȗ��L�@��W�J����
*
* CALL
*      A0     {} ���܂ތ�̐擪�A�h���X�D��� ', " and/or \ �ɂ��N�I�[�g���D
*             ��̒����� MAXWORDLEN �ȓ��ł��邱�ƁD
*
*      A1     �W�J����o�b�t�@�̃A�h���X
*      D0.W   �W�J������̌��x
*      D1.W   �o�b�t�@�̗e��
*
* RETURN
*      A1     �o�b�t�@�̎��̊i�[�ʒu
*
*      D0.L   �����Ȃ�ΐ����D���̂Ƃ����ʃ��[�h�͓W�J�������D
*             �����Ȃ�΃G���[�D
*                  -1  �W�J�������x�𒴂���
*                  -2  �o�b�t�@�̗e�ʂ𒴂���
*                  -4  } �������i���b�Z�[�W���\�������j
*
*      D1.L   ���ʃ��[�h�͎c��o�b�t�@�e��
*             ��ʃ��[�h�͔j��
*
*      CCR    TST.L D0
*****************************************************************
.xdef unpack_word

unpack_word:
		movem.l	d6-d7/a0/a2,-(a7)
		move.w	d0,d7
		moveq	#-1,d0
		tst.w	d7
		beq	unpack_word_return

		moveq	#2,d6
		cmpi.b	#'{',(a0)
		bne	unpack_word_go

		tst.b	1(a0)
		beq	unpack_word_dont

		cmpi.b	#'}',1(a0)
		bne	unpack_word_go

		tst.b	2(a0)
		bne	unpack_word_go

		addq.w	#1,d6
unpack_word_dont:
		moveq	#-2,d0
		sub.w	d6,d1
		bcs	unpack_word_return

		move.l	d6,d0
		exg	a0,a1
		bsr	memmovi
		exg	a0,a1
		moveq	#1,d0
		bra	unpack_word_return

unpack_word_go:
		move.w	d1,d6
		movea.l	a1,a2
		moveq	#0,d1
		bsr	unpack1
		bne	unpack_word_success

		move.w	d1,d0
unpack_word_success:
		move.w	d6,d1
unpack_word_return:
		movem.l	(a7)+,d6-d7/a0/a2
		tst.l	d0
		rts
****************************************************************
check_slash:
		move.b	(a0),d0
		beq	check_slash_return

		cmp.b	#'\',d0
		bne	check_slash_1

		move.b	1(a0),d0
check_slash_1:
		cmp.b	#'/',d0
		beq	check_slash_return

		cmp.b	#'\',d0
check_slash_return:
		rts
****************************************************************
* expand_tilde - ~ �� = ��W�J����
*
* CALL
*      A0     ~ �܂��� = �Ŏn�܂��Ă���i��������Ȃ��j�P��̐擪�A�h���X
*      A1     �W�J����o�b�t�@�̃A�h���X
*      D1.W   �o�b�t�@�̗e��
*      D2.B   0 �Ȃ�΁A�G���[�R�[�h -4 �̃G���[�E���b�Z�[�W�o�͂�}�~����
*
* RETURN
*      A0     ���̒P��̐擪�A�h���X
*      A1     �o�b�t�@�̎��̊i�[�ʒu
*
*      D0.L
*              0  OK
*             -2  �o�b�t�@�̗e�ʂ𒴂���
*             -3  �P��̒������K��𒴂���
*             -4  ���̑��̃G���[�i���b�Z�[�W���\�������j
*
*      D1.L   ���ʃ��[�h�͎c��o�b�t�@�e��
*             ��ʃ��[�h�͔j��
*
*      CCR    TST.L D0
*****************************************************************
.xdef expand_tilde

pwd_buf = -(((PW_SIZE+1)+1)>>1<<1)
cwd_buf = pwd_buf-(((MAXPATH+1)+1)>>1<<1)

expand_tilde:
		link	a6,#cwd_buf
		movem.l	d4-d6/a2-a3,-(a7)
		move.w	d1,d6
		move.w	#MAXWORDLEN,d5
		movea.l	a0,a2

		move.b	(a0)+,d0
		cmp.b	#'~',d0
		beq	maybe_home_directory

		cmp.b	#'=',d0
		bne	expand_tilde_go
****************
****************
maybe_directory_stack:
		bsr	atou
		bmi	expand_tilde_go

		move.l	d0,d4
		bsr	check_slash
		bne	expand_tilde_go

		tst.l	d4
		bne	expand_tilde_dstack_not_deep

		movea.l	a0,a2
		move.l	d1,d0
		beq	expand_tilde_cwd

		bsr	get_dstack_d0
		bhi	expand_tilde_dstack_not_deep

		bra	expand_tilde_copy_dir
****************
expand_tilde_cwd:
		lea	cwd_buf(a6),a0
		bsr	getcwd
		bra	expand_tilde_copy_dir
****************
****************
maybe_home_directory:
skip_username_loop:
		move.b	(a0)+,d0
		bsr	iscsym
		beq	skip_username_loop

		cmp.b	#'-',d0
		beq	skip_username_loop

		subq.l	#1,a0
		bsr	check_slash
		bne	expand_tilde_go

		addq.l	#1,a2				*  A2 �� ~ �̎����w��
		move.l	a0,d1
		sub.l	a2,d1				*  D1.L : username �̒���
		beq	expand_tilde_myhome
****************
		exg	a0,a2				*  A0 : ���[�U���̐擪  A2 : ���[�U���̎�

		bsr	open_passwd
		bmi	expand_tilde_unknown_user	*  �p�X���[�h�E�t�@�C��������

		move.l	d0,tmpfd(a5)
		movem.l	a0-a1,-(a7)
		movea.l	a0,a1
		lea	pwd_buf(a6),a0
		bsr	fgetpwnam
		movem.l	(a7)+,a0-a1
		bsr	close_tmpfd
		tst.l	d0
		bne	expand_tilde_unknown_user

		lea	pwd_buf(a6),a0
		lea	PW_DIR(a0),a0
		bra	expand_tilde_copy_dir
****************
expand_tilde_myhome:
		lea	word_home,a0			*  �V�F���ϐ� home ��
		bsr	find_shellvar			*  ��`�����
		beq	expand_tilde_go			*  ���Ȃ���΁A~�ȍ~���R�s�[����̂�

		bsr	get_var_value
		beq	expand_tilde_go			*  $#home �� 0 �Ȃ�΁A~�ȍ~���R�s�[����̂�
****************
expand_tilde_copy_dir:
		move.w	d6,d0
		exg	a0,a1
		bsr	copyhead			*  �z�[���E�f�B���N�g�������o�b�t�@�ɃR�s�[����
		exg	a0,a1
		tst.l	d0
		bmi	expand_tilde_buffer_over

		move.w	d6,d4
		sub.w	d0,d4
		sub.w	d4,d5
		bcs	expand_tilde_too_long

		move.w	d0,d6				*  D6.W : �o�b�t�@�̎c��e��
		btst	#0,d1				*  / �ŏI�����
		beq	expand_tilde_go			*  ���Ȃ��Ȃ�� ~�ȍ~����������

		tst.b	(a2)				*  ~�ȍ~����Ȃ��
		beq	expand_tilde_go			*  ��������

		*  �Ō�� / ���폜���� ~ �ȍ~����������
		subq.l	#1,a1
		addq.w	#1,d6
		addq.w	#1,d5
****************
expand_tilde_go:
		movea.l	a2,a0
		bsr	strlen
		sub.w	d0,d5
		bcs	expand_tilde_too_long

		addq.l	#1,d0
		sub.w	d0,d6
		bcs	expand_tilde_buffer_over

		exg	a0,a1
		bsr	memmovi
		exg	a0,a1
		moveq	#0,d0
expand_tilde_return:
		move.w	d6,d1
		movem.l	(a7)+,d4-d6/a2-a3
		unlk	a6
		tst.l	d0
		rts

expand_tilde_buffer_over:
		moveq	#-2,d0
		bra	expand_tilde_return

expand_tilde_too_long:
		moveq	#-3,d0
		bra	expand_tilde_return

expand_tilde_unknown_user:
		tst.b	d2
		beq	expand_tilde_passwd_error_1

		move.b	(a2),d0
		clr.b	(a2)
		bsr	pre_perror
		move.b	d0,(a2)
		lea	msg_unknown_user,a0
		bsr	enputs
expand_tilde_passwd_error_1:
		movea.l	a2,a0
		moveq	#-4,d0
		bra	expand_tilde_return

expand_tilde_dstack_not_deep:
		bsr	dstack_not_deep
		bra	expand_tilde_passwd_error_1
****************************************************************
* unpack_wordlist - �������т̊e��ɂ��� ~ {} ��W�J����
*
* CALL
*      A0     �i�[�̈�̐擪�D�������тƏd�Ȃ��Ă��Ă��ǂ��D
*      A1     �������т̐擪
*      D0.W   �ꐔ
*
* RETURN
*      (tmpline)   �j�󂳂��
*
*      D0.L   �����Ȃ�ΐ����D���ʃ��[�h�͓W�J��̌ꐔ
*             �����Ȃ�΃G���[
*      CCR    TST.L D0
****************************************************************
.xdef unpack_wordlist

unpack_wordlist:
		movem.l	d1-d4/a0-a2,-(a7)
		movea.l	a0,a2			* �i�[����A�h���X��A2�ɑҔ�
		movea.l	a1,a0			* A0 : ��������
		lea	tmpline(a5),a1		* ��U {} ���ꎞ�̈�ɓW�J����
		move.w	#MAXWORDLISTSIZE,d1	* D1 : �ő啶����
		move.w	d0,d4			* D4 : �����J�E���^
		moveq	#0,d3			* D3 : �W�J��̌ꐔ
		bra	unpack_wordlist_continue

unpack_wordlist_loop:
		move.w	#MAXWORDS,d0
		sub.w	d3,d0
		bsr	unpack_word
		bmi	unpack_wordlist_error

		add.w	d0,d3
		bsr	strfor1
unpack_wordlist_continue:
		dbra	d4,unpack_wordlist_loop
****************
		lea	tmpline(a5),a0
		movea.l	a2,a1
		move.w	#MAXWORDLISTSIZE,d1	* D1 : �ő啶����
		move.w	d3,d4			* D4 : �����J�E���^
		moveq	#1,d2			* D2 = 1 : Unknown user ���b�Z�[�W��}�~���Ȃ�
		bra	expand_tilde_wordlist_continue

expand_tilde_wordlist_loop:
		bsr	expand_tilde
		bmi	unpack_wordlist_error

expand_tilde_wordlist_continue:
		dbra	d4,expand_tilde_wordlist_loop
****************
		moveq	#0,d0
		move.w	d3,d0
unpack_wordlist_return:
		movem.l	(a7)+,d1-d4/a0-a2
		tst.l	d0
		rts
****************
unpack_wordlist_error:
		cmp.l	#-1,d0
		beq	unpack_wordlist_too_many_words

		cmp.l	#-2,d0
		beq	unpack_wordlist_buffer_over

		cmp.l	#-3,d0
		bne	unpack_wordlist_error_return

		bsr	too_long_word
		bra	unpack_wordlist_error_return

unpack_wordlist_buffer_over:
		bsr	too_long_line
		bra	unpack_wordlist_error_return

unpack_wordlist_too_many_words:
		bsr	too_many_words
unpack_wordlist_error_return:
		moveq	#-1,d0
		bra	unpack_wordlist_return

.data

msg_unknown_user:	dc.b	'���̂悤�ȃ��[�U�͓o�^����Ă��܂���',0

.end

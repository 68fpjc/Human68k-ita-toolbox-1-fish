* unpack.s
* Itagaki Fumihiko 23-Sep-90  Create.

.include ../src/fish.h

.xref qstrchr
.xref memmove_inc
.xref no_close_brace
.xref islower
.xref isdigit
.xref open_passwd
.xref findpwent
.xref fseek_nextfield
.xref fgets
.xref fclose
.xref strchr
.xref word_home
.xref find_shellvar
.xref for1str
.xref copyhead
.xref strlen
.xref pre_perror
.xref enputs
.xref too_long_word
.xref too_long_line
.xref too_many_words
.xref tmpline
.xref congetbuf

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
		bsr	memmove_inc
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
		bsr	memmove_inc
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
		bsr	memmove_inc
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
		bsr	memmove_inc
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
*****************************************************************
* skip_username - skip user name
*
* CALL
*      A0     string point
*
* RETURN
*      A0     points first non-username-character point
*****************************************************************
skip_username:
		move.w	d0,-(a7)
		move.b	(a0)+,d0
		bsr	islower
		bne	skip_username_done

skip_username_loop:
		move.b	(a0)+,d0
		bsr	islower
		beq	skip_username_loop

		bsr	isdigit
		beq	skip_username_loop
skip_username_done:
		subq.l	#1,a0
		move.w	(a7)+,d0
		rts
****************************************************************
* expand_tilde - ~ ��W�J����
*
* CALL
*      A0     ~ �Ŏn�܂��Ă���P��̐擪�A�h���X
*      A1     �W�J����o�b�t�@�̃A�h���X
*      D1.W   �o�b�t�@�̗e��
*      D2.B   0 �Ȃ�΁A�G���[�R�[�h -4 �̃G���[���b�Z�[�W�o�͂�}�~����
*
* RETURN
*      A0     ���̒P��̐擪�A�h���X
*      A1     �o�b�t�@�̎��̊i�[�ʒu
*
*      D0.L
*              0  OK
*             -2  �o�b�t�@�̗e�ʂ𒴂���
*             -3  �P��̒������K��𒴂���
*             -4  �w��̃��[�U���͒m��Ȃ��i���b�Z�[�W���\�������j
*
*      D1.L   ���ʃ��[�h�͎c��o�b�t�@�e��
*             ��ʃ��[�h�͔j��
*
*      CCR    TST.L D0
*****************************************************************
.xdef expand_tilde

expand_tilde:
		movem.l	d4-d6/a2-a3,-(a7)
		move.w	d1,d6
		move.w	#MAXWORDLEN,d5
		movea.l	a0,a2

		cmpi.b	#'~',(a0)+
		bne	expand_tilde_go

		bsr	skip_username
		move.b	(a0),d0
		beq	expand_tilde_home

		cmp.b	#'\',d0
		bne	expand_tilde_1

		move.b	1(a0),d0
expand_tilde_1:
		cmp.b	#'/',d0
		beq	expand_tilde_home

		cmp.b	#'\',d0
		bne	expand_tilde_go
expand_tilde_home:
		addq.l	#1,a2			* A2 �� ~ �̎����w��
		move.l	a0,d1
		sub.l	a2,d1			* D1.L : username �̒���
		beq	expand_tilde_myhome
****************
		exg	a0,a2			* A0 : ���[�U���̐擪  A2 : ���[�U���̎�

		bsr	open_passwd
		bmi	expand_tilde_unknown_user	* �m�b��n�p�X���[�h�E�t�@�C��������

		move.w	d0,d4		* D4.W : �p�X���[�h�E�t�@�C���̃t�@�C���E�n���h��
		bsr	findpwent
		bmi	find_user_fail

		moveq	#3,d1			*  password:uid:gid:GCOS: �𒵂΂�
goto_home_field:
		move.w	d4,d0
		bsr	fseek_nextfield
		bmi	find_user_fail
		bne	expand_tilde_go		* �m�b��n�t�B�[���h������Ȃ��F���[�U���ȍ~���R�s�[����

		dbra	d1,goto_home_field

		lea	congetbuf+2,a0
		move.w	#255,d1
		move.w	d4,d0
		bsr	fgets
		bmi	find_user_fail

		exg	d0,d4
		bsr	fclose
		tst.l	d4
		bne	expand_tilde_go		* �m�b��n�s�����߂���F���[�U���ȍ~���R�s�[����

		lea	congetbuf+2,a0
		moveq	#';',d0
		bsr	strchr
		clr.b	(a0)
		lea	congetbuf+2,a0
		bra	expand_tilde_copy_home
****************
expand_tilde_myhome:
		lea	word_home,a0		* �V�F���ϐ� home ��
		bsr	find_shellvar		* ��`�����
		beq	expand_tilde_go		* ���Ȃ���΁A~�ȍ~���R�s�[����̂�

		addq.l	#2,a0
		move.w	(a0)+,d0		* $#home ��
		beq	expand_tilde_go		* 0 �Ȃ�΁A~�ȍ~���R�s�[����̂�

		bsr	for1str			* �ϐ������X�L�b�v���� $home[1]�𓾂�
****************
expand_tilde_copy_home:
		move.w	d6,d0
		exg	a0,a1
		bsr	copyhead		* �z�[���E�f�B���N�g�������o�b�t�@�ɃR�s�[����
		exg	a0,a1
		tst.w	d0
		bmi	expand_tilde_buffer_over

		move.w	d6,d4
		sub.w	d0,d4
		sub.w	d4,d5
		bcs	expand_tilde_too_long

		move.w	d0,d6			* D6.W : �o�b�t�@�̎c��e��
		tst.b	d1			* �R�s�[�����f�B���N�g���������[�g
		beq	expand_tilde_go		* �łȂ��Ȃ�� ~�ȍ~����������

		tst.b	(a2)			* ~�ȍ~����Ȃ��
		beq	expand_tilde_go		* ��������

		subq.l	#1,a1			* �f�B���N�g�����i���[�g�f�B���N�g���ł���j
		addq.w	#1,d6			* �� / ���폜����
		addq.w	#1,d5			* ~�ȍ~����������
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
		bsr	memmove_inc
		exg	a0,a1
		moveq	#0,d0
expand_tilde_return:
		move.w	d6,d1
		movem.l	(a7)+,d4-d6/a2-a3
		tst.l	d0
		rts

expand_tilde_buffer_over:
		moveq	#-2,d0
		bra	expand_tilde_return

expand_tilde_too_long:
		moveq	#-3,d0
		bra	expand_tilde_return

find_user_fail:
		move.w	d4,d0
		bsr	fclose
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
		lea	tmpline,a1		* ��U {} ���ꎞ�̈�ɓW�J����
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
		bsr	for1str
unpack_wordlist_continue:
		dbra	d4,unpack_wordlist_loop
****************
		lea	tmpline,a0
		movea.l	a2,a1
		move.w	#MAXWORDLISTSIZE,d1	* D1 : �ő啶����
		move.w	d3,d4			* D4 : �����J�E���^
		moveq	#1,d2			* D2 = 1 : Unknown user ���b�Z�[�W��}�~���Ȃ�
expand_tilde_wordlist_loop:
		bsr	expand_tilde
		bmi	unpack_wordlist_error

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
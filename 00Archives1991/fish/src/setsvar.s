* setsvar.s
* Itagaki Fumihiko 24-Oct-90  Create.

.xref strcmp
.xref for1str
.xref copychar_export_pathname
.xref rehash
.xref set_var
.xref unset_var
.xref setenv
.xref flagvarptr
.xref is_builtin_dir
.xref command_error
.xref str_nul
.xref str_current_dir
.xref word_path
.xref word_temp
.xref word_user
.xref word_upper_user
.xref word_term
.xref word_upper_term
.xref word_home
.xref word_upper_home
.xref shellvar
.xref tmpargs

.text

****************************************************************
* set_svar - �V�F���ϐ����`����
*
* CALL
*      A0     �ϐ����̐擪�A�h���X
*      A1     �l�̌���т̐擪�A�h���X
*      D0.W   �l�̌ꐔ
*      D1.B   0 : export���Ȃ�
*
* RETURN
*      D0.L   0:����  1:���s
*      CCR    TST.L D0
****************************************************************
.xdef set_svar
.xdef set_svar_nul

set_svar_nul:
		lea	str_nul,a1
		moveq	#1,d0
set_svar:
		movem.l	d1-d2/a0-a4,-(a7)
		movea.l	a1,a2			*  A2 : value
		movea.l	a0,a1			*  A1 : name
		move.w	d0,d2			*  D2.W : number of words
		movea.l	shellvar,a0
		bsr	set_var
		bne	no_space_in_shellvar
****************
		exg	a0,a1
		bsr	flagvarptr
		exg	a0,a1
		beq	not_flagvar

		movea.l	d0,a0
		move.b	#1,(a0)
		bra	set_svar_return0

not_flagvar:
		tst.b	d1			* �G�N�X�|�[�g���֎~����Ă���Ȃ��
		beq	set_svar_return0	* ����

		lea	tmpargs,a3		*  A3 : temporaly
		*
		*  �V�F���ϐ� path ���Đݒ肳�ꂽ�Ȃ�΁A
		*  �n�b�V���\���X�V���A
		*  ���ϐ� path �ɃG�N�X�|�[�g����B
		*
		lea	word_path,a4
		movea.l	a4,a0
		bsr	strcmp
		bne	not_path

		bsr	rehash
		movea.l	a2,a1			*  A1 : value
		bra	export_continue_build

not_path:
		*
		*  �V�F���ϐ� temp ���Đݒ肳�ꂽ�Ȃ�΁A���ϐ� temp �ɃG�N�X�|�[�g����
		*
		lea	word_temp,a4
		movea.l	a4,a0
		bsr	strcmp
		beq	export
		*
		*  �V�F���ϐ� user ���Đݒ肳�ꂽ�Ȃ�΁A���ϐ� USER �ɃG�N�X�|�[�g����
		*
		lea	word_upper_user,a4
		lea	word_user,a0
		bsr	strcmp
		beq	export
		*
		*  �V�F���ϐ� term ���Đݒ肳�ꂽ�Ȃ�΁A���ϐ� TERM �ɃG�N�X�|�[�g����
		*
		lea	word_upper_term,a4
		lea	word_term,a0
		bsr	strcmp
		beq	export
		*
		*  �V�F���ϐ� home ���Đݒ肳�ꂽ�Ȃ�΁A���ϐ� HOME �ɃG�N�X�|�[�g����
		*
		lea	word_upper_home,a4
		lea	word_home,a0
		bsr	strcmp
		beq	export
set_svar_return0:
		moveq	#0,d0
		bra	set_svar_return
****************
export:
		movea.l	a2,a1			*  A1 : value
		tst.w	d2
		beq	do_export

		moveq	#0,d2
		bra	dup_a_word

build_loop:
		lea	str_current_dir,a0
		bsr	strcmp
		beq	build_ignore_this

		exg	a0,a1
		bsr	is_builtin_dir
		exg	a0,a1
		beq	build_ignore_this

		tst.b	d1
		bne	dup_a_word

		move.b	#';',(a3)+
dup_a_word:
		exg	a0,a3
		bsr	copychar_export_pathname
		exg	a0,a3
		moveq	#0,d1
		bra	export_continue_build

build_ignore_this:
		exg	a0,a1
		bsr	for1str
		exg	a0,a1
export_continue_build:
		dbra	d2,build_loop
do_export:
		clr.b	(a3)
		lea	tmpargs,a1
		movea.l	a4,a0
		bsr	setenv
set_svar_return:
		movem.l	(a7)+,d1-d2/a0-a4
		rts
****************
no_space_in_shellvar:
		moveq	#0,d0
		bsr	unset_var
		lea	msg_no_space,a0
		bsr	command_error
		bra	set_svar_return
****************************************************************
.data

msg_no_space:	dc.b	'�V�F���ϐ��L���̈�̗e�ʂ�����܂���',0

.end

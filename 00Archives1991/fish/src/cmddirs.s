* cmddirs.s
* This contains built-in command 'cd'('chdir'), 'dirs', 'popd', 'pushd'.
*
* Itagaki Fumihiko 06-Oct-90  Create.

.include limits.h
.include ../src/fish.h

.xref for1str
.xref rotate
.xref putc
.xref chdir
.xref chdirx
.xref find_shellvar
.xref getcwd
.xref set_svar
.xref perror
.xref strlen
.xref command_error
.xref bad_arg
.xref strcmp
.xref puts
.xref put_space
.xref echo
.xref put_newline
.xref usage
.xref atou
.xref fornstrs
.xref memmove_dec
.xref strcpy
.xref memmove_inc
.xref isabsolute
.xref toupper
.xref issjis
.xref tolower
.xref too_many_args
.xref word_home
.xref msg_no_home
.xref dstack

.text

cwdbuf = -(((MAXPATH+1)+1)>>1<<1)

****************************************************************
*  Name
*       cd - change working directory
*
*  Synopsis
*       cd                go to home directory
*       cd +n             go to n'th of directory stack
*	cd name           go to name
****************************************************************
.xdef cmd_cd
.xdef reset_cwd

cmd_cd:
		cmp.w	#1,d0			* ������
		beq	cd_arg			* �P����Ȃ�Ύw��̃f�B���N�g����chdir����
		bhi	too_many_args		* �Q�ȏ゠��΃G���[

		lea	word_home,a0		* �V�F���ϐ� home ��
		bsr	find_shellvar		* �T��
		beq	no_home			* ������΃G���[

		lea	2(a0),a0
		move.w	(a0)+,d1		* D1.W : �P�ꐔ  A0 : �l
		beq	no_home

		bsr	for1str			* $home[1]��
		tst.b	(a0)
		beq	no_home

		bsr	chdir			* chdir����
		bmi	fail
		bra	chdir_success
****************
cd_arg:
		cmpi.b	#'+',(a0)		* ������'+'�Ŏn�܂�Ȃ��Ȃ��
		bne	cd_name			* ����cd_name��

		bsr	get_dstack_element	* ���l-1��D1.L�ɁA�����v�f�̃A�h���X��A0�ɓ���
		bne	cd_return

		bsr	popd_sub		* �����Ɉړ����Ă��̗v�f���폜����
		bne	cd_return

		tst.l	d1
		beq	cd_dirs_done		* ���ɏ��񂳂�Ă���

		addq.w	#1,d1
		movea.l	dstack,a1
		cmp.w	8(a1),d1
		bhi	cd_dirs_done		* ���ɏ��񂳂�Ă���

		exg	a0,a1
		move.l	4(a0),d0
		lea	(a0,d0.l),a2		* A2 := ���݂̖����A�h���X�i�{�P�j
		lea	10(a0),a0		* A0 := �擪�̗v�f
		bsr	rotate			* �v�f�����񂷂�
cd_dirs_done:
		bsr	print_dirs		* �f�B���N�g���E�X�^�b�N��\��
		bra	chdir_success
****************
cd_name:
		bsr	chdirx			* �w��̃f�B���N�g����chdirx����
		bmi	fail			* ���s�����Ȃ�΃G���[������
		beq	chdir_success

		bsr	pwd
chdir_success:
		moveq	#0,d0
****************
cd_return:
reset_cwd:
		link	a6,#cwdbuf
		movem.l	d0/a0,-(a7)
		lea	cwdbuf(a6),a0
		bsr	getcwd
		movea.l	a0,a1
		lea	word_cwd,a0
		moveq	#1,d0
		moveq	#0,d1
		bsr	set_svar
		movem.l	(a7)+,d0/a0
		unlk	a6
		rts
****************
fail:
		bsr	perror
		moveq	#1,d0
		bra	cd_return
****************************************************************
*  Name
*       pushd - push directory stack
*
*  Synopsis
*       pushd             exchange current and top
*       pushd +n          rotate to let n'th be top
*	pushd directory   push current and chdir to directory
****************************************************************
.xdef cmd_pushd

cmd_pushd:
		link	a6,#cwdbuf
		movea.l	a0,a1
		move.w	d0,d1			* argc ���Z�[�u

		lea	cwdbuf(a6),a0		* cwdbuf��
		bsr	getcwd			* �J�����g�f�B���N�g���𓾂�
		bsr	strlen			* ���̒�����
		addq.l	#1,d0
		move.l	d0,d7			* D7.L�ɕۑ�����

		move.w	d1,d0			* argc ���|�b�v
		beq	exchange		* �����������Ȃ�擪�v�f�ƃJ�����g����������

		cmp.w	#1,d0			* �������Q�ȏ゠���
		bhi	pushd_too_many_args	* 'Too many args'�G���[��

		cmpi.b	#'+',(a1)		* ������'+'�Ŏn�܂�Ȃ��Ȃ��
		bne	push_new		* ����push_new��

		movea.l	a1,a0
		bsr	get_dstack_element	* ���l�������v�f�̃A�h���X��A0�ɓ���
		bne	cmd_pushd_return	* ���s�����Ȃ炨���܂�

		movem.l	d1/a0,-(a7)
		bsr	pushd_exchange_sub	* A0�������v�f�ƃJ�����g�E�f�B���N�g��������
		movem.l	(a7)+,d1/a0
		bne	cmd_pushd_return	* ���s�����Ȃ炨���܂�

		*  �X�^�b�N�̗v�f�����񂷂�
		bsr	for1str
		movea.l	a0,a1

		addq.w	#1,d1
		movea.l	dstack,a0
		cmp.w	8(a0),d1
		bhs	cmd_pushd_done		* ���ɏ��񂳂�Ă���

		move.l	4(a0),d0
		lea	(a0,d0.l),a2		* A2 := ���݂̖����A�h���X�i�{�P�j
		lea	10(a0),a0		* A0 := �擪�̗v�f
		bsr	rotate			* �O���ƌ㔼�����ւ���
		bra	cmd_pushd_done
****************
exchange:
		movea.l	dstack,a0
		tst.w	8(a0)			* �X�^�b�N�ɗv�f�������Ȃ��
		beq	pushd_empty		* �G���[

		lea	10(a0),a0		* �擪�̗v�f��
		bsr	pushd_exchange_sub	* �J�����g�E�f�B���N�g������������
		bne	cmd_pushd_return	* ���s�����Ȃ炨���܂�

		bra	cmd_pushd_done
****************
push_new:
		movea.l	dstack,a0
		cmpi.w	#MAXWORDS,8(a0)
		bhs	pushd_too_many_elements

		move.l	4(a0),d0		* �X�^�b�N�̒�����
		add.l	d7,d0			* �J�����g�E�f�B���N�g���̒������������
		cmp.l	(a0),d0			* �X�^�b�N�̗e�ʂ𒴂���Ȃ��
		bhi	pushd_stack_full	* �G���[

		movea.l	a1,a0			* �w�肳�ꂽ�f�B���N�g����
		bsr	chdirx			* �ړ�����
		bmi	pushd_perror_return

		bsr	push_cwd		* �ȑO�̃J�����g�E�f�B���N�g�����v�b�V������
cmd_pushd_done:
		bsr	print_dirs		* �X�^�b�N��\������
cmd_pushd_return:
		bsr	reset_cwd
		unlk	a6
		rts
****************
pushd_too_many_args:
		bsr	too_many_args
		bra	cmd_pushd_return
****************
pushd_too_many_elements:
		lea	msg_too_deep,a0
		bsr	command_error
		bra	cmd_pushd_return
****************
pushd_stack_full:
		bsr	stack_full
		bra	cmd_pushd_return
****************
pushd_empty:
		bsr	dstack_empty
		bra	cmd_pushd_return
****************
pushd_perror_return:
		bsr	perror
		moveq.l	#1,d0
		bra	cmd_pushd_return
****************************************************************
*  Name
*       popd - pop directory stack
*
*  Synopsis
*       popd       pop top
*       popd +n    drop n'th
****************************************************************
.xdef cmd_popd

cmd_popd:
		cmp.w	#1,d0			* �������Q�ȏ゠���
		bhi	too_many_args		* �G���[
		blo	pop			* �����������Ȃ�|�b�v

		cmpi.b	#'+',(a0)		* ������'+'�Ŏn�܂�Ȃ��Ȃ��
		bne	bad_arg			* �G���[

		movea.l	a0,a1
		bsr	get_dstack_element	* ���l�������v�f�̃A�h���X��A0�ɓ���
		bne	popd_return		* �G���[�Ȃ�΂����܂�

		bsr	popd_sub_delete		* �v�f���폜����
		bra	pop_done

pop:
		movea.l	dstack,a0
		lea	8(a0),a0
		tst.w	(a0)+			* �X�^�b�N�ɗv�f�������Ȃ��
		beq	dstack_empty		* �G���[

		bsr	popd_sub		* �v�f�Ɉړ����č폜����
		bne	popd_return		* ���s�Ȃ�΋A��
pop_done:
		bsr	print_dirs		* �X�^�b�N��\��
popd_return:
		bra	reset_cwd
****************************************************************
*  Name
*       dirs - print directory stack
*
*  Synopsis
*       dirs [ -l ]
****************************************************************
.xdef cmd_dirs

cmd_dirs:
		cmp.w	#1,d0
		blo	print_dirs
		bhi	pwd_dirs_too_many_args

		lea	word_switch_l,a1
		bsr	strcmp
		bne	pwd_dirs_bad_arg

		lea	puts(pc),a1
		bra	print_dirs_l

print_dirs:
		lea	print_directory(pc),a1
print_dirs_l:
		bsr	print_cwd
		movea.l	dstack,a0
		move.w	8(a0),d0
		beq	print_dirs_done

		bsr	put_space
		lea	10(a0),a0
		clr.l	a2
		bsr	echo
print_dirs_done:
put_newline_return_0:
		bsr	put_newline
		bra	return_0

pwd_dirs_bad_arg:
		bsr	bad_arg
		bra	pwd_dirs_usage

pwd_dirs_too_many_args:
		bsr	too_many_args
pwd_dirs_usage:
		lea	msg_pwd_dirs_usage,a0
		bra	usage
****************************************************************
*  Name
*       pwd - print current working directory
*
*  Synopsis
*       pwd [ -l ]
****************************************************************
.xdef cmd_pwd

cmd_pwd:
		cmp.w	#1,d0
		blo	pwd
		bhi	pwd_dirs_too_many_args

		lea	word_switch_l,a1
		bsr	strcmp
		bne	pwd_dirs_bad_arg

		lea	puts(pc),a1
		bra	pwd_l

pwd:
		lea	print_directory(pc),a1
pwd_l:
		bsr	print_cwd
		bra	put_newline_return_0
****************************************************************
* get_dstack_element
*
* CALL
*      A0     "+n" �� '+' ���w���Ă���
*
* RETURN
*      A0     �f�B���N�g���E�X�^�b�N�� n �Ԗڂ̗v�f�idstack�� n-1 �Ԗڂ̒P��j�̃A�h���X
*      D0.L   �G���[�Ȃ�� 1  �����Ȃ��� 0
*      D1.L   n-1
*      CCR    TST.L D0
*****************************************************************
get_dstack_element:
		addq.l	#1,a0			* '+'�ɑ���
		bsr	atou			* ���l���X�L��������
		tst.b	(a0)			* NUL�łȂ����
		bne	bad_arg			* �G���[

		tst.l	d0
		bmi	bad_arg			* �G���[
		bne	dstack_not_deep

		tst.l	d1			* 0�Ȃ��
		beq	bad_arg			* �G���[

		subq.l	#1,d1
		movea.l	dstack,a0
		lea	8(a0),a0
		moveq	#0,d0
		move.w	(a0)+,d0
		cmp.l	d0,d1
		bhs	dstack_not_deep		* �G���[

		move.w	d1,d0
		bsr	fornstrs
		bra	return_0
****************************************************************
*  A0�������v�f�ƃJ�����g�E�f�B���N�g������������
pushd_exchange_sub:
		movea.l	dstack,a1
		move.l	4(a1),d1		* �X�^�b�N�̌��݂̒�������
		bsr	strlen			* �v�f�̒���
		addq.l	#1,d0
		sub.l	d0,d1			* ������
		add.l	d7,d1			* �J�����g�E�f�B���N�g���̒������������
		cmp.l	(a1),d1			* �X�^�b�N�̗e�ʂ𒴂���Ȃ��
		bhi	stack_full		* �G���[

		bsr	popd_sub		* (A0)�Ɉړ����A�i����������j�폜����
		bne	return			* ���s�Ȃ�΋A��

		bsr	push_cwd		* �ȑO�̃J�����g�E�f�B���N�g�����v�b�V������
		bra	return_0		* ����
****************************************************************
*  �ȑO�̃J�����g�E�f�B���N�g�����v�b�V������
push_cwd:
		movea.l	dstack,a2
		move.l	4(a2),d0		* D0 := ���݂̃X�^�b�N�̒���
		lea	(a2,d0.l),a1		* A1(source) := �]�����̖����i�{�P�j
		lea	(a1,d7.l),a0		* A0(destination)�́A����ɋ󂯂镶�������A��
		sub.l	#10,d0
		bsr	memmove_dec		* �V�t�g����
		lea	cwdbuf(a6),a1		* �ȑO�̃J�����g�E�f�B���N�g����
		lea	10(a2),a0		* �X�^�b�N�̐擪��
		bsr	strcpy			* �u��
		add.l	d7,4(a2)		* �o�C�g�����X�V
		addq.w	#1,8(a2)		* �v�f�����C���N�������g
		rts
****************************************************************
*  A0 �������v�f���J�����g�E�f�B���N�g���Ƃ��A�v�f���폜����
*  D0/CCR �͖߂�l
popd_sub:
		bsr	chdir			* �f�B���N�g���Ɉړ�����
		bmi	popd_sub_error
popd_sub_delete:
		movem.l	d1/a0-a2,-(a7)
		movea.l	dstack,a2
		move.l	4(a2),d0
		lea	(a2,d0.l),a1
		move.l	a1,d0			* D0.L : ���݂̖����A�h���X�i�̎��j
		movea.l	a0,a1
		bsr	for1str
		exg	a0,a1			* A1 : ���̗v�f�̃A�h���X
		sub.l	a1,d0			* D0 : �ړ�����o�C�g��
		move.l	a1,d1
		sub.l	a0,d1			* D1 : �폜����o�C�g��
		bsr	memmove_inc
		sub.l	d1,4(a2)		* ���݂̃o�C�g�����X�V
		subq.w	#1,8(a2)		* �v�f�����f�N�������g
		movem.l	(a7)+,d1/a0-a2
return_0:
		moveq	#0,d0
return:
		rts

popd_sub_error:
		bsr	perror
		moveq	#1,d0
		rts
****************************************************************
print_cwd:
		link	a6,#cwdbuf
		move.l	a0,-(a7)
		lea	cwdbuf(a6),a0
		bsr	getcwd
		jsr	(a1)
		movea.l	(a7)+,a0
		unlk	a6
		rts
****************************************************************
print_directory:
		movem.l	d0-d1/a0-a2,-(a7)
		movea.l	a0,a2			* A2 : �\������f�B���N�g�����̐擪
		bsr	isabsolute
		bne	print_directory_9	* ��΃p�X�łȂ��c�ȗ����Ȃ�

		lea	word_home,a0
		bsr	find_shellvar
		beq	print_directory_9	* $?home��0�ł���c�ȗ��ł��Ȃ�

		addq.l	#2,a0
		tst.w	(a0)+
		beq	print_directory_9	* $#home��0�ł���c�ȗ��ł��Ȃ�

		bsr	for1str			* A0 : $home[1]
		bsr	isabsolute
		bne	print_directory_9	* $home[1]�͐�΃p�X���łȂ��c�ȗ��ł��Ȃ�

		move.b	(a0),d0
		bsr	toupper
		move.b	d0,d1
		move.b	(a2),d0
		bsr	toupper
		cmp.b	d1,d0
		bne	print_directory_9

		movea.l	a2,a1
		addq.l	#3,a1
		addq.l	#3,a0
compare_loop:
		move.b	(a0)+,d0
		beq	check_bottom

		bsr	issjis
		beq	compare_sjis

		bsr	tocompare
		cmp.b	#'/',d0
		bne	compare_ank

		tst.b	(a0)
		beq	check_bottom
compare_ank:
		move.b	d0,d1
		move.b	(a1)+,d0
		bsr	tolower
		cmp.b	d1,d0
		bra	check_one

compare_sjis:
		move.b	d0,d1
		move.b	(a1)+,d0
		bsr	issjis
		bne	print_directory_9

		cmp.b	d1,d0
		bne	print_directory_9

		move.b	(a0)+,d0
		beq	print_directory_9

		cmp.b	(a1)+,d0
check_one:
		bne	print_directory_9

		bra	compare_loop

check_bottom:
		move.b	(a1),d0
		beq	match

		cmp.b	#'/',d0
		beq	match

		cmp.b	#'\',d0
		bne	print_directory_9
match:
		moveq	#'~',d0
		bsr	putc
		movea.l	a1,a2
print_directory_9:
		movea.l	a2,a0
		bsr	puts
		movem.l	(a7)+,d0-d1/a0-a2
		rts
****************************************************************
tocompare:
		cmp.b	#'\',d0
		bne	tolower

		moveq	#'/',d0
		rts
****************************************************************
dstack_not_deep:
		lea	msg_not_deep,a0
		bra	command_error
****************************************************************
dstack_empty:
		lea	msg_dstack_empty,a0
		bra	command_error
****************************************************************
stack_full:
		lea	msg_full,a0
		bra	command_error
****************************************************************
no_home:
		lea	msg_no_home,a0
		bra	command_error
****************************************************************
.data

word_cwd:		dc.b	'cwd',0
word_switch_l:		dc.b	'-l',0
msg_pwd_dirs_usage:	dc.b	'[ -l ]',0
msg_dstack_empty:	dc.b	'�f�B���N�g���E�X�^�b�N�͋�ł�',0
msg_not_deep:		dc.b	'�f�B���N�g���E�X�^�b�N�͂���Ȃɐ[������܂���',0
msg_full:		dc.b	'�f�B���N�g���E�X�^�b�N�̗e�ʂ�����܂���',0
msg_too_deep:		dc.b	'�f�B���N�g���E�X�^�b�N�̗v�f����������t�ł�',0

.end

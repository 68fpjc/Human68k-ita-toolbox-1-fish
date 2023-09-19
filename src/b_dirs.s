* b_dirs.s
* This contains built-in command 'cd'('chdir'), 'dirs', 'popd', 'pushd'.
*
* Itagaki Fumihiko 06-Oct-90  Create.

.include error.h
.include limits.h
.include ../src/fish.h

.xref atou
.xref strlen
.xref strcmp
.xref strcpy
.xref for1str
.xref fornstrs
.xref rotate
.xref memmovd
.xref memmovi
.xref isabsolute
.xref cat_pathname
.xref slash_to_backslash
.xref putc
.xref puts
.xref eputs
.xref enputs1
.xref put_space
.xref put_newline
.xref echo
.xref chdir
.xref getcwd
.xref is_under_home
.xref find_shellvar
.xref set_svar
.xref setenv
.xref perror1
.xref perror_command_name
.xref command_error
.xref usage
.xref no_space_for
.xref bad_arg
.xref too_many_args
.xref word_cdpath
.xref word_home
.xref pathname_buf

.xref dstack

cwdbuf = -(((MAXPATH+1)+1)>>1<<1)

.text

****************************************************************
* chdir_var - Change current working drive/directory to $varname
*
* CALL
*      A0     varname
*
* RETURN
*      D0.L   �G���[�Ȃ�Ε����i�n�r�̃G���[�E�R�[�h�j
*             �V�F���ϐ����������C�l�̒P�ꂪ�������C�ŏ��̒P�ꂪ��Ȃ�� 1
*             $varname[1]�� chdir �ł����Ȃ�� 0
*
*      CCR    TST.L D0
*****************************************************************
.xdef chdir_var

chdir_var:
		move.l	a0,-(a7)
		bsr	find_shellvar
		beq	chdir_var_fail			*  �ϐ�������

		lea	2(a0),a0
		move.w	(a0)+,d1			*  D1.W : �P�ꐔ  A0 : �l
		beq	chdir_var_fail			*  �P�ꂪ����

		bsr	for1str
		bsr	isabsolute
		bne	chdir_var_fail			*  �ŏ��̒P�ꂪ��

		bsr	chdir
		bmi	chdir_var_done

		moveq	#0,d0
chdir_var_done:
		movea.l	(a7)+,a0
chdir_home_return:
		rts

chdir_var_fail:
		moveq	#1,d0
		bra	chdir_var_done
****************************************************************
* chdir_home - Change current working directory and drive to $home
*
* CALL
*      none
*
* RETURN
*      D0.L   �G���[�Ȃ�Ε����i�n�r�̃G���[�E�R�[�h�j
*             �V�F���ϐ� home ���������C�l���������C�ŏ��̒l����Ȃ�� 1
*             $home[1]�� chdir �ł����Ȃ�� 0
*
*      CCR    TST.L D0
*
*      A0     �j��
*****************************************************************
chdir_home:
		lea	word_home,a0		*  �V�F���ϐ� home ��
		bsr	chdir_var
		beq	chdir_home_return
		bmi	chdir_home_return

		lea	msg_no_home,a0
		bra	command_error		*  D0.L �� 1 �ɂȂ�D
****************************************************************
* chdirx - Change current working directory and/or drive.
*
* CALL
*      A0     �i�h���C�u���{�j�f�B���N�g����
*
* RETURN
*      D0.L   �G���[�Ȃ�Ε����i�n�r�̃G���[�E�R�[�h�j�D
*             �w��̃f�B���N�g���Ɉړ������Ȃ�� 0�D
*             �w��̖��O����⊮���ꂽ�f�B���N�g���Ɉړ������Ȃ�� 1�D
*
*      CCR    TST.L D0
*
* DESCRIPTION
*      name ���󕶎���Ȃ�
*           chdir($home)
*      �����Ȃ���
*           chdir(name)
*           ���s�����Ȃ�iname ���h���C�u����������
*           ./ �� ../ �Ŏn�܂��Ă��Ȃ��ꍇ�Ɍ���j
*                chdir(concat($cdpath[1], name))
*                chdir(concat($cdpath[2], name))
*                             :
*                chdir(concat($cdpath[$#cdpath], name))
*                chdir($name)
*****************************************************************
chdirx:
		movem.l	d1-d3/a0-a3,-(a7)
		tst.b	(a0)
		bne	chdirx_try

		bsr	chdir_home
		bmi	chdirx_done
		bra	chdirx_done1

chdirx_try:
		bsr	chdir				*  �J�����g�E�f�B���N�g����ύX����D
		bpl	chdirx_done0			*  ���������Ȃ�A��D

		cmpi.b	#':',1(a0)			*  �h���C�u�w�肪����ꍇ��
		beq	chdirx_done			*  ����ȏ�g���C���Ȃ��D

		movea.l	a0,a1
		cmpi.b	#'.',(a1)
		bne	chdirx_1

		addq.l	#1,a1
		cmpi.b	#'.',(a1)
		bne	chdirx_1

		addq.l	#1,a1
chdirx_1:
		cmpi.b	#'/',(a1)
		beq	chdirx_done

		cmpi.b	#'\',(a1)
		beq	chdirx_done

		movea.l	a0,a2				*  A2 : dirname
		lea	word_cdpath,a0
		bsr	find_shellvar
		beq	try_varname

		addq.l	#2,a0
		move.w	(a0)+,d1			*  D1.W : cdpath �̒P�ꐔ
		bsr	for1str
		movea.l	a0,a1				*  A1 : cdpath �̒P�����
		lea	pathname_buf,a0
		bra	try_cdpath_continue

try_cdpath_loop:
		bsr	cat_pathname
		bmi	try_cdpath_continue

		bsr	chdir
		bpl	chdirx_done1
try_cdpath_continue:
		dbra	d1,try_cdpath_loop
****************
try_varname:
		movea.l	a2,a0
		bsr	chdir_var
		beq	chdirx_done1
		bmi	chdirx_done

		moveq	#ENODIR,d0
chdirx_done:
		movem.l	(a7)+,d1-d3/a0-a3
		tst.l	d0
		rts

chdirx_done0:
		moveq	#0,d0
		bra	chdirx_done

chdirx_done1:
		moveq	#1,d0
		bra	chdirx_done
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
		cmp.w	#1,d0			*  ������
		bhi	too_many_args		*  2�ȏ゠��΃G���[�D
		blo	cd_home			*  1�������Ȃ� $home �� chdir ����D

		cmpi.b	#'+',(a0)		*  ������ + �Ŏn�܂�Ȃ��Ȃ��
		bne	cd_name			*  ���� cd_name ��

		bsr	get_dstack_element	*  D1.L : ���l-1  A0 : �v�f�̃A�h���X
		bne	cd_return		*  �G���Ȃ炨���܂��D

		bsr	popd_sub		*  �����Ɉړ����Ă��̗v�f���폜����D
		bne	cd_return		*  �G���[�Ȃ炨���܂��D

		tst.l	d1
		beq	cd_dirs_done		*  �z����̕K�v�Ȃ��D

		addq.w	#1,d1
		movea.l	dstack(a5),a1
		cmp.w	8(a1),d1
		bhi	cd_dirs_done		*  �z����̕K�v�Ȃ��D

		exg	a0,a1
		move.l	4(a0),d0
		lea	(a0,d0.l),a2		*  A2 : ���݂̖����A�h���X(+1)
		lea	10(a0),a0		*  A0 : �擪�̗v�f
		bsr	rotate			*  �v�f���z���肷��D
cd_dirs_done:
		bsr	print_dirs		*  �f�B���N�g���E�X�^�b�N��\������D
		bra	chdir_success
****************
cd_name:
		bsr	chdirx			*  �w��̃f�B���N�g���� chdirx ����D
		bmi	cd_fail			*  ���s�����Ȃ�΃G���[�����ցD
		beq	cd_return

		lea	print_directory(pc),a1
		bsr	print_cwd
		bsr	put_newline
chdir_success:
		moveq	#0,d0
		bra	cd_return
****************
cd_home:
		bsr	chdir_home
		bmi	cd_fail
cd_return:
reset_cwd:
		link	a6,#cwdbuf
		movem.l	d0-d1/a0-a1,-(a7)
		lea	cwdbuf(a6),a0
		bsr	getcwd
		movea.l	a0,a1
		lea	word_cwd,a0
		moveq	#1,d0
		moveq	#0,d1
		bsr	set_svar
		movea.l	a1,a0
		bsr	slash_to_backslash
		lea	word_upper_pwd,a0
		bsr	setenv
		movem.l	(a7)+,d0-d1/a0-a1
		unlk	a6
		rts
****************
cd_fail:
		bsr	perror1
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
		move.w	d0,d1			*  argc ���Z�[�u����D

		lea	cwdbuf(a6),a0		*  cwdbuf��
		bsr	getcwd			*  �J�����g�f�B���N�g���𓾂�
		bsr	strlen			*  ���̒���(+1)��
		addq.l	#1,d0
		move.l	d0,d7			*  D7.L�ɕۑ�����D

		move.w	d1,d0			*  argc ���|�b�v����D
		beq	exchange		*  �����������Ȃ�擪�v�f�ƃJ�����g�������D

		cmp.w	#1,d0			*  ������ 2�ȏ゠���
		bhi	pushd_too_many_args	*  'Too many args' �G���[�ցD

		cmpi.b	#'+',(a1)		*  ������ + �Ŏn�܂�Ȃ��Ȃ��
		bne	push_new		*  ���� push_new �ցD

		movea.l	a1,a0
		bsr	get_dstack_element	*  D1.L : ���l-1  A0 : �v�f�̃A�h���X
		bne	cmd_pushd_return	*  �G���[�Ȃ炨���܂��D

		bsr	pushd_exchange_sub	*  A0�������v�f�Ƀ|�b�v���C�J�����g���v�b�V������D
		bne	cmd_pushd_return	*  �G���[�Ȃ炨���܂��D

		*  �X�^�b�N�̗v�f�����񂷂�
		movea.l	a0,a1

		addq.w	#1,d1
		movea.l	dstack(a5),a0
		cmp.w	8(a0),d1
		bhs	cmd_pushd_done		*  �z����̕K�v�Ȃ��D

		move.l	4(a0),d0
		lea	(a0,d0.l),a2		*  A2 : ���݂̖����A�h���X(+1)
		lea	10(a0),a0		*  A0 : �擪�̗v�f
		bsr	rotate			*  �v�f���z���肷��D
		bra	cmd_pushd_done
****************
exchange:
		movea.l	dstack(a5),a0
		tst.w	8(a0)			*  �X�^�b�N�ɗv�f�������Ȃ��
		beq	pushd_empty		*  �G���[�D

		lea	10(a0),a0		*  �擪�̗v�f��
		bsr	pushd_exchange_sub	*  �J�����g�E�f�B���N�g������������D
		bne	cmd_pushd_return	*  ���s�����Ȃ炨���܂��D

		bra	cmd_pushd_done
****************
push_new:
		movea.l	dstack(a5),a0
		cmpi.w	#MAXWORDS,8(a0)
		bhs	pushd_too_many_elements

		move.l	4(a0),d0		*  �X�^�b�N�̒�����
		add.l	d7,d0			*  �J�����g�E�f�B���N�g���̒���(+1)���������
		cmp.l	(a0),d0			*  �X�^�b�N�̗e�ʂ𒴂���Ȃ��
		bhi	pushd_stack_full	*  �G���[�D

		movea.l	a1,a0			*  �w�肳�ꂽ�f�B���N�g����
		bsr	chdirx			*  chdirx ����D
		bmi	pushd_perror_return

		bsr	push_cwd		*  ���̃J�����g�E�f�B���N�g�����v�b�V������D
cmd_pushd_done:
		bsr	print_dirs		*  �f�B���N�g���E�X�^�b�N��\������D
cmd_pushd_return:
		bsr	reset_cwd		*  cwd �� set����
		unlk	a6
		rts				*  �I���D
****************
pushd_too_many_args:
		bsr	too_many_args
		bra	cmd_pushd_return
****************
pushd_too_many_elements:
		bsr	perror_command_name
		lea	msg_directory_stack,a0
		bsr	eputs
		lea	msg_too_deep,a0
		bsr	enputs1
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
		bsr	perror1
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
		cmp.w	#1,d0			*  �������Q�ȏ゠���
		bhi	too_many_args		*  �G���[�D
		blo	pop			*  �����������Ȃ�|�b�v�D

		cmpi.b	#'+',(a0)		*  ������ + �Ŏn�܂�Ȃ��Ȃ��
		bne	bad_arg			*  �G���[�D

		movea.l	a0,a1
		bsr	get_dstack_element	*  A0 : ���l�������v�f�̃A�h���X
		bne	popd_return		*  �G���[�Ȃ�΂����܂��D

		bsr	popd_sub_delete		*  �v�f���폜����D
		bra	pop_done		*  �X�^�b�N��\�����Ccwd �� set���ďI���D

pop:
		movea.l	dstack(a5),a0
		lea	8(a0),a0
		tst.w	(a0)+			*  �X�^�b�N�ɗv�f�������Ȃ��
		beq	dstack_empty		*  �G���[�D

		bsr	popd_sub		*  �v�f�Ɉړ����č폜����
		bne	popd_return		*  ���s�Ȃ�΂����܂��D
pop_done:
		bsr	print_dirs		*  �f�B���N�g���E�X�^�b�N��\������D
popd_return:
		bra	reset_cwd		*  cwd �� set���ďI���D
****************************************************************
*  Name
*       pwd/dirs - print current working directory / directory stack
*
*  Synopsis
*       pwd [ -l ]
*       dirs [ -l ]
****************************************************************
.xdef cmd_pwd
.xdef cmd_dirs

cmd_pwd:
		sf	d1
		bra	cmd_pwd_dirs

cmd_dirs:
		st	d1
cmd_pwd_dirs:
		cmp.w	#1,d0
		blo	print_dirs_1
		bhi	pwd_dirs_too_many_args

		lea	word_switch_l,a1
		bsr	strcmp
		bne	pwd_dirs_bad_arg

		lea	puts(pc),a1
		bra	print_dirs_2

print_dirs:
		st	d1
print_dirs_1:
		lea	print_directory(pc),a1
print_dirs_2:
		bsr	print_cwd
		tst.b	d1
		beq	print_dirs_done

		movea.l	dstack(a5),a0
		move.w	8(a0),d0
		beq	print_dirs_done

		bsr	put_space
		lea	10(a0),a0
		clr.l	a2
		bsr	echo
print_dirs_done:
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
		addq.l	#1,a0			*  + �ɑ���
		bsr	atou			*  ���l���X�L��������D
		tst.b	(a0)			*  NUL�łȂ����
		bne	bad_arg			*  �G���[�D

		tst.l	d0
		bmi	bad_arg			*  �G���[�D
		bne	dstack_not_deep

		tst.l	d1			*  ���l�� 0 �Ȃ��
		beq	bad_arg			*  �G���[�D

		subq.l	#1,d1
		movea.l	dstack(a5),a0
		lea	8(a0),a0
		moveq	#0,d0
		move.w	(a0)+,d0		*  �f�B���N�g���E�X�^�b�N�̗v�f������
		cmp.l	d0,d1			*  ���l���傫���Ȃ��
		bhs	dstack_not_deep		*  �G���[�D

		move.w	d1,d0
		bsr	fornstrs
		bra	return_0
****************************************************************
* pushd_exchange_sub - �f�B���N�g���E�X�^�b�N��̃f�B���N�g����
*                      �ړ����āC���̃f�B���N�g�����폜���C����
*                      �J�����g�E�f�B���N�g�����f�B���N�g���E�X
*                      �^�b�N�̐擪�Ƀv�b�V������
*
* CALL
*      A0    �ړ�����f�B���N�g���v�f�̃A�h���X
*      D7.L  �J�����g�E�f�B���N�g���̒���(+1)
*
* RETURN
*      A0     �i���������Ȃ�΁j���̃f�B���N�g���v�f�̃A�h���X
*      D0.L   �����Ȃ�� 0
*      CCR    TST.L D0
****************************************************************
pushd_exchange_sub:
		movem.l	d1/a1,-(a7)
		movea.l	dstack(a5),a1
		move.l	4(a1),d1		*  �X�^�b�N�̌��݂̒�������
		bsr	strlen			*  �v�f�̒���
		addq.l	#1,d0
		sub.l	d0,d1			*  ������
		add.l	d7,d1			*  �J�����g�E�f�B���N�g���̒���(+1)���������
		cmp.l	(a1),d1			*  �X�^�b�N�̗e�ʂ𒴂���Ȃ��
		movem.l	(a7)+,d1/a1
		bhi	stack_full		*  �G���[�D

		bsr	popd_sub		*  (A0)�Ɉړ����C�i����������j�폜����D
		bne	pushd_exchange_sub_return	*  ���s�Ȃ�΋A��D

		adda.l	d7,a0			*  ���Ƀv�b�V�����邱�Ƃł���镪��␳����D
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* push_cwd -  �ȑO�̃J�����g�E�f�B���N�g�����v�b�V������
*
* CALL
*      D7.L  �J�����g�E�f�B���N�g���̒���(+1)
*
* RETURN
*      D0.L  0
*      CCR   TST.L D0
***************************************************************
push_cwd:
		movem.l	a0-a2,-(a7)
		movea.l	dstack(a5),a2
		move.l	4(a2),d0		*  D0.L : ���݂̃X�^�b�N�̒���
		lea	(a2,d0.l),a1		*  A1(source) : �]�����̖���(+1)
		lea	(a1,d7.l),a0		*  A0(destination)�͂���ɋ󂯂镶��������
		sub.l	#10,d0
		bsr	memmovd			*  �V�t�g����D
		lea	cwdbuf(a6),a1		*  �ȑO�̃J�����g�E�f�B���N�g����
		lea	10(a2),a0		*  �X�^�b�N�̐擪��
		bsr	strcpy			*  �u���D
		add.l	d7,4(a2)		*  �o�C�g�����X�V����D
		addq.w	#1,8(a2)		*  �v�f�����C���N�������g����D
		movem.l	(a7)+,a0-a2
		moveq	#0,d0
pushd_exchange_sub_return:
		rts
****************************************************************
* popd_sub - A0 ���w���v�f�̃f�B���N�g���Ɉړ����C���̗v�f���폜����
*
* CALL
*      A0     �ړ�����f�B���N�g���v�f�̃A�h���X
*
* RETURN
*      D0.L   �����Ȃ�� 0
*      CCR    TST.L D0
****************************************************************
popd_sub:
		bsr	chdir			*  �f�B���N�g���Ɉړ�����D
		bmi	perror1
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* popd_sub_delete - A0 ���w���f�B���N�g���v�f���폜����
*
* CALL
*      A0     �폜����f�B���N�g���v�f�̃A�h���X
*
* RETURN
*      D0.L   0
*      CCR    TST.L D0
****************************************************************
popd_sub_delete:
		movem.l	d1/a0-a2,-(a7)
		movea.l	dstack(a5),a2
		move.l	4(a2),d0
		lea	(a2,d0.l),a1
		move.l	a1,d0			*  D0.L : ���݂̖����A�h���X�i�̎��j
		movea.l	a0,a1
		bsr	for1str
		exg	a0,a1			*  A1 : ���̗v�f�̃A�h���X
		sub.l	a1,d0			*  D0 : �ړ�����o�C�g��
		move.l	a1,d1
		sub.l	a0,d1			*  D1.L : �폜����o�C�g��
		bsr	memmovi
		sub.l	d1,4(a2)		*  ���݂̃o�C�g�����X�V����D
		subq.w	#1,8(a2)		*  �v�f�����f�N�������g����D
		movem.l	(a7)+,d1/a0-a2
return_0:
		moveq	#0,d0
		rts
****************************************************************
print_cwd:
		link	a6,#cwdbuf
		lea	cwdbuf(a6),a0
		bsr	getcwd
		jsr	(a1)
		unlk	a6
		rts
****************************************************************
print_directory:
		movem.l	d0/a0,-(a7)
		bsr	is_under_home
		beq	print_directory_1

		add.l	d0,a0
		moveq	#'~',d0
		bsr	putc
print_directory_1:
		bsr	puts
		movem.l	(a7)+,d0/a0
		rts
****************************************************************
dstack_not_deep:
		bsr	perror_command_name
		lea	msg_directory_stack,a0
		bsr	eputs
		lea	msg_not_deep,a0
		bra	enputs1
****************************************************************
dstack_empty:
		bsr	perror_command_name
		lea	msg_directory_stack,a0
		bsr	eputs
		lea	msg_dstack_empty,a0
		bra	enputs1
****************************************************************
stack_full:
		lea	msg_directory_stack,a0
		bra	no_space_for
****************************************************************
.data

.xdef word_cwd
.xdef msg_directory_stack

word_upper_pwd:		dc.b	'PWD',0
word_cwd:		dc.b	'cwd',0
word_switch_l:		dc.b	'-l',0
msg_pwd_dirs_usage:	dc.b	'[ -l ]',0
msg_directory_stack:	dc.b	'�f�B���N�g���E�X�^�b�N',0
msg_dstack_empty:	dc.b	'�͋�ł�',0
msg_not_deep:		dc.b	'�͂���Ȃɐ[������܂���',0
msg_too_deep:		dc.b	'�̗v�f����������t�ł�',0
msg_no_home:		dc.b	'�V�F���ϐ� home ������`����ł�',0

.end

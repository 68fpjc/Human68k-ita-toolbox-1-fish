* b_dirs.s
* This contains built-in command 'cd'('chdir'), 'dirs', 'popd', 'pushd', 'cdd'.
*
* Itagaki Fumihiko 06-Oct-90  Create.

.include doscall.h
.include error.h
.include limits.h
.include ../src/fish.h
.include ../src/dirstack.h

.xref toupper
.xref atou
.xref utoa
.xref strlen
.xref strcmp
.xref strcpy
.xref strfor1
.xref strforn
.xref rotate
.xref memmovd
.xref memmovi
.xref isfullpath
.xref cat_pathname
.xref bsltosl
.xref putc
.xref puts
.xref nputs
.xref eputs
.xref enputs1
.xref put_tab
.xref put_space
.xref put_newline
.xref printu
.xref chdir
.xref getcwd
.xref drvchk
.xref is_under_home
.xref xmalloc
.xref free
.xref find_shellvar
.xref set_shellvar
.xref get_shellvar
.xref fish_getenv
.xref fish_setenv
.xref get_var_value
.xref perror
.xref perror_command_name
.xref command_error
.xref usage
.xref bad_arg
.xref too_many_args
.xref dstack_not_deep
.xref insufficient_memory
.xref word_cdpath
.xref word_home
.xref pathname_buf

.xref dirstack
.xref cwd_changed
.xref command_name
.xref flag_pushdsilent

cwdbuf = -(((MAXPATH+1)+1)>>1<<1)

.text

****************************************************************
var_value_a1:
		beq	var_value_a1_nul

		bsr	get_var_value
		bne	var_value_a1_ok
var_value_a1_nul:
		lea	str_nul,a0
var_value_a1_ok:
		movea.l	a0,a1
		rts
****************************************************************
.xdef reset_cwd

reset_cwd:
		link	a6,#cwdbuf
		movem.l	d0-d1/a0-a1,-(a7)
		lea	cwdbuf(a6),a0
		bsr	getcwd
		movea.l	a0,a1
		lea	word_cwd,a0
		moveq	#1,d0
		sf	d1
		bsr	set_shellvar
		lea	word_upper_pwd,a0
		bsr	fish_setenv
		movem.l	(a7)+,d0-d1/a0-a1
		unlk	a6
		rts
****************************************************************
.xdef set_oldcwd

set_oldcwd:
		movem.l	d0-d1/a0-a1,-(a7)
		*
		*  $@cwd -> $@oldcwd
		*
		lea	word_cwd,a0
		bsr	find_shellvar
		bsr	var_value_a1
		lea	word_oldcwd,a0
		moveq	#1,d0
		sf	d1
		bsr	set_shellvar
		*
		*  $%PWD -> $%OLDPWD
		*
		lea	word_upper_pwd,a0
		bsr	fish_getenv
		bsr	var_value_a1
		lea	word_upper_oldpwd,a0
		bsr	fish_setenv
		*
		*  $@cwd �� $%PWD ���Z�b�g����
		*
		bsr	reset_cwd
		*
		st	cwd_changed(a5)
		*
		movem.l	(a7)+,d0-d1/a0-a1
		rts
****************************************************************
* fish_chdir - �J�����g��ƃf�B���N�g����ύX����
*
* CALL
*      A0     �h���C�u�E�f�B���N�g����
*
* RETURN
*      D0.L   �G���[�Ȃ�Ε����i�n�r�G���[�E�R�[�h�j
*             �����Ȃ�� 0�D
*
*      CCR    TST.L D0
*
* DESCRIPTION
*      ���������Ȃ�΁C�V�F���ϐ� oldcwd, cwd�C���ϐ� PWD,
*      OLDPWD ���Z�b�g���C�����t���O cwd_changed ���Z�b�g����D
****************************************************************
fish_chdir:
		bsr	chdir
		bmi	return

		bsr	set_oldcwd
return_0:
		moveq	#0,d0
return:
		rts
****************************************************************
* test_var - �ϐ��𒲂ׂ�
*
* CALL
*      A0     �ϐ���
*
* RETURN
*      A0     ��������Εϐ��̒l�D�����Ȃ��Δj��
*
*      D0.L   �j��
*
*      CCR    NE �Ȃ�� �V�F���ϐ����������C�l�̒P�ꂪ�������C
*             �ŏ��̒P�ꂪ�󂩁C���S�p�X���łȂ��D
*             �����Ȃ��� EQ�D
****************************************************************
test_var:
		bsr	get_shellvar
		beq	return_1

		bra	isfullpath
****************************************************************
* chdir_var - Change current working drive/directory to $varname
*
* CALL
*      A0     �ϐ���
*
* RETURN
*      A0     ��������Εϐ��̒l�D�����Ȃ��Δj��
*
*      D0.L   1 �Ȃ�� �V�F���ϐ����������C�l�̒P�ꂪ�������C
*             �ŏ��̒P�ꂪ�󂩁C���S�p�X���łȂ��D
*             �����Ȃ��΁C�n�r�̃G���[�R�[�h
*
*      CCR    TST.L D0
****************************************************************
chdir_var:
		bsr	test_var
		beq	fish_chdir
return_1:
		moveq	#1,d0
		rts
****************************************************************
* chdir_home - Change current working directory and drive to $home
*
* CALL
*      none
*
* RETURN
*      A0     �j��
*
*      D0.L   $home[1]�� chdir �ł����Ȃ�� 0
*             �����Ȃ��Δ�0�i�G���[�E���b�Z�[�W���o�͂���j
*
*      CCR    TST.L D0
****************************************************************
chdir_home:
		lea	word_home,a0
		bsr	chdir_var
		beq	return
		bmi	perror
chdir_home_error:
		lea	msg_no_home,a0
		bra	command_error
****************************************************************
* chdirx - Change current working directory and/or drive.
*
* CALL
*      A0     �h���C�u�E�f�B���N�g����
*
* RETURN
*      D0.L   �G���[�Ȃ�� -1�D�i�G���[�E���b�Z�[�W���o�͂���j
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
****************************************************************
chdirx:
		movem.l	d1-d3/a0-a3,-(a7)
		tst.b	(a0)
		bne	chdirx_try

		bsr	chdir_home
		bne	chdirx_error
		bra	chdirx_done1

chdirx_try:
		bsr	fish_chdir			*  �J�����g�E�f�B���N�g����ύX����
		bpl	chdirx_done			*  ���������Ȃ�A��

		cmpi.b	#':',1(a0)			*  �h���C�u�w�肪����ꍇ��
		beq	chdirx_perror			*  ����ȏ�g���C���Ȃ�

		movea.l	a0,a1
		cmpi.b	#'.',(a1)
		bne	chdirx_1

		addq.l	#1,a1
		cmpi.b	#'.',(a1)
		bne	chdirx_1

		addq.l	#1,a1
chdirx_1:
		cmpi.b	#'/',(a1)			*  / ./ ../ �Ȃ��
		beq	chdirx_perror			*  ����ȏ�g���C���Ȃ�

		cmpi.b	#'\',(a1)			*  \ .\ ..\ �Ȃ��
		beq	chdirx_perror			*  ����ȏ�g���C���Ȃ�
****************
		movea.l	a0,a2				*  A2 : dirname
		lea	word_cdpath,a0
		bsr	find_shellvar
		beq	try_varname

		bsr	get_var_value
		move.w	d0,d1				*  D1.W : $#cdpath
		movea.l	a0,a1				*  A1 : cdpath �̒P�����
		lea	pathname_buf,a0
		bra	try_cdpath_continue

try_cdpath_loop:
		tst.b	(a1)
		beq	try_cdpath_next

		bsr	cat_pathname
		bmi	try_cdpath_continue

		bsr	fish_chdir
		bmi	try_cdpath_continue
chdirx_done1:
		moveq	#1,d0
		bra	chdirx_done

try_cdpath_next:
		exg	a0,a1
		bsr	strfor1
		exg	a0,a1
try_cdpath_continue:
		dbra	d1,try_cdpath_loop
****************
try_varname:
		movea.l	a2,a0
		bsr	chdir_var
		beq	chdirx_done1
		bmi	chdirx_perror

		movea.l	a2,a0
		moveq	#ENODIR,d0
chdirx_perror:
		bsr	perror
chdirx_error:
		moveq	#-1,d0
chdirx_done:
		movem.l	(a7)+,d1-d3/a0-a3
test_return:
		tst.l	d0
		rts
****************************************************************
*  Name
*       cdd - change directory of drive
*
*  Synopsis
*       cdd           print current directory of current drive
*       cdd d:        print current directory of drive d
*	cdd dir       change current directory of current drive to dir
*	cdd d:dir     change current directory of drive d to dir
****************************************************************
.xdef cmd_cdd

cmd_cdd:
		move.w	d0,-(a7)
		DOS	_CURDRV
		add.b	#'A',d0			*  D0 : �J�����g�E�h���C�u��
		cmp.w	#1,(a7)+		*  ������
		bhi	too_many_args		*  2�ȏ゠��΃G���[
		blo	cdd_print

		move.b	(a0),d1
		beq	cdd_print

		cmpi.b	#':',1(a0)
		bne	cdd_change_cwd

		exg	d0,d1
		bsr	toupper
		cmp.b	d1,d0
		bne	cdd_other_drive

		tst.b	2(a0)
		beq	cdd_print
cdd_change_cwd:
		bsr	fish_chdir
		bra	cdd_check_result

cdd_other_drive:
		move.b	d0,d1
		bsr	drvchk
		bmi	perror

		move.b	d1,d0
		tst.b	2(a0)
		bne	cdd_change
cdd_print:
		link	a6,#cwdbuf
		lea	cwdbuf(a6),a0
		move.b	d0,(a0)+
		move.b	#':',(a0)+
		move.b	#'/',(a0)+
		move.l	a0,-(a7)
		sub.b	#'@',d0
		move.w	d0,-(a7)
		DOS	_CURDIR
		addq.l	#6,a7
		lea	cwdbuf(a6),a0
		bsr	bsltosl
		bsr	nputs
		unlk	a6
		bra	cdd_return_0

cdd_change:
		move.l	a0,-(a7)
		DOS	_CHDIR
		addq.l	#4,a7
		tst.l	d0
cdd_check_result:
		bmi	perror
cdd_return_0:
		moveq	#0,d0
		rts
****************************************************************
* getopt - cd/pushd/popd/dirs/pwd �̃I�v�V�����𓾂�
*
* CALL
*      A0     �������X�g�̐擪
*      D0.W   �����̐�
*
* RETURN
*      A0     ��I�v�V���������̐擪
*      D0.W   ��I�v�V���������̐�
*      A3     �f�B���N�g���o�̓��[�`���E�G���g���E�A�h���X
*      A4     �f�B���N�g���Ԃ̃Z�p���[�^�o�̓��[�`���E�G���g���E�A�h���X
*      D4.B   bit0:-l, bit1:-v, bit2:-s
*      CCR    ��������������� EQ
****************************************************************
getopt:
		lea	print_directory(pc),a3
		lea	put_space(pc),a4
		moveq	#0,d4
getopt_loop1:
		tst.w	d0
		beq	getopt_ok

		cmpi.b	#'-',(a0)
		bne	getopt_ok

		tst.b	1(a0)
		beq	getopt_ok

		subq.w	#1,d0
		addq.l	#1,a0
getopt_loop2:
		move.b	(a0)+,d2
		beq	getopt_loop1

		cmp.b	#'l',d2
		beq	getopt_l

		cmp.b	#'v',d2
		beq	getopt_v

		cmp.b	#'s',d2
		bne	getopt_return

		bset	#2,d4
		bra	getopt_loop2

getopt_v:
		bset	#1,d4
		lea	put_newline(pc),a4
		bra	getopt_loop2

getopt_l:
		bset	#0,d4
		lea	puts(pc),a3
		bra	getopt_loop2

getopt_ok:
		cmp.w	d0,d0
getopt_return:
		rts
****************************************************************
test_arg_minus:
		cmpi.b	#'-',(a0)
		bne	test_arg_plus

		tst.b	1(a0)
		bne	test_arg_plus

		lea	word_oldcwd,a0
		bsr	test_var
		beq	arg_minus_ok

		lea	word_home,a0
		bsr	test_var
		bne	chdir_home_error	*  D0.L := 1 .. error
arg_minus_ok:
						*  A0 == value of var
arg_name:
		moveq	#-1,d0			*  D0.L == -1 .. <name>
		rts
****************************************************************
test_arg_plus:
		cmpi.b	#'+',(a0)
		bne	arg_name		*  D0.L := -1 .. <name>

		addq.l	#1,a0			*  + �ɑ���
		bsr	atou			*  ���l���X�L��������
		bmi	dirs_bad_arg		*  �G���[�i�����������j .. D0.L := 1 .. error
		bne	dstack_not_deep		*  �G���[�i�I�[�o�[�t���[�j .. D0.L := 1 .. error

		cmpi.b	#'.',(a0)
		seq	d3			*  D3.B : dextract flag
		bne	get_dstack_arg

		addq.l	#1,a0
get_dstack_arg:
		tst.b	(a0)
		bne	dirs_bad_arg		*  D0.L := 1 .. error

		move.l	d1,d0			*  ���l�� 0 �Ȃ�΃G���[
		beq	dirs_bad_arg		*  D0.L := 1 .. error

		bsr	get_dstack_d0		*  D2.L := �v�f�̃I�t�Z�b�g
		bmi	dstack_not_deep		*  D0.L := 1 .. error

		subq.l	#1,d1			*  D1.L := n-1
		moveq	#0,d0			*  D0.L := 0 .. +<n>
		rts
****************************************************************
check_not_empty:
		moveq	#0,d0
		movea.l	dirstack(a5),a0
		tst.w	dirstack_nelement(a0)		*  �X�^�b�N�ɗv�f�������Ȃ��
		bne	test_return			*  D0 == 0

		bsr	perror_command_name
		lea	msg_directory_stack,a0
		bsr	eputs
		lea	msg_dstack_empty,a0
		bra	enputs1				*  D0 == 1
****************************************************************
*  Name
*       cd - change working directory
*
*  Synopsis
*       cd                go to home directory
*       cd +n             rotate to n'th be top
*	cd +n.            extract n'th directory and go to it
*	cd name           go to name
****************************************************************
.xdef cmd_cd

cmd_cd:
		lea	msg_cd_pushd_usage,a1
		bsr	getopt
		bne	dirs_bad_arg

		subq.w	#1,d0
		bcs	chdir_home			*  ������ 0�Ȃ� $home �� chdir ����
		bne	dirs_too_many_args		*  ������ 2�ȏ�Ȃ�G���[

		bsr	test_arg_minus
		bmi	cmd_cd_name
		bne	return
*  cd +<n>[.]
cmd_cd_plus:
		*  D1.L:n-1, D2.L:�v�f�̃I�t�Z�b�g
		bsr	popd				*  �����Ɉړ����A���������Ȃ�v�f���폜����
		bmi	return				*  �G���[�Ȃ炨���܂�

		bra	rotate_and_return		*  �v�f���z���肷��
*  cd <name>
cmd_cd_name:
		bsr	chdirx				*  �w��̃f�B���N�g����chdirx����
		bmi	return
		beq	return_0

		bra	pushd_popd_done
****************************************************************
*  Name
*       pushd - push directory stack
*
*  Synopsis
*       pushd               exchange current and top
*       pushd +n            rotate to let n'th be top
*       pushd +n.           extract n'th and push it to top
*	pushd directory     push current and chdir to directory
****************************************************************
.xdef cmd_pushd

cmd_pushd:
		lea	msg_cd_pushd_usage,a1
		bsr	getopt
		bne	dirs_bad_arg

		subq.w	#1,d0
		bcs	cmd_pushd_exchange		*  ������ 0�Ȃ�擪�v�f�ƃJ�����g������
		bne	dirs_too_many_args		*  ������ 2�ȏ�Ȃ�G���[

		bsr	test_arg_minus
		bmi	cmd_pushd_name
		bne	return
*  pushd +<n>[.]
		*  D1.L:n-1, D2.L:�v�f�̃I�t�Z�b�g
		bra	cmd_pushd_exchange_1

*  pushd (no arg)
cmd_pushd_exchange:
		bsr	check_not_empty
		bne	return

		st	d3
		moveq	#0,d1
		move.l	#dirstack_top,d2
cmd_pushd_exchange_1:
		bsr	push_cwd			*  ���̃J�����g�E�f�B���N�g�����v�b�V������
		beq	cmd_pushd_error_return

		add.l	d0,d2
		bsr	popd
		bne	cmd_pushd_fail

		addq.w	#1,d1
rotate_and_return:
		tst.b	d3				*  ���o���[�h�Ȃ�
		bne	pushd_popd_done			*  �z���肵�Ȃ�

		tst.l	d1				*  ���ɐ擪�ƂȂ��Ă���Ȃ��
		beq	pushd_popd_done			*  �z����̕K�v�Ȃ�

		movea.l	dirstack(a5),a0
		cmp.w	dirstack_nelement(a0),d1
		bhs	pushd_popd_done			*  �z����̕K�v�Ȃ�

		lea	(a0,d2.l),a1			*  A1 : �擪�ƂȂ�ׂ��A�h���X
		move.l	dirstack_bottom(a0),d0
		lea	(a0,d0.l),a2			*  A2 : ���݂̖����A�h���X(+1)
		lea	dirstack_top(a0),a0		*  A0 : �擪�̗v�f
		bsr	rotate				*  �v�f���z���肷��
		bra	pushd_popd_done
*  pushd <name>
cmd_pushd_name:
		movea.l	dirstack(a5),a1
		cmpi.w	#MAXWORDS-1,dirstack_nelement(a1)
		bhs	pushd_too_many_elements

		bsr	push_cwd			*  ���̃J�����g�E�f�B���N�g�����v�b�V������
		beq	cmd_pushd_error_return

		bsr	chdirx				*  �����Ɏw�肳�ꂽ�f�B���N�g����chdirx����
		bpl	pushd_popd_done
cmd_pushd_fail:
		move.l	#dirstack_top,d2		*  �v�b�V�������擪�̗v�f��
		bsr	delete_element			*  �폜����
cmd_pushd_error_return:
		moveq	#1,d0
		rts
****************
pushd_too_many_elements:
		bsr	perror_command_name
		lea	msg_directory_stack,a0
		bsr	eputs
		lea	msg_too_deep,a0
		bra	enputs1
****************************************************************
* push_cwd -  �J�����g�E�f�B���N�g�����v�b�V������
*
* CALL
*      none
*
* RETURN
*      D0.L  �����Ȃ�΁A�v�b�V�������J�����g�E�f�B���N�g���̒���(+1)
*            �G���[�Ȃ�� 0
*
*      CCR   TST.L D0
****************************************************************
push_cwd:
		link	a6,#cwdbuf
		movem.l	d1/a0-a2,-(a7)
		lea	cwdbuf(a6),a0
		bsr	getcwd
		bsr	strlen
		addq.l	#1,d0
		move.l	d0,d1				*  D1.L : strlen(cwd) + 1
		bsr	realloc_dirstack
		beq	push_cwd_fail

		movea.l	dirstack(a5),a2
		move.l	dirstack_bottom(a2),d0		*  D0.L : ���݂̃X�^�b�N�̒���
		lea	(a2,d0.l),a1			*  A1(source) : �]�����̖���(+1)
		lea	(a1,d1.l),a0			*  A0(destination)�͂���ɋ󂯂镶��������
		subq.l	#dirstack_top,d0
		bsr	memmovd				*  �V�t�g����
		lea	cwdbuf(a6),a1			*  �ȑO�̃J�����g�E�f�B���N�g����
		lea	dirstack_top(a2),a0		*  �X�^�b�N�̐擪��
		bsr	strcpy				*  �u��
		add.l	d1,dirstack_bottom(a2)		*  �o�C�g�����X�V����
		addq.w	#1,dirstack_nelement(a2)	*  �v�f�����C���N�������g����
		move.l	d1,d0
push_cwd_return:
		movem.l	(a7)+,d1/a0-a2
		unlk	a6
		rts

push_cwd_fail:
		bsr	perror_command_name
		bsr	insufficient_memory
		moveq	#0,d0
		bra	push_cwd_return
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
		lea	msg_popd_usage,a1
		bsr	getopt
		bne	dirs_bad_arg

		subq.w	#1,d0
		bcs	cmd_popd_noarg			*  ������ 0�Ȃ�|�b�v
		bne	dirs_too_many_args		*  ������ 2�ȏ�Ȃ�G���[

		bsr	test_arg_plus
		bne	dirs_bad_arg
*  popd +<n>[.]
		*  D2.L:���l�������v�f�̃I�t�Z�b�g
		bsr	delete_element			*  �v�f���폜����
		bra	pushd_popd_done

*  popd (no arg)
cmd_popd_noarg:
		bsr	check_not_empty
		bne	return

		move.l	#dirstack_top,d2		*  �擪��
		bsr	popd				*  �v�f�Ɉړ����A���������Ȃ�v�f���폜����
		bmi	return				*  �G���[
pushd_popd_done:
		tst.b	flag_pushdsilent(a5)
		bne	return_0

		btst	#2,d4
		bne	return_0

		bra	print_dirstack
****************************************************************
*  Name
*       dirs - print directory stack
*
*  Synopsis
*       dirs [ -lv ]
****************************************************************
.xdef cmd_dirs

cmd_dirs:
		lea	msg_dirs_usage,a1
		bsr	getopt
		bne	dirs_bad_arg

		btst	#2,d4				*  bit2�ȏ��
		bne	dirs_bad_arg			*  ����

		tst.w	d0
		bne	dirs_too_many_args
print_dirstack:
		moveq	#0,d2
		bsr	print_stacklevel
		bsr	print_cwd
		movea.l	dirstack(a5),a0
		move.w	dirstack_nelement(a0),d7
		beq	print_dirs_done

		subq.w	#1,d7
		jsr	(a4)
		lea	dirstack_top(a0),a0
		bra	print_dirs_start

print_dirs_loop:
		bsr	strfor1
		jsr	(a4)
print_dirs_start:
		bsr	print_stacklevel
		jsr	(a3)
		dbra	d7,print_dirs_loop
print_dirs_done:
		bsr	put_newline
		bra	return_0


dirs_bad_arg:
		bsr	bad_arg
		bra	dirs_usage

dirs_too_many_args:
		bsr	too_many_args
dirs_usage:
		movea.l	a1,a0
		bra	usage
****************************************************************
print_stacklevel:
		btst	#1,d4
		beq	print_stack_level_done

		movem.l	d0-d4,-(a7)
		move.l	d2,d0					*  �ԍ���
		moveq	#1,d1					*  ���l�߂�
		moveq	#1,d3					*  ���Ȃ��Ƃ� 1�����̕���
		moveq	#1,d4					*  ���Ȃ��Ƃ� 1���̐�����
		bsr	printu					*  �\������
		movem.l	(a7)+,d0-d4
		bsr	put_tab
		addq.l	#1,d2
print_stack_level_done:
		rts
****************************************************************
*  Name
*       pwd - print current working directory
*
*  Synopsis
*       pwd [ -l ]
****************************************************************
.xdef cmd_pwd

cmd_pwd:
		lea	msg_pwd_usage,a1
		bsr	getopt
		bne	dirs_bad_arg

		cmp.b	#2,d4				*  bit1�ȏ��
		bhs	dirs_bad_arg			*  ����

		tst.w	d0
		bne	dirs_too_many_args

		bsr	print_cwd
		bsr	put_newline
		bra	return_0
****************************************************************
print_cwd:
		link	a6,#cwdbuf
		lea	cwdbuf(a6),a0
		bsr	getcwd
		jsr	(a3)
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
* get_dstack_d0
*
* CALL
*      D0.L   �v�f�ԍ��i1�ȏ�ł��邱�Ɓj
*
* RETURN
*      D2.L   �f�B���N�g���E�X�^�b�N�� D0.L�Ԗڂ̗v�f�idstack�� n-1 �Ԗڂ̒P��j�̃I�t�Z�b�g
*             D0.L���v�f�������傫���Ȃ�� -1
*      CCR    TST.L D2
****************************************************************
.xdef get_dstack_d0

get_dstack_d0:
		move.l	a0,-(a7)
		moveq	#-1,d2
		cmp.l	#MAXWORDS-1,d0
		bhi	get_dstack_d0_return

		movea.l	dirstack(a5),a0
		cmp.w	dirstack_nelement(a0),d0	*  �f�B���N�g���E�X�^�b�N�̗v�f������
		bhi	get_dstack_d0_return		*  ���l���傫���Ȃ�΃G���[�D

		move.l	a0,-(a7)
		lea	dirstack_top(a0),a0
		subq.l	#1,d0
		bsr	strforn
		addq.l	#1,d0
		move.l	a0,d2
		sub.l	(a7)+,d2
		cmp.w	d0,d0
get_dstack_d0_return:
		movea.l	(a7)+,a0
		tst.l	d2
		rts
****************************************************************
* delete_element - D2.L ���w���f�B���N�g���v�f���폜����
*
* CALL
*      D2.L   �폜����f�B���N�g���v�f�̃I�t�Z�b�g
*
* RETURN
*      D0-D1/A0-A2   �j��
****************************************************************
delete_element:
		movea.l	dirstack(a5),a2
		move.l	dirstack_bottom(a2),d0
		lea	(a2,d0.l),a1
		move.l	a1,d0				*  D0.L : ���݂̖����A�h���X�i�̎��j
		lea	(a2,d2.l),a0
		bsr	strfor1
		movea.l	a0,a1				*  A1 : �폜����v�f�̎��̗v�f�̃A�h���X
		lea	(a2,d2.l),a0			*  A0 : �폜����v�f�̃A�h���X
		sub.l	a1,d0				*  D0 : �ړ�����o�C�g��
		move.l	a1,d1
		sub.l	a0,d1				*  D1.L : �폜����o�C�g��
		bsr	memmovi
		sub.l	d1,dirstack_bottom(a2)		*  ���݂̃o�C�g�����X�V����
		subq.w	#1,dirstack_nelement(a2)	*  �v�f�����f�N�������g����
		moveq	#0,d0
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
realloc_dirstack:
		movem.l	a0-a1,-(a7)
		movea.l	dirstack(a5),a1
		add.l	dirstack_bottom(a1),d0
		bsr	xmalloc
		beq	realloc_dirstack_return

		move.l	d0,dirstack(a5)
		move.l	d0,-(a7)
		movea.l	d0,a0
		move.l	dirstack_bottom(a1),d0
		move.l	a1,-(a7)
		bsr	memmovi
		move.l	(a7)+,d0
		bsr	free
		move.l	(a7)+,d0
realloc_dirstack_return:
		movem.l	(a7)+,a0-a1
		rts
****************************************************************
* popd - D2.L ���w���v�f�̃f�B���N�g���Ɉړ����C���̗v�f���폜����
*
* CALL
*      D2.L   �ړ�����f�B���N�g���v�f�̃I�t�Z�b�g
*
* RETURN
*      D0.L   ��������� 0�D�ړ��ł��Ȃ������Ȃ�Ε�
*      CCR    TST.L D0
*      A0     �j��
****************************************************************
popd:
		move.l	dirstack(a5),a0
		lea	(a0,d2.l),a0
		bsr	fish_chdir		*  �f�B���N�g���Ɉړ�����D
		bmi	perror

		bsr	delete_element
		moveq	#0,d0
		rts
****************************************************************
.data

.xdef word_cwd

word_upper_oldpwd:	dc.b	'OLD'
word_upper_pwd:		dc.b	'PWD',0
word_oldcwd:		dc.b	'old'
word_cwd:		dc.b	'cwd'
str_nul:		dc.b	0
msg_cd_pushd_usage:	dc.b	'[-lvs] [-|<���O>|+<n>[.]]',0
msg_popd_usage:		dc.b	'[-lvs] [+<n>]',0
msg_dirs_usage:		dc.b	'[-lv]',0
msg_pwd_usage:		dc.b	'[-l]',0
msg_directory_stack:	dc.b	'�f�B���N�g���E�X�^�b�N',0
msg_dstack_empty:	dc.b	'�͋�ł�',0
msg_too_deep:		dc.b	'�̗v�f����������t�ł�',0
msg_no_home:		dc.b	'�V�F���ϐ� home �̐ݒ肪�����ł�',0

.end

* b_dirs.s
* This contains built-in command 'cd'('chdir'), 'dirs', 'popd', 'pushd', 'cdd'.
*
* Itagaki Fumihiko 06-Oct-90  Create.

.include doscall.h
.include error.h
.include limits.h
.include stat.h
.include ../src/fish.h
.include ../src/dirstack.h

.xref issjis
.xref atou
.xref strlen
.xref strcpy
.xref stpcpy
.xref strfor1
.xref strforn
.xref rotate
.xref memmovd
.xref memmovi
.xref isopt
.xref isfullpathx
.xref scan_drive_name
.xref skip_slashes
.xref headtail
.xref cat_pathname
.xref make_sys_pathname
.xref get_fair_pathname
.xref bsltosl
.xref start_output
.xref end_output
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
.xref lgetmode
.xref is_under_home
.xref xmalloc
.xref free
.xref find_shellvar
.xref set_shellvar
.xref get_shellvar
.xref fish_setenv
.xref get_var_value
.xref perror
.xref pre_perror
.xref perror_command_name
.xref command_error
.xref usage
.xref bad_arg
.xref too_many_args
.xref dstack_not_deep
.xref insufficient_memory
.xref msg_too_long_pathname
.xref word_cdpath
.xref word_home

.xref pathname_buf

.xref cwd
.xref old_cwd
.xref dirstack
.xref cwd_changed
.xref flag_pushdsilent
.xref flag_refersysroot
.xref flag_symlinks

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
* getcdd - �w��h���C�u�̃J�����g�E�f�B���N�g���𓾂�
*
* CALL
*      D0.B   �h���C�u�� 'A'... �啶���łȂ���΂Ȃ�Ȃ�
*      A0     �i�[�o�b�t�@�iMAXPATH+1�o�C�g�K�v�j
*
* RETURN
*      none
*
* DESCRIPTION
*      �o�b�t�@�ɂ̓h���C�u�����̊��S�p�X�����i�[�����D
*      �f�B���N�g���̋�؂�� /
****************************************************************
.xdef getcdd

getcdd:
		movem.l	d0/a0,-(a7)
		move.b	d0,(a0)+
		move.b	#':',(a0)+
		move.b	#'/',(a0)+
		move.l	a0,-(a7)
		sub.b	#'@',d0
		and.w	#$ff,d0
		move.w	d0,-(a7)
		DOS	_CURDIR
		addq.l	#6,a7
		movem.l	(a7)+,d0/a0
		jmp	bsltosl
****************************************************************
.xdef is_nul_or_slash_or_backslash
.xdef is_slash_or_backslash

is_nul_or_slash_or_backslash:
		tst.b	d0
		beq	is_nul_or_slash_or_backslash_return
is_slash_or_backslash:
		cmp.b	#'/',d0
		beq	is_nul_or_slash_or_backslash_return

		cmp.b	#'\',d0
is_nul_or_slash_or_backslash_return:
		rts
****************************************************************
* normalize_pathname
*
* CALL
*      A0     pathname
*      A1     result buffer
*      A2     cwd to refference
*      D0.L   buffer size - 1�iMAXPATH�ȏ�K�v�j
*
* RETURN
*      D0.L   0 if success, otherwise -1.
*      CCR    TST.L D0
****************************************************************
normalize_pathname:
		link	a6,#cwdbuf
		movem.l	d2-d3/a0-a3,-(a7)
		move.l	d0,d2				*  D2.L : buffer size -1�i\0 �̕��j
		bsr	scan_drive_name
		exg	a0,a2				*  A0 : reference, A2 : expression
		bne	normalize_pathname_no_drive

		addq.l	#2,a2
		cmpa.l	#0,a0
		beq	normalize_pathname_getcdd

		cmp.b	(a0),d0
		beq	normalize_pathname_start
normalize_pathname_getcdd:
		lea	cwdbuf(a6),a0
		bsr	getcdd
		bra	normalize_pathname_start

normalize_pathname_no_drive:
		cmpa.l	#0,a0
		bne	normalize_pathname_start

		lea	cwdbuf(a6),a0
		bsr	getcwd
normalize_pathname_start:
		exg	a0,a1				*  A0 : buffer, A1 : reference
		movea.l	a0,a3
		bsr	stpcpy
		exg	a0,a3				*  A0 : operand top, A3 : operand bottom
		addq.l	#3,a0
		move.b	(a2),d0
		bsr	is_slash_or_backslash
		bne	normalize_pathname_loop

		clr.b	(a0)
		movea.l	a0,a3
normalize_pathname_loop:
		exg	a0,a2
		bsr	skip_slashes
		exg	a0,a2
		beq	normalize_pathname_done

		cmp.b	#'.',d0
		bne	normalize_pathname_down

		addq.l	#1,a2
		move.b	(a2),d0
		bsr	is_nul_or_slash_or_backslash
		beq	normalize_pathname_loop

		subq.l	#1,a2
		cmp.b	#'.',d0
		bne	normalize_pathname_down

		move.b	2(a2),d0
		bsr	is_nul_or_slash_or_backslash
		beq	normalize_pathname_up
normalize_pathname_down:
		move.l	a3,d3
		sub.l	a0,d3
		addq.l	#3,d3
		sub.l	d2,d3
		neg.l	d3
		cmpa.l	a0,a3
		beq	normalize_pathname_addone

		subq.l	#1,d3
		bcs	normalize_pathname_buffer_over

		move.b	#'/',(a3)+
normalize_pathname_addone:
		move.b	(a2)+,d0
		beq	normalize_pathname_done

		bsr	is_slash_or_backslash
		beq	normalize_pathname_loop

		subq.l	#1,d3
		bcs	normalize_pathname_buffer_over

		move.b	d0,(a3)+
		bsr	issjis
		bne	normalize_pathname_addone

		move.b	(a2)+,d0
		beq	normalize_pathname_done

		subq.l	#1,d3
		bcs	normalize_pathname_buffer_over

		move.b	d0,(a3)+
		bra	normalize_pathname_addone

normalize_pathname_up:
		addq.l	#2,a2
		clr.b	(a3)
		bsr	headtail
		beq	normalize_pathname_up_1

		subq.l	#1,a1
normalize_pathname_up_1:
		movea.l	a1,a3
		bra	normalize_pathname_loop

normalize_pathname_done:
		clr.b	(a3)
		moveq	#0,d0
normalize_pathname_return:
		movem.l	(a7)+,d2-d3/a0-a3
		unlk	a6
		rts

normalize_pathname_buffer_over:
		moveq	#-1,d0
		bra	normalize_pathname_return
****************************************************************
* set_oldcwd
*
*      ���� cwd �� ���� old_cwd, �V�F���ϐ� oldcwd, ���ϐ� OLDPWD
****************************************************************
set_oldcwd:
		movem.l	d0-d1/a0-a1,-(a7)
		lea	cwd(a5),a1
		lea	old_cwd(a5),a0
		bsr	strcpy
		lea	word_oldcwd,a0
		moveq	#1,d0
		sf	d1
		bsr	set_shellvar
		lea	word_upper_oldpwd,a0
		bsr	fish_setenv
		movem.l	(a7)+,d0-d1/a0-a1
		rts
****************************************************************
* reset_cwd
*
*      ���� cwd �� ���� old_cwd, �V�F���ϐ� oldcwd, ���ϐ� OLDPWD
*      DOS cwd �� ���� cwd, �V�F���ϐ� cwd, ���ϐ� PWD
*
* set_cwd
*
*      ���� cwd �� �V�F���ϐ� cwd, ���ϐ� PWD
****************************************************************
.xdef reset_cwd
.xdef set_cwd

reset_cwd:
		bsr	set_oldcwd
		move.l	a0,-(a7)
		lea	cwd(a5),a0
		bsr	getcwd
		movea.l	(a7)+,a0
set_cwd:
		movem.l	d0-d1/a0-a1,-(a7)
		lea	cwd(a5),a1
		lea	word_cwd,a0
		moveq	#1,d0
		sf	d1
		bsr	set_shellvar
		lea	word_upper_pwd,a0
		bsr	fish_setenv
		st	cwd_changed(a5)
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
		tst.b	flag_refersysroot(a5)
		beq	fish_chdir_1

		cmpi.b	#'/',(a0)
		bne	fish_chdir_1

		link	a6,#cwdbuf
		movem.l	a0-a1,-(a7)
		movea.l	a0,a1
		lea	cwdbuf(a6),a0
		bsr	make_sys_pathname
		bmi	cdsysroot_error

		bsr	fish_chdir_1
cdsysroot_return:
		movem.l	(a7)+,a0-a1
		unlk	a6
		rts

cdsysroot_error:
		moveq	#ENODIR,d0
		bra	cdsysroot_return

fish_chdir_1:
		link	a6,#cwdbuf
		movem.l	a0-a2,-(a7)
		suba.l	a2,a2
		move.b	flag_symlinks(a5),d0
		beq	fish_chdir_ignore_links		*  unset symlinks

		subq.b	#1,d0
		beq	fish_chdir_chase_links		*  set symlinks=chase

		*  set symlinks={ignore,expand}
		lea	cwd(a5),a2
fish_chdir_ignore_links:
		lea	cwdbuf(a6),a1
		moveq	#MAXPATH,d0
		bsr	normalize_pathname
		bmi	fish_chdir_chase_links

		movea.l	a1,a0
		bsr	chdir
		bmi	fish_chdir_return

		bsr	set_oldcwd
		lea	cwd(a5),a0
		bsr	strcpy
		bsr	set_cwd
		bra	fish_chdir_success_return
**
fish_chdir_chase_links:
		bsr	get_fair_pathname
		bcs	fish_chdir_fail

		bsr	chdir
		bmi	fish_chdir_return

		bsr	reset_cwd
fish_chdir_success_return:
		moveq	#0,d0
fish_chdir_return:
		movem.l	(a7)+,a0-a2
		unlk	a6
		rts

fish_chdir_fail:
		moveq	#ENODIR,d0
		bra	fish_chdir_return
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

		bra	isfullpathx
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
chdir_home_return:
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
		beq	chdir_home_return
		bmi	perror
bad_home:
		lea	msg_bad_home,a0
		bra	command_error
****************************************************************
* chdir_oldcwd - Change current working directory and drive to old_cwd
*
* CALL
*      none
*
* RETURN
*      A0     �j��
*
*      D0.L   old_cwd �� chdir �ł����Ȃ�� 1
*             �G���[�Ȃ�Ε��D�i�G���[�E���b�Z�[�W���o�͂���j
*
*      CCR    TST.L D0
****************************************************************
chdir_oldcwd:
		lea	old_cwd(a5),a0
		bsr	fish_chdir
		bmi	perror

		moveq	#1,d0
		rts
****************************************************************
* complex_chdir - Change current working directory and/or drive.
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
*           / ./ ../ �Ŏn�܂��Ă��Ȃ��ꍇ�Ɍ���j
*                chdir(concat($cdpath[1], name))
*                chdir(concat($cdpath[2], name))
*                             :
*                chdir(concat($cdpath[$#cdpath], name))
*                chdir($name)
****************************************************************
complex_chdir:
		movem.l	d1-d2/a0-a3,-(a7)
		tst.b	(a0)
		bne	complex_chdir_try

		bsr	chdir_home
		bne	complex_chdir_error
		bra	complex_chdir_done1

complex_chdir_try:
		bsr	fish_chdir			*  �J�����g�E�f�B���N�g����ύX����
		move.l	d0,d2
		bpl	complex_chdir_done		*  ���������Ȃ�A��

		cmpi.b	#':',1(a0)			*  �h���C�u�w�肪����ꍇ��
		beq	complex_chdir_perror		*  ����ȏ�g���C���Ȃ�

		movea.l	a0,a1
		cmpi.b	#'.',(a1)
		bne	complex_chdir_1

		addq.l	#1,a1
		cmpi.b	#'.',(a1)
		bne	complex_chdir_1

		addq.l	#1,a1
complex_chdir_1:
		move.b	(a1),d0
		bsr	is_nul_or_slash_or_backslash	*  . .. /* ./* ../* �Ȃ��
		beq	complex_chdir_perror		*  ����ȏ�g���C���Ȃ�

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
complex_chdir_done1:
		moveq	#1,d0
		bra	complex_chdir_done

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
		move.l	d0,d2
		beq	complex_chdir_done1
		bmi	complex_chdir_perror

		movea.l	a2,a0
		moveq	#ENODIR,d2
complex_chdir_perror:
		move.l	d2,d0
		bsr	perror
complex_chdir_error:
		moveq	#-1,d0
complex_chdir_done:
		movem.l	(a7)+,d1-d2/a0-a3
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
		move.w	d0,d1			*  D1.W : �����̐�
		DOS	_CURDRV			*  D0.W : �J�����g�E�h���C�u�ԍ� (A:0, B:1, ...)
		move.w	d0,d2			*  D2.W : �Ώۃh���C�u�ԍ��i�b��j
		subq.w	#1,d1			*  ������
		bhi	too_many_args		*  2�ȏ゠��΃G���[
		blo	cdd_print		*  0�Ȃ�Ε\��

		tst.b	(a0)
		beq	cdd_print

		move.w	d0,d1			*  D1.W : �J�����g�E�h���C�u�ԍ�
		bsr	scan_drive_name
		bne	cdd_current_drive

		moveq	#0,d2
		move.b	d0,d2
		sub.b	#'A',d2			*  D2.W : �Ώۃh���C�u�ԍ�
		bclr	#31,d0
		bsr	drvchk
		bmi	perror

		tst.b	2(a0)
		bne	do_cdd
cdd_print:
		move.b	d2,d0
		add.b	#'A',d0
		lea	pathname_buf,a0
		bsr	getcdd
		bsr	nputs
		bra	cdd_return_0

cdd_current_drive:
		bsr	strlen
		cmp.l	#MAXPATH-MAXDRIVE,d0
		bhi	cdd_too_long

		movea.l	a0,a1
		lea	pathname_buf,a0
		move.b	d1,d0
		add.b	#'A',d0
		move.b	d0,(a0)+
		move.b	#':',(a0)+
		bsr	strcpy
		lea	pathname_buf,a0
do_cdd:
		bsr	lgetmode
		bmi	do_cdd_1

		btst	#MODEBIT_LNK,d0
		bne	cdd_link
do_cdd_1:
		movea.l	a0,a1
		bsr	get_fair_pathname
		exg	a0,a1
		bcs	cdd_too_long

		move.l	a1,-(a7)
		DOS	_CHDIR
		addq.l	#4,a7
		tst.l	d0
		bmi	perror

		cmp.w	d1,d2
		bne	cdd_return_0

		bsr	reset_cwd
cdd_return_0:
		moveq	#0,d0
		rts

cdd_link:
		bsr	perror_command_name
		bsr	pre_perror
		lea	msg_illegal_cdd,a0
		bra	enputs1

cdd_too_long:
		bsr	perror_command_name
		bsr	pre_perror
		lea	msg_too_long_pathname,a0
		bra	enputs1
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
		bsr	isopt
		beq	getopt_loop2
getopt_ok:
		cmp.w	d0,d0
getopt_return:
		rts

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
****************************************************************
test_arg_minus:
		cmpi.b	#'-',(a0)
		bne	test_arg_plus

		tst.b	1(a0)
		bne	test_arg_plus

		lea	chdir_oldcwd(pc),a2
arg_name:
		moveq	#-1,d0			*  D0.L := -1 .. <name>
		rts

test_arg_plus:
		lea	complex_chdir(pc),a2
		cmpi.b	#'+',(a0)
		bne	arg_name

		addq.l	#1,a0			*  + �ɑ���
		bsr	atou			*  ���l���X�L��������
		bmi	dirs_bad_arg		*  ���������� .. D0.L := 1 .. error
		bne	dstack_not_deep		*  �I�[�o�[�t���[ .. D0.L := 1 .. error

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
pushd_popd_return_0:
print_dirs_return_0:
cmd_pwd_return_0:
cmd_cd_return_0:
		moveq	#0,d0			*  D0.L := 0 .. +<n>
cmd_cd_return:
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
*       cd -              go to last directory
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
		bne	cmd_cd_return
*  cd +<n>[.]
cmd_cd_plus:
		*  D1.L:n-1, D2.L:�v�f�̃I�t�Z�b�g
		bsr	popd				*  �����Ɉړ����A���������Ȃ�v�f���폜����
		bmi	cmd_cd_return			*  �G���[�Ȃ炨���܂�

		bra	rotate_and_return		*  �v�f���z���肷��
*  cd <name>
cmd_cd_name:
		jsr	(a2)
		bmi	cmd_cd_return
		beq	cmd_cd_return
		bra	pushd_popd_done
****************************************************************
*  Name
*       pushd - push directory stack
*
*  Synopsis
*       pushd               exchange current and top
*       pushd -             push current and chdir to last directory
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
		bne	cmd_pushd_return
*  pushd +<n>[.]
		*  D1.L:n-1, D2.L:�v�f�̃I�t�Z�b�g
		bra	cmd_pushd_exchange_1

*  pushd (no arg)
cmd_pushd_exchange:
		bsr	check_not_empty
		bne	cmd_pushd_return

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
		jsr	rotate				*  �v�f���z���肷��
		bra	pushd_popd_done
*  pushd <name>
cmd_pushd_name:
		movea.l	dirstack(a5),a1
		cmpi.w	#MAXWORDS-1,dirstack_nelement(a1)
		bhs	pushd_too_many_elements

		bsr	push_cwd			*  ���̃J�����g�E�f�B���N�g�����v�b�V������
		beq	cmd_pushd_error_return

		jsr	(a2)
		bpl	pushd_popd_done
cmd_pushd_fail:
		move.l	#dirstack_top,d2		*  �v�b�V�������擪�̗v�f��
		bsr	delete_element			*  �폜����
cmd_pushd_error_return:
		moveq	#1,d0
cmd_pushd_return:
cmd_popd_return:
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
		movem.l	d1/a0-a2,-(a7)
		lea	cwd(a5),a0
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
		jsr	memmovd				*  �V�t�g����
		lea	cwd(a5),a1			*  �ȑO�̃J�����g�E�f�B���N�g����
		lea	dirstack_top(a2),a0		*  �X�^�b�N�̐擪��
		bsr	strcpy				*  �u��
		add.l	d1,dirstack_bottom(a2)		*  �o�C�g�����X�V����
		addq.w	#1,dirstack_nelement(a2)	*  �v�f�����C���N�������g����
		move.l	d1,d0
push_cwd_return:
		movem.l	(a7)+,d1/a0-a2
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
		bne	cmd_popd_return

		move.l	#dirstack_top,d2		*  �擪��
		bsr	popd				*  �v�f�Ɉړ����A���������Ȃ�v�f���폜����
		bmi	cmd_popd_return			*  �G���[
pushd_popd_done:
		tst.b	flag_pushdsilent(a5)
		bne	pushd_popd_return_0

		btst	#2,d4
		bne	pushd_popd_return_0

		bra	print_dirstack
****************************************************************
*  Name
*       dirs - print directory stack
*
*  Synopsis
*       dirs [ -lv ]
****************************************************************
.xdef cmd_dirs
.xdef print_dirstack

cmd_dirs:
		lea	msg_dirs_usage,a1
		bsr	getopt
		bne	dirs_bad_arg

		btst	#2,d4				*  bit2�ȏ��
		bne	dirs_bad_arg			*  ����

		tst.w	d0
		bne	dirs_too_many_args
print_dirstack:
		bsr	start_output
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
		bsr	end_output
		bra	print_dirs_return_0


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

		bsr	start_output
		bsr	print_cwd
		bsr	put_newline
		bsr	end_output
		bra	cmd_pwd_return_0
****************************************************************
print_cwd:
		lea	cwd(a5),a0
		jmp	(a3)
****************************************************************
print_directory:
		movem.l	d0/a0,-(a7)
		jsr	is_under_home
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

		movem.l	d1/a1-a2,-(a7)
		bsr	delete_element
		movem.l	(a7)+,d1/a1-a2
		moveq	#0,d0
		rts
****************************************************************
.data

word_upper_oldpwd:	dc.b	'OLD'
word_upper_pwd:		dc.b	'PWD',0
word_oldcwd:		dc.b	'old'
word_cwd:		dc.b	'cwd',0
msg_cd_pushd_usage:	dc.b	'[-lvs] [--] [<���O>|+<n>[.]|-]',0
msg_popd_usage:		dc.b	'[-lvs] [+<n>]',0
msg_dirs_usage:		dc.b	'[-lv]',0
msg_pwd_usage:		dc.b	'[-l]',0
msg_directory_stack:	dc.b	'�f�B���N�g���E�X�^�b�N',0
msg_dstack_empty:	dc.b	'�͋�ł�',0
msg_too_deep:		dc.b	'�̗v�f����������t�ł�',0
msg_bad_home:		dc.b	'�V�F���ϐ� home �̐ݒ肪�����ł�',0
msg_illegal_cdd:	dc.b	'�����N�ł�'
str_nul:		dc.b	0

.end

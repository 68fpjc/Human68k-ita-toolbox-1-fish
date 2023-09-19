**
**  fish - Fumihiko Itagaki SHell
**
**  for Human68k (version 2.0 or lator)
**

.include doscall.h
.include iocscall.h
.include error.h
.include limits.h
.include chrcode.h
.include stat.h
.include pwd.h
.include irandom.h
.include ../src/fish.h
.include ../src/var.h
.include ../src/dirstack.h
.include ../src/source.h
.include ../src/function.h
.include ../src/history.h
.include ../src/loop.h

PDB_envPtr	equ	$00
PDB_argPtr	equ	$10
PDB_ProcessFlag	equ	$50

PDB_dataPtr	equ	$f0
PDB_stackPtr	equ	$f8

.xref iscsym
.xref isspace3
.xref issjis
.xref atou
.xref itoa
.xref utoa
.xref strlen
.xref strchr
.xref strcmp
.xref memcmp
.xref strcpy
.xref stpcpy
.xref strbot
.xref strdup
.xref strfor1
.xref strforn
.xref stricmp
.xref strmove
.xref strazcpy
.xref memmovi
.xref wordlistpcmp
.xref wordlistlen
.xref make_wordlist
.xref copy_wordlist
.xref words_to_line
.xref strip_quotes
.xref strip_quotes_list
.xref bsltosl
.xref sltobsl
.xref xmalloc
.xref free
.xref xfree
.xref xfreep
.xref free_all_tmp
.xref free_all_memory_reg_saved
.xref putc
.xref eputc
.xref puts
.xref eputs
.xref ecputs
.xref nputs
.xref enputs
.xref enputs1
.xref put_newline
.xref eput_newline
.xref printu
.xref printfi
.xref echo
.xref isblkdev
.xref isnotttyin
.xref tfopen
.xref fgetc
.xref fgets
.xref fclose
.xref fclosexp
.xref fskip_space
.xref remove
.xref redirect
.xref unredirect
.xref create_savefile
.xref create_normal_file
.xref tmpfile
.xref stat
.xref getcwd
.xref chdir
.xref drvchkp
.xref contains_dos_wildcard
.xref headtail
.xref split_pathname
.xref cat_pathname
.xref suffix
.xref make_sys_pathname
.xref DecodeHUPAIR
.xref EncodeHUPAIR
.xref SetHUPAIR
.xref fish_getenv
.xref fish_setenv
.xref rehash
.xref set_shellvar
.xref set_shellvar_num
.xref set_shellvar_nul
.xref get_shellvar
.xref get_var_value
.xref dupvar
.xref varsize
.xref reset_cwd
.xref set_oldcwd
.xref clear_flagvars
.xref init_key_bind
.xref put_prompt_1
.xref getline
.xref getline_phigical
.xref enter_history
.xref find_history
.xref expand_wordlist_var
.xref expand_wordlist
.xref subst_history
.xref subst_alias
.xref subst_var
.xref subst_var_2
.xref subst_var_wordlist
.xref subst_command
.xref subst_command_2
.xref unpack_word
.xref expand_tilde
.xref glob
.xref test_nonomatch
.xref get_dstack_d0
.xref isquoted
.xref isfullpath
.xref skip_paren
.xref check_wildcard
.xref find_shellvar
.xref svartou
.xref svartol
.xref divul
.xref mulul
.xref minmaxul
.xref init_irandom
.xref hash
.xref do_print_history
.xref find_function
.xref enter_function
.xref do_defun
.xref source_goto_onintr
.xref abort_loops
.xref state_if
.xref state_else
.xref state_endif
.xref state_function
.xref state_sub_function
.xref state_nonsub_function
.xref state_endfunc
.xref state_switch
.xref state_case
.xref state_default
.xref state_endsw
.xref state_foreach
.xref state_while
.xref state_end
.xref cmd_set_expression
.xref cmd_alias
.xref cmd_alloc
.if 0
.xref cmd_apply
.endif
.xref cmd_bind
.xref cmd_break
.xref cmd_breaksw
.xref cmd_cd
.xref cmd_cdd
.xref cmd_continue
.xref cmd_dirs
.xref cmd_echo
.xref cmd_eval
.xref cmd_exec
.xref cmd_exit
.xref cmd_glob
.xref cmd_goto
.xref cmd_hashstat
.xref cmd_history
.xref cmd_functions
.xref cmd_logout
.xref cmd_onintr
.xref cmd_popd
.xref cmd_printf
.xref cmd_pushd
.xref cmd_pwd
.xref cmd_rehash
.xref cmd_repeat
.xref cmd_return
.xref cmd_set
.xref cmd_setenv
.xref cmd_shift
.xref cmd_source
.xref cmd_srand
.xref cmd_time
.xref cmd_unalias
.xref cmd_undefun
.xref cmd_unhash
.xref cmd_unset
.xref cmd_unsetenv
.xref cmd_which
.if 0
.xref cmd_xargs
.endif
.xref pre_perror
.xref perror
.xref syntax_error
.xref too_long_line
.xref too_many_words
.xref no_match
.xref ambiguous
.xref insufficient_memory
.xref cannot_because_no_memory
.xref msg_syntax_error
.xref word_cwd
.xref word_echo
.xref word_glob
.xref word_execbit
.xref word_symlinks
.xref word_verbose

auto_pathname	equ	(((MAXPATH+1)+1)>>1<<1)

.text
*****************************************************************
texttop:					*   BIND��  :��BIND��
	dc.l	bsstop				* 0(texttop):$f0(PDB): �q�V�F�����̃f�[�^�̃A�h���X
	dc.l	bsstop+bsssize-texttop		* 4(texttop):$f4(PDB): BIND�ł́A�؂�l�߂�傫��
	dc.l	bsstop+bsssize+STACKSIZE	* 8(texttop):$f8(PDB): �X�^�b�N�E�|�C���^�̏����l
	dc.l	bsssize				*12(texttop):$fc(PDB): �q�V�F�����̃f�[�^�̑傫��
*****************************************************************
.even
start:
		bra.s	start1
str_hupair:	dc.b	'#HUPAIR',0
start1:
	**
	**  �v���O�����E�X�^�b�N�E�|�C���^��ݒ肷��
	**  ��BIND�łȂ�΃�������؂�l�߂�
	**
		DOS	_GETPDB
		movea.l	d0,a4				*  A4 : PDB�A�h���X
		movea.l	PDB_stackPtr(a4),a7
		lea	texttop-$f0,a0			*  A0 : ��BIND�łȂ�΁Atexttop == PDB + $f0
		cmpa.l	d0,a0
		bne	binded

		move.l	a7,d0
		sub.l	a0,d0
		move.l	d0,-(a7)
		move.l	a0,-(a7)
		DOS	_SETBLOCK
		addq.l	#8,a7
binded:
		st	in_fish
		sf	doing_logout
		clr.b	argument_pathname
	**
	**  �i���[�g�E�V�F���Ȃ�΁j�����ݒ肷��
	**
		movea.l	PDB_dataPtr(a4),a5		*  A5 : �����̃f�[�^�̃A�h���X
		cmpa.l	#bsstop,a5
		bne	i_am_not_root_shell

		move.l	#1,pid_count
i_am_not_root_shell:
		move.l	a7,stackp(a5)
		bsr	disable_break			*  ���������ςނ܂Ńu���[�N���֎~����
		bsr	init_bss
		clr.b	linecutbuf(a5)
		move.l	pid_count,pid(a5)
		add.l	#1,pid_count
		move.l	#1,current_eventno(a5)
		clr.l	hash_hits(a5)
		clr.l	hash_misses(a5)
		sf	hash_flag(a5)
		sf	in_function(a5)
		moveq	#0,d0
		bsr	isnotttyin
		move.b	d0,input_is_tty(a5)		*  �[���Ȃ��0
		move.b	d0,interactive_mode(a5)		*  �[���Ȃ��0�ɂ��Ă���
		bsr	init_key_bind
		*
		*  �f�B���N�g���E�X�^�b�N��������
		*
		moveq	#dirstack_top,d0
		bsr	xmalloc
		beq	abort_because_of_insufficient_memory

		movea.l	d0,a0
		move.l	#dirstack_top,dirstack_bottom(a0)
		clr.w	dirstack_nelement(a0)
		move.l	a0,dirstack(a5)
		*
		*  ����������
		*
		movea.l	PDB_envPtr(a4),a0		*  A0 : �e����󂯎�������G���A�̐擪�A�h���X
		cmpa.l	#-1,a0
		beq	init_env_done

		addq.l	#4,a0
init_env_loop:
		tst.b	(a0)
		beq	init_env_done

		movea.l	a0,a1
		moveq	#'=',d0
		bsr	strchr				*  '=' �ɃV�t�gJIS�̍l���͕s�v
		exg	a0,a1
		move.b	(a1),d1
		beq	init_env_1

		clr.b	(a1)+
init_env_1:
		bsr	fish_setenv
		beq	abort_because_of_insufficient_memory

		tst.b	d1
		beq	init_env_2

		move.b	#'=',-1(a1)
init_env_2:
		bsr	strfor1
		bra	init_env_loop

init_env_done:
		clr.l	fork_stackp(a5)
		move.w	#'!',histchar1(a5)
		move.w	#'^',histchar2(a5)
		lea	default_wordchars,a0
		move.l	a0,wordchars(a5)
		bsr	clear_flagvars
		clr.b	last_congetbuf(a5)
		clr.b	last_congetbuf+1(a5)
	**
	**  $%FISHCONFIG�����߂���
	**
		lea	word_upper_fishconfig,a0
		bsr	fish_getenv
		beq	parse_fishconfig_done

		bsr	get_var_value
		movea.l	a0,a1
parse_fishconfig_loop:
		move.b	(a1)+,d0
		beq	parse_fishconfig_done

		bsr	issjis
		beq	parse_fishconfig_ignore_next

		cmp.b	#'l',d0
		beq	fishconfig_l

		cmp.b	#'x',d0
		bne	parse_fishconfig_loop
fishconfig_x:
		lea	word_execbit,a0
		bra	fishconfig_set

fishconfig_l:
		lea	word_symlinks,a0
fishconfig_set:
		bsr	set_shellvar_nul
		bra	parse_fishconfig_loop

parse_fishconfig_ignore_next:
		tst.b	(a1)+
		bne	parse_fishconfig_loop
parse_fishconfig_done:
	**
	**  ���������߂���
	**
		movea.l	PDB_argPtr(a4),a0
		addq.l	#1,a0
		bsr	strlen
		addq.l	#1,d0
		bsr	xmalloc
		beq	abort_because_of_insufficient_memory

		movea.l	d0,a1
		bsr	DecodeHUPAIR
		move.l	d0,d5				*  D5.L : �����J�E���^
		exg	a0,a1				*  A0   : �����|�C���^,  A1 : ARG0
	*
	*  ���O�C���E�V�F���ł��邩�ǂ����𔻒肷��
	*
		*
		*  ����0�̍ŏ��̕�����'-'�Ȃ�΃��O�C���E�V�F���Ƃ���
		*
		sf	i_am_login_shell(a5)
		movem.l	a0-a1,-(a7)
		movea.l	PDB_argPtr(a4),a0
		subq.l	#8,a0
		lea	str_hupair,a1
		bsr	strcmp
		movem.l	(a7)+,a0-a1
		bne	check_l				*  ARG0�͖���

		cmpi.b	#'-',(a1)
		beq	set_login_shell_flag
check_l:
		*
		*  ������ -l �݂̂Ȃ�΃��O�C���E�V�F���Ƃ���
		*
		cmp.w	#1,d5
		bne	begin_parse_args

		lea	str_option_l,a1
		bsr	strcmp
		bne	begin_parse_args

		moveq	#0,d5
set_login_shell_flag:
		st	i_am_login_shell(a5)		*  ���O�C���E�V�F���ƂȂ�
		*
		*  $HOME �� chdir ����
		*
		move.l	a0,-(a7)
		lea	word_upper_home,a0
		bsr	fish_getenv
		beq	no_home

		bsr	get_var_value
		bsr	chdir
		bpl	chdir_home_done

		bsr	perror
		bra	chdir_home_done

no_home:
		lea	msg_no_home,a0
		bsr	enputs
chdir_home_done:
		movea.l	(a7)+,a0
begin_parse_args:
	*
	*  ���������߂���
	*
		clr.l	arg_command(a5)			*  �Ō�� -c �̃R�}���h
		sf	not_execute(a5)			*  -n
		sf	exit_on_error(a5)		*  -e
		sf	flag_t(a5)			*  -t
		clr.l	d7				*  bc-----------------------vxfshd
parse_args_loop:
		tst.l	d5
		beq	done_flag_argument_parsing

		btst	#31,d7				*  -b occurence
		bne	done_flag_argument_parsing

		cmpi.b	#'-',(a0)
		bne	done_flag_argument_parsing

		subq.l	#1,d5
		addq.l	#1,a0
parse_one_arg_loop:
		move.b	(a0)+,d0
		beq	parse_one_arg_done

		cmp.b	#'t',d0			*  -t : �W�����͂���̃R�}���h��1�s���s���ďI������
		beq	flag_t_found

		cmp.b	#'n',d0			*  -n : �R�}���h�����s���Ȃ�
		beq	flag_n_found

		cmp.b	#'e',d0			*  -e : �G���[�ŏI������
		beq	flag_e_found

		cmp.b	#'i',d0			*  -i : �Θb���[�h
		beq	flag_i_found

		moveq	#31,d1
		cmp.b	#'b',d0			*  -b : �t���O�����̉��߂��u���[�N����
		beq	set_flag

		moveq	#30,d1
		cmp.b	#'c',d0			*  -c : �����̃R�}���h�����s���ďI������
		beq	set_flag

		moveq	#0,d1
		cmp.b	#'d',d0			*  -d : ~/.fishdirs��source����
		beq	set_flag

		moveq	#1,d1
		cmp.b	#'h',d0			*  -h : �����ȋN�� .. ������ǂݍ��܂Ȃ�
		beq	set_flag

		moveq	#2,d1
		cmp.b	#'s',d0			*  -s : �R�}���h�͕W�����͂���ǂݎ��
		beq	set_flag

		moveq	#3,d1
		cmp.b	#'f',d0			*  -f : �����ȋN�� .. ���t�@�C�������s���Ȃ�
		beq	set_flag

		moveq	#4,d1
		cmp.b	#'x',d0			*  -x : echo ��set����
		beq	set_flag

		moveq	#5,d1
		cmp.b	#'v',d0			*  -v : verbose ��set����
		beq	set_flag

		cmp.b	#'X',d0			*  -X : ~/.fishrc �����s����O�� echo ��set����
		beq	set_x_now

		cmp.b	#'V',d0			*  -V : ~/.fishrc �����s����O�� verbose ��set����
		beq	set_v_now

		bsr	issjis
		bne	parse_one_arg_loop

		tst.b	(a0)+
		bne	parse_one_arg_loop
parse_one_arg_done:
		btst	#30,d7				*  -c occurence
		beq	parse_args_loop

		bclr	#30,d7
		move.l	#-1,arg_command(a5)
		tst.l	d5
		beq	parse_args_loop

		move.l	a0,arg_command(a5)
		bsr	strfor1
		subq.l	#1,d5
		bra	parse_args_loop

flag_n_found:
		st	not_execute(a5)
		bra	parse_one_arg_loop

flag_e_found:
		st	exit_on_error(a5)
		bra	parse_one_arg_loop

flag_t_found:
		st	flag_t(a5)
		bra	parse_one_arg_loop

flag_i_found:
		st	interactive_mode(a5)
		moveq	#2,d1				*  -s
set_flag:
		bset	d1,d7
		bra	parse_one_arg_loop

set_v_now:
		bsr	set_verbose
		bra	parse_one_arg_loop

set_x_now:
		bsr	set_echo
		bra	parse_one_arg_loop

done_flag_argument_parsing:
		move.b	d7,flags(a5)
		move.l	a0,arg_script(a5)
	**
	**  �N�����̍�ƃf�B���N�g�����o���Ă���
	**
		lea	first_cwd(a5),a0
		bsr	getcwd
	**
	**  $0 �� $argv �������ݒ肷��
	**
		movea.l	arg_script(a5),a0
		clr.l	arg_script(a5)
		tst.l	d5
		beq	set_init_argv

		tst.b	flag_t(a5)			*  -t
		bne	set_init_argv

		btst.b	#2,flags(a5)			*  -s
		bne	set_init_argv

		tst.l	arg_command(a5)			*  -c
		bne	set_init_argv

		move.l	a0,arg_script(a5)
		bsr	strfor1
		subq.l	#1,d5
set_init_argv:
		movea.l	a0,a1
		move.l	d5,d0
		cmp.l	#MAXWORDS,d0
		bls	set_init_argv_1

		lea	word_argv,a0
		bsr	pre_perror
		bsr	too_many_words
		moveq	#0,d0
set_init_argv_1:
		bsr	set_argv
	**
	**  ���ϐ����V�F���ϐ��ɃC���|�[�g����
	**
		*
		*  path -> path
		*
		bsr	import_path
		*
		*  temp -> temp
		*
		lea	word_temp,a2
		movea.l	a2,a1
		st	d0				*  \ �� / �ɒu��������
		bsr	import
		*
		*  USER or LOGNAME -> user
		*
		lea	word_user,a2
		lea	word_upper_user,a1
		bsr	importn
		bpl	import_user_done

		lea	word_upper_logname,a1
		bsr	importn
import_user_done:
		*
		*  TERM -> term
		*
		lea	word_term,a2
		lea	word_upper_term,a1
		bsr	importn
		*
		*  HOME -> home
		*
		lea	word_home,a2
		lea	word_upper_home,a1
		bsr	importn
		*
		*  UID -> uid
		*
		lea	word_uid,a2
		lea	word_upper_uid,a1
		bsr	importn
		*
		*  GID -> gid
		*
		lea	word_gid,a2
		lea	word_upper_gid,a1
		bsr	importn
		*
		*  ++SHLVL -> shlvl
		*
		moveq	#0,d2
		lea	word_upper_shlvl,a0
		bsr	fish_getenv
		beq	set_shlvl

		bsr	get_var_value
		bsr	atou
		bne	set_shlvl

		tst.b	(a0)
		bne	set_shlvl

		move.l	d1,d2
set_shlvl:
		move.l	d2,d0
		addq.l	#1,d0
		lea	word_shlvl,a0
		st	d1				*  export����
		bsr	set_shellvar_num
	**
	**  ���̑��̃V�F���ϐ��������ݒ肷��
	**
		sf	d1				*  D1.B := 0 ; export���Ȃ�
		*
		*  batshell
		*
		lea	init_batshell,a1
		lea	pathname_buf,a0
		bsr	make_sys_pathname
		bmi	set_batshell_done

		bsr	bsltosl
		movea.l	a0,a1
		lea	word_batshell,a0
		moveq	#1,d0
		bsr	set_shellvar
set_batshell_done:
		*
		*  shell
		*
		lea	init_shell,a1
		lea	tmpargs,a0
		bsr	make_sys_pathname
		bmi	set_shell_done

		bsr	bsltosl
		bsr	strfor1
		lea	init_shell_init_arg,a1
		bsr	strcpy
		lea	tmpargs,a1
		lea	word_shell,a0
		moveq	#2,d0
		bsr	set_shellvar
set_shell_done:
		*
		*  misc. static variables
		*
		lea	initial_vars_script_mode,a2
		tst.l	arg_script(a5)
		bne	set_initial_vars

		tst.l	arg_command(a5)			* -c
		bne	set_initial_vars

		tst.b	flag_t(a5)			* -t
		bne	set_initial_vars

		lea	initial_vars_stdin_mode,a2
set_initial_vars:
		tst.l	(a2)
		beq	set_initial_vars_done

		move.l	(a2)+,a0			*  A0 := �ϐ���
		move.l	(a2)+,a1			*  A1 := �l
		move.w	(a2)+,d0			*  D0.W := �l�̌ꐔ
		bsr	set_shellvar
		bra	set_initial_vars

set_initial_vars_done:
		*
		*  cwd
		*
		bsr	reset_cwd
		*
		*  status
		*
		bsr	clear_status
	**
	**  �V�O�i���������[�`����ݒ肵�C�u���[�N�E�t���O�����ɖ߂�
	**
		sf	interrupted(a5)
		lea	login_interrupted(pc),a0
		move.l	a0,mainjmp(a5)
		pea	manage_interrupt_signal(pc)
		move.w	#_CTRLVC,-(a7)
		DOS	_INTVCS
		addq.l	#6,a7
		pea	manage_abort_signal(pc)
		move.w	#_ERRJVC,-(a7)
		DOS	_INTVCS
		addq.l	#6,a7
		bsr	resume_breakflag
	**
	**  �X�^�[�g�A�b�v
	**
		btst.b	#3,flags(a5)			*  -f���w�肳��Ă���Ȃ�
		bne	startup_done			*  ���Ȃ�
		*
		*  $SYSROOT/etc/fishrc
		*
		lea	etc_fishrc,a1
		lea	pathname_buf,a0
		bsr	make_sys_pathname
		bmi	etc_fishrc_done

		clr.b	d7
		bsr	run_source_if_any
etc_fishrc_done:
		*
		*  ~/.fishrc
		*
		lea	dot_fishrc,a1
		bsr	run_home_source_if_any
		bpl	home_fishrc_done

		lea	percent_fishrc,a1
		bsr	run_home_source_if_any
home_fishrc_done:
		*
		*  ~/.login
		*
		tst.b	i_am_login_shell(a5)		*  ���O�C���E�V�F���łȂ����
		beq	home_login_done			*  ���Ȃ�

		lea	dot_login,a1
		bsr	run_home_source_if_any
		bpl	home_login_done

		lea	percent_login,a1
		bsr	run_home_source_if_any
home_login_done:
		*
		*  ~/.fishdirs
		*
		tst.b	i_am_login_shell(a5)		*  ���O�C���E�V�F���Ȃ��
		bne	do_source_fishdirs		*  ���

		btst.b	#0,flags(a5)			*  -d���w�肳��Ă��Ȃ��Ȃ�
		beq	home_fishdirs_done		*  ���Ȃ�
do_source_fishdirs:
		lea	dot_fishdirs,a1
		bsr	run_home_source_if_any
		bpl	home_fishdirs_done

		lea	percent_fishdirs,a1
		bsr	run_home_source_if_any
home_fishdirs_done:
		*
		*  ~/.history
		*
		btst.b	#1,flags(a5)			*  -h���w�肳��Ă���Ȃ�
		bne	load_history_done		*  ���Ȃ�

		lea	dot_history,a1
		bsr	try_load_history
		bpl	load_history_done

		lea	percent_history,a1
		bsr	try_load_history
load_history_done:
startup_done:
	**
	**  -v �� -x ����������
	**
		btst.b	#5,flags(a5)			*  -v
		beq	set_verbose_done

		bsr	set_verbose
set_verbose_done:
		btst.b	#4,flags(a5)			*  -x
		beq	start_run

		bsr	set_echo
		bra	start_run

login_interrupted:
		st	interrupted(a5)
start_run:
	**
	**  ���s�J�n
	**
		lea	exit_shell_status(pc),a0
		move.l	a0,mainjmp(a5)

		tst.l	arg_command(a5)			*  -c
		bne	do_argument

		tst.b	flag_t(a5)			*  -t
		bne	do_tty_line

		btst.b	#3,flags(a5)			*  -f
		bne	not_rehash

		tst.b	not_execute(a5)
		bne	not_rehash

		tst.b	hash_flag(a5)
		bne	not_rehash

		bsr	rehash
not_rehash:
		tst.l	arg_script(a5)
		bne	do_file

		lea	main(pc),a0
		move.l	a0,mainjmp(a5)
		sf	exitflag(a5)
main:
		bsr	do_line_getline
		tst.b	exitflag(a5)			* exit?
		bne	exit_shell_status

		tst.l	d0				* EOF?
		bpl	main

		tst.b	input_is_tty(a5)
		beq	shell_eol

		tst.b	flag_ignoreeof(a5)
		beq	shell_eof

		lea	msg_use_exit_to_leave_fish,a0
		tst.b	i_am_login_shell(a5)
		beq	ignore_eof

		lea	msg_use_logout_to_logout,a0
ignore_eof:
		bsr	enputs
		bra	main
*****************************************************************
do_tty_line:
		lea	ttymain(pc),a0
		move.l	a0,mainjmp(a5)
ttymain:
		bsr	do_line_getline
		tst.l	d0
		bpl	shell_eol

		tst.b	input_is_tty(a5)
		beq	shell_eol

		bra	shell_eof
*****************************************************************
do_argument:
		tst.b	interrupted(a5)
		bne	exit_shell_status

		move.l	arg_command(a5),d0
		bmi	exit_shell_0

		movea.l	d0,a0
		bsr	strlen
		cmp.l	#MAXLINELEN,d0
		bhi	do_argment_too_long

		movea.l	a0,a1
		lea	line(a5),a0
		bsr	strcpy
		st	d0
		bsr	do_line_substhist
		bra	shell_eol

do_argment_too_long:
		bsr	too_long_line
		bra	exit_shell_1
*****************************************************************
do_file:
		tst.b	interrupted(a5)
		bne	exit_shell_status

		movea.l	arg_script(a5),a0
		moveq	#-1,d1
		clr.b	d7
		sf	d6				*  D6.B := 0 .. open�ł��Ȃ���΃G���[
		bsr	OpenLoadRun_source
		bra	exit_shell_status
*****************************************************************
*  ���[�g�E�V�F����T�u�V�F�����̃f�[�^������������
*****************************************************************
init_bss:
		movem.l	d0-d1/a0,-(a7)

		IOCS	_ONTIME
		move.l	d1,shell_timer_high(a5)
		move.l	d0,shell_timer_low(a5)

		moveq	#1,d0
		moveq	#RND_POOLSIZE,d1
		lea	irandom_struct(a5),a0
		bsr	init_irandom

		clr.l	lake_top(a5)			*  Extmalloc������
		clr.l	tmplake_top(a5)

		clr.l	env_top(a5)			*  ���ϐ���������
		clr.l	shellvar_top(a5)		*  �V�F���ϐ���������
		clr.l	alias_top(a5)			*  �ʖ���������

		clr.l	function_root(a5)		*  �֐����X�g��������
		clr.l	function_bot(a5)

		clr.l	history_top(a5)			*  ������������
		clr.l	history_bot(a5)

		clr.l	tmpgetlinebufp(a5)
		clr.l	user_command_env(a5)
		clr.l	current_source(a5)
		clr.l	current_argbuf(a5)
		clr.l	command_name(a5)
		moveq	#-1,d0
		move.l	d0,undup_input(a5)
		move.l	d0,undup_output(a5)
		move.l	d0,save_stdin(a5)
		move.l	d0,save_stdout(a5)
		move.l	d0,save_stderr(a5)
		move.l	d0,push_stdin(a5)
		move.l	d0,push_stdout(a5)
		move.l	d0,push_stderr(a5)
		move.l	d0,tmpfd(a5)
		clr.b	pipe1_delete(a5)
		clr.b	pipe2_delete(a5)
		sf	pipe_flip_flop(a5)
		clr.b	prev_search(a5)
		clr.b	prev_lhs(a5)
		clr.b	prev_rhs(a5)
		sf	in_prompt(a5)
		sf	var_line_eof(a5)
		bsr	clear_each_source_bss
		movem.l	(a7)+,d0-d1/a0
		rts
*****************************************************************
clear_each_source_bss:
		movem.l	d0/a0,-(a7)
		lea	loop_stack(a5),a0
		moveq	#MAXLOOPLEVEL,d0
clear_loop_stack:
		clr.l	LOOPINFO_STORE(a0)
		lea	LOOPINFOSIZE(a0),a0
		dbra	d0,clear_loop_stack

		movem.l	(a7)+,d0/a0
		clr.b	loop_status(a5)
clear_line_status:
		sf	funcdef_status(a5)
		clr.b	if_status(a5)
		clr.w	if_level(a5)
		clr.b	switch_status(a5)
		clr.w	switch_level(a5)

		clr.l	in_history_ptr(a5)
		sf	keep_loop(a5)
		rts
*****************************************************************
set_verbose:
		move.l	a0,-(a7)
		lea	word_verbose,a0
		bra	set_echo_verbose_e
*****************************************************************
set_echo:
		move.l	a0,-(a7)
		lea	word_echo,a0
set_echo_verbose_e:
		bsr	set_shellvar_nul
		movea.l	(a7)+,a0
		rts
****************************************************************
set_argv:
		lea	word_argv,a0
		sf	d1				*  export ���Ȃ�
		bra	set_shellvar
****************************************************************
import_path:
		lea	word_path,a3
		movea.l	a3,a0
		bsr	fish_getenv
		beq	init_path_default

		bsr	get_var_value
		movea.l	a0,a2
		bsr	init_path_static
		tst.b	(a2)
		beq	do_import_path
import_path_loop:
		movea.l	a2,a0
		moveq	#';',d0
		bsr	strchr				*  ';' �ɃV�t�gJIS�̍l���͕s�v
		exg	a0,a2

		move.l	a2,d1
		sub.l	a0,d1
		bne	import_path_1

		lea	str_dot,a0
		moveq	#1,d1
import_path_1:
		addq.l	#1,d3
		cmp.l	#MAXWORDS,d3
		bhi	import_path_too_long

		cmp.l	#MAXWORDLEN,d1
		bhi	import_path_too_long

		add.l	d1,d2
		addq.l	#1,d2
		cmp.l	#MAXWORDLISTSIZE,d2
		bhi	import_path_too_long

		subq.w	#1,d1
import_path_dup:
		move.b	(a0)+,d0
		bsr	issjis
		beq	import_path_dup_sjis

		cmp.b	#'\',d0
		bne	import_path_dup_1

		moveq	#'/',d0
		bra	import_path_dup_1

import_path_dup_sjis:
		move.b	d0,(a1)+
		dbra	d1,import_path_dup_sjis_2
		bra	import_path_dup_done

import_path_dup_sjis_2:
		move.b	(a0)+,d0
import_path_dup_1:
		move.b	d0,(a1)+
		dbra	d1,import_path_dup
import_path_dup_done:
		clr.b	(a1)+
		tst.b	(a2)+
		bne	import_path_loop
		bra	do_import_path

import_path_too_long:
		movea.l	a3,a0
		bsr	import_too_long0
init_path_default:
		bsr	init_path_static
do_import_path:
		lea	tmpargs,a1
		move.w	d3,d0
		lea	word_path,a0
		sf	d1				*  export���Ȃ�
		bra	set_shellvar
****************
init_path_static:
		lea	tmpargs,a0
		lea	str_builtin_dir,a1
		bsr	strmove
		moveq	#1,d3
		movea.l	a0,a1
		lea	tmpargs,a0
		move.l	a1,d2
		sub.l	a0,d2				*  D2.L : �P����т̒����J�E���^
		rts
****************************************************************
* import - ���ϐ����V�F���ϐ��ɃC���|�[�g����
*
* CALL
*      A1     ���ϐ���
*      A2     �V�F���ϐ���
*      D0.B   0 �ȊO: \ �� / �ɑւ���
*
* RETURN
*      D0.L   -1:���ϐ��͒�`����Ă��Ȃ�  0:�C���|�[�g����  1:�G���[
*      CCR    TST.L D0
****************************************************************
importn:
		sf	d0
import:
		movem.l	d1-d3/a0-a1,-(a7)
		move.b	d0,d3				*  D3.B : subst \ to /
		movea.l	a1,a0
		bsr	fish_getenv
		beq	not_import

		bsr	get_var_value
		bsr	strlen
		cmp.l	#MAXWORDLEN,d0
		bhi	import_too_long
import_set:
		movea.l	a0,a1
		movea.l	a2,a0
		moveq	#1,d0
		sf	d1
		bsr	set_shellvar
		bne	import_return

		tst.b	d3
		beq	import_return

		bsr	get_shellvar
		beq	import_return

		bsr	bsltosl
		moveq	#0,d0
import_return:
		movem.l	(a7)+,d1-d3/a0-a1
		tst.l	d0
		rts

not_import:
		moveq	#-1,d0
		bra	import_return

import_too_long:
		movea.l	a1,a0
		bsr	import_too_long0
		bra	import_return

import_too_long0:
		bsr	pre_perror
		lea	msg_import_too_long,a0
		bra	enputs1
****************************************************************
reset_bss:
		movem.l	d0/a0,-(a7)
		DOS	_GETPDB
		movea.l	d0,a0
		move.l	a5,PDB_dataPtr(a0)
		movem.l	(a7)+,d0/a0
		rts
*****************************************************************
.xdef free_current_argbuf

free_current_argbuf:
		movem.l	d0/a0,-(a7)
		move.l	current_argbuf(a5),d0
		beq	free_current_argbuf_return

		movea.l	d0,a0
		move.l	(a0),current_argbuf(a5)
		bsr	free
		move.l	current_argbuf(a5),d0
free_current_argbuf_return:
		movem.l	(a7)+,d0/a0
		rts
*****************************************************************
manage_abort_signal:
		move.l	#$3fc,d0		* D0 = 000003FC
		cmp.w	#$100,d1
		bcs	manage_signals

		addq.l	#1,d0			* D0 = 000003FD
		cmp.w	#$200,d1
		bcs	manage_signals

		addq.l	#2,d0			* D0 = 000003FF
		cmp.w	#$ff00,d1
		bcc	manage_signals

		cmp.w	#$f000,d1
		bcc	manage_signals

		move.b	d1,d0
		bra	manage_signals
****************
.xdef manage_interrupt_signal

manage_interrupt_signal:
		move.l	#$200,d0		* D0 = 00000200
****************
.xdef manage_signals

manage_signals:
		tst.b	in_fish
		beq	exit_user_command

		move.l	d0,d1				*  status ���Z�[�u�i�X�^�b�N�͂܂��g���Ȃ��j
		DOS	_GETPDB
		movea.l	d0,a0
		movea.l	PDB_dataPtr(a0),a5
		move.l	d1,d0				*  D0.L : status
break_shell:
		movea.l	stackp(a5),a7
		clr.l	command_name(a5)
		sf	exitflag(a5)
		*
		move.l	d0,-(a7)
	.if EXTMALLOC
		bsr	free_all_tmp
	.else
		*  ��p�i�͖��� (^^;
	.endif
		lea	tmpgetlinebufp(a5),a0
		bsr	xfreep
		lea	user_command_env(a5),a0
		bsr	xfreep
		move.l	(a7)+,d0
free_argbuf_loop:
		bsr	free_current_argbuf
		bne	free_argbuf_loop
		*
		bsr	reset_delete_io
		bsr	set_status
		*
		tst.l	current_source(a5)
		beq	stop_running

		move.l	d0,d1
		lsr.w	#8,d1
		subq.l	#2,d1
		bne	stop_source

		tst.b	doing_logout
		bne	run_source_loop

		movea.l	current_source(a5),a0
		move.l	SOURCE_ONINTR_POINTER(a0),d1
		beq	stop_source			*  D1 == 0

		cmp.l	#-1,d1				*  onintr -
		beq	run_source_loop

		jsr	source_goto_onintr
		bsr	clear_line_status
		bra	run_source_loop

stop_source:
		movea.l	current_source(a5),a0
		btst.b	#SOURCE_FLAGBIT_RUNNING,SOURCE_FLAGS(a0)
		beq	stop_source_1

		movea.l	SOURCE_PARENT_STACKP(a0),a7	*  source���[�v�J�n���̃X�^�b�N�|�C���^
		move.l	(a7)+,stackp(a5)
stop_source_1:
		bsr	close_source
		tst.l	current_source(a5)
		bne	stop_source
stop_running:
		movea.l	stackp(a5),a7

		bsr	clear_line_status
		jsr	abort_loops

		tst.b	doing_logout
		bne	longjmp_mainjmp

		tst.b	exit_on_error(a5)
		bne	exit_shell_d0

		tst.b	input_is_tty(a5)
		beq	exit_shell_d0
longjmp_mainjmp:
		movea.l	mainjmp(a5),a0
		jmp	(a0)
****************
.xdef exit_shell_status
.xdef exit_shell_d0
.xdef logout

abort_because_of_insufficient_memory:
		bsr	insufficient_memory
		bra	do_exit_shell

shell_eof:
		tst.b	i_am_login_shell(a5)
		bne	shell_eol

		lea	msg_eof_exit,a0
		bsr	nputs
shell_eol:
		bsr	check_end
		beq	exit_shell_status
exit_shell_1:
		moveq	#1,d0
		bra	exit_shell_d0

exit_shell_0:
		moveq	#0,d0
		bra	exit_shell_d0

exit_shell_status:
		bsr	get_status
exit_shell_d0:
		bsr	reset_delete_io
		tst.l	fork_stackp(a5)
		bne	longjmp_mainjmp

		tst.b	i_am_login_shell(a5)
		beq	do_exit_shell

		lea	word_logout,a0
		bsr	nputs
logout:
		st	doing_logout
		lea	logout_terminated(pc),a0
		move.l	a0,mainjmp(a5)
		move.l	a7,stackp(a5)
		lea	dot_logout,a1
		bsr	run_home_source_if_any
		bpl	logout_terminated

		lea	percent_logout,a1
		bsr	run_home_source_if_any
logout_terminated:
		bsr	reset_delete_io

		move.w	#-1,-(a7)
		DOS	_BREAKCK
		move.w	d0,d1				*  D1.W : ���݂̃u���[�N�t���O
		move.w	#2,(a7)
		DOS	_BREAKCK			*  �u���[�N�֎~�ibsr disable_break�ł̓_���j
		move.w	d1,(a7)				*  ���݂̃u���[�N�E�t���O���X�^�b�N�ɕۑ�
		move.l	a7,stackp(a5)

		lea	savedirs_terminated(pc),a0
		move.l	a0,mainjmp(a5)

		tst.b	flag_savedirs(a5)
		beq	savedirs_done

		lea	dot_fishdirs,a1
		lea	pathname_buf,a0
		bsr	make_home_filename
		bmi	savedirs_try_percent

		bsr	create_savefile
		bpl	do_savedirs

		lea	tmpstatbuf,a1
		bsr	stat
		bpl	savedirs_done
savedirs_try_percent:
		lea	percent_fishdirs,a1
		lea	pathname_buf,a0
		bsr	make_home_filename
		bmi	savedirs_done

		bsr	create_savefile
		bmi	savedirs_done
do_savedirs:
		move.l	d0,tmpfd(a5)
		st	d1				*  D1.B : cdflag
		movea.l	dirstack(a5),a0
		move.w	dirstack_nelement(a0),d3
		bra	savedirs_continue

savedirs_loop:
		moveq	#0,d0
		move.w	d3,d0
		addq.l	#1,d0
		bsr	get_dstack_d0
		bmi	savedirs_continue

		movea.l	dirstack(a5),a0
		adda.l	d2,a0
		bsr	savedirs_one
		bmi	savedirs_close
savedirs_continue:
		dbra	d3,savedirs_loop

		link	a6,#-auto_pathname
		lea	-auto_pathname(a6),a0
		bsr	getcwd
		bsr	savedirs_one
		unlk	a6
		bmi	savedirs_close

		lea	tmpargs,a0
		lea	word_builtin_dirs,a1
		bsr	stpcpy
		bsr	savedirs_write
		bmi	savedirs_close
savedirs_terminated:
		moveq	#0,d0
savedirs_close:
		bsr	close_tmpfd
savedirs_done:
		lea	savehist_terminated(pc),a0
		move.l	a0,mainjmp(a5)

		lea	word_savehist,a0
		bsr	get_shellvar
		beq	savehist_done

		tst.b	(a0)
		beq	savehist_done

		movea.l	a0,a2
		lea	dot_history,a1
		lea	pathname_buf,a0
		bsr	make_home_filename
		bmi	savehist_try_percent

		bsr	create_savefile
		bpl	do_savehist

		lea	tmpstatbuf,a1
		bsr	stat
		bpl	savedirs_done
savehist_try_percent:
		lea	percent_history,a1
		lea	pathname_buf,a0
		bsr	make_home_filename
		bmi	savehist_done

		bsr	create_savefile
		bmi	savehist_done
do_savehist:
		move.l	d0,d1				* ���_�C���N�g��� D1 �ɃZ�b�g����
		move.l	d1,undup_output(a5)		*   undup_output �Ɋo���Ă���
		moveq	#1,d0				* �W���o�͂�
		bsr	redirect			* ���_�C���N�g
		bmi	savehist_terminated

		move.l	d0,save_stdout(a5)		* ���f�X�N���v�^�̃R�s�[���Z�[�u

		sf	d5				*  -r : false
		moveq	#3,d6				*  -h : true
		movea.l	a2,a0
		bsr	do_print_history
savehist_terminated:
		bsr	reset_io
savehist_done:
		*  �X�^�b�N��Ƀu���[�N�E�t���O���ۑ�����Ă���
		DOS	_BREAKCK
		addq.l	#2,a7

		bsr	get_status
do_exit_shell:
		move.l	d0,-(a7)
		lea	first_cwd(a5),a0
		bsr	chdir
		bpl	do_exit_shell_cwd_ok

		bsr	perror
do_exit_shell_cwd_ok:
		bsr	resume_io
		move.l	(a7)+,d0
		sf	in_fish
		sf	doing_logout
		cmp.l	#$200,d0
		blo	exit_process

		cmp.l	#$400,d0
		bhs	exit_process
exit_user_command:
		move.l	d0,user_command_signal
exit_process:
		move.w	d0,-(a7)
		DOS	_EXIT2
exit_halt:
		bra	exit_halt


savedirs_one:
		move.l	a0,-(a7)
		lea	tmpargs,a0
		lea	word_builtin_pushd,a1
		tst.b	d1				*  D1.B : cdflag
		beq	savedirs_one_1

		lea	word_builtin_cd,a1
		sf	d1
savedirs_one_1:
		bsr	stpcpy
		lea	str_option_s,a1
		bsr	stpcpy
		movea.l	(a7)+,a1
savedirs_one_loop:
		move.b	(a1)+,d0
		beq	savedirs_one_3

		bsr	iscsym
		beq	savedirs_one_2

		cmp.b	#'/',d0
		beq	savedirs_one_2

		cmp.b	#':',d0
		beq	savedirs_one_2

		move.b	#'\',(a0)+
savedirs_one_2:
		move.b	d0,(a0)+
		bra	savedirs_one_loop

savedirs_one_3:
savedirs_write:
		lea	str_newline,a1
		bsr	stpcpy
		move.l	d1,-(a7)
		move.l	a0,d0
		lea	tmpargs,a0
		sub.l	a0,d0
		move.l	d0,d1
		move.l	d0,-(a7)
		move.l	a0,-(a7)
		move.l	tmpfd(a5),d0
		move.w	d0,-(a7)
		DOS	_WRITE
		lea	10(a7),a7
		cmp.l	d1,d0
		beq	savedirs_write_done

		moveq	#-23,d0
savedirs_write_done:
		move.l	(a7)+,d1
		tst.l	d0
		rts
*****************************************************************
resume_io:
		movem.l	d0/a0,-(a7)

		moveq	#0,d0
		lea	push_stdin(a5),a0
		bsr	unredirect

		moveq	#1,d0
		lea	push_stdout(a5),a0
		bsr	unredirect

		moveq	#2,d0
		lea	push_stderr(a5),a0
		bsr	unredirect

		movem.l	(a7)+,d0/a0
		rts
*****************************************************************
* fork_and_wait
*
* CALL
*      A1     cleanup entry
*
* fork
*
* CALL
*      A0     �P����� �܂��� ������
*      D0.W   A0���P����тȂ�ΒP�ꐔ�DA0��������Ȃ�Ε�����̒���
*      D1.B   A0���P����тȂ��0�ȊO
*      D2.B   -n �t���O
*
* RETURN
*      D0.L   �X�e�[�^�X
*****************************************************************
.xdef fork_and_wait

fork_and_wait:
		movem.l	d6-d7,-(a7)
		movem.l	d0-d1,-(a7)
		IOCS	_ONTIME
		move.l	d0,d6
		move.l	d1,d7
		movem.l	(a7)+,d0-d1
		bsr	fork
		jsr	(a1)
		bsr	check_simple_command_signal
		movem.l	d0-d4/a0,-(a7)
		move.l	d6,d2
		move.l	d7,d3
		bsr	check_command_time
		movem.l	(a7)+,d0-d4/a0
		bsr	check_and_set_status
		movem.l	(a7)+,d6-d7
		rts

run_function_in_subshell:
		bset.b	#FUNCTYPEBIT_SOURCEONCE,FUNC_TYPE(a1)
		move.l	a1,-(a7)
		bsr	run_command_in_subshell
		movea.l	(a7)+,a1
		bclr.b	#FUNCTYPEBIT_SOURCEONCE,FUNC_TYPE(a1)
		rts

run_command_in_subshell:
		moveq	#1,d1
		move.b	not_execute(a5),d2
fork:
		movem.l	d1-d7/a0-a4/a6,-(a7)
		movea.l	a0,a2				*  A2 : argv / line
		move.w	d0,d3				*  D3 : argc / linelen
		moveq	#1,d4				*  D4 : error flag

		*  BSS�𕡐�����
		move.l	#bsssize+STACKSIZE,d0
		bsr	xmalloc
		beq	fork_fail1

		movea.l	d0,a4				*  A4 : ��������BSS
		movea.l	a5,a1
		movea.l	a4,a0
		move.l	#xbsssize,d0
		bsr	memmovi

		bsr	remember_misc_environments

		move.l	a5,-(a7)			*  �e��BSS�|�C���^��ۑ�
		exg	a4,a5
		move.l	a7,fork_stackp(a5)		*  �X�^�b�N�E�|�C���^��ۑ�
		lea	bsssize(a5),a7
		adda.l	#STACKSIZE,a7			*  ���̃v���Z�X�̃X�^�b�N�E�|�C���^���Z�b�g
		move.l	a7,stackp(a5)			*  stackp ���Z�b�g
		lea	fork_ran(pc),a0
		move.l	a0,mainjmp(a5)			*  mainjmp ���Z�b�g
		bsr	reset_bss
		bsr	init_bss
		move.b	d2,not_execute(a5)

		*  �����X�g�𕡐�����
		move.w	#env_top,d0
		bsr	dupvar
		bmi	fork_fail3

		*  �V�F���ϐ����X�g�𕡐�����
		move.w	#shellvar_top,d0
		bsr	dupvar
		bmi	fork_fail3

		*  �ʖ����X�g�𕡐�����
		move.w	#alias_top,d0
		bsr	dupvar
		bmi	fork_fail3

		*  �f�B���N�g���E�X�^�b�N�𕡐�����
		movea.l	dirstack(a4),a0
		move.l	dirstack_bottom(a0),d0
		bsr	xmalloc
		beq	fork_fail3

		move.l	d0,dirstack(a5)
		move.l	a1,-(a7)
		movea.l	a0,a1
		movea.l	d0,a0
		move.l	dirstack_bottom(a1),d0
		bsr	memmovi
		movea.l	(a7)+,a1

		*  �֐����X�g�𕡐�����
		movem.l	d1/a1-a3,-(a7)
		lea	function_root(a5),a2
		movea.l	function_bot(a4),a3
dup_funcs_loop:
		cmpa.l	#0,a3
		beq	dup_funcs_done

		move.l	FUNC_SIZE(a3),d1
		move.b	FUNC_TYPE(a3),d0
		lea	FUNC_NAME(a3),a1
		lea	FUNC_HEADER_SIZE(a3),a0
		movea.l	FUNC_PREV(a3),a3
		bsr	enter_function
		bne	dup_funcs_loop

		moveq	#-1,d0
dup_funcs_done:
		movem.l	(a7)+,d1/a1-a3
		bmi	fork_fail3

		*  �������X�g�𕡐�����
		movem.l	d1/a1-a3,-(a7)
		movea.l	history_top(a4),a2
dup_history_loop:
		cmpa.l	#0,a2
		beq	dup_history_done

		move.w	HIST_NWORDS(a2),d0
		lea	HIST_BODY(a2),a0
		bsr	wordlistlen
		add.l	#HIST_BODY,d0
		move.l	d0,d1
		bsr	xmalloc
		beq	dup_history_no_memory

		movea.l	d0,a3
		movea.l	a3,a0
		movea.l	a2,a1
		move.l	d1,d0
		bsr	memmovi
		movea.l	history_bot(a5),a0
		move.l	a0,HIST_PREV(a3)
		bne	dup_history_1

		move.l	a3,history_top(a5)
		bra	dup_history_2

dup_history_1:
		move.l	a3,HIST_NEXT(a0)
dup_history_2:
		clr.l	HIST_NEXT(a3)
		move.l	a3,history_bot(a5)
		movea.l	HIST_NEXT(a2),a2
		bra	dup_history_loop

dup_history_no_memory:
		moveq	#-1,d0
dup_history_done:
		movem.l	(a7)+,d1/a1-a3
		bmi	fork_fail3

		*  �L�[�}�N���𕡐�����
		movem.l	d1/a0-a1,-(a7)
		lea	keymacromap(a5),a1
		move.w	#128*3-1,d1
dup_keymacro_loop:
		tst.l	(a1)
		beq	dup_keymacro_continue

		movea.l	(a1),a0
		bsr	strdup
		beq	dup_keymacro_done

		move.l	d0,(a1)
dup_keymacro_continue:
		addq.l	#4,a1
		dbra	d1,dup_keymacro_loop
dup_keymacro_done:
		tst.w	d1
		movem.l	(a7)+,d1/a0-a1
		bpl	fork_fail3

		movea.l	a2,a1
		moveq	#0,d0
		move.w	d3,d0
		tst.b	d1
		bne	fork_wordlist

		lea	line(a5),a0
		bsr	memmovi
		clr.b	(a0)
		lea	line(a5),a0
		sf	d0
		bsr	do_line_substhist
		bra	fork_ran0

fork_wordlist:
		lea	do_line_args(a5),a0
		bsr	copy_wordlist
		bsr	do_line
fork_ran0:
		bsr	get_status
fork_ran:
		bsr	resume_io
		move.l	d0,d3
		moveq	#0,d4
fork_fail3:
		lea	tmpgetlinebufp(a5),a0
		bsr	xfreep
		lea	user_command_env(a5),a0
		bsr	xfreep
	.if EXTMALLOC
		bsr	free_all_tmp
		bsr	free_all_memory_reg_saved
	.else
		*  ��p�i�͖��� (^^;
	.endif
		movea.l	a5,a4
		movea.l	fork_stackp(a5),a7
		movea.l	(a7)+,a5
		bsr	reset_bss

		st	d0
		lea	str_nul,a0
		bsr	resume_misc_environments
fork_fail2:
		move.l	a4,d0
		bsr	free
fork_fail1:
		move.l	d3,d0
		tst.b	d4
		beq	fork_done

		subq.l	#2,a7
		move.w	#-1,-(a7)
		DOS	_BREAKCK
		move.w	d0,2(a7)
		move.w	#2,(a7)
		DOS	_BREAKCK
		addq.l	#2,a7
		lea	msg_fork_failure,a0
		bsr	cannot_because_no_memory
		DOS	_BREAKCK
		addq.l	#2,a7
		moveq	#1,d0
fork_done:
		movem.l	(a7)+,d1-d7/a0-a4/a6
		ext.l	d0
		rts
*****************************************************************
close_source:
		tst.l	current_source(a5)
		beq	close_source_done

		movem.l	d0-d1/a0-a2,-(a7)
		movea.l	current_source(a5),a2
		btst.b	#SOURCE_FLAGBIT_IN_FUNCTION,SOURCE_FLAGS(a2)
		sne	in_function(a5)
		lea	SOURCE_HEADER_SIZE(a2),a1
		adda.w	SOURCE_ARGV0_SIZE(a2),a1	*  ������
		move.w	SOURCE_PUSHARGC(a2),d0
		bmi	close_source_1

		bsr	set_argv
close_source_1:
		adda.w	SOURCE_PUSHARGV_SIZE(a2),a1	*  ������
		lea	each_source_bss_top(a5),a0
		move.l	#EACH_SOURCE_BSS_SIZE,d0
		bsr	memmovi

		move.l	SOURCE_PARENT(a2),current_source(a5)
		move.l	a2,-(a7)
		DOS	_MFREE
		addq.l	#4,a7
		movem.l	(a7)+,d0-d1/a0-a2
close_source_done:
		rts
*****************************************************************
* open_source_header
*
* CALL
*      A0     ���O
*      D1.L   ���[�h����R�[�h�̒���
*      A2     �������X�g�̐擪�A�h���X�iD2.W >= 0 �̂Ƃ��̂݁j
*      D2.W   �����̐��i���Fpush���Ȃ��j
*
* RETURN
*      D0.L   �m�ۂ����̈�̐擪�A�h���X�D�������m�ۂł��Ȃ������Ȃ畉�D
*      A1     �R�[�h���[�h�̈�擪�A�h���X�D������ D0.L < 0 �̂Ƃ��͕s��
*      A3     D0.L �Ɠ���
*      CCR    TST.L D0
*****************************************************************
open_source_header:
		movem.l	d1/d3-d5/a0/a2/a4,-(a7)
		move.l	a0,-(a7)
		bsr	strlen
		addq.l	#1,d0
		move.l	d0,d3				*  D3.L : ���O�̃T�C�Y
		*
		*  D4.L := push���� argv �̃T�C�Y�i������ D2.W < 0 �̂Ƃ��� 0�j
		*  D5.W := push���� argv �̒P�ꐔ�i������ D2.W < 0 �̂Ƃ��� -1�j
		*  A4   := push���� argv �̒l�̐擪�A�h���X�i������ D6.W < 0 �̂Ƃ��͕s��j
		*
		moveq	#0,d4
		moveq	#-1,d5
		tst.w	d2
		bmi	open_source_header_alloc

		moveq	#0,d5
		lea	word_argv,a0
		bsr	find_shellvar
		beq	open_source_header_alloc

		bsr	get_var_value
		movea.l	a0,a4
		move.w	d0,d5
		bsr	wordlistlen
		move.w	d0,d4
open_source_header_alloc:
		movea.l	(a7)+,a0
		move.l	d1,d0
		add.l	d3,d0
		add.l	d4,d0
		add.l	#SOURCE_HEADER_SIZE+EACH_SOURCE_BSS_SIZE,d0
		move.l	d0,-(a7)
		move.w	#2,-(a7)			*  MD=2 : ��ʂ���T���Ċ��蓖�Ă�
		DOS	_MALLOC2
		addq.l	#6,a7
		tst.l	d0
		bmi	open_source_header_return

		movea.l	d0,a3
		clr.l	SOURCE_LINENO(a3)
		clr.l	SOURCE_ONINTR_POINTER(a3)
		move.w	d3,SOURCE_ARGV0_SIZE(a3)
		move.w	d4,SOURCE_PUSHARGV_SIZE(a3)
		move.w	d5,SOURCE_PUSHARGC(a3)

		movea.l	a0,a1
		lea	SOURCE_HEADER_SIZE(a3),a0
		bsr	strmove
		tst.w	d2
		bmi	open_source_header_1

		movea.l	a4,a1
		move.l	d4,d0
		bsr	memmovi
		movea.l	a2,a1
		move.w	d2,d0
		move.l	a0,-(a7)
		bsr	set_argv
		movea.l	(a7)+,a0
		bne	shell_error
open_source_header_1:
		lea	each_source_bss_top(a5),a1
		move.l	#EACH_SOURCE_BSS_SIZE,d0
		bsr	memmovi
		movea.l	a0,a1
		move.l	current_source(a5),SOURCE_PARENT(a3)
		move.l	a3,current_source(a5)
		move.l	a3,d0
open_source_header_return:
		movem.l	(a7)+,d1/d3-d5/a0/a2/a4
		rts
*****************************************************************
init_source_pointers:
		move.l	a1,SOURCE_TOP(a3)
		move.l	a1,SOURCE_BOT(a3)
		add.l	d1,SOURCE_BOT(a3)
		move.l	a1,SOURCE_POINTER(a3)
		move.b	d7,SOURCE_FLAGS(a3)
		tst.b	in_function(a5)
		beq	init_source_pointers_done

		bset.b	#SOURCE_FLAGBIT_IN_FUNCTION,SOURCE_FLAGS(a3)
init_source_pointers_done:
		rts
*****************************************************************
* load_source
*
* CALL
*      A0     �t�@�C����
*      D0.W   �t�@�C���E�n���h��
*      A1     �������X�g�̐擪�A�h���X�iD1.W >= 0 �̂Ƃ��̂݁j
*      D1.W   �����̐��i��:push���Ȃ��j
*      D7.B   �t���O
*
* RETURN
*      ���ׂĔj��
*      (�G���[�Ȃ� shell_error �� longjump ����)
*****************************************************************
load_source:
		move.l	d0,tmpfd(a5)
		move.w	d0,d6				*  D6.W : �t�@�C���E�n���h��
		movea.l	a1,a2				*  A2   : �������X�g�̐擪�A�h���X
		move.w	d1,d2				*  D2.W : �����̐�

		move.w	#2,-(a7)			*  EOF �̈ʒu
		clr.l	-(a7)				*  �܂�
		move.w	d6,-(a7)			*  �t�@�C����
		DOS	_SEEK				*  SEEK ���āC�t�@�C���̒����𓾂�D
		addq.l	#8,a7
		move.l	d0,d1				*  D1.L : �t�@�C���̒���
		bmi	cannot_load_unseekable

		clr.w	-(a7)				*  �t�@�C���̐擪
		clr.l	-(a7)				*  �܂�
		move.w	d6,-(a7)			*  �t�@�C����
		DOS	_SEEK				*  SEEK ����
		addq.l	#8,a7
		tst.l	d0
		bmi	cannot_load_unseekable

		bsr	open_source_header
		bmi	load_source_no_memory

		bsr	init_source_pointers
		sf	in_function(a5)
		move.l	d1,-(a7)			*  �t�@�C���̒�������
		move.l	a1,-(a7)			*  SOURCE_TOP ����̈ʒu��
		move.w	d6,-(a7)			*  �t�@�C������
		DOS	_READ				*  �ǂݍ���
		lea	10(a7),a7
		tst.l	d0
		bmi	load_source_fail

		cmp.l	d1,d0
		bne	load_source_fail

		bra	close_tmpfd			*  rts


load_source_no_memory:
		lea	msg_cannot_load_script,a1
cannot_because_no_memory_shell_error:
		bsr	pre_perror
		bsr	cannot_because_no_memory
		bra	shell_error

cannot_load_unseekable:
		bsr	pre_perror
		lea	msg_cannot_load_unseekable,a0
		bra	print_shell_error

load_source_fail:
		bsr	pre_perror
		lea	msg_read_fail,a0
		bra	print_shell_error
****************************************************************
make_home_filename:
		movem.l	d0/a0-a3,-(a7)
		movea.l	a0,a3
		movea.l	a1,a2
		lea	word_home,a0
		bsr	get_shellvar
		beq	make_home_filename_fail

		tst.b	(a0)
		beq	make_home_filename_fail

		movea.l	a0,a1
		movea.l	a3,a0
		bsr	cat_pathname
make_home_filename_return:
		movem.l	(a7)+,d0/a0-a3
		rts

make_home_filename_fail:
		moveq	#-1,d0
		bra	make_home_filename_return
*****************************************************************
* run_source - run source until EOF
*
* CALL
*      D7.B   source flag
*      D6.B   ��0 �Ȃ�΁C�I�[�v���ł��Ȃ��Ă��G���[�Ƃ��Ȃ�
*
* RETURN
*      �S��   �j��
*****************************************************************
.xdef OpenLoadRun_source

try_load_history:
		moveq	#((1<<SOURCE_FLAGBIT_JUSTREAD)|(1<<SOURCE_FLAGBIT_NOCOMMENT)|(1<<SOURCE_FLAGBIT_NOCONTLINE)),d7
		bra	run_home_source_if_any_1

run_home_source_if_any:
		clr.b	d7
run_home_source_if_any_1:
		lea	pathname_buf,a0
		bsr	make_home_filename
		bmi	run_source_return
run_source_if_any:
		st	d6
		moveq	#-1,d1
		bra	OpenLoadRun_source_file

OpenLoadRun_source:
		cmpi.b	#'-',(a0)
		bne	OpenLoadRun_source_file

		tst.b	1(a0)
		bne	OpenLoadRun_source_file

		lea	str_stdin,a0
		moveq	#0,d0				*  stdin
		bra	LoadRun_source

OpenLoadRun_source_file:
		moveq	#0,d0
		bsr	tfopen
		bpl	LoadRun_source

		tst.b	d6
		bne	run_source_return

		bsr	perror
		bra	shell_error

LoadRun_source:
		bsr	load_source
run_source:
		movea.l	current_source(a5),a2
		move.l	stackp(a5),-(a7)
		move.l	a7,SOURCE_PARENT_STACKP(a2)
		lea	SOURCE_STACK_BOTTOM(a2),a7
		move.l	a7,stackp(a5)
		bset.b	#SOURCE_FLAGBIT_RUNNING,SOURCE_FLAGS(a2)
		bsr	clear_each_source_bss
		sf	exitflag(a5)
run_source_loop:
		bsr	do_line_getline
		tst.l	d0				*  EOF?
		bmi	run_source_eof

		tst.b	exitflag(a5)			*  exit?
		beq	run_source_loop

		sf	exitflag(a5)
		bra	run_source_done

run_source_eof:
		bsr	check_end
		bne	shell_error
run_source_done:
		movea.l	current_source(a5),a2
		movea.l	SOURCE_PARENT_STACKP(a2),a7
		move.l	(a7)+,stackp(a5)
		bsr	close_source
		moveq	#0,d0
run_source_return:
		rts
*****************************************************************
* source_function - �֐������݂̃V�F���Ŏ��s����
*
* CALL
*      A1     �֐��̃w�b�_�̐擪�A�h���X
*      A0     �������X�g�̐擪�A�h���X
*      D0.W   �����̐�
*
* RETURN
*      �S�Ĕj��
*      (�G���[�Ȃ� shell_error �� longjump ����)
*****************************************************************
.xdef source_function

source_function:
		movea.l	a1,a4				*  A4   : �֐��̃w�b�_�̐擪�A�h���X
		movea.l	a0,a2				*  A2   : �������X�g�̐擪�A�h���X
		move.w	d0,d2				*  D2.W : �����̐�
		lea	FUNC_NAME(a4),a0
		moveq	#0,d1
		bsr	open_source_header
		bmi	source_function_no_memory

		lea	FUNC_HEADER_SIZE(a4),a1		*  A1   : �֐��{�̂̐擪�A�h���X
		move.l	FUNC_SIZE(a4),d1		*  D1.L : �֐��̒���
		moveq	#(1<<SOURCE_FLAGBIT_NOCOMMENT),d7
		bsr	init_source_pointers
		st	in_function(a5)
		bra	run_source

source_function_no_memory:
		lea	msg_cannot_source_func,a1
		bra	cannot_because_no_memory_shell_error
*****************************************************************
check_end:
		lea	msg_funcdef_not_done,a0
		tst.b	funcdef_status(a5)
		bne	enputs1

		lea	msg_endif_not_found,a0
		tst.b	if_status(a5)
		bne	enputs1

		lea	msg_endsw_not_found,a0
		tst.b	switch_status(a5)
		bne	enputs1

		lea	msg_end_not_found,a0
		tst.b	loop_status(a5)
		bmi	enputs1

		rts
*****************************************************************
**
**  () "" '' `` �̑΂��`�F�b�N����
**
test_line:
		movem.l	d0-d3/a0,-(a7)
		move.w	d0,d1
		moveq	#0,d2		* D2 : () ���x��
		bra	check_parens_and_quotes_continue

check_parens_and_quotes_loop:
		cmpi.b	#'(',(a0)
		bne	not_open_paren

		tst.b	1(a0)
		bne	not_open_paren
		*{
			addq.w	#1,d2
			bra	check_parens_and_quotes_next
		*}
not_open_paren:
		cmpi.b	#')',(a0)
		bne	not_close_paren

		tst.b	1(a0)
		bne	not_close_paren
		*{
			subq.w	#1,d2
			bcs	unmatched_paren
check_parens_and_quotes_next:
			bsr	strfor1
			bra	check_parens_and_quotes_continue
		*}
not_close_paren:
		moveq	#0,d3				* D3 : ' " `
check_quotes:
		move.b	(a0)+,d0
		beq	check_quotes_break

		bsr	issjis
		beq	check_quotes_skip_1

		tst.b	d3
		beq	check_quotes_test_quote

		cmp.b	d3,d0
		bne	check_quotes
check_quotes_quotes:
		eor.b	d0,d3
		bra	check_quotes

check_quotes_test_quote:
		cmp.b	#'\',d0
		beq	check_quotes_escape

		cmp.b	#'"',d0
		beq	check_quotes_quotes

		cmp.b	#"'",d0
		beq	check_quotes_quotes

		cmp.b	#'`',d0
		beq	check_quotes_quotes

		bra	check_quotes

check_quotes_escape:
		move.b	(a0)+,d0
		beq	check_quotes_break

		bsr	issjis
		bne	check_quotes
check_quotes_skip_1:
		move.b	(a0)+,d0
		bne	check_quotes
check_quotes_break:
		move.b	d3,d0
		bne	unmatched
check_parens_and_quotes_continue:
		dbra	d1,check_parens_and_quotes_loop

		tst.w	d2
		bne	unmatched_paren

		movem.l	(a7)+,d0-d3/a0
		rts

unmatched_paren:
		lea	msg_unmatched_parens,a0
		bra	print_shell_error

unmatched_accent:
		moveq	#'`',d0
unmatched:
		bsr	eputc
		bsr	eputc
		lea	msg_unmatched,a0
		bra	print_shell_error
*****************************************************************
* do_line_getline - �s����͂��A����u���A�P�ꕪ���Averbose�\���A����o�^���A���s����
*
* CALL
*      none.
*
* RETURN
*      D0.L    EOF �Ȃ�� ���D�����Ȃ��� 0�D
*      CCR     TST.L D0
*      ���̑�  �j��
*****************************************************************
do_line_getline:
		move.l	in_history_ptr(a5),d1
		beq	do_line_getline_1

		DOS	_KEYSNS				*  To allow interrupt

		movea.l	d1,a1
		move.l	a1,save_sourceptr
		move.l	HIST_NEXT(a1),in_history_ptr(a5)
		move.w	HIST_NWORDS(a1),d0
		lea	HIST_BODY(a1),a1
		lea	do_line_args(a5),a0
		bsr	copy_wordlist
		bsr	verbose
		bra	do_line

do_line_getline_1:
		tst.l	current_source(a5)
		bne	do_line_getline_script

		suba.l	a1,a1			*  A1 = NULL : �v�����v�g����
		st	d3			*  �s�p����F������
		st	d2			*  �R�����g���폜����
		tst.b	interactive_mode(a5)
		beq	do_line_getline_3

		sf	d2			*  �R�����g���폜���Ȃ�
		tst.b	flag_t(a5)
		bne	do_line_getline_3

		lea	put_prompt_1(pc),a1	*  A1 : �v�����v�g�o�̓��[�`��
		bra	do_line_getline_3

do_line_getline_script:
		movea.l	current_source(a5),a4
		movea.l	SOURCE_POINTER(a4),a3
		move.l	a3,save_sourceptr
		suba.l	a1,a1			*  A1 = NULL : �v�����v�g����
		btst.b	#SOURCE_FLAGBIT_NOCOMMENT,SOURCE_FLAGS(a4)
		seq	d2
		btst.b	#SOURCE_FLAGBIT_NOCONTLINE,SOURCE_FLAGS(a4)
		seq	d3
do_line_getline_3:
		lea	line(a5),a0
		move.w	#MAXLINELEN,d1
		moveq	#0,d7
		lea	getline_phigical(pc),a2
		bsr	getline
		bmi	do_line_just_return
		bne	shell_error

		st	d0
*****************************************************************
* do_line_substhist - �s�𗚗�u���A�P�ꕪ���Averbose�\���A����o�^���A���s����
*
* CALL
*      A0      �s
*      D0.B    0 �łȂ���Η���o�^����
*
* RETURN
*      D0.L    0
*      CCR     TST.L D0
*      ���̑�  �j��
*****************************************************************
.xdef do_line_substhist
.xdef do_line_v

do_line_substhist:
		move.b	d0,d7
		**
		**  �����̒u�����s��
		**
		lea	tmpline(a5),a1

		move.l	current_source(a5),d0
		beq	do_line_substhist_1

		movea.l	d0,a2
		btst.b	#SOURCE_FLAGBIT_JUSTREAD,SOURCE_FLAGS(a2)
		bne	do_not_substhist
do_line_substhist_1:
		tst.b	funcdef_status(a5)
		bne	do_not_substhist

		move.w	#MAXLINELEN,d1
		clr.l	a2
		movem.l	a0-a1,-(a7)
		sf	d0
		bsr	subst_history
		movem.l	(a7)+,a0-a1
		btst	#2,d0
		bne	shell_error

		movea.l	a1,a0
		bra	substhist_done

do_not_substhist:
		exg	a0,a1
		bsr	strcpy
		moveq	#0,d0
substhist_done:
		move.b	d0,d2
do_line_v:
		**
		**  �P���T��
		**
		lea	do_line_args(a5),a1
		move.l	current_source(a5),d1
		beq	find_words_1

		movea.l	d1,a1
		lea	SOURCE_WORDLIST(a1),a1
find_words_1:
		move.w	#MAXWORDLISTSIZE,d1
		move.l	a1,-(a7)
		bsr	make_wordlist
		movea.l	(a7)+,a0
		bmi	shell_error
		**
		**  verbose �\��������
		**
		bsr	verbose_0
		**
		**  �����ɓo�^����
		**
		tst.b	d7
		beq	skip_enter_history

		move.l	current_source(a5),d1
		beq	do_line_substhist_2

		movea.l	d1,a1
		btst.b	#SOURCE_FLAGBIT_JUSTREAD,SOURCE_FLAGS(a1)
		beq	skip_enter_history

		bsr	enter_history
		bra	do_line_return

do_line_substhist_2:
		tst.b	interactive_mode(a5)
		beq	skip_enter_history

		bsr	enter_history
skip_enter_history:
		btst	#0,d2			*  !:p
		bne	do_line_return
*****************************************************************
* do_line - �P�ꕪ�����ꂽ�s�����s����
*
* CALL
*      A0      �P����сi�j�󂳂��BMAXWORDLISTSIZE�o�C�g�K�v�j
*      D0.W    �P�ꐔ
*
* RETURN
*      D0.L    0
*      CCR     TST.L D0
*      ���̑�  �j��
*****************************************************************
.xdef do_line

do_line:
		clr.l	command_name(a5)

		tst.b	funcdef_status(a5)
		beq	not_in_funcdef

		tst.w	d0
		beq	do_line_in_funcdef

		cmpi.b	#'}',(a0)
		bne	do_line_in_funcdef

		tst.b	1(a0)
		bne	do_line_in_funcdef
		**
		**  �֐���`�̏I���
		**
		bsr	do_defun
		bne	shell_error

		bra	do_line_return

do_line_in_funcdef:
		bsr	wordlistlen
		add.l	d0,funcdef_size(a5)
		bra	do_line_return

not_in_funcdef:
	**
	**  �֐���`���ł͂Ȃ�
	**
		tst.b	not_execute(a5)
		bne	do_line_skip_subst_alias

		tst.b	in_function(a5)
		bne	do_line_skip_subst_alias

		tst.b	flag_noalias(a5)
		bne	do_line_skip_subst_alias
do_line_subst_alias:
	**
	**  �ʖ��u��
	**
		bsr	test_line

		lea	tmpline(a5),a1
		move.w	#MAXLINELEN,d1
		move.w	d0,d3
		bsr	subst_alias
		bne	shell_error

		tst.b	d2
		beq	no_alias_substed

		moveq	#MAXALIASLOOP,d4		* D4 : �ʖ��u�����[�v�E�J�E���^
recurse_subst_alias:
		exg	a0,a1
		move.w	#MAXWORDLISTSIZE,d1
		move.l	a1,-(a7)
		bsr	make_wordlist
		movea.l	(a7)+,a1
		exg	a0,a1
		bmi	shell_error

		btst	#1,d2
		beq	no_more_alias

		subq.w	#1,d4
		bcc	alias_loop_ok

		lea	msg_alias_loop,a0
		bra	print_shell_error

alias_loop_ok:
		move.w	#MAXLINELEN,d1
		move.w	d0,d3
		bsr	subst_alias
		bne	shell_error

		tst.b	d2
		bne	recurse_subst_alias
no_alias_substed:
		move.w	d3,d0
no_more_alias:
do_line_skip_subst_alias:
		tst.w	d0
		beq	do_line_return

		bsr	test_line
	**
	**  ���䕶���H
	**
		lea	statement_table,a2
		bsr	find_from_table
		bne	is_not_statement
		**
		**  ���䕶�ł���
		**
		btst.b	#0,8(a2)
		bne	ignore_loop_status

		tst.b	loop_status(a5)
		bmi	do_line_return
ignore_loop_status:
		btst.b	#1,8(a2)
		bne	ignore_if_status

		tst.b	if_status(a5)
		bne	do_line_return
ignore_if_status:
		btst.b	#2,8(a2)
		bne	ignore_switch_status

		tst.b	switch_status(a5)
		bne	do_line_return
ignore_switch_status:
		tst.b	not_execute(a5)
		bne	do_line_return

		movea.l	a0,a1
		bsr	strfor1
		subq.w	#1,d0
		move.l	(a2),command_name(a5)
		movea.l	4(a2),a2
		jsr	(a2)			* ���̏���
do_line_statement_done:
		tst.l	d0
		bne	shell_error

		clr.l	command_name(a5)
do_line_return:
		moveq	#0,d0
do_line_just_return:
		rts

is_not_statement:
		**
		**  ���䕶�ł͂Ȃ�
		**
		tst.b	if_status(a5)		*  if �̏�Ԃ�
		bne	do_line_return		*  '�U'�Ȃ�Ύ��s���Ȃ�

		tst.b	switch_status(a5)	*  switch ��
		bne	do_line_return		*  case�ɓ��B���ĂȂ���breaksw��Ȃ�Ύ��s���Ȃ�

		tst.b	loop_status(a5)		*  loop ��ǂ�ł���Œ�
		bmi	do_line_return		*  �Ȃ�Ύ��s���Ȃ�
	**
	**  ���x�����H
	**
		move.w	d0,d2
		bsr	strlen
		exg	d0,d2
		subq.l	#1,d2
		bcs	is_not_label

		cmpi.b	#':',(a0,d2.l)
		bne	is_not_label
		**
		**  ���x���ł���
		**
		subq.w	#1,d0
		beq	do_line_return

		bsr	pre_perror
		lea	msg_bad_labeldef,a0
		bsr	eputs
		lea	msg_syntax_error,a0
		bsr	enputs
		bra	shell_error

is_not_label:
		**
		**  ���x���ł͂Ȃ�
		**
	**
	**  �֐���`�̊J�n���H
	**
		cmp.w	#3,d0
		blo	is_not_fn

		movem.l	d0/a0,-(a7)
		bsr	strfor1
		lea	paren_pair,a1
		moveq	#4,d0
		bsr	memcmp
		movem.l	(a7)+,d0/a0
		bne	is_not_fn
		**
		**  �֐���`�̊J�n�ł���
		**
		bsr	state_nonsub_function
		bra	do_line_statement_done

is_not_fn:
		**
		**  �֐���`�ł͂Ȃ� - �ʏ�̃R�}���h���X�g�ł���
		**
TPIPE = 1
TLST  = 2
TOR   = 3
TAND  = 4

* A6
nextptr            = -4
nwords_next        = nextptr-2
connect_type       = nwords_next-1
pad1               = connect_type-1			* �����ɍ��킹��

* A4
input_pathname     = -auto_pathname
output_pathname    = input_pathname-auto_pathname
tempptr            = output_pathname-4
last_connect_type  = tempptr-1
line_condition     = last_connect_type-1
here_document      = line_condition-1
output_cat         = here_document-1
output_both        = output_cat-1
output_nonoclobber = output_both-1
input_nonoclobber  = output_nonoclobber-1
pad2               = input_nonoclobber-1		* �����ɍ��킹��

		link	a6,#pad1
		link	a4,#pad2
		move.l	a0,nextptr(a6)
		move.w	d0,nwords_next(a6)
do_next_command_0:
		clr.b	last_connect_type(a4)
do_next_command:
		st	line_condition(a4)
start_DoCommandList:
		move.w	nwords_next(a6),d0
		movea.l	nextptr(a6),a0
		not.b	pipe_flip_flop(a5)
		clr.b	connect_type(a6)	* ���̃R�}���h�Ƃ̐ڑ��`��
****************************************************************
		**
		**  & ��T��
		**  �i��������΁A& �܂ł̃��X�g�̓T�u�V�F���Ŏ��s����j
		**
		movea.l	a0,a1			* A0 ��Ҕ�
		move.w	d0,d7			* D7.W : �ꐔ�J�E���^
		moveq	#0,d1			* D1.W : ���̃R�}���h�E���X�g�̌ꐔ�J�E���^
extract_simple_list:
		tst.w	d7
		beq	no_ampersand

		cmpi.b	#'(',(a0)
		bne	extract_simple_list_1

		tst.b	1(a0)
		bne	extract_simple_list_continue

		move.w	d7,d0
		bsr	skip_paren
		exg	d0,d7			* D7.W : ) �ȍ~�̒P�ꐔ
		sub.w	d7,d0			* D0.W : ( ���� ) �̒��O�܂ł̒P�ꐔ
		add.w	d0,d1
		bra	extract_simple_list_continue

extract_simple_list_1:
		move.b	(a0),d0
		cmp.b	#'&',d0
		beq	ampersand_found

		cmp.b	#'|',d0
		beq	extract_simple_list_vline

		cmp.b	#'>',d0
		beq	extract_simple_list_redirect
extract_simple_list_continue:
		bsr	strfor1
		subq.w	#1,d7
		addq.w	#1,d1
		bra	extract_simple_list

extract_simple_list_redirect:
		bsr	skip_redirect_token
		bra	extract_simple_list

extract_simple_list_vline:
		tst.b	1(a0)
		bne	extract_simple_list_continue

		addq.w	#1,d1
		bsr	strfor1
		subq.w	#1,d7
		beq	extract_simple_list

		cmpi.b	#'&',(a0)
		bne	extract_simple_list

		tst.b	1(a0)
		bne	extract_simple_list
		bra	extract_simple_list_continue
****************
ampersand_found:
		tst.b	1(a0)
		bne	extract_simple_list_continue

		bsr	strfor1
		subq.w	#1,d7
		move.l	a0,nextptr(a6)
		move.w	d7,nwords_next(a6)
		tst.w	d1
		bne	not_null_ampersand

		bsr	is_invalid_null_command
		beq	invalid_null_command
not_null_ampersand:
		tst.b	line_condition(a4)
		beq	do_next_command_0

		movea.l	a1,a0
		move.w	d1,d0
		bsr	run_command_in_subshell
		bsr	clear_status
		bra	do_next_command_0
****************************************************************
no_ampersand:
		**
		**  �R�}���h�̏I����������
		**
		movea.l	a1,a0
		move.w	d1,d7			* D7.W : �ꐔ�J�E���^
		moveq	#0,d1			* D1.W : ���̒P��R�}���h�̌ꐔ�J�E���^
find_command_separation:
		tst.w	d7
		beq	separation_done

		cmpi.b	#'(',(a0)
		bne	find_command_separation_1

		tst.b	1(a0)
		bne	find_command_separation_continue

		move.w	d7,d0
		bsr	skip_paren
		exg	d0,d7			* D7.W : ) �ȍ~�̒P�ꐔ
		sub.w	d7,d0			* D0.W : ( ���� ) �̒��O�܂ł̒P�ꐔ
		add.w	d0,d1
		bra	find_command_separation_continue

find_command_separation_1:
		move.b	(a0),d0
		cmp.b	#';',d0
		beq	find_command_separation_semicolon

		cmp.b	#'|',d0
		beq	find_command_separation_vertical_line

		cmp.b	#'&',d0
		beq	find_command_separation_ampersand

		cmp.b	#'>',d0
		bne	find_command_separation_continue

		bsr	skip_redirect_token
		bra	find_command_separation

find_command_separation_continue:
		bsr	strfor1
		subq.w	#1,d7
		addq.w	#1,d1
		bra	find_command_separation
****************
find_command_separation_vertical_line:
		moveq	#TOR,d2
		tst.b	1(a0)
		bne	test_separator_2

		moveq	#TPIPE,d2
		bsr	strfor1
		subq.w	#1,d7
		bsr	check_out_both

		tst.b	line_condition(a4)
		bne	separator_found

		clr.b	connect_type(a6)
		bra	find_command_separation
****************
find_command_separation_ampersand:
		moveq	#TAND,d2
test_separator_2:
		cmp.b	1(a0),d0
		bne	find_command_separation_continue

		tst.b	2(a0)
		bne	find_command_separation_continue

		bra	list_found_1
****************
find_command_separation_semicolon:
		moveq	#TLST,d2
		tst.b	1(a0)
		bne	find_command_separation_continue
list_found_1:
		bsr	strfor1
		subq.w	#1,d7
separator_found:
		move.b	d2,connect_type(a6)
		move.l	a0,nextptr(a6)
		move.w	d7,nwords_next(a6)
separation_done:
		tst.b	line_condition(a4)
		bne	parse_redirection

		tst.w	d1
		bne	pipeline_done

		bsr	is_invalid_null_command
		beq	invalid_null_command
		bra	pipeline_done
********************************
parse_redirection:
		**
		**  ���o�͐؂芷����F������
		**
		movea.l	a1,a0
		move.w	d1,d7			* D7.W : �ꐔ�J�E���^

		lea	simple_args(a5),a1
		clr.w	argc(a5)

		moveq	#0,d5			* D5.L : ���̓t�@�C�����|�C���^
		moveq	#0,d6			* D6.L : �o�̓t�@�C�����|�C���^
find_redirection:
		tst.w	d7
		beq	find_redirection_done

		cmpi.b	#'(',(a0)
		bne	find_redirection_not_paren

		tst.b	1(a0)
		bne	find_redirection_not_paren

		movea.l	a0,a2
		move.w	d7,d0
		bsr	skip_paren
		exg	d0,d7
		sub.w	d7,d0
		add.w	d0,argc(a5)
		exg	a0,a2
		exg	a0,a1
		move.l	a2,d0
		sub.l	a1,d0
		bsr	memmovi
		exg	a0,a1
		exg	a0,a2
		bra	find_redirection_continue

find_redirection_not_paren:
		move.b	(a0),d0
		moveq	#0,d2
		cmp.b	#'<',d0
		beq	find_redirection_1

		moveq	#1,d2
		cmp.b	#'>',d0
		bne	find_redirection_continue
find_redirection_1:
		moveq	#0,d3
		tst.b	1(a0)
		beq	redirection_found

		cmp.b	1(a0),d0
		bne	find_redirection_continue

		moveq	#1,d3
		tst.b	2(a0)
		beq	redirection_found

		cmp.b	#'<',d0
		bne	find_redirection_continue

		cmp.b	2(a0),d0
		bne	find_redirection_continue

		moveq	#2,d3
		tst.b	3(a0)
		beq	redirection_found
find_redirection_continue:
		subq.w	#1,d7
		addq.w	#1,argc(a5)
		exg	a0,a1
		bsr	strmove
		exg	a0,a1
		bra	find_redirection
****************
redirection_found:
		tst.b	d2
		bne	redirect_out_found

		cmpi.b	#TPIPE,last_connect_type(a4)
		beq	input_ambiguous

		tst.l	d5
		bne	input_ambiguous

		bsr	strfor1
		subq.w	#1,d7
		move.b	d3,here_document(a4)		*  0:<  1:<<  2:<<<
		bne	heredoc_found

		sf	input_nonoclobber(a4)
		tst.w	d7
		beq	rd_in_get_filename

		cmpi.b	#'!',(a0)
		bne	rd_in_get_filename

		tst.b	1(a0)
		bne	rd_in_get_filename

		st	input_nonoclobber(a4)
		bsr	strfor1
		subq.w	#1,d7
rd_in_get_filename:
		lea	input_pathname(a4),a2		*  A2 : ���͐�̃t�@�C�����i�[��
		move.l	a2,d5				*  D5 : ���͐�t�@�C����������
		bra	get_redirect_filename
****************
redirect_out_found:
		cmpi.b	#TPIPE,connect_type(a6)
		beq	output_ambiguous

		tst.l	d6
		bne	output_ambiguous

		move.b	d3,output_cat(a4)		*  0:>  1:>>
		bsr	strfor1
		subq.w	#1,d7
		bsr	check_out_both
		sf	output_nonoclobber(a4)
		tst.w	d7
		beq	rd_out_get_filename

		cmpi.b	#'!',(a0)
		bne	rd_out_get_filename

		tst.b	1(a0)
		bne	rd_out_get_filename

		st	output_nonoclobber(a4)
		bsr	strfor1
		subq.w	#1,d7
rd_out_get_filename:
		lea	output_pathname(a4),a2		*  A2 : �o�͐�t�@�C�����i�[��
		move.l	a2,d6				*  D6 : �o�͐�t�@�C����������
get_redirect_filename:
		tst.w	d7
		beq	missing_redirect_filename_1

		movea.l	a0,a3				*  A3:�t�@�C����
		bsr	strfor1				*  A0:���̒P��
		subq.w	#1,d7
		exg	a0,a3				*  A0:�t�@�C����  A3:���̒P��
		movem.l	a0-a1,-(a7)
		lea	tmpline(a5),a1
		moveq	#1,d0
		move.w	#MAXWORDLEN+1,d1
		bsr	subst_var
		movem.l	(a7)+,a0-a1
		beq	redirect_name_error
		bmi	redirect_name_error

		exg	a0,a3				*  A0:���̒P��  A3:�t�@�C����
		move.l	a0,-(a7)
		lea	tmpline(a5),a0
		exg	a1,a2
		move.l	#MAXPATH,d1
		bsr	expand_a_word
		exg	a1,a2
		movea.l	(a7)+,a0
		bpl	find_redirection

		movea.l	a3,a0				*  A0:�t�@�C����
		cmp.l	#-5,d0
		bne	redirect_name_error

		moveq	#0,d0
redirect_name_error:
		cmp.l	#-4,d0
		beq	shell_error

		tst.l	d0
		beq	missing_redirect_filename_0

		addq.l	#1,d0
		beq	redirect_name_ambiguous

		lea	msg_too_long_pathname,a0
		bra	print_shell_error

redirect_name_ambiguous:
		bsr	ambiguous
		bra	shell_error

missing_redirect_filename_0:
		bsr	strip_quotes
		bsr	pre_perror
missing_redirect_filename_1:
		lea	msg_missing_input,a0
		tst.b	d2
		beq	missing_redirect_filename_2

		lea	msg_missing_output,a0
missing_redirect_filename_2:
		bra	print_shell_error
****************
heredoc_found:
		tst.w	d7
		beq	missing_heredoc_word

		move.l	a0,d5
		bsr	strfor1
		subq.w	#1,d7
		bra	find_redirection

missing_heredoc_word:
		lea	msg_missing_heredoc_word,a0
		bra	print_shell_error
********************************
find_redirection_done:
		move.w	argc(a5),d1
		bne	not_null_command

		bsr	is_invalid_null_command
		beq	invalid_null_command

		tst.l	d5
		bne	invalid_null_command

		tst.l	d6
		bne	invalid_null_command
not_null_command:
********************************
		**
		**  ���͂�؂芷����
		**
		lea	pipe1_name(a5),a0
		lea	pipe1_delete(a5),a3
		tst.b	pipe_flip_flop(a5)
		bne	redirect_in_1

		lea	pipe2_name(a5),a0
		lea	pipe2_delete(a5),a3
redirect_in_1:
		cmpi.b	#TPIPE,last_connect_type(a4)
		beq	redirect_in_pipe

		tst.l	d5
		beq	redirect_in_done

		tst.b	here_document(a4)
		bne	redirect_in_here_document

		movea.l	d5,a0
		cmpi.b	#'-',(a0)
		bne	redirect_in_open

		moveq	#0,d1
		move.b	1(a0),d1
		sub.b	#'0',d1
		bcs	redirect_in_open

		cmp.b	#4,d2
		bls	redirect_in_opened		*  -0 ... -4 : �W���n���h��
		bra	redirect_in_open
****************
redirect_in_pipe:
		move.b	#2,(a3)
****************
redirect_in_open:
		tst.b	not_execute(a5)
		bne	redirect_in_done

		moveq	#0,d0				* �ǂݍ��݃��[�h��
		bsr	tfopen				* ���͐�t�@�C�����I�[�v������
		move.l	d0,d1				* �f�X�N���v�^�� D1 �ɃZ�b�g
		bmi	rd_perror
redirect_in_opened:
		move.l	d1,undup_input(a5)		* �f�X�N���v�^�� undup_input �Ɋo���Ă���

		bsr	isblkdev			* �������L�����N�^�E�f�o�C�X��
		beq	redirect_in_ok			*   �Ȃ����OK

		tst.b	input_nonoclobber(a4)
		bne	redirect_in_ok

		tst.b	flag_forceio(a5)
		bne	redirect_in_ok

		move.w	d1,-(a7)			* ������
		move.w	#6,-(a7)			* �t�@�C���n���h������ē��͉\��
		DOS	_IOCTRL				* ���ׂ�
		addq.l	#4,a7
		tst.l	d0				* ���͉\�Ȃ��
		bne	redirect_in_ok			*   OK

		lea	msg_not_inputable_device,a1
		bra	rd_errorp
****************
redirect_in_here_document:
		tst.b	not_execute(a5)
		bne	heredoc_open_ok

		movea.l	a0,a2
		bsr	tmpfile
		bmi	shell_error

		move.l	d0,undup_input(a5)
		move.l	d0,d1				* D1.W : ���ߍ��ݕ����p�ꎞ�t�@�C���̃t�@�C���E�n���h��
		move.b	#2,(a3)				* �R�}���h�I���㑦��������
heredoc_open_ok:
		cmp.b	#1,here_document(a4)
		bne	here_string

		movea.l	d5,a0
		bsr	isquoted
		move.b	d0,d3				* D3 : �u�N�I�[�g����Ă���v�t���O
heredoc_loop:
		lea	line(a5),a0
		move.l	d1,-(a7)
		move.w	#MAXLINELEN,d1
		suba.l	a1,a1				* �v�����v�g����
		moveq	#0,d0
		bsr	getline_phigical
		move.l	(a7)+,d1
		tst.l	d0
		bmi	heredoc_eof
		bne	shell_error

		lea	line(a5),a0
		movea.l	d5,a1
		bsr	strcmp
		beq	heredoc_end

		tst.b	d3
		bne	heredoc_subst_ok

		move.l	d1,-(a7)
		lea	tmpline(a5),a1
		move.w	#MAXLINELEN,d1
		moveq	#0,d0
		bsr	subst_var_2
		move.l	(a7)+,d1
		tst.l	d0
		bmi	heredoc_subst_error

		lea	tmpline(a5),a0
		lea	line(a5),a1
		move.l	d1,-(a7)
		move.w	#MAXLINELEN,d1
		bsr	subst_command_2
		move.l	(a7)+,d1
		tst.l	d0
		bmi	heredoc_subst_error
		bra	heredoc_subst_ok

here_string:
		movea.l	d5,a1
		lea	line(a5),a0
		moveq	#1,d0
		bsr	expand_wordlist_var
		tst.l	d0
		bmi	shell_error

		bsr	words_to_line
heredoc_subst_ok:
		tst.b	not_execute(a5)
		bne	heredoc_continue

		lea	line(a5),a0
		bsr	strlen
		move.l	d0,d2
		move.l	d0,-(a7)
		move.l	a0,-(a7)
		move.w	d1,-(a7)
		DOS	_WRITE
		lea	10(a7),a7
		tst.l	d0
		bmi	heredoc_write_error

		cmp.l	d2,d0
		bne	heredoc_disk_full

		move.l	#2,-(a7)
		pea	str_newline
		move.w	d1,-(a7)
		DOS	_WRITE
		lea	10(a7),a7
		tst.l	d0
		bmi	heredoc_write_error

		cmp.l	#2,d0
		bne	heredoc_disk_full
heredoc_continue:
		cmp.b	#1,here_document(a4)
		beq	heredoc_loop
heredoc_end:
		tst.b	not_execute(a5)
		bne	redirect_in_done

		clr.w	-(a7)				* �擪
		clr.l	-(a7)				* �@�܂�
		move.w	d1,-(a7)			*
		DOS	_SEEK				* �@�V�[�N����
		addq.l	#8,a7
		movea.l	a2,a0
		bra	redirect_in_ok

heredoc_eof:
		movea.l	d5,a0
		lea	msg_no_heredoc_terminator,a1
		bra	rd_errorp

heredoc_disk_full:
		moveq	#-23,d0				*  DISK FULL
heredoc_write_error:
		movea.l	a2,a0
		bra	rd_perror

heredoc_subst_error:
		cmp.l	#-4,d0
		beq	shell_error

		bsr	reset_delete_io
		bsr	too_long_line
		bra	shell_error
****************
redirect_in_ok:
		moveq	#0,d0				* �W�����͂�
		bsr	redirect			*   ���_�C���N�g
		bmi	rd_perror

		move.l	d0,save_stdin(a5)		* ���f�X�N���v�^�̃R�s�[���Z�[�u
redirect_in_done:
********************************
		**
		**  �o�͂�؂芷����
		**
		lea	pipe2_name(a5),a0
		lea	pipe2_delete(a5),a3
		tst.b	pipe_flip_flop(a5)
		bne	rd_pipe_1

		lea	pipe1_name(a5),a0
		lea	pipe1_delete(a5),a3
rd_pipe_1:
		tst.b	not_execute(a5)
		bne	redirect_out_done

		cmpi.b	#TPIPE,connect_type(a6)
		beq	redirect_out_pipe

		tst.l	d6
		beq	redirect_out_done

		movea.l	d6,a0
		cmpi.b	#'-',(a0)
		bne	redirect_out_not_stdfd

		moveq	#0,d2
		move.b	1(a0),d2
		sub.b	#'0',d2
		bcs	redirect_out_not_stdfd

		cmp.b	#4,d2
		bls	redirect_out_device_check	*  -0 ... -4 : �W���n���h��
redirect_out_not_stdfd:
		moveq	#0,d0				* �܂��ǂݍ��݃��[�h��
		bsr	tfopen				* �o�͐�t�@�C�����I�[�v�����Ă݂�
		move.l	d0,d2				* �f�X�N���v�^��D2�ɃZ�b�g
		bpl	redirect_out_device_check	* �I�[�v���ł����Ȃ�f�o�C�X�`�F�b�N

		cmp.l	#-2,d0				* �G���g�����Ȃ����
		beq	redirect_out_exist_check_done	*   �`�F�b�N�I���

		bra	rd_perror
			* ���ƂŖ{����OPEN�����Ƃ��ɂ��`�F�b�N����̂ŕs�v�Ǝv�������m���
			* �����ACREATE�ł̓f�B���N�g���ւ̃A�N�Z�X���u���̃t�@�C���͏�����
			* �݂ł��Ȃ��v�ƂȂ��Ă��܂��̂ŁA�����ŗ\�߃`�F�b�N���Ă���

redirect_out_device_check:
		bsr	isblkdev			* �������L�����N�^�E�f�o�C�X���ǂ�����
		move.b	d0,d1				*   D1�ɃZ�b�g
		moveq	#1,d0
		tst.b	d1				* �L�����N�^�E�f�o�C�X��
		beq	redirect_out_device_check_done	*   �Ȃ���΃`�F�b�N�I���

		tst.b	output_nonoclobber(a4)
		bne	redirect_out_device_check_done

		tst.b	flag_forceio(a5)
		bne	redirect_out_device_check_done

		move.w	d2,-(a7)			* ������
		move.w	#7,-(a7)			*   �o�͉\�f�o�C�X���ǂ���
		DOS	_IOCTRL				*   ���ׂ�
		addq.l	#4,a7
redirect_out_device_check_done:
		move.l	d0,-(a7)
		move.w	d2,d0
		cmp.w	#4,d0
		bls	redirect_out_device_check_not_close

		bsr	fclose
redirect_out_device_check_not_close:
		move.l	(a7)+,d0			* �o�͉\���H
		beq	redirect_not_outputable_device
redirect_out_exist_check_done:
		move.l	d2,d0
		cmp.l	#4,d0
		bls	redirect_out_ready

		tst.b	output_cat(a4)
		beq	redirect_out_not_cat

		tst.l	d2				* �o�͐�t�@�C�������݂���
		bpl	redirect_out_open		*   ����Ȃ�΂n�j�B�I�[�v������

		tst.b	output_nonoclobber(a4)
		bne	redirect_out_create

		tst.b	flag_noclobber(a5)
		beq	redirect_out_create

		lea	msg_nofile,a1
		bra	rd_errorp
****************
redirect_out_not_cat:
		tst.l	d2				* �o�͐�t�@�C�������݂���
		bmi	redirect_out_create		* �@���Ȃ��Ȃ�΂n�j�D�쐬����

		tst.b	d1				* �L�����N�^�E�f�o�C�X
		bne	redirect_out_open		* �@�Ȃ�΂n�j�D�I�[�v������

		tst.b	output_nonoclobber(a4)
		bne	redirect_out_create

		tst.b	flag_noclobber(a5)
		bne	redirect_out_file_exists
redirect_out_create:
		clr.b	output_cat(a4)
		bsr	create_normal_file
		bra	redirect_out_opened
****************
redirect_out_pipe:
		clr.b	output_cat(a4)
		bsr	tmpfile
		bmi	shell_error

		move.b	#1,(a3)				* ���̃R�}���h�̏I����ɂ͏�������
		bra	redirect_out_ready
****************
redirect_out_open:
		moveq	#1,d0				* �������݃��[�h��
		bsr	tfopen				* �o�͐�t�@�C�����I�[�v������
redirect_out_opened:
		bmi	rd_perror
redirect_out_ready:
		move.l	d0,d1				* ���_�C���N�g��� D1 �ɃZ�b�g����
		move.l	d1,undup_output(a5)		*   undup_output �Ɋo���Ă���

		tst.b	output_cat(a4)			* >> ��
		beq	do_redirect_out			*   �Ȃ���΃V�[�N���Ȃ�

		bsr	isblkdev			* ���_�C���N�g�悪�V�[�N�s��
		bne	do_redirect_out			*   �Ȃ�΃V�[�N���Ȃ�

		move.w	#2,-(a7)			* EOF
		clr.l	-(a7)				* �@�܂�
		move.w	d1,-(a7)			* �@�o�͂�
		DOS	_SEEK				* �@�V�[�N����
		addq.l	#8,a7
do_redirect_out:
		moveq	#1,d0				* �W���o�͂�
		bsr	redirect			* ���_�C���N�g
		bmi	rd_perror

		move.l	d0,save_stdout(a5)		* ���f�X�N���v�^�̃R�s�[���Z�[�u

		tst.b	output_both(a4)
		beq	redirect_out_done

		moveq	#2,d0				* �x���o�͂�
		bsr	redirect			* ���_�C���N�g
		bmi	rd_perror

		move.l	d0,save_stderr(a5)		* ���f�X�N���v�^�̃R�s�[���Z�[�u
redirect_out_done:
********************************
		**
		**  �P��̃R�}���h�����s����
		**
		unlk	a4
		moveq	#0,d1
		sf	d2
		bsr	DoSimpleCommand
		link	a4,#pad2
pipeline_done:
		move.b	connect_type(a6),d1
		move.b	d1,last_connect_type(a4)
		beq	command_done

		tst.b	not_execute(a5)
		bne	do_next_command

		move.b	last_connect_type(a4),d1
		cmp.b	#TOR,d1
		beq	test_or

		cmp.b	#TAND,d1
		bne	do_next_command
test_and:
		bsr	get_status
		bne	shell_error

		tst.l	d0
		seq	line_condition(a4)
		bra	start_DoCommandList

test_or:
		bsr	get_status
		bne	shell_error

		tst.l	d0
		sne	line_condition(a4)
		bra	start_DoCommandList

command_done:
		unlk	a4
		unlk	a6
cmd_nop:
		moveq	#0,d0
		rts


input_ambiguous:
		lea	msg_input_ambiguous,a0
		bra	print_shell_error

output_ambiguous:
		lea	msg_output_ambiguous,a0
		bra	print_shell_error

invalid_null_command:
		lea	msg_invalid_null_command,a0
		bra	print_shell_error

redirect_out_file_exists:
		lea	msg_file_exists,a1
		bra	rd_errorp

redirect_not_outputable_device:
		lea	msg_not_outputable_device,a1
rd_errorp:
		bsr	reset_delete_io
		bsr	pre_perror
		movea.l	a1,a0
		bra	print_shell_error

rd_perror:
		bsr	reset_delete_io
		bsr	perror
		bra	shell_error
*****************************************************************
is_invalid_null_command:
		move.b	last_connect_type(a4),d0
		cmp.b	#TPIPE,d0
		beq	is_invalid_null_command_return

		cmp.b	#TOR,d0
		beq	is_invalid_null_command_return

		cmp.b	#TAND,d0
		beq	is_invalid_null_command_return

		move.b	connect_type(a6),d0
		cmp.b	#TPIPE,d0
		beq	is_invalid_null_command_return

		cmp.b	#TOR,d0
		beq	is_invalid_null_command_return

		cmp.b	#TAND,d0
is_invalid_null_command_return:
		rts
*****************************************************************
check_out_both:
		sf	output_both(a4)
		tst.w	d7
		beq	out_not_both

		cmpi.b	#'&',(a0)
		bne	out_not_both

		tst.b	1(a0)
		bne	out_not_both

		st	output_both(a4)
		bsr	strfor1
		subq.w	#1,d7
out_not_both:
		rts
*****************************************************************
.xdef verbose

verbose_0:
*		tst.l	fork_stackp(a5)
*		bne	print_verbose_done

		btst	#1,d2
		bne	verbose

		btst	#3,d2
		bne	do_print_verbose
verbose:
		tst.b	flag_verbose(a5)
		beq	print_verbose_done
do_print_verbose:
		bsr	echo_args
print_verbose_done:
		rts
*****************************************************************
skip_redirect_token:
		tst.b	1(a0)
		beq	skip_redirect_token_1

		cmp.b	1(a0),d0
		bne	skip_redirect_token_9

		tst.b	2(a0)
		bne	skip_redirect_token_9
skip_redirect_token_1:
		addq.w	#1,d1
		bsr	strfor1
		subq.w	#1,d7
		beq	skip_redirect_token_done

		cmpi.b	#'&',(a0)
		bne	skip_redirect_token_2

		tst.b	1(a0)
		bne	skip_redirect_token_2

		addq.w	#1,d1
		bsr	strfor1
		subq.w	#1,d7
skip_redirect_token_2:
		tst.w	d7
		beq	skip_redirect_token_done

		cmpi.b	#'!',(a0)
		bne	skip_redirect_token_done

		tst.b	1(a0)
		bne	skip_redirect_token_done
skip_redirect_token_9:
		addq.w	#1,d1
		bsr	strfor1
		subq.w	#1,d7
skip_redirect_token_done:
		rts
*****************************************************************
* DoSimpleCommand - �P���R�}���h�����s����
*
* CALL
*      simple_args
*      argc
*      D1.B   ����ԕ�  0:$time�ɏ]��  1:��ɍs��
*      D2.B   ��0:�ċA�ł���..�ϐ��W�J�����Ȃ��C���o�͂����Z�b�g���Ȃ�
*
* RETURN
*      �S��   �j��
*****************************************************************
.xdef DoSimpleCommand_recurse_2
.xdef DoSimpleCommand_recurse
.xdef set_status

status = -4
timer_exec_start_low = status-4
timer_exec_start_high = timer_exec_start_low-4
timer_flag = timer_exec_start_high-1
recursed = timer_flag-1
arg_is_huge = recursed-1
status_ok = arg_is_huge-1
pad = status_ok-0

DoSimpleCommand_recurse_2:
		move.w	d0,argc(a5)
		lea	simple_args(a5),a0
		bsr	copy_wordlist
DoSimpleCommand_recurse:
		st	d4
DoSimpleCommand:
		link	a6,#pad
		clr.l	user_command_signal
		sf	cwd_changed(a5)
		sf	status_ok(a6)
		move.b	d1,timer_flag(a6)
		move.b	d2,recursed(a6)
		move.w	argc(a5),d0
		beq	simple_command_done_0
	*
	*  �R�}���h�E�O���[�v�ł��邩�ǂ����𒲂ׂ�
	*
		lea	simple_args(a5),a0
		cmpi.b	#'(',(a0)
		bne	is_not_command_group

		tst.b	1(a0)
		bne	is_not_command_group
	*
	*  �R�}���h�̓R�}���h�E�O���[�v�ł���
	*
		movea.l	a0,a1
		subq.w	#1,d0
		bcs	badly_placed_paren

		bsr	strforn
		cmpi.b	#')',(a0)
		bne	badly_placed_paren

		tst.b	1(a0)
		bne	badly_placed_paren

		subq.w	#1,d0
		bcs	simple_command_done_0

		movea.l	a1,a0
		bsr	strfor1
run_simple_command_in_subshell:
		bsr	set_timer_exec_start
		bsr	run_command_in_subshell
		bra	simple_command_done

is_not_command_group:
	*
	*  �R�}���h�̓R�}���h�E�O���[�v�ł͂Ȃ�
	*
		tst.b	recursed(a6)			*  �ċA�Ȃ��
		bne	start_do_simple_command		*  �ϐ��u���͂��Ȃ�

		move.w	argc(a5),d0
		movea.l	a0,a1
		bsr	subst_var_wordlist
		bmi	shell_error

		move.w	d0,argc(a5)
		beq	simple_command_done_0

		tst.b	not_execute(a5)
		beq	start_do_simple_command

		movea.l	a0,a1
		bsr	expand_wordlist			* �����`�F�b�N�̂���
		bra	simple_command_done_0

start_do_simple_command:
	*
	*  �R�}���h���� program_name �ɓW�J����
	*
		lea	simple_args(a5),a0
		lea	program_name(a5),a1
		move.l	#MAXPATH,d1
		bsr	expand_a_word
		bpl	command_name_ok

		cmp.l	#-4,d0
		beq	shell_error

		bsr	strip_quotes
		bsr	pre_perror

		lea	msg_too_long_command_name,a0
		cmp.l	#-3,d0
		beq	print_shell_error

		cmp.l	#-2,d0
		beq	print_shell_error

		lea	msg_command_ambiguous,a0
		cmp.l	#-1,d0
		beq	print_shell_error

		lea	msg_missing_command_name,a0
		bra	print_shell_error

command_name_ok:
		lea	program_name(a5),a0
		lea	function_root(a5),a2
		bsr	find_function
		beq	not_function
	*
	*  �֐�
	*
		movea.l	d0,a1				*  A1 : �֐��̃w�b�_�̐擪�A�h���X
		lea	simple_args(a5),a0
		move.w	argc(a5),d0
		bsr	test_function_sub
		bne	simple_run_function_in_subshell

		tst.l	undup_input(a5)
		bpl	simple_run_function_in_subshell

		tst.l	undup_output(a5)
		bpl	simple_run_function_in_subshell

		bclr.b	#FUNCTYPEBIT_SOURCEONCE,FUNC_TYPE(a1)
		not.b	pipe_flip_flop(a5)
		bsr	strfor1
		subq.w	#1,d0
		bsr	check_paren
		bne	badly_placed_paren

		bsr	echo_command_clear_status	*  �R�}���h���G�R�[�^status �� 0 �ɂ��Ă���
		exg	a1,a2
		movea.l	a0,a1
		lea	simple_args(a5),a0
		bsr	expand_wordlist			*  �������т�W�J����
		exg	a1,a2
		bmi	shell_error

		bsr	set_timer_exec_start
		move.l	a6,-(a7)
		bsr	source_function			*  �֐������s����
		movea.l	(a7)+,a6
		bra	simple_command_done_0		*  source_function��status��Ԃ��Ȃ�
							*  �i�G���[��������shell_error�ɒ��ԁj
simple_run_function_in_subshell:
		bsr	set_timer_exec_start
		bsr	run_function_in_subshell
		bra	simple_command_done

not_function:
		lea	program_name(a5),a0
		lea	program_pathname(a5),a1
		move.l	a1,d4				*  D4.L : exec(2) �ւ̈���
		moveq	#0,d0
		bsr	search_command_0		*  ��������
		cmp.l	#-1,d0
		beq	command_not_found

		add.l	#1,hash_hits(a5)
		btst	#31,d0
		beq	simple_command_user_command
	*
	*  �g�ݍ��݃R�}���h
	*
		bclr	#31,d0
		move.l	d0,a2

		lea	simple_args(a5),a0
		move.w	argc(a5),d0

		btst.b	#2,8(a2)
		beq	builtin_io_ok

		tst.l	undup_output(a5)
		bpl	run_simple_command_in_subshell

		not.b	pipe_flip_flop(a5)
builtin_io_ok:
		btst.b	#3,8(a2)
		beq	builtin_no_sub

		cmpi.b	#1,pipe1_delete(a5)
		beq	run_simple_command_in_subshell

		cmpi.b	#1,pipe2_delete(a5)
		beq	run_simple_command_in_subshell
builtin_no_sub:
		move.l	(a2),command_name(a5)

		bsr	strfor1
		subq.w	#1,d0

		btst.b	#1,8(a2)
		bne	builtin_paren_ok

		bsr	check_paren
		bne	badly_placed_paren
builtin_paren_ok:
		bsr	echo_command_clear_status	*  �R�}���h���G�R�[�^status �� 0 �ɂ��Ă���
		*
		*  �������т�W�J����
		*  �i�R�}���h�ɂ���ẮA�����ł͂܂��W�J���Ȃ��j
		*
		btst.b	#0,8(a2)
		bne	run_builtin

		movea.l	a0,a1
		lea	simple_args(a5),a0
		bsr	expand_wordlist
		bmi	shell_error
run_builtin:
		bsr	set_timer_exec_start
		movea.l	4(a2),a2
		move.l	a6,-(a7)
		jsr	(a2)
		movea.l	(a7)+,a6
		tst.l	d0
		bne	shell_error	* �g�ݍ��݃R�}���h�̃G���[�͍\���G���[�Ɠ����Ƃ���
		bra	simple_command_done_0

simple_command_user_command:
	*
	*  �v���O�����E�t�@�C��
	*
		move.l	d0,d2				* D2.L : �g���q�R�[�h

		lea	simple_args(a5),a0
		movea.l	a0,a1
		bsr	strfor1
		move.w	argc(a5),d0
		subq.w	#1,d0
		bsr	check_paren
		bne	badly_placed_paren
		*
		*  �������т�W�J����
		*
		exg	a0,a1
		bsr	expand_wordlist
		bmi	shell_error

		move.w	d0,argc(a5)
		*
		*  �R�}���h���G�R�[����
		*
		bsr	echo_command
		*
		*  ���ۂɋN������o�C�i���E�R�}���h�E�t�@�C���̃p�X����
		*  �p�����[�^�s�����肷��
		*
		lea	user_command_parameter(a5),a3	*  A3 : �p�����[�^�s�̐擪
		move.l	#MAXLINELEN,d3			*  D3.L : �p�����[�^�s�̍ő啶����
		*
		*  ���s�\���H
		*
		subq.l	#1,d2
		blo	cannot_exec			*  0 : ���s�s��
		beq	do_script_or_x			*  1 : no ext

		subq.l	#3,d2
		blo	do_binary_command		*  2 : .R, 3:.X
		beq	do_script_with_batshell		*  4 : .BAT
do_script_or_x:
		lea	program_pathname(a5),a0
		bsr	open_command
		bmi	do_binary_command		*  �V�X�e���C��

		move.l	d1,tmpfd(a5)
		tst.l	d0
		beq	do_x_type			*  .X�`��

		lea	word_shell,a0
		cmp.b	#'$',d0				*  # �̎��̕����� $ �Ȃ��
		beq	do_script_with_implicit_shell	*  $shell �Ŏ��s

		*  �C���^�[�v���^�̃p�X����ǂݎ��

		move.l	d1,d0
		bsr	fskip_space
		bmi	do_script_with_implicit_shell

		cmp.b	#LF,d0
		beq	do_script_with_implicit_shell

		lea	program_name(a5),a0
		move.w	#MAXPATH,d2
get_shell_loop:
		subq.w	#1,d2
		bcs	shell_too_long

		move.b	d0,(a0)+
		move.l	tmpfd(a5),d0
		bsr	fgetc
		bmi	get_shell_done

		bsr	isspace3			*  SP, HT, CR, LF
		bne	get_shell_loop
get_shell_done:
		clr.b	(a0)

		*  �C���^�[�v���^�ɓn�������������X�g��ǂݎ��

		tst.l	d0
		bmi	do_script_initargs_ok

		cmp.b	#LF,d0
		beq	do_script_initargs_ok

		move.l	tmpfd(a5),d0
		bsr	fskip_space
		bmi	do_script_initargs_ok

		cmp.b	#LF,d0
		beq	do_script_initargs_ok

		lea	tmpargs,a0
		move.b	#' ',(a0)+
		move.b	d0,(a0)+
		move.l	tmpfd(a5),d0
		move.w	#MAXWORDLISTSIZE-3,d1
		bsr	fgets
		beq	script_arg_ok
		bpl	hugearg_error
script_arg_ok:
		lea	tmpargs,a0
		bsr	strlen
		sub.l	d0,d3
		bcs	simple_command_too_long_line

		movea.l	a0,a1
		movea.l	a3,a0
		bsr	memmovi
		movea.l	a0,a3
do_script_initargs_ok:
		bra	do_script_with_explicit_shell
****************
do_script_with_batshell:
		lea	program_pathname(a5),a0		*  �X�N���v�g�̃p�X����
		bsr	sltobsl				*  \ �� / �ɕς���
		lea	word_batshell,a0
do_script_with_implicit_shell:
		clr.b	program_name(a5)
		bsr	get_shellvar
		beq	do_script_with_explicit_shell

		move.l	d0,d1
		bsr	strlen				*  �ŏ��̒P��̒���
		cmp.l	#MAXPATH,d0
		bhi	shell_too_long

		movea.l	a0,a1
		lea	program_name(a5),a0
		bsr	strmove

		*  �擱�������G���R�[�h����
		subq.l	#1,d1
		movea.l	a3,a0
		move.l	d3,d0
		bsr	EncodeHUPAIR
		bmi	simple_command_too_long_line

		movea.l	a0,a3
		move.l	d0,d3
do_script_with_explicit_shell:
		bsr	close_tmpfd

		lea	program_pathname(a5),a1		*  �X�N���v�g�̃p�X����
		moveq	#1,d1
		movea.l	a3,a0
		move.l	d3,d0
		bsr	EncodeHUPAIR			*  �R�}���h���C���ɃG���R�[�h����
		bmi	simple_command_too_long_line

		movea.l	a0,a3
		move.l	d0,d3

		*  �C���^�[�v���^����������

		*  A1 : program_pathname(a5)
		lea	program_name(a5),a0
		moveq	#1,d0				*  ~~ �͌������Ȃ�
		bsr	search_command_0
		tst.l	d0
		bmi	interpreter_not_found
		beq	cannot_exec			*  0 : ���s�s��

		subq.l	#2,d0
		blo	test_interpreter_magic		*  1 : no ext
		beq	do_binary_command		*  2 : .R �͎��s��

		subq.l	#2,d0
		blo	do_binary_command		*  3 : .X �͎��s��
		beq	cannot_exec			*  4 : .BAT �͎��s�s��
test_interpreter_magic:
		movea.l	a1,a0
		bsr	test_command_file
		bne	do_binary_command		*  .X �ȊO�̓V�X�e���C��
do_x_type:
		bsr	close_tmpfd
		or.l	#$03000000,d4			*  Load as .X type file
do_binary_command:
		lea	simple_args(a5),a1
		moveq	#0,d1
		move.w	argc(a5),d1
		movea.l	a3,a0
		move.l	d3,d0
		bsr	EncodeHUPAIR
		bmi	simple_command_too_long_line

		lea	user_command_parameter(a5),a1	*  A1 : �p�����[�^�s�̐擪
		move.l	#MAXLINELEN,d1			*  D1.L : �p�����[�^�s�̍ő啶����
		lea	program_name(a5),a2		*  A2 : argv0
		bsr	SetHUPAIR
		bmi	simple_command_too_long_line

		cmp.l	d1,d0
		sne	arg_is_huge(a6)

		bsr	build_user_env
		beq	exec_failure

		move.l	d0,user_command_env(a5)
		bsr	remember_misc_environments

		move.w	#-1,-(a7)
		DOS	_BREAKCK
		addq.l	#2,a7
		move.w	d0,saved_breakflag(a5)
		DOS	_VERNUM
		cmp.w	#$0203,d0
		bhs	load_binary
		*  Human68k 2.02 �܂ł́C_EXEC(LOAD)�Ԃ̓u���[�N���֎~���Ă����D
		*  �����Ńu���[�N�������Ă��܂��ƁCLOAD�̂��߂̃t�@�C���E�n���h����
		*  �N���[�Y���ꂸ�ɖ߂��ė��Ă��܂��C����͉���ł��Ȃ�����ł���D
		move.w	#2,-(a7)			*  BREAK KILL
		DOS	_BREAKCK
		addq.l	#2,a7
load_binary:
		sf	in_fish
		movem.l	a5-a6,-(a7)
		move.l	user_command_env(a5),-(a7)	*  ���̃A�h���X
		pea	user_command_parameter(a5)	*  �p�����[�^�̃A�h���X
		move.l	d4,-(a7)			*  �N������R�}���h�̃p�X���̃A�h���X
		move.w	#1,-(a7)			*  �t�@���N�V���� : LOAD
		DOS	_EXEC
		lea	14(a7),a7
		movem.l	(a7),a5-a6
		bsr	resume_breakflag
		tst.l	d0
		bmi	loadprg_stop

		tst.l	user_command_signal
		bne	loadprg_stop			*  ���[�h���� break ���ꂽ

		cmp.w	#1,saved_breakflag(a5)		*  BREAK ON ?
		bne	load_binary_done

		move.l	a7,$3c(a0)
		move.l	#loadprg_stop,$14(a0)
		DOS	_KEYSNS				*  �����łP�x�u���[�N������
load_binary_done:
		tst.b	arg_is_huge(a6)
		beq	do_exec
****************
		*  ���[�U�E�v���O�����ւ̈�����255�o�C�g�𒴂��Ă���
		*
		*  �R�}���h�� HUPAIR�������ǂ����𒲂ׂ�
		*
		movea.l	a0,a3
		lea	2(a4),a0
		lea	str_hupair,a1
		bsr	strcmp
		beq	do_exec				*  HUPAIR�����ł��� .. ���s����
		*
		*  �V�F���ϐ� hugearg �𒲂ׂ�
		*
		lea	word_hugearg,a0			*  �V�F���ϐ� hugearg ��
		bsr	find_shellvar			*  ��`�����
		beq	ask_hugearg			*  ���Ȃ��Ȃ�΁C�₢���킹��

		bsr	get_var_value
		beq	hugearg_abort			*  �P�ꐔ��0�Ȃ�A�{�[�g����

		move.w	d0,d2				*  D2.W : �P�ꐔ
		lea	word_force,a1			*  force
		bsr	strcmp
		beq	do_exec				*    �Ȃ�Ύ��s����

		lea	word_indirect,a1		*  indirect
		bsr	strcmp
		beq	hugearg_indirect		*    �Ȃ�� indirect
hugearg_abort:						*  �����Ȃ��΃A�{�[�g����
ask_hugearg:
		lea	hugearg_error(pc),a4
hugearg_abort1:
		movem.l	d0/a4-a6,-(a7)
		lea	fail_hugearg(pc),a1
		move.l	a1,$14(a3)
		move.l	a7,$3c(a3)
		DOS	_EXIT
fail_hugearg:
		movem.l	(a7)+,d0/a4-a6
		st	in_fish
		jmp	(a4)

hugearg_indirect:
		lea	str_indirect_flag,a1
		cmp.w	#2,d2
		blo	hugearg_indirect_flag_ok

		bsr	strfor1
		tst.b	(a0)
		beq	hugearg_indirect_flag_ok

		movea.l	a0,a1
hugearg_indirect_flag_ok:
		lea	argument_pathname,a0
		bsr	tmpfile
		bmi	hugearg_indirect_error

		move.l	d0,tmpfd(a5)
		move.w	d0,d2
		lea	user_command_parameter+1(a5),a0
		bsr	strlen
		move.l	d0,-(a7)
		move.l	a0,-(a7)
		move.w	d2,-(a7)
		move.l	d0,d2				*  D2.L : �������ރo�C�g��
		DOS	_WRITE
		lea	10(a7),a7
		bsr	close_tmpfd
		bmi	hugearg_indirect_perror

		cmp.l	d2,d0
		bne	hugearg_indirect_disk_full

		bsr	stpcpy
		move.l	d0,d1
		lea	argument_pathname,a1
		bsr	strcpy
		bsr	sltobsl
		add.l	d1,d0
		cmp.l	#255,d0
		bhs	hugearg_indirect_too_long

		move.b	d0,user_command_parameter(a5)
		bra	do_exec

hugearg_indirect_too_long:
		lea	too_long_indirect_flag(pc),a4
		bra	hugearg_abort1

hugearg_indirect_error:
		lea	shell_error(pc),a4
		bra	hugearg_abort1

hugearg_indirect_disk_full:
		moveq	#-23,d0
hugearg_indirect_perror:
		lea	argument_indirect_perror(pc),a4
		bra	hugearg_abort1
****************
do_exec:
		bsr	set_timer_exec_start
		move.l	a4,-(a7)		*  �G���g���E�A�h���X
		move.w	#4,-(a7)		*  �t�@���N�V���� : EXEC
		DOS	_EXEC
		addq.l	#6,a7
loadprg_stop:
		movem.l	(a7)+,a5-a6
		st	in_fish
		movem.l	d0/a0,-(a7)
		lea	user_command_env(a5),a0
		bsr	xfreep
		sf	d0
		lea	program_pathname(a5),a0
		bsr	resume_misc_environments
		movem.l	(a7)+,d0/a0
		tst.l	d0
		bmi	exec_failure

		cmp.l	#$10000,d0
		bcs	exec_done

		and.l	#$ff,d0
		or.l	#$100,d0
exec_done:
		ext.l	d0
		bra	simple_command_done

simple_command_done:
		bsr	check_simple_command_signal
		move.l	d0,status(a6)
		st	status_ok(a6)
		bset.b	#1,timer_flag(a6)
simple_command_done_0:
		clr.l	command_name(a5)
		tst.b	recursed(a6)
		bne	not_reset_io

		bsr	reset_io
not_reset_io:
		move.l	timer_exec_start_low(a6),d2
		move.l	timer_exec_start_high(a6),d3
		btst.b	#0,timer_flag(a6)
		bne	report_command_time

		btst.b	#1,timer_flag(a6)
		beq	simple_command_done_1

		bsr	check_command_time
		bra	simple_command_done_1

report_command_time:
		bsr	report_time
simple_command_done_1:
		tst.b	status_ok(a6)
		beq	not_set_status

		move.l	status(a6),d0
		bsr	check_and_set_status
not_set_status:
		unlk	a6
		tst.b	cwd_changed(a5)
		beq	simple_command_return
		*
		*  �֐� cwdcmd ���i��������΁j���s����
		*
		lea	word_cwdcmd,a0
		lea	function_root(a5),a2
		bsr	find_function
		beq	simple_command_return

		clr.l	user_command_signal
		movea.l	d0,a1				*  A1 : �֐��̃w�b�_�̐擪�A�h���X
		moveq	#0,d0				*  �֐��ւ̈����͖���
		bsr	test_function_sub
		beq	source_function

		moveq	#1,d0				*  �T�u�V�F���ւ̈����͂P�i�֐����j
		bsr	run_function_in_subshell
check_and_set_status:
		tst.l	d0
		beq	set_status

		tst.b	flag_printexitvalue(a5)
		beq	check_and_set_status_e

		movem.l	d0-d4/a0-a2,-(a7)
		lea	msg_exit,a0
		bsr	puts
		moveq	#1,d1				*  ���l��
		moveq	#1,d3				*  �ŏ��t�B�[���h���F1
		moveq	#1,d4				*  �����Ƃ� 1��
		lea	itoa(pc),a0			*  signed -> decimal ��
		lea	putc(pc),a1			*  �W���o�͂�
		suba.l	a2,a2				*  prefix �Ȃ�
		bsr	printfi
		bsr	put_newline
		movem.l	(a7)+,d0-d4/a0-a2
check_and_set_status_e:
		tst.b	exit_on_error(a5)
		bne	exit_shell_d0
set_status:
		movem.l	d1-d2/a0,-(a7)

		move.l	d0,-(a7)

		move.w	#-1,-(a7)
		DOS	_BREAKCK
		move.w	d0,d2
		move.w	#2,(a7)
		DOS	_BREAKCK
		addq.l	#2,a7

		move.l	(a7)+,d0

		lea	word_status,a0
		sf	d1
		bsr	set_shellvar_num
		move.l	d0,-(a7)
		move.w	d2,-(a7)
		DOS	_BREAKCK
		addq.l	#2,a7
		move.l	(a7)+,d0
		movem.l	(a7)+,d1-d2/a0
simple_command_return:
		rts


check_simple_command_signal:
		move.l	d0,d1
		move.l	user_command_signal,d0
		bne	manage_signals

		move.l	d1,d0
		cmp.l	#$200,d0
		blo	check_simple_command_signal_return

		cmp.l	#$400,d0
		blo	manage_signals
check_simple_command_signal_return:
		rts


test_function_sub:
		move.b	FUNC_TYPE(a1),d1
		bclr.b	#FUNCTYPEBIT_SOURCEONCE,FUNC_TYPE(a1)
		btst	#FUNCTYPEBIT_SUB,d1
		beq	test_function_sub_return

		btst	#FUNCTYPEBIT_SOURCEONCE,d1
		seq	d1
		tst.b	d1
test_function_sub_return:
		rts


argument_indirect_perror:
		lea	argument_pathname,a0
		bra	simple_command_perror

interpreter_not_found:
		moveq	#ENOFILE,d0
		lea	program_name(a5),a0
simple_command_perror:
		bsr	reset_delete_io
		bsr	perror
		bra	shell_error

simple_command_too_long_line:
		bsr	reset_delete_io
		bsr	too_long_line
		bra	shell_error

exec_failure:
		lea	msg_exec_failure,a1
		bra	simple_command_errorp

cannot_exec:
		lea	msg_cannot_exec,a1
		bra	simple_command_errorp

badly_placed_paren:
		lea	msg_badly_placed_paren,a0
		bra	print_shell_error

shell_too_long:
		lea	msg_shell_too_long,a0
		bra	print_shell_error

hugearg_error:
		lea	msg_too_long_arg_for_program,a0
		bra	print_shell_error

too_long_indirect_flag:
		lea	msg_too_long_indirect_flag,a0
		bra	print_shell_error

command_not_found:
		lea	msg_no_command,a1
		bra	simple_command_errorpp

simple_command_errorp:
		lea	program_pathname(a5),a0
simple_command_errorpp:
		bsr	reset_io
		bsr	pre_perror
		movea.l	a1,a0
		bra	print_shell_error


set_timer_exec_start:
		movem.l	d0-d1,-(a7)
		IOCS	_ONTIME
		move.l	d1,timer_exec_start_high(a6)
		move.l	d0,timer_exec_start_low(a6)
		movem.l	(a7)+,d0-d1
		rts
****************************************************************
* test_command_file - �R�}���h�t�@�C�������s�\���ǂ������ׂ�
*
* CALL
*      A0     �p�X��
*
* RETURN
*      D0.L   ��:���s�s�C0:.X�C'$' or '!':text
*      CCR    TST.L D0
****************************************************************
.xdef test_command_file

test_command_file:
		movem.l	d1,-(a7)
		bsr	open_command
		bmi	test_command_file_return

		bsr	fclose1_tstd0
test_command_file_return:
		movem.l	(a7)+,d1
		rts
****************************************************************
* open_command - �R�}���h�t�@�C����open���C���s�\���ǂ������ׂ�
*
* CALL
*      A0     �p�X��
*
* RETURN
*      D0.L   ��:���s�s�C0:.X�C'$' or '!':text
*      D1.L   D0.L>=0 �̂Ƃ��C�t�@�C���n���h���i2�o�C�g�i��ł���j
*             D0.L<0 �̂Ƃ��͔j��
*      CCR    TST.L D0
****************************************************************
open_command:
		moveq	#0,d0
		bsr	tfopen
		bmi	open_command_return

		move.l	d0,d1
		bsr	check_executable_magic
		bpl	open_command_return
fclose1_tstd0:
		exg	d0,d1
		bsr	fclose
		exg	d0,d1
		tst.l	d0
open_command_return:
		rts
*****************************************************************
* check_executable_magic - �R�}���h�t�@�C����magic�𒲂ׂ�
*
* CALL
*      D1.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   ��:���s�s�C0:.X�C'$' or '!':text
*      CCR    TST.L d0
*
* NOTE
*      D0.L>=0 �̂Ƃ��C�t�@�C���|�C���^�� 2�o�C�g�i��ł���D
*      D0.L<0 �̂Ƃ��͕s��D
*****************************************************************
check_executable_magic:
		move.w	d1,d0
		bsr	fgetc
		cmp.b	#'#',d0
		beq	maybe_commands_text

		cmp.b	#'H',d0
		bne	check_executable_magic_error

		move.w	d1,d0
		bsr	fgetc
		cmp.b	#'U',d0
		bne	check_executable_magic_error

		moveq	#0,d0
		bra	check_executable_magic_return	*  D0.L = 0 : .X�^�C�v

maybe_commands_text:
		move.w	d1,d0
		bsr	fgetc				*  # �̎��̕�����
		cmp.b	#'$',d0				*  $ �Ȃ�� fish �Ŏ��s
		beq	check_executable_magic_return	*  D0.L = '$' : text

		cmp.b	#'!',d0
		bne	check_executable_magic_error
							*  D0.L = '!'
check_executable_magic_return:
		tst.l	d0
		rts

check_executable_magic_error:
		moveq	#-1,d0
		bra	check_executable_magic_return
****************************************************************
build_user_env:
		movem.l	d1-d2/a0-a2,-(a7)
		movea.l	env_top(a5),a1
		moveq	#0,d2
build_user_env_calc_loop:
		cmpa.l	#0,a1
		beq	build_user_env_calc_done

		movea.l	a1,a0
		bsr	varsize
		add.l	d0,d2
		movea.l	var_next(a1),a1
		bra	build_user_env_calc_loop

build_user_env_calc_done:
		lea	word_envmargin,a0
		bsr	get_shellvar
		beq	build_user_env_margin_ok

		bsr	atou
		bmi	build_user_env_margin_ok
		bne	build_user_env_fail

		add.l	d1,d2				*  + margin
build_user_env_margin_ok:
		addq.l	#4+1+1,d2			*  + size field + tail null + pad
		bclr	#0,d2				*  D2 : ���G���A�̃T�C�Y
		move.l	d2,d0
		bsr	xmalloc
		beq	build_user_env_fail

		movea.l	d0,a0
		move.l	d2,(a0)+
		move.l	d0,d1
		movea.l	env_top(a5),a2
build_user_env_loop:
		cmpa.l	#0,a2
		beq	build_user_env_done

		lea	var_body(a2),a1
		bsr	strmove
		move.b	#'=',-1(a0)
		bsr	strmove
		movea.l	var_next(a2),a2
		bra	build_user_env_loop

build_user_env_done:
		clr.b	(a0)
		move.l	d1,d0
build_user_env_return:
		movem.l	(a7)+,d1-d2/a0-a2
		rts

build_user_env_fail:
		moveq	#0,d0
		bra	build_user_env_return
****************************************************************
* remember_misc_environments - ���v���Z�X�����L������
*
* CALL
*      none
*
* RETURN
*      none
****************************************************************
remember_misc_environments:
		movem.l	d0/a0,-(a7)
		lea	save_cwd(a5),a0
		bsr	getcwd
		movem.l	(a7)+,d0/a0
		rts
****************************************************************
* resume_misc_environments - ���v���Z�X���𕜋�����
*
* CALL
*      A0       ���s�����v���O�����̃p�X���i�T�u�V�F���Ȃ�""�j
*      D0.B     cwd �ۑ��t���O
*
* RETURN
*      none
****************************************************************
resume_misc_environments:
		link	a6,#-auto_pathname
		movem.l	d0-d1/a0-a2,-(a7)
		movea.l	a0,a2
		move.b	d0,d1
		lea	-auto_pathname(a6),a0
		bsr	getcwd
		lea	save_cwd(a5),a1
		bsr	strcmp
		beq	resume_cwd_ok2			*  ��ƃf�B���N�g���͕ς���Ă��Ȃ�

		tst.b	d1
		bne	resume_cwd

		lea	word_cdcmds,a0
		bsr	get_shellvar
		beq	resume_cwd

		movem.l	d0/a0,-(a7)
		movea.l	a2,a0
		bsr	headtail
		movem.l	(a7)+,d0/a0
		bsr	wordlistpcmp
		beq	resume_cwd_ok0			*  ����̍�ƃf�B���N�g�����󂯓����
resume_cwd:
		*  ��ƃf�B���N�g�������ɖ߂�
		lea	save_cwd(a5),a0
		bsr	chdir
		bpl	resume_cwd_ok1

		*  ���ɖ߂��Ȃ����� .. ����̍�ƃf�B���N�g�����󂯓����
		bsr	pre_perror
		lea	msg_cwd_failure,a0
		bsr	enputs
		lea	-auto_pathname(a6),a0
		bsr	eputs
		lea	msg_change_cwd,a0
		bsr	enputs
resume_cwd_ok0:
		bsr	set_oldcwd
resume_cwd_ok1:
		bsr	reset_cwd
resume_cwd_ok2:
		movem.l	(a7)+,d0-d1/a0-a2
		unlk	a6
		rts
****************************************************************
check_paren:
		movem.l	d0/a0,-(a7)
		bra	check_paren_continue

check_paren_loop:
		cmpi.b	#'(',(a0)
		beq	check_paren_1

		cmpi.b	#')',(a0)
		bne	check_paren_next
check_paren_1:
		tst.b	1(a0)
		beq	check_paren_break
check_paren_next:
		bsr	strfor1
check_paren_continue:
		dbra	d0,check_paren_loop
check_paren_break:
		addq.w	#1,d0
		movem.l	(a7)+,d0/a0
not_echo_command:
		rts
****************************************************************
echo_command:
		tst.b	flag_echo(a5)
		beq	not_echo_command

		movem.l	d0/a0,-(a7)
		lea	program_name(a5),a0
		bsr	ecputs
		moveq	#' ',d0
		bsr	eputc
		movem.l	(a7)+,d0/a0
		bra	echo_args
****************************************************************
print_shell_error:
		bsr	reset_delete_io
		bsr	enputs
shell_error:
		moveq	#1,d0
		bra	break_shell


echo_command_clear_status:
		bsr	echo_command
clear_status:
		move.l	d0,-(a7)
		moveq	#0,d0
		bsr	set_status
		move.l	(a7)+,d0
		rts
*****************************************************************
* get_status - �V�F���ϐ� status �̒l�𐔒l�ɕϊ�����
*
* CALL
*      none
*
* RETURN
*      D0.L   $status[1]�̒l�D������ $status[1]�̎擾���G���[�Ȃ�� 1
*      CCR    $status[1]�̎擾���G���[�Ȃ�� NE
*
* NOTE
*      $status[1]�̎擾���G���[�Ȃ�΃G���[�E���b�Z�[�W��\������
*****************************************************************
get_status:
		movem.l	d1/a0,-(a7)
		lea	word_status,a0
		bsr	svartol
		exg	d0,d1
		cmp.l	#5,d1
		beq	get_status_ok

		lea	msg_bad_status,a0
		bsr	enputs
		moveq	#0,d0
		moveq	#1,d1
get_status_ok:
		movem.l	(a7)+,d1/a0
		rts
*****************************************************************
echo_args:
		movem.l	d0/a1,-(a7)
		lea	ecputs(pc),a1
		bsr	echo
		bsr	eput_newline
		movem.l	(a7)+,d0/a1
		rts
*****************************************************************
count_time:
		IOCS	_ONTIME
		sub.l	d3,d1		* D1 : 24���Ԉȏ㕔���̓���
		sub.l	d2,d0		* D0 : 24���Ԗ���������1/100�b��
		bcc	count_time_1

		add.l	#24*60*60*100,d0
		subq.l	#1,d1
count_time_1:
		move.l	d1,-(a7)
		move.l	#60*60*100,d1
		bsr	divul
		move.l	d0,d3		* D3 : 1���Ԉȏ�24���Ԗ��������̎��Ԑ�
		move.l	d1,d2		* D2 : 1���Ԗ���������1/100�b��
		move.l	(a7)+,d1
		move.l	#24,d0
		bsr	mulul		* D1:D0 : 24���Ԉȏ㕔���̓��������Ԑ��Ɋ��Z�����l
		tst.l	d1
		bne	count_time_hour_overflow

		add.l	d3,d0
		bcs	count_time_hour_overflow

		cmp.l	#99,d0
		bls	count_time_hour_ok
count_time_hour_overflow:
		moveq	#99,d0
count_time_hour_ok:
		move.l	#60*60*100,d1
		bsr	mulul
		add.l	d2,d0
		rts
*****************************************************************
.xdef report_time

check_command_time:
		tst.l	fork_stackp(a5)
		bne	check_command_time_return	*  �T�u�V�F���̒��ł� $time �͖���

		lea	word_time,a0
		bsr	svartou
		move.l	d1,d4				*  D4.L : $time[1] �̒l
		neg.l	d0
		bpl	check_command_time_return	*  $time[1] �͖����^�I�[�o�[�t���[

		bsr	count_time
		move.l	d0,d2
		move.l	#100,d1
		bsr	divul
		cmp.l	d4,d0
		blo	check_command_time_return

		move.l	d2,d0
		bra	report_time_1

report_time:
		bsr	count_time
report_time_1:
		movem.l	d0-d5/a0,-(a7)
		moveq	#0,d5				*  �E�l��
		moveq	#'0',d2				*  '0' �� padding�D
		moveq	#1,d3				*  ���Ȃ��Ƃ�1�������o��
		moveq	#1,d4				*  ���Ȃ��Ƃ�1�����o��
		cmp.l	#60*100,d0
		blo	report_time_second

		lea	str_colon,a0
		cmp.l	#60*60*100,d0
		blo	report_time_minute

		move.l	#60*60*100,d1
		bsr	report_time_printi
report_time_minute:
		move.l	#60*100,d1
		bsr	report_time_printi
report_time_second:
		moveq	#100,d1
		lea	str_dot,a0
		bsr	report_time_printi
		moveq	#1,d1
		lea	str_newline,a0
		bsr	report_time_printi
		movem.l	(a7)+,d0-d5/a0
check_command_time_return:
		moveq	#0,d0
		rts

report_time_printi:
		bsr	divul
		exg	d1,d5
		bsr	printu
		exg	d1,d5
		moveq	#2,d4				*  ������͏��Ȃ��Ƃ�2�����o��
		bsr	puts
		move.l	d1,d0				*  D0.L : ��]
		rts
****************************************************************
.xdef is_builtin_dir

is_builtin_dir:
		movem.l	d0/a1,-(a7)
		lea	str_builtin_dir,a1
		bsr	strcmp
		movem.l	(a7)+,d0/a1
		rts
****************************************************************
.xdef builtin_dir_match

builtin_dir_match:
		movem.l	d1/a1,-(a7)
		lea	str_builtin_dir,a1
		exg	a0,a1
		bsr	strlen
		move.l	d0,d1
		bsr	memcmp
		exg	a0,a1
		beq	builtin_dir_match_ok

		moveq	#0,d1
builtin_dir_match_ok:
		move.l	d1,d0
		movem.l	(a7)+,d1/a1
		rts
*****************************************************************
find_from_table:
		movem.l	d0/a1,-(a7)
find_from_table_loop:
		move.l	(a2),d0
		beq	find_from_table_not_found

		movea.l	d0,a1
		bsr	strcmp
		bls	find_from_table_return

		lea	10(a2),a2
		bra	find_from_table_loop

find_from_table_not_found:
		moveq	#-1,d0
find_from_table_return:
		movem.l	(a7)+,d0/a1
		rts
*****************************************************************
.xdef check_executable_suffix

check_executable_suffix:
		movem.l	d1/a1,-(a7)
		moveq	#1,d1
		bsr	suffix
		beq	check_executable_suffix_done

		lea	ext_table,a1
check_executable_suffix_loop:
		addq.l	#1,d1
		tst.b	(a1)
		beq	check_executable_suffix_done

		bsr	stricmp
		beq	check_executable_suffix_done

		exg	a0,a1
		bsr	strfor1
		exg	a0,a1
		bra	check_executable_suffix_loop

check_executable_suffix_done:
		move.l	d1,d0
		movem.l	(a7)+,d1/a1
		rts
*****************************************************************
* find_command_file - �R�}���h����������
*
* CALL
*      A0     ��������R�}���h�̃p�X��
*             �t�@�C�������͎��ۂ̃t�@�C�����ɏ�����������̂ŁC
*             ���̕��̗]�T�����邱��
*
*      D0.B   0�Ȃ�Ίg���q�����Č�������
*
* RETURN
*      D0.L
*              1: �g���q����
*              2: .R
*              3: .X
*              4: .BAT
*              5: ��L�ȊO�̊g���q
*              0: ���s�s��
*             -1: ��������Ȃ�
*
*             ����ȊO: �g�ݍ��݃R�}���h�\�̃A�h���X+$80000000
*
* NOTE
*      �g���q�̑啶���Ə������͋�ʂ��Ȃ��D
*
*      �����D�揇�ʂȂ�΁C��Ɍ������ꂽ�����L���ƂȂ�D
*
*      set execbit �Ȃ�C�g���q�� .R .X .BAT �łȂ��Cx bit �������Ă��Ȃ�
*      �t�@�C���͎��s�s�Ƃ���D
*****************************************************************
statbuf = -STATBUFSIZE
l_statbuf = statbuf-STATBUFSIZE
realname = l_statbuf-((((MAXTAIL+1)+1)>>1)<<1)

find_command_file:
		link	a6,#realname
		movem.l	d1-d4/a0-a3,-(a7)
		movea.l	a0,a3
		move.b	d0,d3
		moveq	#-1,d1
		bsr	builtin_dir_match
		beq	find_disk_command

		cmpi.b	#'/',(a0,d0.l)
		beq	find_bultin_command

		cmpi.b	#'\',(a0,d0.l)
		bne	find_disk_command
****************
find_bultin_command:
		lea	1(a0,d0.l),a0
		lea	builtin_table,a2
		bsr	find_from_table
		bne	find_command_done

		move.l	a2,d1
		bset	#31,d1
		bra	find_command_file_return
****************
find_disk_command:
		bsr	drvchkp
		bmi	find_command_done

		tst.b	d3
		bne	find_command_file_static

		movea.l	a0,a2
		bsr	strbot
		lea	ext_asta,a1
		bsr	strcpy
		exg	a0,a2
find_command_file_static:
		move.w	#MODEVAL_ALL,-(a7)
		move.l	a0,-(a7)
		pea	statbuf(a6)
		DOS	_FILES
		lea	10(a7),a7
find_more_loop:
		tst.l	d0
		bmi	find_command_done

		lea	statbuf+ST_NAME(a6),a0
		bsr	check_executable_suffix
		cmp.l	d1,d0
		bhs	find_more_next

		move.l	d0,d4			*  D4.L : ���ڂ��Ă���t�@�C���̊g���q�R�[�h

		move.b	statbuf+ST_MODE(a6),d0	*  D0.B : mode
		tst.b	d3			*  �g���q�t���Ō��� - ���C���h�J�[�h�Ȃ� -
		bne	find_more_check_mode	*    ���� symbolic link �ł��Amode �͂���ŗǂ�
						*    �ilndrv�Ή��j

		*  �g���q�ȗ����� - ���C���h�J�[�h�����ł��� -
		*    o �g���q�R�[�h���T�Ȃ疳������
		*    o �V���{���b�N�E�����N�Ȃ�{�̂� mode �𓾂�

		cmp.l	#5,d4
		beq	find_more_next

		tst.b	flag_symlinks(a5)
		beq	find_more_check_mode

		btst	#MODEBIT_LNK,d0
		beq	find_more_check_mode

		movea.l	a0,a1
		movea.l	a2,a0
		bsr	strcpy
		movea.l	a3,a0
		lea	l_statbuf(a6),a1
		bsr	stat
		bmi	find_more_cannot_exec

		move.b	ST_MODE(a1),d0		*  D0.B : �����N���w���{�̂� mode
find_more_check_mode:
		btst	#MODEBIT_DIR,d0
		bne	find_more_cannot_exec

		btst	#MODEBIT_VOL,d0
		bne	find_more_cannot_exec

		cmp.l	#2,d4
		blo	find_more_check_mode_x

		cmp.l	#4,d4
		bls	find_more_ok
find_more_check_mode_x:
		tst.b	flag_execbit(a5)
		beq	find_more_ok

		btst	#MODEBIT_EXE,d0
		bne	find_more_ok
find_more_cannot_exec:
		moveq	#6,d4
		cmp.l	d1,d4
		bhs	find_more_next
find_more_ok:
		move.l	d4,d1
		tst.b	d3
		bne	find_command_done

		lea	statbuf+ST_NAME(a6),a1
		lea	realname(a6),a0
		bsr	strcpy
find_more_next:
		pea	statbuf(a6)
		DOS	_NFILES
		addq.l	#4,a7
		bra	find_more_loop

find_command_done:
		tst.l	d1
		bmi	find_command_file_miss

		cmp.l	#6,d1
		blo	command_file_done_1

		moveq	#0,d1
command_file_done_1:
		tst.b	d3
		bne	find_command_file_return

		movea.l	a3,a0
		bsr	headtail
		movea.l	a1,a0
		lea	realname(a6),a1
		bsr	strcpy
find_command_file_return:
		move.l	d1,d0
		movem.l	(a7)+,d1-d4/a0-a3
		unlk	a6
		rts

find_command_file_miss:
		add.l	#1,hash_misses(a5)
		bra	find_command_file_return
*****************************************************************
* search_command - �R�}���h����������
*
* CALL
*      A0     ��������R�}���h���DMAXPATH�o�C�g�ȉ��ł��邱��
*      A1     �R�[���o�b�N��NULL�̂Ƃ��C�������ʂ��i�[����o�b�t�@�DMAXPATH+1�o�C�g�K�v
*      A4     �R�[���o�b�N
*      D0.B   bit 0: $path ���̃��^�E�f�B���N�g���i~~�j�𖳎�����
*
* RETURN
*      �R�[���o�b�N��NULL�łȂ��ꍇ...
*      D0.L   �j��
*      D1-D4/A0-A3 �ۑ������
*      ���̑�   �R�[���o�b�N�ɂ��
*
*      �R�[���o�b�N��NULL�Ȃ��...
*      D0.L
*              1: �g���q����
*              2: .R
*              3: .X
*              4: .BAT
*              5: ��L�ȊO�̊g���q
*              0: ���s�s��
*             -1: ��������Ȃ�
*             ��L�ȊO : �g�ݍ��݃R�}���h�\�̃A�h���X+$80000000
*
*     (A1)    �������ʂ��i�[�����
*
* NOTE
*      �g���q�̑啶���Ə������͋�ʂ��Ȃ��D
*      �����D�揇�ʂȂ�΁C��Ɍ������ꂽ�����L���ƂȂ�D
*      set execbit �Ȃ�Cx bit �������Ă��Ȃ��t�@�C���͂��ׂĎ��s�s�Ƃ���D
*****************************************************************
.xdef search_command_0
.xdef search_command

exp_command_name = -auto_pathname

search_command_reglist		reg	d1-d4/a1-a3
search_command_precious_reglist	reg	d1-d4/a0-a3

search_command_0:
		suba.l	a4,a4
search_command:
		link	a6,#exp_command_name
		move.l	a0,-(a7)
		movem.l	search_command_reglist,-(a7)
		move.b	d0,d4				*  D4.B : �t���O

		bsr	contains_dos_wildcard		*  Human �̃��C���h�J�[�h���܂��
		bne	search_command_not_found	*  ����Ȃ�Ζ���

		bsr	split_pathname
		cmp.l	#MAXDIR,d1			*  �f�B���N�g������
		bhi	search_command_not_found	*  ���߂���

		*** TwentyOne �Ή� --��������--
		tst.l	d2				*  . �Ŏn�܂���
		beq	search_command_no_ext		*  ����...Human�g���q�͖���

		cmp.l	#1,d3				*  �Ō�� . ����̒�����
		bls	search_command_no_ext		*  1�ȉ�...Human�g���q�͖���

		cmp.l	#MAXEXT,d3			*  �Ō�� . ����̒�����
		bls	search_command_ext_ok		*  Human�g���q�ɓK��
search_command_no_ext:
		add.l	d3,d2				*  �Ō�� . ����̕�����file���Ƃ�
		moveq	#0,d3				*  �g���q�͖������̂Ƃ���D
search_command_ext_ok:
		*** TwentyOne �Ή� --�����܂�--
		cmp.l	#MAXFILE,d2			*  �t�@�C������
		bhi	search_command_not_found	*  ���߂���

		cmp.l	#MAXEXT,d3			*  �g���q����
		bhi	search_command_not_found	*  ���߂���

		move.b	(a3),d3				*  D3.B : �u�t�@�C�����Ɂe.�f����v�t���O

		tst.l	d0				*  �h���C�u�{�f�B���N�g���������邩�H
		beq	search_command_in_pathlist
	*
	*  �h���C�u�{�f�B���N�g���������� .. ���̂܂܌�������
	*
		movea.l	a0,a1				*  �p�X����
		lea	exp_command_name(a6),a0		*  exp_command_name ��
		bsr	strcpy				*  �R�s�[����
		move.b	d3,d0				*
		bsr	find_command_file		*  ��������
		cmp.l	#-1,d0
		beq	search_command_not_found	*  ������Ȃ�����

		cmpa.l	#0,a4
		beq	search_command_found

		movea.l	a7,a3
		movem.l	search_command_precious_reglist,-(a7)
		movem.l	(a3),search_command_reglist
		jsr	(a4)
		movem.l	(a7)+,search_command_precious_reglist
		bra	search_command_return

search_command_in_pathlist:
	*
	*  �f�B���N�g�������Ȃ� .. $path �ɏ]���Č�������
	*
							*  A2 : cmdname
		lea	word_path,a0
		bsr	get_shellvar
		beq	search_command_not_found

		move.l	a0,-(a7)			*  A0 : pathlist
		subq.w	#1,d0
		move.w	d0,d1				*  D1.W : $path �̗v�f�� - 1
		moveq	#-1,d2
		tst.b	hash_flag(a5)
		beq	search_command_in_pathlist_hash_done

		movea.l	a2,a0
		bsr	hash
		lea	hash_table(a5),a0
		move.b	(a0,d0.l),d2
search_command_in_pathlist_hash_done:
		movea.l	(a7)+,a0			*  A0 : pathlist
		lea	exp_command_name(a6),a1		*  A1 : buffer
search_command_in_pathlist_loop:
		tst.b	(a0)
		beq	search_command_in_pathlist_next

		ror.b	#1,d2
		bcs	search_command_hash_hit

		*  �n�b�V�����q�b�g���Ă��Ȃ��D
		*  ����ł��C���΃p�X�ł���ꍇ�ɂ͒T��
		bsr	isfullpath
		beq	search_command_in_pathlist_next	*  ��΃p�X�ł���

		bsr	is_builtin_dir
		beq	search_command_in_pathlist_next	*  ���z�f�B���N�g���ł���

		bra	search_command_tryone

search_command_hash_hit:
		*  �n�b�V�����q�b�g�����D
		*  �������C���z�f�B���N�g���𖳎�����悤�w������Ă���ꍇ�C
		*  ���ꂪ���z�f�B���N�g���Ȃ�Ό������Ȃ��D
		btst	#0,d4
		beq	search_command_tryone

		bsr	is_builtin_dir
		beq	search_command_in_pathlist_next
search_command_tryone:
		cmpi.b	#'.',(a0)
		bne	search_command_tryone_cat

		tst.b	1(a0)
		bne	search_command_tryone_cat

		* �J�����g�f�B���N�g��
		bsr	strfor1				*  A0:nextpath A1:buffer    A2:cmdname
		exg	a0,a1				*  A0:buffer   A1:nextpath
		exg	a1,a2				*              A1:cmdname   A2:nextpath
		bsr	strcpy
		exg	a1,a2				*              A1:nextpath  A2:cmdname
		bra	search_command_tryone_find

search_command_tryone_cat:
		bsr	strlen
		cmp.l	#MAXHEAD,d0
		bhs	search_command_in_pathlist_continue

		exg	a0,a1				*  A0:buffer   A1:currpath  A2:cmdname
		bsr	cat_pathname			*              A1:nextpath
		bmi	search_command_in_pathlist_continue
search_command_tryone_find:
							*  A0:buffer   A1:nextpath  A2:cmdname
		move.b	d3,d0
		bsr	find_command_file
		cmp.l	#-1,d0
		beq	search_command_in_pathlist_continue

		tst.l	d0
		beq	search_command_in_pathlist_continue

		cmpa.l	#0,a4
		beq	search_command_found

		movea.l	a7,a3
		movem.l	search_command_precious_reglist,-(a7)
		movem.l	(a3),search_command_reglist
		jsr	(a4)
		movem.l	(a7)+,search_command_precious_reglist
		bra	search_command_in_pathlist_continue

search_command_found:
		movem.l	(a7)+,search_command_reglist
		exg	a0,a1
		move.l	d0,-(a7)
		bsr	strcpy
		move.l	(a7)+,d0
		exg	a0,a1
		bra	search_command_return_0

search_command_in_pathlist_next:
		bsr	strfor1
		exg	a0,a1
search_command_in_pathlist_continue:
		exg	a0,a1
		dbra	d1,search_command_in_pathlist_loop
search_command_not_found:
		moveq	#-1,d0
search_command_return:
		movem.l	(a7)+,search_command_reglist
search_command_return_0:
		movea.l	(a7)+,a0
		unlk	a6
		rts
*****************************************************************
* expand_a_word - 1�̒P����R�}���h�u���A�t�@�C�����W�J���� 1�̒P��𓾂�
*
* CALL
*      A0     �\�[�X�P��i������ MAXWORDLEN �ȓ��ł��邱�Ɓj
*      A1     �W�J�P��̈�
*      D1.L   �W�J�P��̈�̑傫���i�Ō�� NUL �̕��͊܂܂Ȃ��j
*
* RETURN
*      D0.L    0 : �����D�t�@�C�����W�J�͖�������
*              1 : �����D�t�@�C������ 1�ȏ�W�J���ꂽ
*             -1 : �P�ꐔ�� 2��ȏ�ɂȂ���
*             -2 : �P��̒��������߂���
*             -4 : ���̂��܂��܂ȃG���[�i���b�Z�[�W���\�������j
*             -5 : �t�@�C�����W�J�ȑO�ɒP�ꂪ�����Ȃ���
*
*      CCR    TST.L D0
*****************************************************************
.xdef expand_a_word

expand_a_word:
		movem.l	d1-d3/a0-a2,-(a7)
		movea.l	a1,a2			*  A2 : destination
		move.l	d1,d3
	*
	*  �R�}���h�u��
	*
	*  source -> tmp1
	*
		lea	tmpword01(a5),a1
		moveq	#1,d0
		move.w	#MAXWORDLEN+1,d1
		bsr	subst_command
		bmi	expand_a_word_fail
		beq	expand_a_word_miss

		lea	tmpword01(a5),a0	*  �����܂ł̌��ʂ� tmp1 �ɂ���
		tst.b	flag_noglob(a5)		*  noglob �� set �����
		bne	expand_a_word_stop	*  ����Ȃ�΁A����ł����܂�
	*
	*  {} ��W�J����
	*
	*  tmp1 -> tmp2
	*
		lea	tmpword02(a5),a1
		move.w	#MAXWORDLEN+1,d1
		bsr	unpack_word
		bmi	expand_a_word_fail
		beq	expand_a_word_miss

		lea	tmpword02(a5),a0	*  �����܂ł̌��ʂ� tmp2 �ɂ���
		tst.b	not_execute(a5)		*  ���Ƃ̓W�J�͎��s���̏󋵎����
		bne	expand_a_word_stop	*  ���邩��A-n �ł͂����܂łƂ���
	*
	*  ~ ��W�J����
	*
	*  tmp2 -> tmp1
	*
		lea	tmpword01(a5),a1
		move.w	#MAXWORDLEN+1,d1
		moveq	#1,d2
		bsr	expand_tilde
		bmi	expand_a_word_fail

		lea	tmpword01(a5),a0	*  �����܂ł̌��ʂ� tmp1 �ɂ���
		bsr	check_wildcard		*  �P�ꂪ * ? [ ���܂��
		beq	expand_a_word_stop	*  ���Ȃ��Ȃ�΂����܂�
	*
	*  * ? [] ��W�J����
	*
	*  tmp1 -> tmp2
	*
		lea	tmpword02(a5),a1
		moveq	#1,d0
		move.w	#MAXPATH+1,d1
		bsr	glob
		bmi	expand_a_word_fail
		beq	expand_a_word_nomatch

		lea	tmpword02(a5),a0
		moveq	#1,d0
		bra	expand_a_word_store

		*  nomatch �͖������āA�W�J���Ȃ��P���Ԃ�
expand_a_word_stop:
		bsr	strip_quotes
		moveq	#0,d1
expand_a_word_store:
		bsr	strlen
		cmp.l	d3,d0
		bhi	expand_a_word_too_long

		movea.l	a0,a1
		movea.l	a2,a0
		bsr	strcpy
		move.l	d1,d0
expand_a_word_return:
		movem.l	(a7)+,d1-d3/a0-a2
		tst.l	d0
		rts


expand_a_word_nomatch:
		bsr	test_nonomatch
		beq	expand_a_word_nomatch_error	*  unset nonomatch

		btst	#0,d0
		bne	expand_a_word_stop		*  set nonomatch
		*  set nonomatch=drop
expand_a_word_miss:
		moveq	#-5,d0
		bra	expand_a_word_return

expand_a_word_nomatch_error:
		bsr	strip_quotes
		bsr	pre_perror
		bsr	no_match
		moveq	#-4,d0
		bra	expand_a_word_return

expand_a_word_fail:
		cmp.l	#-3,d0
		bne	expand_a_word_return
expand_a_word_too_long:
		moveq	#-2,d0
		bra	expand_a_word_return
*****************************************************************
*								*
*	reset input/output redirection file			*
*								*
*****************************************************************
.xdef close_tmpfd

reset_delete_io:
		tst.b	pipe1_delete(a5)
		beq	reset_io_del_1

		move.b	#2,pipe1_delete(a5)
reset_io_del_1:
		tst.b	pipe2_delete(a5)
		beq	reset_io

		move.b	#2,pipe2_delete(a5)
reset_io:
		movem.l	d0-d1/a0,-(a7)

		moveq	#0,d0
		lea	save_stdin(a5),a0
		bsr	unredirect

		moveq	#1,d0
		lea	save_stdout(a5),a0
		bsr	unredirect

		moveq	#2,d0
		lea	save_stderr(a5),a0
		bsr	unredirect
*
		lea	undup_input(a5),a0
		bsr	fclosexp
*
		lea	undup_output(a5),a0
		bsr	fclosexp
*
		cmp.b	#2,pipe1_delete(a5)
		bne	reset_io_5

		lea	pipe1_name(a5),a0
		bsr	remove
		clr.b	pipe1_delete(a5)
reset_io_5:
		cmp.b	#2,pipe2_delete(a5)
		bne	reset_io_6

		lea	pipe2_name(a5),a0
		bsr	remove
		clr.b	pipe2_delete(a5)
reset_io_6:
		lea	argument_pathname,a0
		tst.b	(a0)
		beq	reset_io_done

		bsr	remove
		clr.b	(a0)
reset_io_done:
		movem.l	(a7)+,d0-d1/a0
close_tmpfd:
		move.l	d0,-(a7)
		move.l	tmpfd(a5),d0
		cmp.l	#4,d0
		ble	close_tmpfd_return

		bsr	fclose
close_tmpfd_return:
		move.l	#-1,tmpfd(a5)
		move.l	(a7)+,d0
		rts
*****************************************************************
disable_break:
		move.l	d0,-(a7)
		move.w	#-1,-(a7)		*  -1:�擾
		DOS	_BREAKCK
		move.w	d0,saved_breakflag(a5)
		move.w	#2,(a7)			*   2:�֎~
		bra	dos_breakck
*****************************************************************
resume_breakflag:
		move.l	d0,-(a7)
		move.w	saved_breakflag(a5),-(a7)
dos_breakck:
		DOS	_BREAKCK
		addq.l	#2,a7
		move.l	(a7)+,d0
		rts
*****************************************************************
*****************************************************************
*****************************************************************
.data

.xdef statement_table
.xdef builtin_table

.xdef str_nul
.xdef str_newline
.xdef str_space
.xdef paren_pair
.xdef dos_allfile
.xdef default_wordchars
.xdef word_close_brace
.xdef word_upper_home
.xdef word_upper_shlvl
.xdef word_upper_term
.xdef word_upper_user
.xdef word_if
.xdef word_switch
.xdef word_alias
.xdef word_argv
.xdef word_cdpath
.xdef word_history
.xdef word_home
.xdef word_function
.xdef word_sub
.xdef word_path
.xdef word_prompt
.xdef word_prompt2
.xdef word_shell
.xdef word_shlvl
.xdef word_status
.xdef word_temp
.xdef word_term
.xdef word_unalias
.xdef word_user
.xdef msg_ambiguous
.xdef msg_too_long_pathname
.xdef msg_unmatched
.xdef msg_badly_placed_paren

fish_copyright:	dc.b	'Copyright(C)1991-92 by Itagaki Fumihiko',0
fish_author:	dc.b	'�_ �j�F ( Itagaki Fumihiko )',0

fish_version:	dc.b	'0',0		*  major version
		dc.b	'7',0		*  minor version
		dc.b	'4',0		*  patch level

.even
statement_table:
		dc.l	word_case
		dc.l	state_case
		dc.b	4,0

		dc.l	word_default
		dc.l	state_default
		dc.b	4,0

		dc.l	word_default_colon
		dc.l	state_default
		dc.b	4,0

		dc.l	word_defun
		dc.l	state_function
		dc.b	0,0

		dc.l	word_else
		dc.l	state_else
		dc.b	2,0

		dc.l	word_end
		dc.l	state_end
		dc.b	1,0

		dc.l	word_endif
		dc.l	state_endif
		dc.b	2,0

		dc.l	word_endsw
		dc.l	state_endsw
		dc.b	4,0

		dc.l	word_foreach
		dc.l	state_foreach
		dc.b	1,0

		dc.l	word_function
		dc.l	state_function
		dc.b	0,0

		dc.l	word_if
		dc.l	state_if
		dc.b	2,0

		dc.l	word_sub
		dc.l	state_sub_function
		dc.b	0,0

		dc.l	word_switch
		dc.l	state_switch
		dc.b	4,0

		dc.l	word_while
		dc.l	state_while
		dc.b	1,0

		dc.l	word_close_brace
		dc.l	state_endfunc
		dc.b	0,0

		dc.l	0

builtin_table:
		*  1 : �R�}���h�u���E�t�@�C�����W�J�͓Ǝ��ɍs��
		*  2 : () ���`�F�b�N���Ȃ�
		*  4 : �o�͂��؂�ւ����Ă���Ȃ�΃T�u�V�F���Ŏ��s���C
		*      �����Ȃ��΃p�C�v�̃t���b�v�E�t���b�v�𔽓]����
		*  8 : �p�C�v�̍\���v�f�i�Ō�������j�Ȃ�΃T�u�V�F���Ŏ��s����
		*
		dc.l	word_exprmark
		dc.l	cmd_set_expression
		dc.b	1+2,0

		dc.l	word_alias
		dc.l	cmd_alias
		dc.b	1,0

		dc.l	word_alloc
		dc.l	cmd_alloc
		dc.b	0,0
.if 0
		dc.l	word_apply
		dc.l	cmd_apply
		dc.b	4,0
.endif
		dc.l	word_bind
		dc.l	cmd_bind
		dc.b	1,0

		dc.l	word_break
		dc.l	cmd_break
		dc.b	0,0

		dc.l	word_breaksw
		dc.l	cmd_breaksw
		dc.b	0,0

		dc.l	word_cd
		dc.l	cmd_cd
		dc.b	0,0

		dc.l	word_cdd
		dc.l	cmd_cdd
		dc.b	0,0

		dc.l	word_chdir
		dc.l	cmd_cd
		dc.b	0,0

		dc.l	word_continue
		dc.l	cmd_continue
		dc.b	0,0

		dc.l	word_dirs
		dc.l	cmd_dirs
		dc.b	0,0

		dc.l	word_echo
		dc.l	cmd_echo
		dc.b	0,0

		dc.l	word_eval
		dc.l	cmd_eval
		dc.b	4,0

		dc.l	word_exec
		dc.l	cmd_exec
		dc.b	8,0

		dc.l	word_exit
		dc.l	cmd_exit
		dc.b	1+2,0

		dc.l	word_functions
		dc.l	cmd_functions
		dc.b	0,0

		dc.l	word_glob
		dc.l	cmd_glob
		dc.b	0,0

		dc.l	word_goto
		dc.l	cmd_goto
		dc.b	0,0

		dc.l	word_hashstat
		dc.l	cmd_hashstat
		dc.b	0,0

		dc.l	word_history
		dc.l	cmd_history
		dc.b	0,0

		dc.l	word_logout
		dc.l	cmd_logout
		dc.b	0,0

		dc.l	word_nop
		dc.l	cmd_nop
		dc.b	1+2,0

		dc.l	word_onintr
		dc.l	cmd_onintr
		dc.b	0,0

		dc.l	word_popd
		dc.l	cmd_popd
		dc.b	0,0

		dc.l	word_printf
		dc.l	cmd_printf
		dc.b	1+2,0

		dc.l	word_pushd
		dc.l	cmd_pushd
		dc.b	0,0

		dc.l	word_pwd
		dc.l	cmd_pwd
		dc.b	0,0

		dc.l	word_rehash
		dc.l	cmd_rehash
		dc.b	0,0

		dc.l	word_repeat
		dc.l	cmd_repeat
		dc.b	1+2,0

		dc.l	word_return
		dc.l	cmd_return
		dc.b	1+2,0

		dc.l	word_set
		dc.l	cmd_set
		dc.b	1+2,0

		dc.l	word_setenv
		dc.l	cmd_setenv
		dc.b	1,0

		dc.l	word_shift
		dc.l	cmd_shift
		dc.b	0,0

		dc.l	word_source
		dc.l	cmd_source
		dc.b	4,0

		dc.l	word_srand
		dc.l	cmd_srand
		dc.b	0,0

		dc.l	word_time
		dc.l	cmd_time
		dc.b	1,0

		dc.l	word_unalias
		dc.l	cmd_unalias
		dc.b	1,0

		dc.l	word_undefun
		dc.l	cmd_undefun
		dc.b	1,0

		dc.l	word_unhash
		dc.l	cmd_unhash
		dc.b	0,0

		dc.l	word_unset
		dc.l	cmd_unset
		dc.b	1,0

		dc.l	word_unsetenv
		dc.l	cmd_unsetenv
		dc.b	1,0

		dc.l	word_which
		dc.l	cmd_which
		dc.b	0,0
.if 0
		dc.l	word_xargs
		dc.l	cmd_xargs
		dc.b	1,0
.endif
		dc.l	0

word_case:		dc.b	'case',0
word_default:		dc.b	'default',0
word_default_colon:	dc.b	'default:',0
word_defun:		dc.b	'defun',0
word_else:		dc.b	'else',0
word_end:		dc.b	'end',0
word_endif:		dc.b	'end'
word_if:		dc.b	'if',0
word_endsw:		dc.b	'endsw',0
word_foreach:		dc.b	'foreach',0
word_function:		dc.b	'function',0
word_sub:		dc.b	'sub',0
word_switch:		dc.b	'switch',0
word_while:		dc.b	'while',0
word_close_brace:	dc.b	'}',0

word_exprmark:		dc.b	'@',0
word_unalias:		dc.b	'un'
word_alias:		dc.b	'alias',0
word_alloc:		dc.b	'alloc',0
.if 0
word_apply:		dc.b	'apply',0
.endif
word_bind:		dc.b	'bind',0
word_breaksw:		dc.b	'breaksw',0
word_break:		dc.b	'break',0
word_builtin_cd:	dc.b	'~~/'
word_cd:		dc.b	'cd',0
word_cdd:		dc.b	'cdd',0
word_chdir:		dc.b	'chdir',0
word_continue:		dc.b	'continue',0
word_builtin_dirs:	dc.b	'~~/'
word_dirs:		dc.b	'dirs',0
word_eval:		dc.b	'eval',0
word_exec:		dc.b	'exec',0
word_exit:		dc.b	'exit',0
word_functions:		dc.b	'functions',0
word_goto:		dc.b	'goto',0
word_hashstat:		dc.b	'hashstat',0
word_nop:		dc.b	'nop',0
word_onintr:		dc.b	'onintr',0
word_popd:		dc.b	'popd',0
word_printf:		dc.b	'printf',0
word_builtin_pushd:	dc.b	'~~/'
word_pushd:		dc.b	'pushd',0
word_pwd:		dc.b	'pwd',0
word_rehash:		dc.b	'rehash',0
word_repeat:		dc.b	'repeat',0
word_return:		dc.b	'return',0
word_unset:		dc.b	'un'
word_set:		dc.b	'set',0
word_unsetenv:		dc.b	'un'
word_setenv:		dc.b	'setenv',0
word_shift:		dc.b	'shift',0
word_source:		dc.b	'source',0
word_srand:		dc.b	'srand',0
word_time:		dc.b	'time',0
word_undefun:		dc.b	'undefun',0
word_unhash:		dc.b	'unhash',0
word_which:		dc.b	'which',0
.if 0
word_xargs:		dc.b	'xargs',0
.endif

init_batshell:		dc.b	'/bin/COMMAND.X',0
init_shell:		dc.b	'/bin/fish.x',0
init_shell_init_arg:	dc.b	'-f',0
etc_fishrc:		dc.b	'/etc/fishrc',0
percent_fishrc:		dc.b	'%fishrc',0
dot_fishrc:		dc.b	'.fishrc',0
percent_login:		dc.b	'%login',0
dot_login:		dc.b	'.login',0
percent_logout:		dc.b	'%logout',0
dot_logout:		dc.b	'.'
word_logout:		dc.b	'logout',0
percent_fishdirs:	dc.b	'%fishdirs',0
dot_fishdirs:		dc.b	'.fishdirs',0
word_upper_gid:		dc.b	'GID',0
word_upper_home:	dc.b	'HOME',0
word_upper_logname:	dc.b	'LOGNAME',0
word_upper_shlvl:	dc.b	'SHLVL',0
word_upper_term:	dc.b	'TERM',0
word_upper_uid:		dc.b	'UID',0
word_upper_user:	dc.b	'USER',0
word_upper_fishconfig:	dc.b	'FISHCONFIG',0
word_argv:		dc.b	'argv',0
word_batshell:		dc.b	'batshell',0
word_cdpath:		dc.b	'cd'	* "cdpath"
word_path:		dc.b	'path',0
word_cdcmds:		dc.b	'cdcmds',0
word_cwdcmd:		dc.b	'cwdcmd',0
word_envmargin:		dc.b	'envmargin',0
word_force:		dc.b	'force',0
word_gid:		dc.b	'gid',0
percent_history:	dc.b	'%history',0
dot_history:		dc.b	'.'	* ".history"
word_history:		dc.b	'history',0
word_home:		dc.b	'home',0
word_hugearg:		dc.b	'hugearg',0
word_indirect:		dc.b	'indirect',0
word_prompt:		dc.b	'prompt',0
word_prompt2:		dc.b	'prompt2',0
word_savehist:		dc.b	'savehist',0
word_shell:		dc.b	'shell',0
word_shlvl:		dc.b	'shlvl',0
word_status:		dc.b	'status',0
word_temp:		dc.b	'temp',0
word_term:		dc.b	'term',0
word_uid:		dc.b	'uid',0
word_user:		dc.b	'user',0
word_fish_author:	dc.b	'FISH_AUTHOR',0
word_fish_copyright:	dc.b	'FISH_COPYRIGHT',0
word_fish_version:	dc.b	'FISH_VERSION',0
dos_allfile:		dc.b	'*'	* "*.*"
ext_asta:		dc.b	'.*',0
str_dot:		dc.b	'.',0
str_builtin_dir:	dc.b	'~~',0
init_prompt:		dc.b	'%%'	* "% "
str_space:		dc.b	' '
str_nul:		dc.b	0
default_wordchars:	dc.b	'*?_-.[]~=',0
str_option_s:		dc.b	' -s ',0
init_prompt2:		dc.b	'? '
init_env:		dc.b	0
str_colon:		dc.b	':',0
str_indirect_flag:	dc.b	'-+-+-',0
str_option_l:		dc.b	'-l',0
str_stdin:		dc.b	'(�W������)',0
str_newline:		dc.b	CR,LF,0
paren_pair:		dc.b	'(',0,')',0

ext_table:
		dc.b	'.R',0
		dc.b	'.X',0
		dc.b	'.BAT',0
		dc.b	0

.even
initial_vars_stdin_mode:
			dc.l	word_prompt
			dc.l	init_prompt
			dc.w	1

			dc.l	word_prompt2
			dc.l	init_prompt2
			dc.w	1
initial_vars_script_mode:
			dc.l	word_fish_author
			dc.l	fish_author
			dc.w	1

			dc.l	word_fish_copyright
			dc.l	fish_copyright
			dc.w	1

			dc.l	word_fish_version
			dc.l	fish_version
			dc.w	3

			dc.l	0

msg_no_home:			dc.b	'���ϐ� HOME ����`����Ă��܂���',0
msg_dirnofile:			dc.b	' '
msg_nofile:			dc.b	'�t�@�C��������܂���',0
msg_nodir:			dc.b	'�f�B���N�g����������܂���',0
msg_use_exit_to_leave_fish:	dc.b	CR,LF,'fish ���甲����ɂ� "~~/exit" ��p���ĉ�����',0
msg_use_logout_to_logout:	dc.b	CR,LF,'���O�A�E�g����ɂ� "~~/logout" ��p���ĉ�����',0
msg_cannot_source_func:		dc.b	'�֐������s�ł��܂���',0
msg_cannot_load_script:		dc.b	'�X�N���v�g�����[�h�ł��܂���',0
msg_read_fail:			dc.b	'�ǂݍ��݂Ɏ��s���܂���',0
msg_unmatched_parens:		dc.b	'()'
msg_unmatched:			dc.b	'���肠���Ă��܂���',0
msg_bad_labeldef:		dc.b	'���x����`��',0
msg_alias_loop:			dc.b	'�ʖ��u�����[�߂��܂�',0
msg_import_too_long:		dc.b	'���ϐ��̒l�����߂��܂�',0
msg_badly_placed_paren:		dc.b	'��������()������܂�',0
msg_missing_heredoc_word:	dc.b	'<< �̈�̒P�ꂪ����܂���',0
msg_missing_input:		dc.b	'���̓t�@�C����������܂���',0
msg_missing_output:		dc.b	'�o�̓t�@�C����������܂���',0
msg_input_ambiguous:		dc.b	'���͂̐؂芷�����B���ł�',0
msg_output_ambiguous:		dc.b	'�o�͂̐؂芷�����B���ł�',0
msg_not_inputable_device:	dc.b	'���͕s�ł�',0
msg_not_outputable_device:	dc.b	'�o�͕s�ł�',0
msg_invalid_null_command:	dc.b	'�����ȋ�R�}���h�ł�',0
msg_no_command:			dc.b	'�R�}���h����������܂���',0
msg_command_ambiguous:		dc.b	'�R�}���h����'
msg_ambiguous:			dc.b	'�B���ł�',0
msg_too_long_pathname:		dc.b	'�p�X�������߂��܂�',0
msg_no_heredoc_terminator:	dc.b	'<< �̏I���̈󂪌�����܂���ł���',0
msg_file_exists:		dc.b	'�t�@�C�������łɑ��݂��Ă��܂�',0
msg_bad_status:			dc.b	'�V�F���ϐ� status ���s���ł�',0
msg_cannot_exec:		dc.b	'���s�ł��܂���',0
msg_fork_failure:		dc.b	'�T�u�V�F���𐶐��ł��܂���',0
msg_exec_failure:		dc.b	'�N���ł��܂���ł���',0
msg_too_long_command_name:	dc.b	'�R�}���h�������߂��܂�',0
msg_missing_command_name:	dc.b	'�R�}���h��������܂���',0
msg_shell_too_long:		dc.b	'�X�N���v�g���s�V�F���̃p�X�������߂��܂�',0
msg_too_long_arg_for_program:	dc.b	'HUPAIR�񏀋��R�}���h�ւ̃p�����[�^��255�o�C�g�𒴉߂��Ă��܂�',0
msg_too_long_indirect_flag:	dc.b	'�Ԑڈ��������߂��܂�',0
msg_funcdef_not_done:		dc.b	'�֐���`�̏I��� } ������܂���',0
msg_endif_not_found:		dc.b	'endif ������܂���',0
msg_endsw_not_found:		dc.b	'endsw ������܂���',0
msg_end_not_found:		dc.b	'end ������܂���',0
msg_cannot_load_unseekable:	dc.b	'�V�[�N�ł��Ȃ��f�o�C�X����̓��[�h�ł��܂���',0
msg_cwd_failure:		dc.b	'��ƃf�B���N�g�����������܂����B',0
msg_change_cwd:			dc.b	' ����ƃf�B���N�g���Ƃ��܂��B',0
msg_eof_exit:			dc.b	'[EOF] '
msg_exit:			dc.b	'Exit ',0
*****************************************************************
*****************************************************************
*****************************************************************
.bss

**  �e�V�F�����ʂ̃f�[�^
**  ���[�g�E�V�F���������ݒ肷��

.xdef dummy

.even
pid_count:		ds.l	1
user_command_signal:	ds.l	1
in_fish:		ds.b	1
doing_logout:		ds.b	1
dummy:			ds.b	1

**  �e�V�F�����ʂ̈ꎞ�o�b�t�@
**  �i�����̃V�F���������ɂ͓����Ȃ��̂ŋ��p���č\��Ȃ��j

.xdef save_sourceptr
.xdef congetbuf
.xdef tmpargs
.xdef tmpword1
.xdef tmpword2
.xdef pathname_buf
.xdef tmpstatbuf
.xdef tmppwline

.even
save_sourceptr:			ds.l	1
congetbuf:			ds.b	2+256
argument_pathname:		ds.b	MAXPATH+1	* ���[�U�E�R�}���h�ւ̈������������t�@�C����
tmpword1:			ds.b	MAXWORDLEN*2+1	* x_complete, glob, cmd_undefun, state_case, cmd_unalias, state_function
tmpword2:			ds.b	MAXWORDLEN*2+1	* x_complete, globsub
tmpargs:			ds.b	MAXWORDLISTSIZE
pathname_buf:			ds.b	MAXPATH+1
.even
tmpstatbuf:			ds.b	STATBUFSIZE
tmppwline:			ds.b	PW_LINESIZE
*****************************************************************
.even
bsstop:

.offset 0

**  �V�F������уT�u�V�F�����̃f�[�^

.xdef fork_stackp
.xdef dirstack
.xdef lake_top
.xdef tmplake_top
.xdef shellvar_top
.xdef alias_top
.xdef command_name
.xdef hash_flag
.xdef hash_table
.xdef hash_hits
.xdef hash_misses
.xdef shell_timer_high
.xdef shell_timer_low
.xdef tmpfd
.xdef prev_search
.xdef prev_lhs
.xdef prev_rhs
.xdef current_source
.xdef current_argbuf
.xdef in_history_ptr
.xdef loop_top_eventno
.xdef funcdef_topptr
.xdef funcdef_size
.xdef env_top
.xdef line
.xdef tmpline
.xdef current_eventno
.xdef function_root
.xdef function_bot
.xdef history_top
.xdef history_bot
.xdef argc
.xdef simple_args
.xdef exitflag
.xdef histchar1
.xdef histchar2
.xdef wordchars
.xdef flag_autolist
.xdef flag_cifilec
.xdef flag_ciglob
.xdef flag_echo
.xdef flag_execbit
.xdef flag_forceio
.xdef flag_ignoreeof
.xdef flag_listexec
.xdef flag_listlinks
.xdef flag_noalias
.xdef flag_nobeep
.xdef flag_noclobber
.xdef flag_noglob
.xdef flag_nonullcommandc
.xdef flag_printexitvalue
.xdef flag_pushdsilent
.xdef flag_recexact
.xdef flag_reconlyexec
.xdef flag_savedirs
.xdef flag_symlinks
.xdef flag_usegets
.xdef flag_verbose
.xdef functype
.xdef funcname
.xdef funcdef_status
.xdef if_status
.xdef if_level
.xdef loop_stack
.xdef loop_status
.xdef loop_level
.xdef forward_loop_level
.xdef switch_level
.xdef switch_status
.xdef switch_string
.xdef keep_loop
.xdef loop_fail
.xdef not_execute
.xdef in_prompt
.xdef keymap
.xdef keymacromap
.xdef irandom_struct
.xdef tmpgetlinebufp
.xdef var_line_eof
.xdef cwd_changed

current_eventno:	ds.l	1			*  ���݂̗����C�x���g�ԍ�
hash_hits:		ds.l	1
hash_misses:		ds.l	1
wordchars:		ds.l	1
histchar1:		ds.w	1
histchar2:		ds.w	1
hash_flag:		ds.b	1
hash_table:		ds.b	1024
flag_autolist:		ds.b	1
flag_cifilec:		ds.b	1
flag_ciglob:		ds.b	1
flag_echo:		ds.b	1
flag_execbit:		ds.b	1
flag_forceio:		ds.b	1
flag_ignoreeof:		ds.b	1
flag_listexec:		ds.b	1
flag_listlinks:		ds.b	1
flag_noalias:		ds.b	1
flag_nobeep:		ds.b	1
flag_noclobber:		ds.b	1
flag_noglob:		ds.b	1
flag_nonullcommandc:	ds.b	1
flag_printexitvalue:	ds.b	1
flag_pushdsilent:	ds.b	1
flag_recexact:		ds.b	1
flag_reconlyexec:	ds.b	1
flag_savedirs:		ds.b	1
flag_symlinks:		ds.b	1
flag_usegets:		ds.b	1
flag_verbose:		ds.b	1
exitflag:		ds.b	1
in_function:		ds.b	1
keymap:			ds.b	128*3
.even
keymacromap:		ds.l	128*3

.xdef pid
.xdef i_am_login_shell
.xdef last_congetbuf
.xdef linecutbuf

.even
pid:			ds.l	1
arg_script:		ds.l	1
arg_command:		ds.l	1
i_am_login_shell:	ds.b	1
input_is_tty:		ds.b	1
interactive_mode:	ds.b	1
exit_on_error:		ds.b	1
flag_t:			ds.b	1
flags:			ds.b	1
interrupted:		ds.b	1
last_congetbuf:		ds.b	1+256
first_cwd:		ds.b	MAXPATH+1

xbsssize:

.xdef mainjmp
.xdef stackp
.xdef undup_input
.xdef undup_output
.xdef save_stdin
.xdef save_stdout
.xdef save_stderr
.xdef push_stdin
.xdef push_stdout
.xdef push_stderr

.even
mainjmp:		ds.l	1
stackp:			ds.l	1
fork_stackp:		ds.l	1			*  �v���O�����E�X�^�b�N�E�|�C���^
lake_top:		ds.l	1			*  Extmalloc�̌Ό�
tmplake_top:		ds.l	1			*  Extmalloc�̌Ό�
env_top:		ds.l	1
shellvar_top:		ds.l	1
alias_top:		ds.l	1
function_root:		ds.l	1			*  �֐��`�F�C���̐擪�m�[�h
function_bot:		ds.l	1			*  �֐��`�F�C���̌���m�[�h�i�������ȁI�j
history_top:		ds.l	1			*  �����`�F�C���̐擪�m�[�h
history_bot:		ds.l	1			*  �����`�F�C���̌���m�[�h
dirstack:		ds.l	1			*  �f�B���N�g���E�X�^�b�N
tmpgetlinebufp:		ds.l	1
user_command_env:	ds.l	1
current_source:		ds.l	1			*  source ���[�N�E�o�b�t�@�̃`�F�C��
current_argbuf:		ds.l	1			*  eval, repeat �̈����̃`�F�C��
command_name:		ds.l	1
undup_input:		ds.l	1
undup_output:		ds.l	1
save_stdin:		ds.l	1
save_stdout:		ds.l	1
save_stderr:		ds.l	1
push_stdin:		ds.l	1
push_stdout:		ds.l	1
push_stderr:		ds.l	1
tmpfd:			ds.l	1
shell_timer_high:	ds.l	1
shell_timer_low:	ds.l	1
saved_breakflag:	ds.w	1
argc:			ds.w	1
irandom_struct:		ds.b	IRANDOM_STRUCT_HEADER_SIZE+(2*RND_POOLSIZE)
pipe1_delete:		ds.b	1
pipe2_delete:		ds.b	1
pipe_flip_flop:		ds.b	1
prev_search:		ds.b	MAXSEARCHLEN+1
prev_lhs:		ds.b	MAXSEARCHLEN+1
prev_rhs:		ds.b	MAXSUBSTLEN+1
pipe1_name:		ds.b	MAXPATH+1
pipe2_name:		ds.b	MAXPATH+1
save_cwd:		ds.b	MAXPATH+1
line:			ds.b	MAXLINELEN+1		*  here document ���� subst_command_2 ���ĂԂƂ��Ɏg���Ă���
tmpline:		ds.b	MAXLINELEN+1		*  subst_command_wordlist �Ŏg���Ă���
do_line_args:		ds.b	MAXWORDLISTSIZE		*  do_line �̓���
simple_args:		ds.b	MAXWORDLISTSIZE		*  DoSimpleCommand �̓���
tmpword01:		ds.b	MAXWORDLEN+1		*  expand_a_word
tmpword02:		ds.b	MAXWORDLEN+1		*  expand_a_word
program_name:		ds.b	MAXPATH+1
program_pathname:	ds.b	MAXPATH+1
not_execute:		ds.b	1
in_prompt:		ds.b	1
var_line_eof:		ds.b	1
cwd_changed:		ds.b	1

.even
each_source_bss_top:
in_history_ptr:		ds.l	1
loop_top_eventno:	ds.l	1
funcdef_topptr:		ds.l	1
funcdef_size:		ds.l	1
if_level:		ds.w	1
switch_level:		ds.w	1
loop_level:		ds.w	1
forward_loop_level:	ds.w	1
loop_stack:		ds.b	(LOOPINFOSIZE)*(MAXLOOPLEVEL+1)
loop_status:		ds.b	1
funcdef_status:		ds.b	1
if_status:		ds.b	1
switch_status:		ds.b	1
keep_loop:		ds.b	1
loop_fail:		ds.b	1
functype:		ds.b	1
funcname:		ds.b	MAXFUNCNAMELEN+1
switch_string:		ds.b	MAXWORDLEN+1
each_source_bss_bottom:
EACH_SOURCE_BSS_SIZE	equ	each_source_bss_bottom-each_source_bss_top

.even
			ds.b	8
user_command_parameter:	ds.b	1+MAXLINELEN+1		*  ���[�U�E�R�}���h�ւ̈���
linecutbuf:		ds.b	MAXLINELEN+1		*  �s�J�b�g�E�o�b�t�@

.even
.xdef bsssize		*  $7fff �𒴂��Ă��Ȃ����ǂ����m�F����K�v������I�I
bsssize:

.text

.end start

* b_set.s
* This contains built-in command 'set'.
*
* Itagaki Fumihiko 15-Jul-90  Create.

.xref strfor1
.xref strforn
.xref divsl
.xref mulsl
.xref atou
.xref find_close_paren
.xref expand_wordlist
.xref expression
.xref expr_atoi
.xref expr_itoa
.xref find_shellvar
.xref set_svar
.xref print_var
.xref skip_varname
.xref undefined
.xref ambiguous
.xref syntax_error
.xref bad_subscript
.xref subscript_out_of_range
.xref divide_by_0
.xref mod_by_0
.xref strmove
.xref str_nul

.xref tmpargs

.xref shellvar
.xref tmpline

OP_ASSIGN	equ	1
OP_MULASSIGN	equ	2
OP_DIVASSIGN	equ	3
OP_MODASSIGN	equ	4
OP_ADDASSIGN	equ	5
OP_SUBASSIGN	equ	6
OP_SHLASSIGN	equ	7
OP_SHRASSIGN	equ	8
OP_BITANDASSIGN	equ	9
OP_BITXORASSIGN	equ	10
OP_BITORASSIGN	equ	11
OP_INCREMENT	equ	12
OP_DECREMENT	equ	13

.text

****************************************************************
*  Name
*       set - �V�F���ϐ��̕\���Ɛݒ�
*
*  Synopsis
*       set
*            ��`����Ă��邷�ׂẴV�F���ϐ��Ƃ����̒l��\������
*
*       set name
*
*       set name=word
*       set name= word
*       set name = word
*
*       set name[index]=word
*       set name[index]= word
*       set name[index] = word
*
*       set name= (wordlist)
*       set name = (wordlist)
****************************************************************
.xdef cmd_set

cmd_set:
		move.w	d0,d7			* �����������Ȃ�
		beq	set_disp		* �V�F���ϐ��̃��X�g��\��
set_loop:
		tst.w	d7
		beq	set_success_return

		bsr	scan_name_and_index
		bne	cmd_set_return

		cmpi.b	#'=',(a0)
		beq	cmd_set_op_found

		tst.b	(a0)+
		bne	syntax_error

		subq.w	#1,d7
		beq	set_nul_string

		cmpi.b	#'=',(a0)
		bne	set_nul_string
cmd_set_op_found:
		clr.b	(a0)+
		tst.b	(a0)
		bne	value_found

		subq.w	#1,d7
		beq	syntax_error

		addq.l	#1,a0
value_found:
		cmpi.b	#'(',(a0)
		bne	set_single_word

		tst.l	d2
		bpl	syntax_error

		bsr	strfor1
		subq.w	#1,d7
		movea.l	a0,a1
		move.w	d7,d0
		bsr	find_close_paren
		bmi	syntax_error

		sub.w	d0,d7
		bra	set_value

set_single_word:
		movea.l	a0,a1
		move.l	a1,d6				* D6.L : �W�J�O�̒l���w���|�C���^
		moveq	#1,d0
set_value:
		bsr	strfor1
		subq.w	#1,d7
		movea.l	a0,a4				* A4 : ���̈������w���|�C���^
		lea	tmpargs,a0
		bsr	expand_wordlist
		bmi	cmd_set_return

		movea.l	a0,a1				* A1 : value wordlist
		tst.l	d2				* [index]�`���łȂ����
		bmi	do_set_one			* name �� A1 ��ݒ肷��

		cmp.w	#1,d0				* [index]�`���Ȃ̂ɒP�ꐔ��
		bhi	set_ambiguous			* �P�𒴂���Ȃ�G���[
		beq	do_set_a_element		* �P�Ȃ�΂n�j

		clr.b	(a1)				* 0�Ȃ�� "\0" �Ƃ���
do_set_a_element:
		bsr	set_a_element
		bra	cmd_set_next

set_nul_string:
		tst.l	d2
		bpl	syntax_error

		movea.l	a0,a4
		lea	str_nul,a1
		moveq	#1,d0
do_set_one:
		bsr	do_set
cmd_set_next:
		bne	cmd_set_return

		movea.l	a4,a0
		bra	set_loop


set_ambiguous:
		movea.l	d6,a0
		bra	ambiguous
********************************
set_disp:
		movea.l	shellvar(a5),a0
		bsr	print_var
set_success_return:
		moveq	#0,d0
cmd_set_return:
		rts
****************************************************************
*  Name
*       @ - �V�F���ϐ��̕\���Ɛݒ�
*
*  Synopsis
*       @
*            ��`����Ă��邷�ׂẴV�F���ϐ��Ƃ����̒l��\������
*
*       @ lvalue op expression
*
*            lvalue:
*                 name
*                 name[index]
*
*            op:
*                 =
*                 +=
*                 -=
*                 *=
*                 /=
*                 %=
*                 <<=
*                 >>=
*                 &=
*                 ^=
*                 |=
*
*            op �̍��E�ɂ͋󔒂������Ă��Ȃ��Ă��ǂ�
****************************************************************
.xdef cmd_set_expression

cmd_set_expression:
		move.w	d0,d7			* �����������Ȃ�
		beq	set_disp		* �V�F���ϐ��̃��X�g��\��
set_expression_loop:
		tst.w	d7
		beq	cmd_set_expression_success_return

		bsr	scan_name_and_index
		bne	cmd_set_expression_return
		*
		*  A0   : �����|�C���^
		*  D7.W : �����J�E���^
		*  A2   : ���ӕϐ���
		*  D2.L : ���ӕϐ��̓Y���̒l�i[index]�`���Ŗ������-1�j
		*
		bsr	scan_assign_operator
		move.b	d0,d4
		bne	set_expression_op_ok

		tst.b	(a0)+
		bne	syntax_error

		subq.w	#1,d7
		beq	syntax_error

		bsr	scan_assign_operator
		move.b	d0,d4
		beq	syntax_error
set_expression_op_ok:
		clr.b	(a0)
		movea.l	a3,a0
		*
		*  A0   : �����|�C���^
		*  D7.W : �����J�E���^
		*  A2   : ���ӕϐ���
		*  D2.L : ���ӕϐ��̓Y���̒l�i[index]�`���Ŗ������-1�j
		*  D4.B : ���Z�q�R�[�h
		*
		cmp.b	#OP_INCREMENT,d4
		blo	set_expression_expression

		tst.b	(a0)+
		bne	syntax_error

		subq.w	#1,d7
		moveq	#1,d1
		cmp.b	#OP_DECREMENT,d4
		beq	set_expression_decrement
**  var ++
		moveq	#OP_ADDASSIGN,d4
		bra	set_expression_postcalc
**  var --
set_expression_decrement:
		moveq	#OP_SUBASSIGN,d4
		bra	set_expression_postcalc
**  var op= expr
set_expression_expression:
		tst.b	(a0)
		bne	set_expression_do_expression

		addq.l	#1,a0
		subq.w	#1,d7
set_expression_do_expression:
		bsr	expression
		bne	cmd_set_expression_return
********************************
set_expression_postcalc:
		movea.l	a0,a4				* A4 : ���̈���
		*
		*  A4   : �����|�C���^
		*  D7.W : �����J�E���^
		*  A2   : ���ӕϐ���
		*  D2.L : ���ӕϐ��̓Y���̒l�i[index]�`���Ŗ������-1�j
		*  D1.L : �E�Ӓl
		*  D4.B : ���Z�q�R�[�h
		*
		move.l	d1,-(a7)
		subq.b	#OP_ASSIGN,d4
		beq	set_expression_lvalue_ok

		moveq	#0,d1
		movea.l	a2,a0				*  A0 = A2 (name)
		bsr	find_shellvar			*  A0 = var ptr
		beq	set_expression_lvalue_ok

		addq.l	#4,a0
		bsr	strfor1
		move.l	d2,d0
		bmi	set_expression_get_lvalue	*  index�Ȃ�
		beq	set_expression_lvalue_ok

		moveq	#0,d3
		move.w	2(a0),d3			*  ���̕ϐ��̗v�f��
		cmp.l	d3,d2
		bgt	set_expression_lvalue_ok

		subq.l	#1,d0
		bsr	strforn
set_expression_get_lvalue:
		tst.b	(a0)
		beq	set_expression_lvalue_ok

		movea.l	a0,a1
		bsr	expr_atoi
		bne	cmd_set_expression_return
set_expression_lvalue_ok:
		move.l	(a7)+,d0
		*
		*  A4   : �����|�C���^
		*  D7.W : �����J�E���^
		*  A2   : ���ӕϐ���
		*  D2.L : ���ӕϐ��̓Y���̒l�i[index]�`���Ŗ������-1�j
		*  D0.L : �E�Ӓl
		*  D4.B : ���Z�q�R�[�h
		*  D1.L : ���Ӓl
		*
		lea	postcalc_jump_table,a0
		moveq	#0,d5
		move.b	d4,d5
		lsl.l	#2,d5
		move.l	(a0,d5.l),a0
		jmp	(a0)

postcalc_or:
		or.l	d0,d1
		bra	postcalc_itoa

postcalc_xor:
		eor.l	d0,d1
		bra	postcalc_itoa

postcalc_and:
		and.l	d0,d1
		bra	postcalc_itoa

postcalc_shr:
		asr.l	d0,d1
		bra	postcalc_itoa

postcalc_shl:
		asl.l	d0,d1
		bra	postcalc_itoa

postcalc_sub:
		sub.l	d0,d1
		bra	postcalc_itoa

postcalc_add:
		add.l	d0,d1
		bra	postcalc_itoa

postcalc_mod:
		exg	d0,d1
		tst.l	d1
		beq	mod_by_0

		bsr	divsl
		bra	postcalc_itoa

postcalc_div:
		exg	d0,d1
		tst.l	d1
		beq	divide_by_0

		bsr	divsl
		bra	postcalc_itoa_0

postcalc_mul:
		bsr	mulsl
postcalc_itoa_0:
		move.l	d0,d1
postcalc_itoa:
		link	a6,#-12
		lea	-12(a6),a1
		bsr	expr_itoa
		*
		*  A4   : �����|�C���^
		*  D7.W : �����J�E���^
		*  A2   : ���ӕϐ���
		*  D2.L : ���ӕϐ��̓Y���̒l�i[index]�`���Ŗ������-1�j
		*  A1   : �l��\�������񂪊i�[����Ă���o�b�t�@�̃A�h���X
		*
		tst.l	d2				*  [index]�`���łȂ����
		bmi	do_set_expression		*  name �� A1 ��ݒ肷��

		bsr	set_a_element
		bra	set_expression_next

do_set_expression:
		moveq	#1,d0
		bsr	do_set
set_expression_next:
		unlk	a6
		bne	cmd_set_expression_return

		movea.l	a4,a0
		bra	set_expression_loop

cmd_set_expression_success_return:
		moveq	#0,d0
cmd_set_expression_return:
		rts
****************************************************************
* CALL
*      A0     �P��
*
* RETURN
*      A0     �P��̑���
*      A2     ���O
*      D0.L   �G���[���������0
*      D1.L   �j��
*      D2.L   �Y���̒l�i[index]�`���Ŗ������-1�j
*      CCR    TST.L D0
****************************************************************
scan_name_and_index:
		movea.l	a0,a2			* A2 : name
		moveq	#-1,d2			* D2.L : index
		bsr	skip_varname
		cmpa.l	a2,a0
		beq	syntax_error

		cmpi.b	#'[',(a0)
		bne	name_and_index_are_ok

		clr.b	(a0)+
		bsr	atou
		bmi	bad_subscript

		cmpi.b	#']',(a0)+
		bne	bad_subscript

		move.l	d1,d2
		bmi	subscript_out_of_range
name_and_index_are_ok:
		moveq	#0,d0
		rts
****************************************************************
* CALL
*      A0     ������
*
* RETURN
*      D0.B   ���Z�q�R�[�h
*      A3     ���Z�q�̎����w��
****************************************************************
scan_assign_operator:
		tst.b	(a0)
		beq	no_operator

		lea	1(a0),a3
		moveq	#OP_ASSIGN,d0
		cmpi.b	#'=',(a0)
		beq	scan_assign_operator_return

		tst.b	1(a0)
		beq	no_operator

		cmpi.b	#'=',1(a0)
		bne	scan_assign_operator_2

		lea	2(a0),a3
		moveq	#OP_MULASSIGN,d0
		cmpi.b	#'*',(a0)
		beq	scan_assign_operator_return

		moveq	#OP_DIVASSIGN,d0
		cmpi.b	#'/',(a0)
		beq	scan_assign_operator_return

		moveq	#OP_MODASSIGN,d0
		cmpi.b	#'%',(a0)
		beq	scan_assign_operator_return

		moveq	#OP_ADDASSIGN,d0
		cmpi.b	#'+',(a0)
		beq	scan_assign_operator_return

		moveq	#OP_SUBASSIGN,d0
		cmpi.b	#'-',(a0)
		beq	scan_assign_operator_return

		moveq	#OP_BITANDASSIGN,d0
		cmpi.b	#'&',(a0)
		beq	scan_assign_operator_return

		moveq	#OP_BITXORASSIGN,d0
		cmpi.b	#'^',(a0)
		beq	scan_assign_operator_return

		moveq	#OP_BITORASSIGN,d0
		cmpi.b	#'|',(a0)
		beq	scan_assign_operator_return

		bra	no_operator

scan_assign_operator_2:
		cmpi.b	#'=',2(a0)
		bne	try_scan_incdec

		lea	3(a0),a3
		cmpi.b	#'<',(a0)
		bne	try_scan_shla

		cmpi.b	#'<',1(a0)
		bne	no_operator

		moveq	#OP_SHLASSIGN,d0
		bra	scan_assign_operator_return

try_scan_shla:
		cmpi.b	#'>',(a0)
		bne	try_scan_incdec

		cmpi.b	#'>',1(a0)
		bne	no_operator

		moveq	#OP_SHRASSIGN,d0
		bra	scan_assign_operator_return

try_scan_incdec:
		lea	2(a0),a3
		cmpi.b	#'+',(a0)
		bne	try_scan_dec

		cmpi.b	#'+',1(a0)
		bne	no_operator

		moveq	#OP_INCREMENT,d0
		rts

try_scan_dec:
		cmpi.b	#'-',(a0)
		bne	no_operator

		cmpi.b	#'-',1(a0)
		bne	no_operator

		moveq	#OP_DECREMENT,d0
		rts

no_operator:
		lea	(a0),a3
		moveq	#0,d0
scan_assign_operator_return:
		rts
****************************************************************
* CALL
*      A1     �Z�b�g����l�i������j
*      A2     ���O
*      D2.L   �Y���̒l�i�����j
*
* RETURN
*      D1-D3/A0-A1/A3     �j��
*      D0.L   �G���[���������0
*      CCR    TST.L D0
****************************************************************
set_a_element:
		movea.l	a2,a0				* A0 = A2 (name)
		bsr	find_shellvar			* A0 = var ptr
		exg	a0,a2				* A0 : name   A2 : var ptr
		beq	undefined

		tst.l	d2
		bmi	set_a_element_ok
		beq	subscript_out_of_range

		exg	a0,a2
		moveq	#0,d3
		move.w	2(a0),d3			* D3.L : ���̕ϐ��̗v�f��
		cmp.l	d3,d2
		bgt	subscript_out_of_range

		addq.l	#4,a0
		bsr	strfor1
set_a_element_ok:
		movea.l	a0,a3
		lea	tmpline(a5),a0
		moveq	#0,d1				* D1.W : �v�f�ԍ��J�E���^
		bra	set_a_element_dup_continue

set_a_element_dup_loop:
		cmp.w	d2,d1
		bne	set_a_element_dup_other

		bsr	strmove
		exg	a0,a3
		bsr	strfor1
		exg	a0,a3
		bra	set_a_element_dup_continue

set_a_element_dup_other:
		exg	a1,a3
		bsr	strmove
		exg	a1,a3
set_a_element_dup_continue:
		addq.w	#1,d1
		dbra	d3,set_a_element_dup_loop

		subq.w	#1,d1
		move.w	d1,d0
		lea	tmpline(a5),a1
****************************************************************
* CALL
*      A1     �Z�b�g����l�i�P����сj
*      A2     ���O
*      D0.L   �P�ꐔ
*
* RETURN
*      D1/A0     �j��
*      D0.L   0:����  1:���s
*      CCR    TST.L D0
****************************************************************
do_set:
		movea.l	a2,a0
		st	d1				*  export ����
		bra	set_svar
****************************************************************
.data

.even
postcalc_jump_table:
		dc.l	postcalc_itoa_0
		dc.l	postcalc_mul
		dc.l	postcalc_div
		dc.l	postcalc_mod
		dc.l	postcalc_add
		dc.l	postcalc_sub
		dc.l	postcalc_shl
		dc.l	postcalc_shr
		dc.l	postcalc_and
		dc.l	postcalc_xor
		dc.l	postcalc_or

.end

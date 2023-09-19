* file.s
* Itagaki Fumihiko 23-Feb-91  Create.
*
* This contains file controll routines.

.include doscall.h
.include chrcode.h

.xref isspace
.xref fclose
.xref drvchkp

.text

*****************************************************************
* create_normal_file - �ʏ�̃t�@�C���𐶐�����
*
* CALL
*      A0     ��������t�@�C���̃p�X��
*
* RETRUN
*      D0.L   ��: �G���[�E�R�[�h
*             ��: ���ʃ��[�h���A�쐬���ăI�[�v�����ꂽ�t�@�C���E�n���h��������
*
*      CCR    TST.L D0
*
* NOTE
*      �h���C�u�̌����͍s��Ȃ�
*****************************************************************
.xdef create_normal_file

create_normal_file:
		move.w	#$20,-(a7)
		move.l	a0,-(a7)
		DOS	_CREATE
		addq.l	#6,a7
		tst.l	d0
		rts
*****************************************************************
* fclosex - �t�@�C���E�f�X�N���v�^�����Ȃ�΃t�@�C�����N���[�Y����
*
* CALL
*      D0.L   �t�@�C���E�f�X�N���v�^
*
* RETURN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*****************************************************************
.xdef fclosex

fclosex:
		tst.l	d0
		bpl	fclose

		rts
*****************************************************************
.xdef redirect

redirect:
		subq.l	#4,a7
		move.w	d0,-(a7)		* ���_�C���N�g�����fd��
		DOS	_DUP			* �R�s�[��
		move.l	d0,2(a7)		* ����Ă���
		bmi	cannot_redirect

		move.w	d1,-(a7)		* ���_�C���N�g��Ƀ��_�C���N�g����t�@�C����
		DOS	_DUP2			* �R�s�[����
		addq.l	#2,a7
cannot_redirect:
		addq.l	#2,a7
		move.l	(a7)+,d0
		rts
*****************************************************************
.xdef unredirect

unredirect:
		tst.l	d1
		bmi	unredirect_done

		move.w	d0,-(a7)
		move.w	d1,-(a7)
		DOS	_DUP2
		DOS	_CLOSE
		addq.l	#4,a7
unredirect_done:
		moveq	#-1,d0
		rts
*****************************************************************
* fgets - �t�@�C������1�s�ǂݎ��
*
* CALL
*      A0     ���̓o�b�t�@�̐擪�A�h���X
*      D0.W   �t�@�C���E�n���h��
*      D1.W   ���͍ő�o�C�g���i�Ō�� NUL �̕��͊��肵�Ȃ��j
*
* RETURN
*      A0     ���͕��������i��
*
*      D0.L   ��: �G���[�E�R�[�h
*             0 : ���͗L��
*             1 : �o�b�t�@�E�I�[�o�[
*
*      D1.W   �c����͉\�o�C�g���i�Ō�� NUL �̕��͊��肵�Ȃ��j
*
*      CCR    TST.L D0
*****************************************************************
.xdef fgets

fgets:
		move.w	d0,-(a7)
fgets_loop:
		DOS	_FGETC
		tst.l	d0
		bmi	fgets_return

		cmp.b	#LF,d0
		beq	fgets_lf

		cmp.b	#CR,d0
		bne	fgets_input_one

		DOS	_FGETC
		tst.l	d0
		bmi	fgets_return

		cmp.b	#LF,d0
		beq	fgets_lf

		subq.w	#1,d1
		bcs	fgets_over

		move.b	#CR,(a0)+
fgets_input_one:
		subq.w	#1,d1
		bcs	fgets_over

		move.b	d0,(a0)+
		bra	fgets_loop

fgets_lf:
		clr.b	(a0)
		moveq	#0,d0
fgets_return:
		addq.l	#2,a7
		tst.l	d0
		rts

fgets_over:
		moveq	#1,d0
		bra	fgets_return
*****************************************************************
* fforline - �t�@�C�������̍s�̐擪�ɃV�[�N����
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h���邢�� EOF
*             ��: ���̍s�̐擪�ɃV�[�N����
*
*      CCR    TST.L D0
*****************************************************************
.xdef fforline

fforline:
		move.w	d0,-(a7)
fforline_loop:
		DOS	_FGETC
		tst.l	d0
		bmi	fforline_return

		cmp.b	#LF,d0
		bne	fforline_loop
fforline_return:
		addq.l	#2,a7
		tst.l	d0
		rts
*****************************************************************
* fforfield - �t�@�C�������̃t�B�[���h�̐擪�ɃV�[�N����
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h���邢�� EOF
*             ��: D0.B:LF:  ���̍s�̐擪�ɃV�[�N����
*                 D0.B:';'  ���̃t�B�[���h�̐擪�ɃV�[�N����
*
*      CCR    TST.L D0
*****************************************************************
.xdef fforfield

fforfield:
		move.w	d0,-(a7)
fforfield_loop:
		DOS	_FGETC
		tst.l	d0
		bmi	fforfield_return

		cmp.b	#';',d0
		beq	fforfield_return

		cmp.b	#LF,d0
		bne	fforfield_loop
fforfield_return:
		addq.l	#2,a7
		tst.l	d0
		rts
*****************************************************************
* fskip_space - �t�@�C���̋󔒂�ǂݔ�΂�
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h���邢�� EOF
*             ��: �ŉ��ʃo�C�g�͍ŏ��̋󔒈ȊO�̕����i�܂���LF�j
*
*      CCR    TST.L D0
*****************************************************************
.xdef fskip_space

fskip_space:
		move.w	d0,-(a7)
fskip_space_loop:
		DOS	_FGETC
		tst.l	d0
		bmi	fskip_space_return

		cmp.b	#LF,d0
		beq	fskip_space_return

		bsr	isspace
		beq	fskip_space_loop
fskip_space_return:
		addq.l	#2,a7
		tst.l	d0
		rts
.if 0
*****************************************************************
* fmemcmp - �X�g���[���ƃ��������ƍ�����
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*      D1.W   �ƍ����钷��
*      A0     �������E�A�h���X
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h���邢�� EOF
*             0 : ��v����
*             1 : ��v���Ȃ�
*
*      CCR    TST.L D0
*****************************************************************
.xdef fmemcmp

fmemcmp:
		movem.l	d1/a0,-(a7)
		move.w	d0,-(a7)
		tst.l	d1
		beq	fmemcmp_matched
fmemcmp_loop:
		DOS	_FGETC
		tst.l	d0
		bmi	fmemcmp_return

		cmp.b	(a0)+,d0
		bne	fmemcmp_fail

		subq.l	#1,d1
		bne	fmemcmp_loop
fmemcmp_matched:
		moveq	#0,d0
fmemcmp_return:
		addq.l	#2,a7
		movem.l	(a7)+,d1/a0
		tst.l	d0
		rts

fmemcmp_fail:
		moveq	#1,d0
		bra	fmemcmp_return
*****************************************************************
.endif

.end

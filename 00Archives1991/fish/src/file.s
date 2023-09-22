* file.s
* Itagaki Fumihiko 23-Feb-91  Create.
*
* This contains file controll routines.

.include doscall.h
.include chrcode.h

.xref isspace
.xref test_drive_path

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
* fopen - �t�@�C�����I�[�v������
*
* CALL
*      A0     �I�[�v������t�@�C���̃p�X��
*      D0.W   �I�[�v�����[�h
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h
*             ��: ���ʃ��[�h���A�I�[�v�������t�@�C���̃t�@�C���E�n���h��������
*
*      CCR    TST.L D0
*
* NOTE
*      �I�[�v������O�Ƀh���C�u����������
*****************************************************************
.xdef fopen

fopen:
		move.w	d0,-(a7)
		move.l	a0,-(a7)
		bsr	test_drive_path
		bne	fopen_return

		DOS	_OPEN
fopen_return:
		addq.l	#6,a7
		tst.l	d0
		rts
*****************************************************************
* fclose - �t�@�C�����N���[�Y����
*
* CALL
*      D0.W   �t�@�C���E�f�X�N���v�^
*
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
.xdef fclose

fclosex:
		tst.w	d0
		bmi	fclose_return
fclose:
		move.w	d0,-(a7)
		DOS	_CLOSE
		addq.l	#2,a7
		tst.l	d0
fclose_return:
		rts
*****************************************************************
* remove - �t�@�C�����폜����
*
* CALL
*      A0     �폜����t�@�C���̃p�X��
*
* RETRUN
*      D0.L   �G���[�E�R�[�h
*      CCR    TST.L D0
*
* NOTE
*      �h���C�u�̌����͍s��Ȃ�
*****************************************************************
.xdef remove

remove:
		move.l	a0,-(a7)
		DOS	_DELETE
		addq.l	#4,a7
		tst.l	d0
		rts
*****************************************************************
.xdef redirect

redirect:
		subq.l	#2,a7
		move.w	d0,-(a7)		* ���_�C���N�g�����fd��
		DOS	_DUP			* �R�s�[��
		move.w	d0,2(a7)		* ����Ă���
		bmi	cannot_redirect

		move.w	d1,-(a7)		* ���_�C���N�g��Ƀ��_�C���N�g����t�@�C����
		DOS	_DUP2			* �R�s�[����
		addq.l	#2,a7
cannot_redirect:
		addq.l	#2,a7
		move.w	(a7)+,d0
		rts
*****************************************************************
.xdef unredirect

unredirect:
		tst.w	d1
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
* fgetc - �t�@�C������1�����ǂݎ��
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h
*             ��: ���ʃo�C�g���ǂݎ����������ێ����Ă���
*
*      CCR    TST.L D0
*****************************************************************
.xdef fgetc

fgetc:
		move.w	d0,-(a7)
		DOS	_FGETC
		addq.l	#2,a7
		tst.l	d0
		bmi	fgetc_return

		cmp.b	#EOT,d0
		bne	fgetc_return

		moveq	#-1,d0
fgetc_return:
		tst.l	d0
		rts
*****************************************************************
fskip_until_LF:
		move.w	d7,d0
		bsr	fgetc
		bmi	fskip_until_LF_return

		cmp.b	#LF,d0
		bne	fskip_until_LF
fskip_until_LF_return:
		tst.l	d0
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
		move.w	d7,-(a7)
		move.w	d0,d7
fgets_loop:
		move.w	d7,d0
		bsr	fgetc
		bmi	fgets_return

		cmp.b	#CR,d0
		beq	fgets_cr

		subq.w	#1,d1
		bcs	fgets_over

		move.b	d0,(a0)+
		bra	fgets_loop

fgets_cr:
		bsr	fskip_until_LF
		bmi	fgets_return

		clr.b	(a0)
		moveq	#0,d0
fgets_return:
		move.w	(a7)+,d7
		tst.l	d0
		rts

fgets_over:
		moveq	#1,d0
		bra	fgets_return
*****************************************************************
* fseek_nextline - �t�@�C�������̍s�̐擪�ɃV�[�N����
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h
*             0 : ���̍s�̐擪�ɃV�[�N����
*
*      CCR    TST.L D0
*****************************************************************
.xdef fseek_nextline

fseek_nextline:
		move.w	d7,-(a7)
		move.w	d0,d7
fseek_nextline_loop:
		move.w	d7,d0
		bsr	fgetc
		bmi	fseek_nextline_return

		cmp.b	#CR,d0
		bne	fseek_nextline_loop

		bsr	fskip_until_LF
		bmi	fseek_nextline_return

		moveq	#0,d0
fseek_nextline_return:
		move.w	(a7)+,d7
		tst.l	d0
		rts
*****************************************************************
* fseek_nextline - �t�@�C�������̃t�B�[���h�̐擪�ɃV�[�N����
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h
*             1 : ���̍s�̐擪�ɃV�[�N����
*             0 : ���̃t�B�[���h�̐擪�ɃV�[�N����
*
*      CCR    TST.L D0
*****************************************************************
.xdef fseek_nextfield

fseek_nextfield:
		move.w	d7,-(a7)
		move.w	d0,d7
fseek_nextfield_loop:
		move.w	d7,d0
		bsr	fgetc
		bmi	fseek_nextfield_return

		cmp.b	#';',d0
		beq	fseek_nextfield_rearched

		cmp.b	#CR,d0
		bne	fseek_nextfield_loop

		bsr	fskip_until_LF
		bmi	fseek_nextfield_return

		moveq	#1,d0
		bra	fseek_nextfield_return

fseek_nextfield_rearched:
		moveq	#0,d0
fseek_nextfield_return:
		move.w	(a7)+,d7
		tst.l	d0
		rts
*****************************************************************
* fskip_space - �t�@�C���̋󔒂�ǂݔ�΂�
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h���邢�͂d�n�e
*              0: CR
*             ��: �ŉ��ʃo�C�g�͍ŏ��̋󔒈ȊO�̕���
*
*      CCR    TST.L D0
*****************************************************************
.xdef fskip_space

fskip_space:
		move.w	d1,-(a7)
		move.w	d0,d1
fskip_space_loop:
		move.w	d1,d0
		bsr	fgetc
		bmi	fskip_space_return

		cmp.b	#CR,d0
		beq	fskip_space_cr

		bsr	isspace
		beq	fskip_space_loop

		bra	fskip_space_return

fskip_space_cr:
		moveq	#0,d0
fskip_space_return:
		move.w	(a7)+,d1
		tst.l	d0
		rts
*****************************************************************
* fmemcmp - �X�g���[���ƃ��������ƍ�����
*
* CALL
*      D0.W   �t�@�C���E�n���h��
*      D1.W   �ƍ����钷��
*      A0     �������E�A�h���X
*
* RETURN
*      D0.L   ��: �G���[�E�R�[�h
*             0 : ��v����
*             1 : ��v���Ȃ�
*
*      CCR    TST.L D0
*****************************************************************
.xdef fmemcmp

fmemcmp:
		movem.l	d1-d2/a0,-(a7)
		move.w	d0,d2
		tst.l	d1
		beq	fmemcmp_matched
fmemcmp_loop:
		move.w	d2,d0
		bsr	fgetc
		bmi	fmemcmp_return

		cmp.b	(a0)+,d0
		bne	fmemcmp_fail

		subq.l	#1,d1
		bne	fmemcmp_loop
fmemcmp_matched:
		moveq	#0,d0
fmemcmp_return:
		movem.l	(a7)+,d1-d2/a0
		rts

fmemcmp_fail:
		moveq	#1,d0
		bra	fmemcmp_return
*****************************************************************

.end

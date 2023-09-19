* fgetpwent.s
* Itagaki Fumihiko 17-Aug-91  Create.

.include chrcode.h
.include limits.h
.include pwd.h

.xref fgetc
.xref atoi
.xref skip_space

.text

*****************************************************************
* fgetpwent - �p�X���[�h�E�t�@�C������1�G���g���𓾂�
*
* CALL
*      D0.W   �p�X���[�h�E�t�@�C���̃t�@�C���E�n���h��
*             �i�s�̐擪���w���Ă��邱�Ɓj
*
*      A0     pwd�\���̂̐擪�A�h���X
*      A1     �s�ǂݍ��݃o�b�t�@�̐擪�A�h���X
*      D1.L   �s�ǂݍ��݃o�b�t�@�̗e��
*
* RETURN
*      D0.L   0 �Ȃ�ΐ����D�����Ȃ��΂����G���g���͂Ȃ��D
*      CCR    TST.L D0
*****************************************************************
.xdef fgetpwent

fgetpwent:
		movem.l	d1-d5/a0-a3,-(a7)
		move.w	d0,d3				*  D3.W : �t�@�C���E�n���h��
		move.l	d1,d2				*  D2.L : �o�b�t�@�e��
scan:
		movea.l	a1,a2
		move.l	d2,d4
		moveq	#';',d5
		move.l	a2,PW_NAME(a0)
		bsr	getpwfield
		bne	getpwent_error
		*
		move.l	a2,PW_PASSWD(a0)
		bsr	getpwfield
		bne	getpwent_error
		*
		bsr	getpwid
		bne	getpwent_error

		move.l	d1,PW_UID(a0)
		*
		bsr	getpwid
		bne	getpwent_error

		move.l	d1,PW_GID(a0)
		*
		move.l	a2,PW_GECOS(a0)
		bsr	getpwfield
		bne	getpwent_error
		*
		move.l	a2,PW_DIR(a0)
		bsr	getpwfield
		bne	getpwent_error
		*
		moveq	#LF,d5
		move.l	a2,PW_SHELL(a0)
		bsr	getpwfield
		beq	getpwent_return
getpwent_error:
		bpl	scan
getpwent_return:
		movem.l	(a7)+,d1-d5/a0-a3
		tst.l	d0
		rts
****************
getpwfield:
		sf	d1				*  D1.B : CR pending flag
getpwfield_loop:
		move.w	d3,d0
		jsr	fgetc
		bmi	getpwfield_return

		cmp.b	#LF,d0
		beq	getpwfield_lf

		tst.b	d1
		beq	getpwfield_no_pending_cr

		subq.w	#1,d4
		bcs	getpwfield_skip

		move.b	#CR,(a2)+
		sf	d1
getpwfield_no_pending_cr:
		cmp.b	#CR,d0
		bne	getpwfield_not_cr

		st	d1
		bra	getpwfield_loop			*  pending CR

getpwfield_not_cr:
		cmp.b	d5,d0
		beq	getpwfield_done

		subq.w	#1,d4
		bcs	getpwfield_skip

		move.b	d0,(a2)+
		bra	getpwfield_loop

getpwfield_lf:
		cmp.b	d0,d5
		bne	getpwfield_error
getpwfield_done:
		subq.l	#1,d4
		bcs	getpwfield_skip

		clr.b	(a2)+
getpwfield_success:
		moveq	#0,d0
getpwfield_return:
		rts

getpwfield_skip_more:
		move.w	d3,d0
		jsr	fgetc
		bmi	getpwfield_return
getpwfield_skip:
		cmp.b	#LF,d0
		bne	getpwfield_skip_more
getpwfield_error:
		moveq	#1,d0
		rts
****************
getpwid:
		move.l	a2,a3
		bsr	getpwfield
		bne	getpwfield_return

		exg	a0,a3
		jsr	skip_space
		jsr	atoi
		exg	a0,a3
		bra	getpwfield_success
****************
.end

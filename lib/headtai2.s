* headtai2.s
* Itagaki Fumihiko 27-Mar-93  Create.

.include limits.h

.xref skip_root
.xref skip_slashes
.xref find_slashes

.text

****************************************************************
* headtail2 - �p�X���̃t�@�C�����̈ʒu
*
* CALL
*      A0     �p�X���̐擪�A�h���X
*
* RETURN
*      A1     �t�@�C�����̃A�h���X
*      D0.L   �h���C�u�{�f�B���N�g�����̒����i�Ō�� / �܂��� \ �̕����܂ށj
*      CCR    TST.L D0
*
* DESCRIPTION
*      /foo/bar/ �̂悤�ȏꍇ�ɂ� bar ���f�B���N�g�����ł͂Ȃ�
*      �t�@�C�����Ƃ���D
*****************************************************************
.xdef headtail2

headtail2:
		move.l	a0,-(a7)
		jsr	skip_root
		jsr	skip_slashes
loop:
		movea.l	a0,a1
		jsr	find_slashes
		jsr	skip_slashes
		bne	loop

		movea.l	(a7)+,a0
		move.l	a1,d0
		sub.l	a0,d0
		rts
*****************************************************************

.end

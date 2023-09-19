* expwords.s
* Itagaki Fumihiko 30-Sep-90  Create.

.xref subst_var_wordlist
.xref subst_command_wordlist
.xref unpack_wordlist
.xref glob_wordlist
.xref strip_quotes_list

.xref flag_noglob
.xref not_execute

.text

****************************************************************
* expand_wordlist_var, expand_wordlist_var
*
* CALL
*      A0     �i�[�̈�̐擪�D�������тƏd�Ȃ��Ă��Ă��ǂ��D
*      A1     �������т̐擪
*      D0.W   �ꐔ
*
* RETURN
*      D0.L   �����Ȃ�ΐ����D���ʃ��[�h�͓W�J��̌ꐔ
*             �����Ȃ�΃G���[
*
*      (tmpline)   �j��
*
*      CCR    TST.L D0
****************************************************************
.xdef expand_wordlist_var
.xdef expand_wordlist

expand_wordlist_var:
		move.l	a1,-(a7)
		bsr	subst_var_wordlist
		bmi	return

		movea.l	a0,a1
		bra	expand_wordlist_2

expand_wordlist:
		move.l	a1,-(a7)
expand_wordlist_2:
		bsr	subst_command_wordlist
		bmi	return

		tst.b	flag_noglob(a5)
		bne	strip

		movea.l	a0,a1
		bsr	unpack_wordlist
		bmi	return

		tst.b	not_execute(a5)
		bne	return

		movea.l	a0,a1
		bsr	glob_wordlist
		bra	return

strip:
		bsr	strip_quotes_list
return:
		movea.l	(a7)+,a1
		tst.l	d0
		rts

.end

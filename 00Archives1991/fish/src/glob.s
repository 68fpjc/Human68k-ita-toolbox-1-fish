* glob.s
* Itagaki Fumihiko 02-Sep-90  Create.

.include doscall.h
.include limits.h
.include ../src/fish.h

.xref issjis
.xref strlen
.xref strbot
.xref strcpy
.xref stpcpy
.xref strmove
.xref strpcmp
.xref memmove_inc
.xref for1str
.xref sort_wordlist
.xref copy_wordlist
.xref escape_quoted
.xref strip_quotes
.xref builtin_dir_match
.xref test_drive_path
.xref check_wildcard
.xref no_match
.xref too_many_words
.xref too_long_line
.xref dos_allfile
.xref command_table
.xref flag_ciglob
.xref flag_nonomatch
.xref pathname_buf
.xref tmpline
.xref tmpword1
.xref tmpword2

.text

****************************************************************
.xdef get_1char

get_1char:
		move.b	(a0)+,d0
		beq	get_1char_done

		cmp.b	#'\',d0
		bne	get_1char_done

		move.b	(a0)+,d0
get_1char_done:
		rts
****************************************************************
* get_firstdir - ファイル名から、ドライブ記述子（もしあれば）と
*                ルート・ディレクトリ（もしあれば）を取り出す．
*
* CALL
*      A0     filename (may be contains \)
*      A1     buffer
*
* RETURN
*      A0     続き
*      (A1)   取り出した文字列
****************************************************************
get_firstdir:
		movem.l	d0-d1/a1-a2,-(a7)
		moveq	#0,d2
get_firstdir_restart:
		movea.l	a0,a2
		bsr	get_1char
		beq	get_firstdir_done

		cmp.b	#'/',d0
		beq	get_firstdir_root

		cmp.b	#'\',d0
		beq	get_firstdir_root

		tst.w	d2
		bne	get_firstdir_done

		bsr	issjis
		beq	get_firstdir_done

		move.b	d0,d1
		bsr	get_1char
		beq	get_firstdir_done

		cmp.b	#':',d0
		bne	get_firstdir_done

		move.b	d1,(a1)+
		move.b	d0,(a1)+
		moveq	#1,d2
		bra	get_firstdir_restart

get_firstdir_root:
		move.b	d0,(a1)+
		movea.l	a0,a2
get_firstdir_done:
		clr.b	(a1)
		movea.l	a2,a0
		movem.l	(a7)+,d0-d1/a1-a2
		rts
****************************************************************
* get_subdir - pathname の最初のディレクトリ名を取り出す。
*
* CALL
*      A0     pathname
*      A1     buffer
*
* RETURN
*      A0     次の / \/ \\ あるいは NUL を指す
*      (A1)   最初のディレクトリ名（末尾の / \/ \\ は含まない）
*      D0.B   破壊
****************************************************************
get_subdir:
		movem.l	d1/a1,-(a7)
get_subdir_loop:
		move.b	(a0),d0
		beq	get_subdir_done

		bsr	issjis
		beq	get_subdir_dup2

		cmp.b	#'/',d0
		beq	get_subdir_done

		cmp.b	#'\',d0
		bne	get_subdir_dup

		cmpi.b	#'/',1(a0)
		beq	get_subdir_done

		cmpi.b	#'\',1(a0)
		beq	get_subdir_done

		addq.l	#1,a0
		move.b	d0,(a1)+
		move.b	(a0),d0
		beq	get_subdir_done

		bsr	issjis
		bne	get_subdir_dup
get_subdir_dup2:
		addq.l	#1,a0
		move.b	d0,(a1)+
		move.b	(a0),d0
		beq	get_subdir_done
get_subdir_dup:
		addq.l	#1,a0
		move.b	d0,(a1)+
		bra	get_subdir_loop

get_subdir_done:
		clr.b	(a1)
		movem.l	(a7)+,d1/a1
		rts
****************************************************************
* globsub
*
* CALL
*      (pathname_buf)  検索するディレクトリのパス名．MAXPATH+1バイトが必要
*      A2     検索するファイル名（may be contains \）
*      D2.W   再帰の深さ．最初は0
*      A3     適合したファイル名を格納するバッファを指す
*      D3.W   展開する個数の限度
*      D4.W   バッファの容量
*
* RETURN
*      D0.L   負数ならば正常．
*                  0: パス名のディレクトリが深過ぎるか，head部がMAXHEAD文字を超えている
*                  1: 最大語数を超えた
*                  2: バッファの容量が足りない
*                  4: その他のエラー。（] がないなど）メッセージが表示される。
*
*      D1.W   適合した数だけ増加する
*             D1>D3 となったら D0.L に 1 をセットして処理を中止する
*
*      D4.W   バッファに追加した分だけ減少する
*             足りなくなったら D0.L に 2 をセットして処理を中止する
*
*      A3     バッファの次の格納位置
*
*      A0, A1, A2     破壊
*
* NOTE
*      33回めまで再帰する．スタックに注意！
*
*      参考までに書いておくと，Human68kでは，絶対パス名のディレクトリ部
*      （ドライブ名は含まない．最初の / から最後の / まで）の長さは，
*      最大64文字という制限がある．
*      ということは，ルート・ディレクトリを1世とすると，サブ・ディレクトリは
*      31世までしか無い．（32世だと，続くファイル名を記述できない）
*      したがって，32回のディレクトリ検索と1回のファイル検索，すなわち，33回
*      の再帰で充分な筈である．
*
*      なお，絶対パスは制限内であっても，相対パスだと制限を超える場合もある
*      が，それは認めず，相対パスであっても絶対パスの制限をそのまま適用する
*      ことにした．（スタックやバッファを静的に安全に確保するため）
****************************************************************
curdot  = -4
dirbot  = curdot-4
filebuf = dirbot-54

globsub:
		link	a6,#filebuf
		move.l	a2,curdot(a6)
		lea	pathname_buf,a0
		move.w	#$37,-(a7)		* ボリューム・ラベル以外の全てを検索
		move.l	a0,-(a7)
		pea	filebuf(a6)
		bsr	strbot
		move.l	a0,dirbot(a6)
		lea	dos_allfile,a1
		bsr	strcpy
		DOS	_FILES
		lea	10(a7),a7
		clr.b	(a0)
globsub_loop:
		tst.l	d0
		bmi	globsub_nomore

		movea.l	curdot(a6),a0
		lea	tmpword2,a1
		bsr	get_subdir
		movea.l	a0,a2
		lea	filebuf+30(a6),a0

		* 検索されたエントリが . で始まっていなければ、よし。
		cmpi.b	#'.',(a0)
		bne	globsub_compare

		* . で始まるエントリも、
		* 検索文字列が . または \. で始まっているならば、よし。
		cmpi.b	#'.',(a1)
		beq	globsub_compare

		cmpi.b	#'\',(a1)
		bne	globsub_next

		cmpi.b	#'.',1(a1)
		bne	globsub_next
globsub_compare:
		move.b	flag_ciglob,d0
		bsr	strpcmp
		bmi	globsub_error4
		bne	globsub_next

		tst.b	(a2)
		beq	globsub_terminal

		btst.b	#4,filebuf+21(a6)
		beq	globsub_next

		movea.l	dirbot(a6),a0
		lea	filebuf+30(a6),a1
		bsr	stpcpy
		move.b	(a2)+,d0
		move.b	d0,(a0)+
		clr.b	(a0)
		cmp.b	#'\',d0
		bne	globsub_find_more

		addq.l	#1,a2
globsub_find_more:
		addq.w	#1,d2
		cmp.w	#MAXDIRDEPTH,d2
		bhi	globsub_error0

		movea.l	a2,a0
		bsr	strlen
		cmp.l	#MAXHEAD,d0
		bhi	globsub_error0

		bsr	globsub				***!! 再帰 !!***
		subq.w	#1,d2
		tst.l	d0
		bpl	globsub_nomore

		bra	globsub_next

globsub_terminal:
		moveq	#1,d0
		addq.w	#1,d1
		cmp.w	d3,d1
		bhi	globsub_nomore

		lea	pathname_buf,a0
		bsr	strlen
		sub.w	d0,d4		* D0.LはMAXPATHを超えない筈．MAXPATHは32767以下の筈
		bcs	globsub_buffer_full

		movea.l	a0,a1
		movea.l	a3,a0
		bsr	stpcpy
		movea.l	a0,a3
		lea	filebuf+30(a6),a0
		bsr	strlen
		addq.w	#1,d0		* D0.LはMAXTAILを超えない筈．MAXTAILは22の筈
		sub.w	d0,d4
		bcs	globsub_buffer_full

		movea.l	a0,a1
		movea.l	a3,a0
		bsr	strmove
		movea.l	a0,a3
globsub_next:
		pea	filebuf(a6)
		DOS	_NFILES
		addq.l	#4,a7
		bra	globsub_loop

globsub_buffer_full:
		moveq	#2,d0
globsub_nomore:
		unlk	a6
		rts

globsub_error0:
		moveq	#0,d0
		bra	globsub_nomore

globsub_error4:
		moveq	#4,d0
		bra	globsub_nomore
****************************************************************
* glob - evaluate filename with wildcard
*
* CALL
*      A0     ワイルド・カードを含むファイル名．', " and/or \ によるクオートが可
*      A1     適合したファイル名を格納するバッファを指す
*      D0.W   展開する個数の限度
*      D1.W   バッファの容量
*
* RETURN
*      A1     バッファの次の格納位置
*
*      D0.L   正数ならば成功．下位ワードは適合した数．
*             負数ならばエラー．
*                  -1  適合するものの個数が限度を超えた
*                  -2  バッファの容量を超えた
*                  -4  その他のエラー．メッセージが表示される．
*                           パス名のディレクトリが深過ぎる，
*                           パス名のhead部がMAXHEAD文字を超えた，
*
*      D1.L   下位ワードは残りバッファ容量
*             上位ワードは破壊
*
*      CCR    TST.L D0
*****************************************************************
.xdef glob

glob:
		movem.l	d2-d5/a0/a2-a4,-(a7)
		move.w	d0,d3			* D3.W : 最大展開個数
		move.w	d1,d4			* D4.W : バッファ容量
		move.w	d1,d5
		movea.l	a1,a4			* A4 : 展開バッファの先頭
		movea.l	a1,a3			* A3 : 展開バッファ
		lea	tmpword1,a1
		bsr	escape_quoted		* A1 : クオートをエスケープに代えた検索文字列
		moveq	#0,d1			* D1.W : 適合した個数を得る

		exg	a0,a1
		bsr	builtin_dir_match
		exg	a0,a1
		beq	glob_real

		move.l	d0,d2
		addq.l	#1,d2			* D2 : コピーする仮想ディレクトリ部の長さ
		cmpi.b	#'\',(a1,d0.l)
		bne	glob_1

		addq.l	#1,d0
glob_1:
		cmpi.b	#'/',(a1,d0.l)
		beq	glob_builtin

		cmpi.b	#'\',(a1,d0.l)
		bne	glob_real
****************
glob_builtin:
		move.l	a0,-(a7)
		movea.l	a1,a2			* A2 : 仮想ディレクトリ部
		lea	1(a2,d0.l),a1		* A1 : 比較パターン
		lea	command_table,a0
glob_builtin_loop:
		moveq	#-1,d0
		tst.b	(a0)
		beq	glob_builtin_nomore

		moveq	#0,d0			* case dependent
		bsr	strpcmp
		tst.l	d0
		bmi	glob_builtin_error4
		bne	glob_builtin_continue

		moveq	#1,d0
		addq.w	#1,d1
		cmp.w	d3,d1
		bhi	glob_builtin_nomore

		bsr	strlen
		add.l	d2,d0
		addq.l	#1,d0
		sub.w	d0,d4
		bcs	glob_builtin_buffer_full
					* A0:entry     A1:pat(com)  A2:pat(top)  A3:buf
		exg	a0,a3		* A0:buf       A1:pat(com)               A3:entry
		move.l	a1,-(a7)
		movea.l	a2,a1		*              A1:pat(top)
		move.l	d2,d0
		bsr	memmove_inc
		movea.l	a3,a1		*              A1:entry
		bsr	strmove
		movea.l	(a7)+,a1	*              A1:pat(com)
		exg	a0,a3		* A0:entry                               A3:buf
glob_builtin_continue:
		lea	14(a0),a0
		bra	glob_builtin_loop

glob_builtin_error4:
		moveq	#4,d0
		bra	glob_builtin_nomore

glob_builtin_buffer_full:
		moveq	#2,d0
glob_builtin_nomore:
		movea.l	(a7)+,a0
		tst.l	d0
		beq	glob_nothing
		bpl	glob_error

		moveq	#0,d0
		move.w	d1,d0
		movea.l	a4,a0
		bra	glob_done
****************
glob_real:
		exg	a0,a2			* A2 : 元の検索文字列
		movea.l	a1,a0			* A0 : クオートをエスケープに代えた検索文字列
		lea	pathname_buf,a1
		bsr	get_firstdir
		exg	a0,a2
		exg	a0,a1
		bsr	test_drive_path
		exg	a0,a1
		bne	glob_nothing

		move.l	a0,-(a7)
		moveq	#0,d2
		bsr	globsub
		movea.l	(a7)+,a0
		tst.l	d0
		beq	glob_nothing
		bpl	glob_error

		moveq	#0,d0
		move.w	d1,d0
		movea.l	a4,a0
		bsr	sort_wordlist
glob_done:
		movea.l	a3,a1
		move.w	d4,d1
		movem.l	(a7)+,d2-d5/a0/a2-a4
		tst.l	d0
		rts

glob_nothing:
		moveq	#0,d0
		move.l	d5,d1
		bra	glob_done

glob_error:
		neg.l	d0
		bra	glob_done
****************************************************************
* glob_wordlist - 引数並びの各語についてファイル名展開をする
*                 ついでにクオートも外してしまう
*
* CALL
*      A0     格納領域の先頭．引数並びと重なっていても良い．
*      A1     引数並びの先頭
*      D0.W   語数
*
* RETURN
*      D0.L   正数ならば成功．下位ワードは展開後の語数
*             負数ならばエラー
*
*      (tmpline)   破壊される
*      (A0)   破壊
*
*      CCR    TST.L D0
****************************************************************
.xdef glob_wordlist

glob_wordlist:
		movem.l	d1-d4/a0-a2,-(a7)
		move.w	#MAXWORDLISTSIZE,d1	* D1 : 最大文字数
		move.w	d0,d2			* D2 : 引数カウンタ
		moveq	#0,d3			* D3 : 展開後の語数
		moveq	#0,d4			* D4 : glob status
		tst.b	flag_nonomatch
		beq	glob_wordlist_1

		moveq	#-1,d4
glob_wordlist_1:
		move.l	a0,-(a7)
		lea	tmpline,a0		* 一時領域に
		bsr	copy_wordlist		* 引数並びを一旦コピーしてこれをソースとする
		movea.l	(a7)+,a1
		bra	glob_wordlist_continue

glob_wordlist_loop:
		bsr	check_wildcard
		beq	glob_wordlist_just_copy

		tst.b	d4
		bne	glob_wordlist_glob_1

		moveq	#1,d4
glob_wordlist_glob_1:
		move.w	#MAXWORDS,d0
		sub.w	d3,d0
		bsr	glob
		bmi	glob_wordlist_glob_error
		bne	glob_wordlist_2

		tst.b	d4
		bpl	glob_wordlist_glob_3

		bra	glob_wordlist_just_copy

glob_wordlist_2:
		tst.b	d4
		beq	glob_wordlist_glob_3
		bmi	glob_wordlist_glob_3

		moveq	#2,d4
glob_wordlist_glob_3:
		add.w	d0,d3
		bsr	for1str
		bra	glob_wordlist_continue

glob_wordlist_just_copy:
		movea.l	a0,a2
		bsr	for1str
		exg	a0,a2
		bsr	strip_quotes
		bsr	strlen
		addq.w	#1,d0
		sub.w	d0,d1
		bmi	glob_wordlist_too_long_line

		cmp.w	#MAXWORDS,d3
		bhs	glob_wordlist_too_many_words

		addq.w	#1,d3
		exg	a0,a1
		bsr	strmove
		exg	a0,a1
		movea.l	a2,a0
glob_wordlist_continue:
		dbra	d2,glob_wordlist_loop

		cmp.b	#1,d4
		beq	glob_wordlist_no_match

		moveq	#0,d0
		move.w	d3,d0
glob_wordlist_return:
		movem.l	(a7)+,d1-d4/a0-a2
		tst.l	d0
		rts

glob_wordlist_glob_error:
		cmp.w	#-1,d0
		beq	glob_wordlist_too_many_words

		cmp.w	#-2,d0
		beq	glob_wordlist_too_long_line

		bra	glob_wordlist_error

glob_wordlist_no_match:
		bsr	no_match
		bra	glob_wordlist_error

glob_wordlist_too_many_words:
		bsr	too_many_words
		bra	glob_wordlist_error

glob_wordlist_too_long_line:
		bsr	too_long_line
glob_wordlist_error:
		moveq	#-1,d0
		bra	glob_wordlist_return

.end

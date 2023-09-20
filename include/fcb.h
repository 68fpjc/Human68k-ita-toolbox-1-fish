*  FCB�̍\���iHuman68k v2.01�ȍ~�j

.offset 0
FCB_USECOUNT:	ds.b	1	* handle use count (0:no use)
FCB_FLAG:	ds.b	1
FCB_DEVADDR:	ds.l	1	* devadr (device driver or DPB)
FCB_SEEKPOS:	ds.l	1	* seek data pos ���݂̃V�[�N�ʒu
FCB_SHAREPOS:	ds.l	1	* share_pos �V�F�A�Ǘ��̈�̃A�h���X
FCB_OPENMODE:	ds.b	1	* open_mode
FCB_DIRNO:	ds.b	1	* �f�B���N�g���Z�N�^�[�����Ԗ�
FCB_SECFAT:	ds.b	1	* �f�[�^FAT���Z�N�^�[�I�t�Z�b�g
FCB_FATSEC:	ds.b	1	* FAT�擪����̃Z�N�^�[�I�t�Z�b�g
FCB_FATPOS:	ds.w	1	* data ��FAT�ԍ�
FCB_DATASEC:	ds.l	1	* ���݂̃f�[�^�̃Z�N�^�[�ʒu
FCB_DATAADDR:	ds.l	1	* ���݂̃f�[�^��iobuf�A�h���X
FCB_DIRSEC:	ds.l	1	* �f�B���N�g���̃Z�N�^�[�ʒu
FCB_NEXTPOS:	ds.l	1	* next data pos
FCB_NAME1:	ds.b	8	* name1
FCB_EXT:	ds.b	3	* ext
FCB_ATTR:	ds.b	1	* atr
FCB_NAME2:	ds.b	10	* name2
FCB_TIME:	ds.w	1	* time
FCB_DATE:	ds.w	1	* date
FCB_FAT:	ds.w	1	* start fat
FCB_SIZE:	ds.l	1	* filelen
FCB_FAT_BUFF:	ds.w	14	* �f�B�X�N��FAT�ԍ�1, �t�@�C����FAT�ԍ�1
				* �f�B�X�N��FAT�ԍ�2, �t�@�C����FAT�ԍ�2
				*    . . .
				* �f�B�X�N��FAT�ԍ�7, �t�@�C����FAT�ԍ�7
FCBBUFSIZE:

*  FCB_FLAG �̃r�b�g

FCB_FLAGBIT_IO			equ	7

FCB_FLAGBIT_FILE_DIRTY		equ	6
FCB_FLAGBIT_FILE_SPECIAL	equ	5

FCB_FLAGBIT_IO_EOF		equ	6
FCB_FLAGBIT_IO_RAW		equ	5
FCB_FLAGBIT_IO_CLOCK		equ	3
FCB_FLAGBIT_IO_NULL		equ	2
FCB_FLAGBIT_IO_CONOUT		equ	1
FCB_FLAGBIT_IO_CONINP		equ	0

FCB_FLAG_DRIVEMASK		equ	$0f


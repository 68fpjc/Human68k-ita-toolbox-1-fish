#  Makefile for ita.l

AS = HAS060
ASFLAGS = -m 68000 -i $(INCLUDE)
AR = oar
AR2 = LIB
RM = -rm -f


INCLUDE = ../include

OBJS = \
	DecHUPAIR.o EncHUPAIR.o atoi.o atou.o bsltosl.o catpath.o chdir.o \
	contwild.o crypt.o csleep.o divul.o drvchk.o fairpath.o fclose.o \
	fgetc.o fgets.o fgetpwent.o fgetpwnam.o findsl.o getcwd.o getenv.o \
	getpass.o headtail.o headtai2.o irandom.o isalnum.o isalpha.o \
	isatty.o iscntrl.o iscsym.o isdigit.o isfullpath.o islower.o \
	isodigit.o isspace.o issjis.o isupper.o itoa.o memicmp.o memmovd.o \
	memmovi.o memset.o memxcmp.o minmaxul.o muldivsl.o mulul.o \
	printfi.o printfs.o remove.o reverse.o rmtslash.o rotate.o \
	setenv.o skipsl.o skipspc.o skiproot.o sltobsl.o splitpath.o \
	stpcpy.o strazbot.o strazcpy.o strbot.o strchr.o strcmp.o strcpy.o \
	strfor1.o strforn.o stricmp.o strlen.o strmem.o strmove.o strspc.o \
	suffix.o tfopen.o tolower.o toupper.o utoa.o utoao.o utoax.o

###

.PHONY : all clean clobber

%.o : %.s
	$(AS) $(ASFLAGS) $<

%.l : %.a
	$(AR2) $@ $<

###

all:: ita.l

clean::
	$(RM) ita.l

clobber:: clean
	$(RM) *.a *.o *.bak

###

ita.a : $(OBJS)
	$(AR) $@ $?

###

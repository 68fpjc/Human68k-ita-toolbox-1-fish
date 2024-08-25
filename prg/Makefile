#  Makefile for fish.x

MAKE = make

AS = HAS060
ASFLAGS = -m 68000 -i $(INCLUDE)
LD = hlk
LDFLAGS	= -p$(@:.x=.map)
LDFLAGS_STRIP = -x
AR = oar
AR2 = LIB
BIND = BIND.X
INSTALL = cp -upv
STRIP = strip
CP = cp
RM = -rm -f

VPATH   = ../src
INCLUDE = ../include
EXTLIBS = ../lib/ita.l ../extlib/Extmalloc.a

###

FILES	      = main.o subst.l var.l misc.l string.l dir_io.l state.l \
		builtin1.l builtin2.l

OBJS_BUILTIN1 = b_alias.o b_alloc.o b_apply.o b_bind.o b_dirs.o b_echo.o \
		b_eval.o b_exec.o b_exit.o b_glob.o b_goto.o b_history.o \
		b_logout.o b_printf.o b_repeat.o b_return.o b_setenv.o

OBJS_BUILTIN2 = b_set.o b_shift.o b_source.o b_srand.o b_time.o b_unset.o \
		b_unsetenv.o b_which.o b_xargs.o

OBJS_MISC     = echo.o error.o expr.o file.o f_getenv.o getcwdx.o \
		getline.o malloc.o misc.o hash.o passwd.o quote.o \
		skippar.o tmpfile.o wordlist.o

OBJS_SUBST    = enterhis.o expwords.o glob.o modify.o substali.o \
		substcom.o substhis.o substvar.o unpack.o

OBJS_VAR      = var.o f_setenv.o flagvar.o setsvar.o

OBJS_STATE    = ifthen.o switchcase.o foreach.o function.o

OBJS_STRING   = qstrchr.o scanch2.o skipvnam.o jstrchr.o strpcmp.o

OBJS_DIR_IO   = pathname.o stat.o

###

.PHONY : all install backup clean clobber

.TERMINAL : *.h *.s

%.o : %.s
	$(AS) $(ASFLAGS) $<

%.l : %.a
	$(AR2) $@ $<

###

all:: fish.x

install::

backup::

clean::

clobber::
	$(RM) *.x *.l *.a *.o *.map *.bak

###

fish.x : fishing.x fishbody.x
	$(BIND) -O $@ fishing.x fishbody.x /A+SHR

install::
	$(INSTALL) fish.x $(DESTDIR)

clean::
	$(RM) fish.x
###

fishing.x : fish_loader.o
	$(LD) $(LDFLAGS) $(LDFLAGS_STRIP) -o $@ $<

clean::
	$(RM) fishing.x fishing.map

###

fishbody.x : fishg.x
	$(CP) fishg.x $@
	$(STRIP) $@

clean::
	$(RM) fishbody.x

###

fishg.x : $(FILES) $(EXTLIBS)
	$(LD) $(LDFLAGS) -o $@ $^
	grep bsssize fishg.map

clean::
	$(RM) fishg.x fishg.map

#

$(EXTLIBS)::
	cd $(@D); $(MAKE) $(@F)

#
fish_loader.o main.o b_ctty.o b_dirs.o b_eval.o b_source.o b_srand.o \
expr.o getline.o glob.o ifthen.o malloc.o modify.o substcom.o substhis.o \
substvar.o switchcase.o unpack.o wordlist.o : fish.h

main.o b_set.o b_unset.o b_setenv.o b_unsetenv.o f_getenv.o f_setenv.o \
var.o : var.h

main.o b_source.o foreach.o getline.o b_goto.o substvar.o : source.h

main.o b_dirs.o unpack.o : dirstack.h

main.o function.o : function.h

main.o function.o enterhis.o substhis.o b_history.o getline.o : history.h

main.o foreach.o b_goto.o : loop.h

modify.o substhis.o substvar.o : modify.h

b_alloc.o : extmalloc.h

clean::
	$(RM) *.o
#

misc.a     : $(OBJS_MISC)
subst.a    : $(OBJS_SUBST)
var.a      : $(OBJS_VAR)
state.a    : $(OBJS_STATE)
builtin1.a : $(OBJS_BUILTIN1)
builtin2.a : $(OBJS_BUILTIN2)
string.a   : $(OBJS_STRING)
dir_io.a   : $(OBJS_DIR_IO)

misc.a subst.a var.a state.a builtin1.a builtin2.a string.a dir_io.a :
	$(AR) $@ $?

clean::
	$(RM) *.a

###

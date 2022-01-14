# fidoroute/Makefile - a generic Makefile for fidoroute
#
# This file is part of fidoroute, part of the Husky fidonet software project
# Use with GNU make v.3.82 or later
# Requires: husky enviroment
#

fidoroute_CFLAGS = $(CFLAGS)
fidoroute_CDEFS := $(CDEFS) -D_TARGET=\"`uname -s`\"

fidoroute_SRC  = $(fidoroute_SRCDIR)fidoroute.cpp
fidoroute_OBJS = $(addprefix $(fidoroute_OBJDIR),$(notdir $(fidoroute_SRC:.cpp=$(_OBJ))))

fidoroute_TARGET     = fidoroute$(_EXE)
fidoroute_TARGET_BLD = $(fidoroute_BUILDDIR)$(fidoroute_TARGET)
fidoroute_TARGET_DST = $(BINDIR_DST)$(fidoroute_TARGET)

ifdef MAN1DIR
    fidoroute_MAN1PAGES := fidoroute.1
    fidoroute_MAN1BLD := $(fidoroute_BUILDDIR)$(fidoroute_MAN1PAGES).gz
    fidoroute_MAN1DST := $(DESTDIR)$(MAN1DIR)$(DIRSEP)$(fidoroute_MAN1PAGES).gz
endif
ifdef MAN5DIR
    fidoroute_MAN5PAGES := fidoroute.conf.5
    fidoroute_MAN5BLD := $(fidoroute_BUILDDIR)$(fidoroute_MAN5PAGES).gz
    fidoroute_MAN5DST := $(DESTDIR)$(MAN5DIR)$(DIRSEP)$(fidoroute_MAN5PAGES).gz
endif

ifdef DOCDIR
    fidoroute_doc_en = Readme.en
    fidoroute_doc_ru = Readme.ru
    fidoroute_doc_en_SRC = $(fidoroute_DOCDIR)$(fidoroute_doc_en)
    fidoroute_doc_ru_SRC = $(fidoroute_DOCDIR)$(fidoroute_doc_ru)
    fidoroute_doc_en_DST = $(DOCDIR_DST)fidoroute_en.txt
    fidoroute_doc_ru_DST = $(DOCDIR_DST)fidoroute_ru.txt
endif

.PHONY: fidoroute_build fidoroute_install fidoroute_uninstall fidoroute_clean \
        fidoroute_distclean fidoroute_depend fidoroute_install_doc \
        fidoroute_clean_OBJ fidoroute_main_distclean

fidoroute_build: $(fidoroute_TARGET_BLD) $(fidoroute_MAN1BLD) $(fidoroute_MAN5BLD) ;


# Build application
$(fidoroute_TARGET_BLD): $(fidoroute_OBJS) | do_not_run_make_as_root
	$(CXX) $(LFLAGS) $(EXENAMEFLAG) $@ $^

# Compile .cpp file
$(fidoroute_OBJS): $(fidoroute_SRC) | $(fidoroute_OBJDIR)
	$(CXX) $(fidoroute_CFLAGS) $(fidoroute_CDEFS) -o $@ $<

$(fidoroute_OBJDIR): | $(fidoroute_BUILDDIR)
	[ -d $@ ] || $(MKDIR) $(MKDIROPT) $@

$(fidoroute_BUILDDIR): | do_not_run_make_as_root
	[ -d $@ ] || $(MKDIR) $(MKDIROPT) $@


# Build man pages
ifdef MAN1DIR
    $(fidoroute_MAN1BLD): $(fidoroute_MANDIR)$(fidoroute_MAN1PAGES) | $(fidoroute_BUILDDIR) do_not_run_make_as_root
	gzip -c $< > $@
else
    $(fidoroute_MAN1BLD): ;
endif
ifdef MAN5DIR
    $(fidoroute_MAN5BLD): $(fidoroute_MANDIR)$(fidoroute_MAN5PAGES) | $(fidoroute_BUILDDIR) do_not_run_make_as_root
	gzip -c $< > $@
else
    $(fidoroute_MAN5BLD): ;
endif

# Install
ifneq ($(MAKECMDGOALS), install)
    fidoroute_install: ;
else
    fidoroute_install: $(fidoroute_TARGET_DST) fidoroute_install_doc \
                       fidoroute_install_man1 fidoroute_install_man5 ;
endif

$(fidoroute_TARGET_DST): $(fidoroute_TARGET_BLD) | $(DESTDIR)$(BINDIR)
	$(INSTALL) $(IBOPT) $< $(DESTDIR)$(BINDIR); \
	$(TOUCH) "$@"

ifndef MAN1DIR
    fidoroute_install_man1: ;
else
    fidoroute_install_man1: $(fidoroute_MAN1DST)

    $(fidoroute_MAN1DST): $(fidoroute_MAN1BLD) | $(DESTDIR)$(MAN1DIR)
	$(INSTALL) $(IMOPT) $< $(DESTDIR)$(MAN1DIR); $(TOUCH) "$@"
endif
ifndef MAN5DIR
    fidoroute_install_man5: ;
else
    fidoroute_install_man5: $(fidoroute_MAN5DST)

    $(fidoroute_MAN5DST): $(fidoroute_MAN5BLD) | $(DESTDIR)$(MAN5DIR)
	$(INSTALL) $(IMOPT) $< $(DESTDIR)$(MAN5DIR); $(TOUCH) "$@"

$(DESTDIR)$(MAN5DIR): | $(DESTDIR)$(MANDIR)
	[ -d $@ ] || $(MKDIR) $(MKDIROPT) $@
endif


ifndef DOCDIR
    fidoroute_install_doc: ;
else
    fidoroute_install_doc: $(fidoroute_doc_en_DST) $(fidoroute_doc_ru_DST) ;

    $(fidoroute_doc_en_DST): $(fidoroute_doc_en_SRC) | $(DOCDIR_DST)
		$(INSTALL) $(IMOPT) $< $@; \
		$(TOUCH) $@

    $(fidoroute_doc_ru_DST): $(fidoroute_doc_ru_SRC) | $(DOCDIR_DST)
		$(INSTALL) $(IMOPT) $< $@; \
		$(TOUCH) $@
endif

# Clean
fidoroute_clean: fidoroute_clean_OBJ
	-[ -d "$(fidoroute_OBJDIR)" ] && $(RMDIR) $(fidoroute_OBJDIR) || true

fidoroute_clean_OBJ:
	-$(RM) $(RMOPT) $(fidoroute_OBJDIR)*


# Distclean
fidoroute_distclean: fidoroute_main_distclean
	-[ -d "$(fidoroute_BUILDDIR)" ] && $(RMDIR) $(fidoroute_BUILDDIR) || true

fidoroute_main_distclean: fidoroute_clean
	-$(RM) $(RMOPT) $(fidoroute_TARGET_BLD)
ifdef MAN1DIR
	-$(RM) $(RMOPT) $(fidoroute_MAN1BLD)
endif
ifdef MAN5DIR
	-$(RM) $(RMOPT) $(fidoroute_MAN5BLD)
endif


# Uninstall
fidoroute_uninstall:
	-$(RM) $(RMOPT) $(fidoroute_TARGET_DST)
ifdef MAN1DIR
	-$(RM) $(RMOPT) $(fidoroute_MAN1DST)
endif
ifdef MAN5DIR
	-$(RM) $(RMOPT) $(fidoroute_MAN5DST)
endif
ifdef DOCDIR
	-$(RM) $(RMOPT) $(fidoroute_doc_en_DST)
	-$(RM) $(RMOPT) $(fidoroute_doc_ru_DST)
endif


# Depend
fidoroute_depend: ;

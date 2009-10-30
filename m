From: Bastian Blank <bastian@waldi.eu.org>
Date: Fri, 30 Oct 2009 14:36:28 +0100
Subject: [PATCH] debian: move owner and group setup, use sane permissions
Message-ID: <20091030133627.GA20856@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Move the OWNER and GROUP setup into the configure script. Move
permission definitions into the make setup, use sane values by default.

--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -165,22 +165,17 @@
 endif
 
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)
 	$(LN_S) -f liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) $(libdir)/liblvm2cmd.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2cmd.h \
-		$(includedir)/lvm2cmd.h
+	$(INSTALL_DATA) -D $(srcdir)/lvm2cmd.h $(includedir)/lvm2cmd.h
 
 install_cmdlib_static: liblvm2cmd-static.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2cmd.a.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2cmd.a.$(LIB_VERSION)
 	$(LN_S) -f liblvm2cmd.a.$(LIB_VERSION) $(libdir)/liblvm2cmd.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2cmd.h \
-		$(includedir)/lvm2cmd.h
+	$(INSTALL) -D $(srcdir)/lvm2cmd.h $(includedir)/lvm2cmd.h
 
 install_tools_dynamic: lvm .commands
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm \
-		$(sbindir)/lvm
+	$(INSTALL) -D lvm $(sbindir)/lvm
 	@echo Creating symbolic links for individual commands in $(sbindir)
 	@( \
 		for v in `cat $(srcdir)/.commands`; do \
@@ -190,14 +185,13 @@
 	)
 
 install_tools_static: lvm.static
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(staticdir)/lvm.static
+	$(INSTALL) -D $< $(staticdir)/$<
 
 install_dmsetup_dynamic: dmsetup
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL) -D $< $(sbindir)/$<
 
 install_dmsetup_static: dmsetup.static
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL) -D $< $(sbindir)/$<
 
 install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
 
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -98,8 +98,8 @@
 .PHONY: install_clvmd
 
 install_clvmd: $(TARGETS)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) clvmd \
-		$(usrsbindir)/clvmd
+	$(INSTALL) -D clvmd \
+		$(sbindir)/clvmd
 
 install: $(INSTALL_TARGETS)
 
--- a/lib/format1/Makefile.in
+++ b/lib/format1/Makefile.in
@@ -32,7 +32,6 @@
 include ../../make.tmpl
 
 install: liblvm2format1.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2format1.so.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2format1.so.$(LIB_VERSION)
 	$(LN_S) -f liblvm2format1.so.$(LIB_VERSION) $(libdir)/liblvm2format1.so
 
--- a/lib/format_pool/Makefile.in
+++ b/lib/format_pool/Makefile.in
@@ -29,8 +29,7 @@
 include ../../make.tmpl
 
 install: liblvm2formatpool.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2formatpool.so.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2formatpool.so.$(LIB_VERSION)
 	$(LN_S) -f liblvm2formatpool.so.$(LIB_VERSION) \
 		$(libdir)/liblvm2formatpool.so
 
--- a/lib/locking/Makefile.in
+++ b/lib/locking/Makefile.in
@@ -25,8 +25,7 @@
 include ../../make.tmpl
 
 install install_cluster: liblvm2clusterlock.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2clusterlock.so.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2clusterlock.so.$(LIB_VERSION)
 	$(LN_S) -f liblvm2clusterlock.so.$(LIB_VERSION) \
 		$(libdir)/liblvm2clusterlock.so
 
--- a/lib/mirror/Makefile.in
+++ b/lib/mirror/Makefile.in
@@ -25,7 +25,6 @@
 include ../../make.tmpl
 
 install: liblvm2mirror.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2mirror.so.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2mirror.so.$(LIB_VERSION)
 	$(LN_S) -f liblvm2mirror.so.$(LIB_VERSION) $(libdir)/liblvm2mirror.so
 
--- a/lib/snapshot/Makefile.in
+++ b/lib/snapshot/Makefile.in
@@ -25,8 +25,7 @@
 include ../../make.tmpl
 
 install: liblvm2snapshot.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2snapshot.so.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2snapshot.so.$(LIB_VERSION)
 	$(LN_S) -f liblvm2snapshot.so.$(LIB_VERSION) \
 		$(libdir)/liblvm2snapshot.so
 
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -63,14 +63,14 @@
 	@for f in $(MAN8); \
 	do \
 	   $(RM) $(MAN8DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
+	   $(INSTALL_DATA) -D $$f $(MAN8DIR)/$$f; \
 	done
 
 	@echo "Installing $(MAN5) in $(MAN5DIR)"
 	@for f in $(MAN5); \
 	do \
 	   $(RM) $(MAN5DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN5DIR)/$$f; \
+	   $(INSTALL_DATA) -D $$f $(MAN5DIR)/$$f; \
 	done
 
 install_cluster:
@@ -78,7 +78,7 @@
 	@for f in $(MAN8CLUSTER); \
 	do \
 	   $(RM) $(MAN8DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
+	   $(INSTALL_DATA) -D $$f $(MAN8DIR)/$$f; \
 	done
 
 install_device-mapper:
@@ -86,7 +86,7 @@
 	@for f in $(MAN8DM); \
 	do \
 	   $(RM) $(MAN8DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
+	   $(INSTALL_DATA) -D $$f $(MAN8DIR)/$$f; \
 	done
 
 install: install_lvm2 install_device-mapper
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -73,7 +69,7 @@
 install_device-mapper: install
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper.h \
+	$(INSTALL_DATA) $(srcdir)/libdevmapper.h \
 		$(includedir)/libdevmapper.h
 
 install_dynamic: install_ at interface@
@@ -81,19 +77,16 @@
 		$(libdir)/libdevmapper.$(LIB_SUFFIX)
 
 install_static: install_@interface@_static
-	$(LN_S) -f libdevmapper.a.$(LIB_VERSION_DM) $(libdir)/libdevmapper.a
 
 install_ioctl: ioctl/libdevmapper.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
+	$(INSTALL) -D $< $(libdir)/libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
 
 install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper.pc \
+	$(INSTALL_DATA) -D libdevmapper.pc \
 		$(usrlibdir)/pkgconfig/devmapper.pc
 
 install_ioctl_static: ioctl/libdevmapper.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper.a.$(LIB_VERSION_DM)
+	$(INSTALL) -D $< $(usrlibdir)/libdevmapper.a
 
 $(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION_DM): $(interface)/%.$(LIB_SUFFIX)
 	rm -f $@
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -73,31 +73,29 @@
 endif
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper-event.h \
+	$(INSTALL_DATA) $(srcdir)/libdevmapper-event.h \
 		$(includedir)/libdevmapper-event.h
 
 install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper-event.pc \
+	$(INSTALL_DATA) libdevmapper-event.pc \
 		$(usrlibdir)/pkgconfig/devmapper-event.pc
 
 install_lib_dynamic: libdevmapper-event.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper-event.$(LIB_SUFFIX).$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/libdevmapper-event.$(LIB_SUFFIX).$(LIB_VERSION)
 	$(LN_S) -f libdevmapper-event.$(LIB_SUFFIX).$(LIB_VERSION) \
 		$(libdir)/libdevmapper-event.$(LIB_SUFFIX)
 
 install_lib_static: libdevmapper-event.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/libdevmapper-event.a.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/libdevmapper-event.a.$(LIB_VERSION)
 	$(LN_S) -f libdevmapper-event.a.$(LIB_VERSION) $(libdir)/libdevmapper-event.a
 
 install_lib: $(INSTALL_LIB_TARGETS)
 
 install_dmeventd_dynamic: dmeventd
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL) -D $< $(sbindir)/$<
 
 install_dmeventd_static: dmeventd.static
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL) -D $< $(sbindir)/$<
 
 install_dmeventd: $(INSTALL_DMEVENTD_TARGETS)
 
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -35,7 +35,7 @@
 LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
 
 install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(libdir)/$<.$(LIB_VERSION)
 	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
 
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -35,7 +35,7 @@
 LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
 
 install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(libdir)/$<.$(LIB_VERSION)
 	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
 
--- a/doc/Makefile.in
+++ b/doc/Makefile.in
@@ -24,7 +24,7 @@
 install_lvm2: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
 		echo "Installing $(CONFSRC) as $(confdir)/$(CONFDEST)"; \
-		@INSTALL@ -D $(OWNER) $(GROUP) -m 644 $< \
+		$(INSTALL_DATA) -D $< \
 			$(confdir)/$(CONFDEST); \
 	fi
 
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -21,6 +21,7 @@
 RANLIB = @RANLIB@
 SHELL = /bin/sh
 INSTALL = @INSTALL@
+INSTALL_DATA = @INSTALL@ -m 644
 MKDIR_P = @MKDIR_P@
 MSGFMT = @MSGFMT@
 LCOV = @LCOV@
@@ -56,11 +57,6 @@
 interface = @interface@
 interfacedir = $(top_srcdir)/libdm/$(interface)
 
-# setup misc variables
-# define the ownership variables for the binaries and man pages
-OWNER = @OWNER@
-GROUP = @GROUP@
-
 # The number of jobs to run, if blank, defaults to the make standard
 ifndef MAKEFLAGS
 MAKEFLAGS = @JOBS@
@@ -107,9 +103,6 @@
 #CFLAGS += -pg
 #LDFLAGS += -pg
 
-STRIP=
-#STRIP = -s
-
 LVM_VERSION := $(shell cat $(top_srcdir)/VERSION)
 
 LIB_VERSION_LVM := $(shell cat $(top_srcdir)/VERSION | \
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -19,13 +19,10 @@
 include ../make.tmpl
 
 install:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/lvm_dump.sh \
-		$(sbindir)/lvmdump
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/vgimportclone.sh \
-		$(sbindir)/vgimportclone
+	$(INSTALL) -D $(srcdir)/lvm_dump.sh $(sbindir)/lvmdump
+	$(INSTALL) -D $(srcdir)/vgimportclone.sh $(sbindir)/vgimportclone
 ifeq ("@FSADM@", "yes")
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/fsadm.sh \
-		$(sbindir)/fsadm
+	$(INSTALL) -D $(srcdir)/fsadm.sh $(sbindir)/fsadm
 endif
 
 install_lvm2: install
--- a/po/Makefile.in
+++ b/po/Makefile.in
@@ -54,13 +54,13 @@
 	@echo Installing translation files in $(localedir)
 	@( \
 		for lang in $(LANGS); do \
-			$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $$lang.mo \
+			$(INSTALL_DATA) -D $$lang.mo \
 			    $(localedir)/$$lang/LC_MESSAGES/lvm2.mo;\
 	  done; \
 	)
 	@( \
 		for lang in $(LANGS); do \
-			$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $$lang.mo \
+			$(INSTALL_DATA) -D $$lang.mo \
 			    $(localedir)/$$lang/LC_MESSAGES/device-mapper.mo;\
 	  done; \
 	)
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -67,22 +67,19 @@
 install: $(INSTALL_TYPE) install_include
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2app.h $(includedir)/lvm2app.h
+	$(INSTALL_DATA) -D $(srcdir)/lvm2app.h $(includedir)/lvm2app.h
 
 install_dynamic: $(LIB_SHARED)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$(LIB_SHARED).$(LIB_VERSION_APP)
+	$(INSTALL) -D $< $(libdir)/$(LIB_SHARED).$(LIB_VERSION_APP)
 	$(LN_S) -f $(LIB_SHARED).$(LIB_VERSION_APP) \
 		$(libdir)/$(LIB_SHARED)
 
 install_static: $(LIB_STATIC)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/$(LIB_STATIC).$(LIB_VERSION_APP)
+	$(INSTALL) -D $< $(libdir)/$(LIB_STATIC).$(LIB_VERSION_APP)
 	$(LN_S) -f $(LIB_STATIC).$(LIB_VERSION_APP) $(libdir)/$(LIB_STATIC)
 
 install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(LIB_NAME).pc \
-		$(usrlibdir)/pkgconfig/lvm2app.pc
+	$(INSTALL_DATA) -D $(LIB_NAME).pc $(usrlibdir)/pkgconfig/lvm2app.pc
 
 liblvm.cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -36,5 +36,4 @@
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
 install: $(TARGETS)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) cmirrord \
-		$(usrsbindir)/cmirrord
+	$(INSTALL) -D cmirrord $(usrsbindir)/cmirrord
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -32,7 +32,7 @@
 	@for f in $(LVM_RULES); \
 	do \
 	   $(RM) $(udevdir)/$$f; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $(srcdir)/$$f $(udevdir)/$$f; \
+	   $(INSTALL_DATA) -c -D $(srcdir)/$$f $(udevdir)/$$f; \
 	done
 
 install_device-mapper: $(DM_RULES)
@@ -40,7 +40,7 @@
 	@for f in $(DM_RULES); \
 	do \
 	   $(RM) $(udevdir)/$$f; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $(srcdir)/$$f $(udevdir)/$$f; \
+	   $(INSTALL_DATA) -c -D $(srcdir)/$$f $(udevdir)/$$f; \
 	done
 
 install: install_lvm2 install_device-mapper
--- a/configure.in
+++ b/configure.in
@@ -144,28 +144,25 @@
 ################################################################################
 dnl -- Setup the ownership of the files
 AC_MSG_CHECKING(file owner)
-OWNER=""
-
 AC_ARG_WITH(user,
   [  --with-user=USER        Set the owner of installed files [[USER=]] ],
   [ OWNER="$withval" ])
 AC_MSG_RESULT($OWNER)
 
 if test x$OWNER != x; then
-	OWNER="-o $OWNER"
+	INSTALL="$INSTALL -o $OWNER"
 fi
 
 ################################################################################
 dnl -- Setup the group ownership of the files
 AC_MSG_CHECKING(group owner)
-GROUP=""
 AC_ARG_WITH(group,
   [  --with-group=GROUP      Set the group owner of installed files [[GROUP=]] ],
   [ GROUP="$withval" ])
 AC_MSG_RESULT($GROUP)
 
 if test x$GROUP != x; then
-	GROUP="-g $GROUP"
+	INSTALL="$INSTALL -g $GROUP"
 fi
 
 ################################################################################
@@ -1092,7 +1089,6 @@
 AC_SUBST(DM_LIB_VERSION)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(FSADM)
-AC_SUBST(GROUP)
 AC_SUBST(GULM_CFLAGS)
 AC_SUBST(GULM_LIBS)
 AC_SUBST(HAVE_LIBDL)
@@ -1116,7 +1112,6 @@
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
 AC_SUBST(MSGFMT)
-AC_SUBST(OWNER)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(QUORUM_CFLAGS)
-- 
Each kiss is as the first.
		-- Miramanee, Kirk's wife, "The Paradise Syndrome",
		   stardate 4842.6



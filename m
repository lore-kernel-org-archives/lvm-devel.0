From: Fabio M. Di Nitto <fabbione@fabbione.net>
Date: Thu,  8 Oct 2009 14:49:18 +0200
Subject: [PATCH 11/11] debian: drop concept of OWNER/GROUP and let install do it's job for permissions
In-Reply-To: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
References: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
Message-ID: <f3faad08f59b098ed7ae0019db660d0e15797cbe.1255002311.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Fabio M. Di Nitto <fdinitto@redhat.com>

remove owner and group definitions and install anything writable as mendated
by the debian policy

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 ad871fd... 6b93b77... M	configure.in
:100644 100644 dad568e... a6ecfe9... M	daemons/clvmd/Makefile.in
:100644 100644 debab27... fa08f03... M	daemons/cmirrord/Makefile.in
:100644 100644 2a14ba6... bf71fdb... M	daemons/dmeventd/Makefile.in
:100644 100644 581e5ec... b9f6974... M	daemons/dmeventd/plugins/mirror/Makefile.in
:100644 100644 823ca3f... a07558e... M	daemons/dmeventd/plugins/snapshot/Makefile.in
:100644 100644 b4689af... f589489... M	doc/Makefile.in
:100644 100644 e12cc6f... f70adf7... M	lib/format1/Makefile.in
:100644 100644 d67c982... 36230f4... M	lib/format_pool/Makefile.in
:100644 100644 584c8d6... 8fa8eb6... M	lib/locking/Makefile.in
:100644 100644 d5b678b... b7076f7... M	lib/mirror/Makefile.in
:100644 100644 3f960fb... 3de0373... M	lib/snapshot/Makefile.in
:100644 100644 191e2ae... dea2771... M	libdm/Makefile.in
:100644 100644 d9afc40... 5b37426... M	liblvm/Makefile.in
:100644 100644 56dfa8b... e4acf88... M	make.tmpl.in
:100644 100644 f0acb84... 647488d... M	man/Makefile.in
:100644 100644 c9f8400... 12d4489... M	po/Makefile.in
:100644 100644 33a10c1... 677f965... M	scripts/Makefile.in
:100644 100644 4f8be22... bd834b9... M	tools/Makefile.in
:100644 100644 341479f... 8c71c2b... M	udev/Makefile.in
 configure.in                                  |   29 -------------------------
 daemons/clvmd/Makefile.in                     |    4 +-
 daemons/cmirrord/Makefile.in                  |    2 +-
 daemons/dmeventd/Makefile.in                  |   10 ++++----
 daemons/dmeventd/plugins/mirror/Makefile.in   |    2 +-
 daemons/dmeventd/plugins/snapshot/Makefile.in |    2 +-
 doc/Makefile.in                               |    2 +-
 lib/format1/Makefile.in                       |    3 +-
 lib/format_pool/Makefile.in                   |    3 +-
 lib/locking/Makefile.in                       |    3 +-
 lib/mirror/Makefile.in                        |    3 +-
 lib/snapshot/Makefile.in                      |    3 +-
 libdm/Makefile.in                             |   16 ++++---------
 liblvm/Makefile.in                            |    8 +++---
 make.tmpl.in                                  |    9 +-------
 man/Makefile.in                               |    8 +++---
 po/Makefile.in                                |    4 +-
 scripts/Makefile.in                           |    6 ++--
 tools/Makefile.in                             |   16 +++++++-------
 udev/Makefile.in                              |    4 +-
 20 files changed, 45 insertions(+), 92 deletions(-)

diff --git a/configure.in b/configure.in
index ad871fd..6b93b77 100644
--- a/configure.in
+++ b/configure.in
@@ -141,33 +141,6 @@ dnl -- Prefix is /usr by default, the exec_prefix default is setup later
 AC_PREFIX_DEFAULT(/usr)
 
 ################################################################################
-dnl -- Setup the ownership of the files
-AC_MSG_CHECKING(file owner)
-OWNER="root"
-
-AC_ARG_WITH(user,
-  [  --with-user=USER        Set the owner of installed files [[USER=root]] ],
-  [ OWNER="$withval" ])
-AC_MSG_RESULT($OWNER)
-
-if test x$OWNER != x; then
-	OWNER="-o $OWNER"
-fi
-
-################################################################################
-dnl -- Setup the group ownership of the files
-AC_MSG_CHECKING(group owner)
-GROUP="root"
-AC_ARG_WITH(group,
-  [  --with-group=GROUP      Set the group owner of installed files [[GROUP=root]] ],
-  [ GROUP="$withval" ])
-AC_MSG_RESULT($GROUP)
-
-if test x$GROUP != x; then
-	GROUP="-g $GROUP"
-fi
-
-################################################################################
 dnl -- Setup device node ownership
 AC_MSG_CHECKING(device node uid)
 
@@ -1023,7 +996,6 @@ AC_SUBST(DM_IOCTLS)
 AC_SUBST(DM_LIB_VERSION)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(FSADM)
-AC_SUBST(GROUP)
 AC_SUBST(GULM_CFLAGS)
 AC_SUBST(GULM_LIBS)
 AC_SUBST(HAVE_LIBDL)
@@ -1049,7 +1021,6 @@ AC_SUBST(LVM_RELEASE)
 AC_SUBST(LVM_RELEASE_DATE)
 AC_SUBST(MIRRORS)
 AC_SUBST(MSGFMT)
-AC_SUBST(OWNER)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
 AC_SUBST(QUORUM_CFLAGS)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index dad568e..a6ecfe9 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -98,8 +98,8 @@ clvmd: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
 .PHONY: install_clvmd
 
 install_clvmd: $(TARGETS)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) clvmd \
-		$(usrsbindir)/clvmd
+	$(INSTALL) -D clvmd \
+		$(sbindir)/clvmd
 
 install: $(INSTALL_TARGETS)
 
diff --git a/daemons/cmirrord/Makefile.in b/daemons/cmirrord/Makefile.in
index debab27..fa08f03 100644
--- a/daemons/cmirrord/Makefile.in
+++ b/daemons/cmirrord/Makefile.in
@@ -36,5 +36,5 @@ cmirrord: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
 		$(LVMLIBS) $(LMLIBS) $(LIBS)
 
 install: $(TARGETS)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) cmirrord \
+	$(INSTALL) -D cmirrord \
 		$(usrsbindir)/cmirrord
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index 2a14ba6..bf71fdb 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -66,24 +66,24 @@ install: $(INSTALL_TYPE) install_include install_dmeventd
 install_device-mapper: $(INSTALL_TYPE) install_include install_dmeventd
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper-event.h \
+	$(INSTALL) -D -m 644 $(srcdir)/libdevmapper-event.h \
 		$(includedir)/libdevmapper-event.h
 
 install_dynamic: libdevmapper-event.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(libdir)/libdevmapper-event.$(LIB_SUFFIX).$(LIB_VERSION)
 	$(LN_S) -f libdevmapper-event.$(LIB_SUFFIX).$(LIB_VERSION) \
 		$(libdir)/libdevmapper-event.$(LIB_SUFFIX)
 
 install_dmeventd: dmeventd
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL) -D $< $(sbindir)/$<
 
 install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 libdevmapper-event.pc \
+	$(INSTALL) -D -m 644 libdevmapper-event.pc \
 		$(usrlibdir)/pkgconfig/devmapper-event.pc
 
 install_static: libdevmapper-event.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(libdir)/libdevmapper-event.a.$(LIB_VERSION)
 	$(LN_S) -f libdevmapper-event.a.$(LIB_VERSION) $(libdir)/libdevmapper-event.a
 
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index 581e5ec..b9f6974 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -34,7 +34,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 include $(top_builddir)/make.tmpl
 
 install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(libdir)/$<.$(LIB_VERSION)
 	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
 
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index 823ca3f..a07558e 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -34,7 +34,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 include $(top_builddir)/make.tmpl
 
 install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(libdir)/$<.$(LIB_VERSION)
 	$(LN_S) -f $<.$(LIB_VERSION) $(libdir)/$<
 
diff --git a/doc/Makefile.in b/doc/Makefile.in
index b4689af..f589489 100644
--- a/doc/Makefile.in
+++ b/doc/Makefile.in
@@ -24,7 +24,7 @@ include ../make.tmpl
 install_lvm2: $(CONFSRC)
 	@if [ ! -e $(confdir)/$(CONFDEST) ]; then \
 		echo "Installing $(CONFSRC) as $(confdir)/$(CONFDEST)"; \
-		@INSTALL@ -D $(OWNER) $(GROUP) -m 644 $< \
+		@INSTALL@ -D $< \
 			$(confdir)/$(CONFDEST); \
 	fi
 
diff --git a/lib/format1/Makefile.in b/lib/format1/Makefile.in
index e12cc6f..f70adf7 100644
--- a/lib/format1/Makefile.in
+++ b/lib/format1/Makefile.in
@@ -32,7 +32,6 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 include ../../make.tmpl
 
 install: liblvm2format1.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2format1.so.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2format1.so.$(LIB_VERSION)
 	$(LN_S) -f liblvm2format1.so.$(LIB_VERSION) $(libdir)/liblvm2format1.so
 
diff --git a/lib/format_pool/Makefile.in b/lib/format_pool/Makefile.in
index d67c982..36230f4 100644
--- a/lib/format_pool/Makefile.in
+++ b/lib/format_pool/Makefile.in
@@ -29,8 +29,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 include ../../make.tmpl
 
 install: liblvm2formatpool.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2formatpool.so.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2formatpool.so.$(LIB_VERSION)
 	$(LN_S) -f liblvm2formatpool.so.$(LIB_VERSION) \
 		$(libdir)/liblvm2formatpool.so
 
diff --git a/lib/locking/Makefile.in b/lib/locking/Makefile.in
index 584c8d6..8fa8eb6 100644
--- a/lib/locking/Makefile.in
+++ b/lib/locking/Makefile.in
@@ -25,8 +25,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 include ../../make.tmpl
 
 install install_cluster: liblvm2clusterlock.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2clusterlock.so.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2clusterlock.so.$(LIB_VERSION)
 	$(LN_S) -f liblvm2clusterlock.so.$(LIB_VERSION) \
 		$(libdir)/liblvm2clusterlock.so
 
diff --git a/lib/mirror/Makefile.in b/lib/mirror/Makefile.in
index d5b678b..b7076f7 100644
--- a/lib/mirror/Makefile.in
+++ b/lib/mirror/Makefile.in
@@ -25,7 +25,6 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 include ../../make.tmpl
 
 install: liblvm2mirror.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2mirror.so.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2mirror.so.$(LIB_VERSION)
 	$(LN_S) -f liblvm2mirror.so.$(LIB_VERSION) $(libdir)/liblvm2mirror.so
 
diff --git a/lib/snapshot/Makefile.in b/lib/snapshot/Makefile.in
index 3f960fb..3de0373 100644
--- a/lib/snapshot/Makefile.in
+++ b/lib/snapshot/Makefile.in
@@ -25,8 +25,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 include ../../make.tmpl
 
 install: liblvm2snapshot.so
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
-		$(libdir)/liblvm2snapshot.so.$(LIB_VERSION)
+	$(INSTALL) -D $< $(libdir)/liblvm2snapshot.so.$(LIB_VERSION)
 	$(LN_S) -f liblvm2snapshot.so.$(LIB_VERSION) \
 		$(libdir)/liblvm2snapshot.so
 
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 191e2ae..dea2771 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -58,11 +58,7 @@ device-mapper: all
 	install_ioctl install_ioctl_static \
 	install_pkgconfig
 
-INSTALL_TYPE = install_dynamic
-
-ifeq ("@STATIC_LINK@", "yes")
-  INSTALL_TYPE += install_static
-endif
+INSTALL_TYPE = install_dynamic install_static
 
 ifeq ("@PKGCONFIG@", "yes")
   INSTALL_TYPE += install_pkgconfig
@@ -73,7 +69,7 @@ install: $(INSTALL_TYPE) install_include
 install_device-mapper: install
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/libdevmapper.h \
+	$(INSTALL_DATA) -D $(srcdir)/libdevmapper.h \
 		$(includedir)/libdevmapper.h
 
 install_dynamic: install_ at interface@
@@ -81,19 +77,17 @@ install_dynamic: install_ at interface@
 		$(libdir)/libdevmapper.$(LIB_SUFFIX)
 
 install_static: install_@interface@_static
-	$(LN_S) -f libdevmapper.a.$(LIB_VERSION_DM) $(libdir)/libdevmapper.a
 
 install_ioctl: ioctl/libdevmapper.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(libdir)/libdevmapper.$(LIB_SUFFIX).$(LIB_VERSION_DM)
 
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
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index d9afc40..5b37426 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -67,21 +67,21 @@ endif
 install: $(INSTALL_TYPE) install_include
 
 install_include:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2app.h $(includedir)/lvm2app.h
+	$(INSTALL_DATA) -D $(srcdir)/lvm2app.h $(includedir)/lvm2app.h
 
 install_dynamic: $(LIB_SHARED)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(libdir)/$(LIB_SHARED).$(LIB_VERSION_APP)
 	$(LN_S) -f $(LIB_SHARED).$(LIB_VERSION_APP) \
 		$(libdir)/$(LIB_SHARED)
 
 install_static: $(LIB_STATIC)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(libdir)/$(LIB_STATIC).$(LIB_VERSION_APP)
 	$(LN_S) -f $(LIB_STATIC).$(LIB_VERSION_APP) $(libdir)/$(LIB_STATIC)
 
 install_pkgconfig:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(LIB_NAME).pc \
+	$(INSTALL_DATA) -D $(LIB_NAME).pc \
 		$(usrlibdir)/pkgconfig/lvm2app.pc
 
 liblvm.cflow: $(SOURCES)
diff --git a/make.tmpl.in b/make.tmpl.in
index 56dfa8b..e4acf88 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -21,6 +21,7 @@ CC = @CC@
 RANLIB = @RANLIB@
 SHELL = /bin/sh
 INSTALL = @INSTALL@
+INSTALL_DATA = $(INSTALL) -m 644
 MKDIR_P = @MKDIR_P@
 MSGFMT = @MSGFMT@
 LCOV = @LCOV@
@@ -56,11 +57,6 @@ udevdir = $(DESTDIR)@udevdir@
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
@@ -106,9 +102,6 @@ endif
 
 #CFLAGS += -pg
 
-STRIP=
-#STRIP = -s
-
 LVM_VERSION := $(shell cat $(top_srcdir)/VERSION)
 
 LIB_VERSION_LVM := $(shell cat $(top_srcdir)/VERSION | \
diff --git a/man/Makefile.in b/man/Makefile.in
index f0acb84..647488d 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -61,14 +61,14 @@ install_lvm2:
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
@@ -76,7 +76,7 @@ install_cluster:
 	@for f in $(MAN8CLUSTER); \
 	do \
 	   $(RM) $(MAN8DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
+	   $(INSTALL_DATA) -D $$f $(MAN8DIR)/$$f; \
 	done
 
 install_device-mapper:
@@ -84,7 +84,7 @@ install_device-mapper:
 	@for f in $(MAN8DM); \
 	do \
 	   $(RM) $(MAN8DIR)/$$f; \
-	   @INSTALL@ -D $(OWNER) $(GROUP) -m 444 $$f $(MAN8DIR)/$$f; \
+	   $(INSTALL_DATA) -D $$f $(MAN8DIR)/$$f; \
 	done
 
 install: install_lvm2 install_device-mapper
diff --git a/po/Makefile.in b/po/Makefile.in
index c9f8400..12d4489 100644
--- a/po/Makefile.in
+++ b/po/Makefile.in
@@ -54,13 +54,13 @@ install: $(TARGETS)
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
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 33a10c1..677f965 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -19,12 +19,12 @@ VPATH = @srcdir@
 include ../make.tmpl
 
 install:
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/lvm_dump.sh \
+	$(INSTALL) -D $(srcdir)/lvm_dump.sh \
 		$(sbindir)/lvmdump
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/vgimportclone.sh \
+	$(INSTALL) -D $(srcdir)/vgimportclone.sh \
 		$(sbindir)/vgimportclone
 ifeq ("@FSADM@", "yes")
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(srcdir)/fsadm.sh \
+	$(INSTALL) -D $(srcdir)/fsadm.sh \
 		$(sbindir)/fsadm
 endif
 
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 4f8be22..bd834b9 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -165,21 +165,21 @@ cflow: lvm.cflow lvm.xref lvm.tree lvm.rtree lvm.rxref
 endif
 
 install_cmdlib_dynamic: liblvm2cmd.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(libdir)/liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)
 	$(LN_S) -f liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) $(libdir)/liblvm2cmd.$(LIB_SUFFIX)
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2cmd.h \
+	$(INSTALL_DATA) -D $(srcdir)/lvm2cmd.h \
 		$(includedir)/lvm2cmd.h
 
 install_cmdlib_static: liblvm2cmd-static.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(libdir)/liblvm2cmd.a.$(LIB_VERSION)
 	$(LN_S) -f liblvm2cmd.a.$(LIB_VERSION) $(libdir)/liblvm2cmd.a
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 444 $(srcdir)/lvm2cmd.h \
+	$(INSTALL_DATA) -D $(srcdir)/lvm2cmd.h \
 		$(includedir)/lvm2cmd.h
 
 install_tools_dynamic: lvm .commands
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm \
+	$(INSTALL) -D lvm \
 		$(sbindir)/lvm
 	@echo Creating symbolic links for individual commands in $(sbindir)
 	@( \
@@ -190,14 +190,14 @@ install_tools_dynamic: lvm .commands
 	)
 
 install_tools_static: lvm.static
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
+	$(INSTALL) -D $< \
 		$(staticdir)/lvm.static
 
 install_dmsetup_dynamic: dmsetup
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL) -D $< $(sbindir)/$<
 
 install_dmsetup_static: dmsetup.static
-	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< $(sbindir)/$<
+	$(INSTALL) -D $< $(sbindir)/$<
 
 install_device-mapper: $(INSTALL_DMSETUP_TARGETS)
 
diff --git a/udev/Makefile.in b/udev/Makefile.in
index 341479f..8c71c2b 100644
--- a/udev/Makefile.in
+++ b/udev/Makefile.in
@@ -32,7 +32,7 @@ install_lvm2: $(LVM_RULES)
 	@for f in $(LVM_RULES); \
 	do \
 	   $(RM) $(udevdir)/$$f; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $(srcdir)/$$f $(udevdir)/$$f; \
+	   $(INSTALL_DATA) -c -D  $(srcdir)/$$f $(udevdir)/$$f; \
 	done
 
 install_device-mapper: $(DM_RULES)
@@ -40,7 +40,7 @@ install_device-mapper: $(DM_RULES)
 	@for f in $(DM_RULES); \
 	do \
 	   $(RM) $(udevdir)/$$f; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $(srcdir)/$$f $(udevdir)/$$f; \
+	   $(INSTALL_DATA) -c -D $(srcdir)/$$f $(udevdir)/$$f; \
 	done
 
 install: install_lvm2 install_device-mapper
-- 
1.5.4.3



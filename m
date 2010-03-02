From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Mar 2010 13:07:24 +0100
Subject: [PATCH 6/9] Pthread linking change
In-Reply-To: <cover.1267529065.git.zkabelac@redhat.com>
References: <cover.1267529065.git.zkabelac@redhat.com>
Message-ID: <fe91ecef7b67e15e380a09ebf0a45de4902c5a6c.1267529065.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Create new substituted variable PTHREAD_LIBS and link this library
only with tools/libs which really needs it - i.e. dmeventd.

Check for libpthread only for builds with clvmd or dmeventd.

Remove variable LIB_PTHREAD

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure.in                                  |    9 ++++++++-
 daemons/clvmd/Makefile.in                     |    4 +++-
 daemons/dmeventd/Makefile.in                  |    2 +-
 daemons/dmeventd/plugins/lvm2/Makefile.in     |    2 +-
 daemons/dmeventd/plugins/mirror/Makefile.in   |    2 +-
 daemons/dmeventd/plugins/snapshot/Makefile.in |    2 +-
 test/api/Makefile.in                          |    2 +-
 tools/Makefile.in                             |   12 +++++-------
 8 files changed, 21 insertions(+), 14 deletions(-)

diff --git a/configure.in b/configure.in
index a9850a2..64ef0b6 100644
--- a/configure.in
+++ b/configure.in
@@ -829,6 +829,12 @@ Features cannot be 'shared' when building statically
 fi
 
 ################################################################################
+if [[ "$DMEVENTD" = yes -o "$CLVMD" != none ]] ; then
+	AC_CHECK_LIB([pthread], [pthread_mutex_lock], 
+		[PTHREAD_LIBS="-lpthread"], [AC_MSG_ERROR(bailing out)])
+fi
+
+################################################################################
 dnl -- Disable selinux
 AC_MSG_CHECKING(whether to enable selinux support)
 AC_ARG_ENABLE(selinux, [  --disable-selinux       Disable selinux support],
@@ -1123,6 +1129,7 @@ AC_SUBST(MSGFMT)
 AC_SUBST(OWNER)
 AC_SUBST(PKGCONFIG)
 AC_SUBST(POOL)
+AC_SUBST(PTHREAD_LIBS)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
 AC_SUBST(READLINE_LIBS)
@@ -1133,10 +1140,10 @@ AC_SUBST(SALCK_LIBS)
 AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
+AC_SUBST(STATIC_LIBS)
 AC_SUBST(STATIC_LINK)
 AC_SUBST(UDEV_RULES)
 AC_SUBST(UDEV_SYNC)
-AC_SUBST([LIB_PTHREAD])
 AC_SUBST(interface)
 AC_SUBST(kerneldir)
 AC_SUBST(missingkernel)
diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index dad568e..d6e653a 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -75,7 +75,7 @@ endif
 TARGETS = \
 	clvmd
 
-LVMLIBS = -llvm-internal -lpthread
+LVMLIBS = -llvm-internal
 
 ifeq ("@DMEVENTD@", "yes")
 	LVMLIBS += -ldevmapper-event
@@ -83,6 +83,8 @@ endif
  
 LVMLIBS += -ldevmapper
 
+LIBS += @PTHREAD_LIBS@
+
 DEFS += -D_REENTRANT
 CFLAGS += -fno-strict-aliasing
 
diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index d185205..eaf897a 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -54,7 +54,7 @@ all: device-mapper
 device-mapper: $(TARGETS)
 
 LIBS += -ldl
-LVMLIBS += -ldevmapper-event -lpthread -ldevmapper
+LVMLIBS += -ldevmapper-event -ldevmapper @PTHREAD_LIBS@
 
 $(VERSIONED_SHLIB): $(LIB_SHARED)
 	$(RM) -f $@
diff --git a/daemons/dmeventd/plugins/lvm2/Makefile.in b/daemons/dmeventd/plugins/lvm2/Makefile.in
index af6807b..80d6a61 100644
--- a/daemons/dmeventd/plugins/lvm2/Makefile.in
+++ b/daemons/dmeventd/plugins/lvm2/Makefile.in
@@ -29,7 +29,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@
+LIBS += @LVM2CMD_LIB@ -ldevmapper @PTHREAD_LIBS@
 
 install_lvm2: libdevmapper-event-lvm2.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
diff --git a/daemons/dmeventd/plugins/mirror/Makefile.in b/daemons/dmeventd/plugins/mirror/Makefile.in
index bdb49d1..e060d96 100644
--- a/daemons/dmeventd/plugins/mirror/Makefile.in
+++ b/daemons/dmeventd/plugins/mirror/Makefile.in
@@ -32,7 +32,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@ -ldevmapper-event-lvm2
+LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper @PTHREAD_LIBS@
 
 install_lvm2: libdevmapper-event-lvm2mirror.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
diff --git a/daemons/dmeventd/plugins/snapshot/Makefile.in b/daemons/dmeventd/plugins/snapshot/Makefile.in
index 4b203a0..ea058c3 100644
--- a/daemons/dmeventd/plugins/snapshot/Makefile.in
+++ b/daemons/dmeventd/plugins/snapshot/Makefile.in
@@ -32,7 +32,7 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 
 include $(top_builddir)/make.tmpl
 
-LIBS += -ldevmapper @LIB_PTHREAD@ @LVM2CMD_LIB@ -ldevmapper-event-lvm2
+LIBS += @LVM2CMD_LIB@ -ldevmapper-event-lvm2 -ldevmapper @PTHREAD_LIBS@
 
 install_lvm2: libdevmapper-event-lvm2snapshot.$(LIB_SUFFIX)
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) $< \
diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index 2c0c62f..605da33 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -35,7 +35,7 @@ include $(top_builddir)/make.tmpl
 LDFLAGS = -L$(top_builddir)/libdm -L$(top_builddir)/liblvm
 
 ifeq ("@DMEVENTD@", "yes")
-	LVMLIBS += -ldevmapper-event -lpthread
+	LVMLIBS += -ldevmapper-event
 	LDFLAGS += -L$(top_builddir)/daemons/dmeventd
 endif
 
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 07fd4a6..974abd2 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -17,8 +17,6 @@ top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 VPATH = @srcdir@
 
-LIB_PTHREAD = @LIB_PTHREAD@
-
 SOURCES =\
 	dumpconfig.c \
 	formats.c \
@@ -100,7 +98,7 @@ ifeq ("@CMDLIB@", "yes")
 endif
 
 ifeq ("@DMEVENTD@", "yes")
-	LVMLIBS += -ldevmapper-event -lpthread
+	LVMLIBS += -ldevmapper-event
 endif
 
 LVMLIBS += -ldevmapper
@@ -113,21 +111,21 @@ device-mapper: $(TARGETS_DM)
 
 dmsetup: dmsetup.o $(top_builddir)/libdm/libdevmapper.$(LIB_SUFFIX)
 	$(CC) $(CFLAGS) $(LDFLAGS) -L$(top_builddir)/libdm \
-	      -o $@ dmsetup.o -ldevmapper $(LIBS) $(LIB_PTHREAD)
+	      -o $@ dmsetup.o -ldevmapper $(LIBS)
 
 dmsetup.static: dmsetup.o $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) \
-	      -o $@ dmsetup.o -ldevmapper $(LIBS) $(LIB_PTHREAD)
+	      -o $@ dmsetup.o -ldevmapper $(LIBS)
 
 all: device-mapper
 
 lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJECTS) lvm.o \
-		$(LVMLIBS) @READLINE_LIBS@ $(LIBS) $(LIB_PTHREAD) -rdynamic
+		$(LVMLIBS) @READLINE_LIBS@ $(LIBS) -rdynamic
 
 lvm.static: $(OBJECTS) lvm-static.o $(top_builddir)/lib/liblvm-internal.a  $(interfacebuilddir)/libdevmapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) -static -L$(interfacebuilddir) -o $@ \
-	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS) $(LIB_PTHREAD) \
+	      $(OBJECTS) lvm-static.o $(LVMLIBS) $(LIBS) \
 	      -rdynamic
 
 liblvm2cmd.a: $(top_builddir)/lib/liblvm-internal.a $(OBJECTS) lvmcmdlib.o lvm2cmd.o
-- 
1.7.0



From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 16 Feb 2023 23:10:49 +0000 (GMT)
Subject: main - configure.ac: use LIBSYSTEMD
Message-ID: <20230216231049.9CA333858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d106ac04ab340d170dc5460e023df73e63bb98ab
Commit:        d106ac04ab340d170dc5460e023df73e63bb98ab
Parent:        3ef26494f2251dc5376f49128bbf49563560cf6b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 16 23:34:25 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 00:00:12 2023 +0100

configure.ac: use LIBSYSTEMD

Convert naming SYSTEMD_CFLAGS/LIB -> LIBSYSTEMD_CFLAGS/LIBS
to better fit library check for libsystemd.

Build lvmlockd with SD_NOTIFY when we have defined LIBSYSTEMD_LIBS.
---
 configure.ac                 | 2 +-
 daemons/lvmlockd/Makefile.in | 8 +++-----
 libdm/make.tmpl.in           | 2 +-
 make.tmpl.in                 | 6 +++---
 4 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/configure.ac b/configure.ac
index e8dc7a92c..17d90bc85 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1090,7 +1090,7 @@ AS_IF([test "$APP_MACHINEID_SUPPORT" = "yes"],
 
 dnl -- Look for libsystemd libraries if needed
 AS_IF([test "$NOTIFYDBUS_SUPPORT" = "yes" || test "$SYSTEMD_JOURNAL_SUPPORT" = "yes" || test "$APP_MACHINEID_SUPPORT" = "yes"], [
-	PKG_CHECK_MODULES(SYSTEMD, [systemd], [SYSTEMD_LIBS="-lsystemd"], $bailout)
+	PKG_CHECK_MODULES(LIBSYSTEMD, [libsystemd], [], $bailout)
 ])
 
 ################################################################################
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index e5ba82517..dd35d5411 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -15,8 +15,6 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-USE_SD_NOTIFY=yes
-
 SOURCES = lvmlockd-core.c
 
 ifeq ("@BUILD_LOCKDSANLOCK@", "yes")
@@ -51,9 +49,9 @@ INCLUDES += -I$(top_srcdir)/libdaemon/server
 LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
 LIBS += $(DAEMON_LIBS) $(PTHREAD_LIBS)
 
-ifeq ($(USE_SD_NOTIFY),yes)
-	CFLAGS += $(SYSTEMD_CFLAGS) -DUSE_SD_NOTIFY
-	LIBS += $(SYSTEMD_LIBS)
+ifneq (,$(firstword $(LIBSYSTEMD_LIBS)))
+	CFLAGS += $(LIBSYSTEMD_CFLAGS) -DUSE_SD_NOTIFY
+	LIBS += $(LIBSYSTEMD_LIBS)
 endif
 
 lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/server/libdaemonserver.a $(INTERNAL_LIBS)
diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index fb8973b6b..a731687c2 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -75,7 +75,7 @@ UDEV_CFLAGS = @UDEV_CFLAGS@
 UDEV_LIBS = @UDEV_LIBS@
 BLKID_CFLAGS = @BLKID_CFLAGS@
 BLKID_LIBS = @BLKID_LIBS@
-SYSTEMD_LIBS = @SYSTEMD_LIBS@
+LIBSYSTEMD_LIBS = @LIBSYSTEMD_LIBS@
 VALGRIND_CFLAGS = @VALGRIND_CFLAGS@
 
 # Setup directory variables
diff --git a/make.tmpl.in b/make.tmpl.in
index 9f4ecc33f..a1fae368d 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -57,7 +57,7 @@ PYTHON3 = @PYTHON3@
 PYCOMPILE = $(top_srcdir)/autoconf/py-compile
 
 LIBS += @LIBS@ $(SELINUX_LIBS) $(UDEV_LIBS) $(RT_LIBS) $(M_LIBS)
-LVMLIBS = $(DMEVENT_LIBS) $(READLINE_LIBS) $(EDITLINE_LIBS) $(SYSTEMD_LIBS) $(BLKID_LIBS) $(AIO_LIBS) $(LIBS)
+LVMLIBS = $(DMEVENT_LIBS) $(READLINE_LIBS) $(EDITLINE_LIBS) $(LIBSYSTEMD_LIBS) $(BLKID_LIBS) $(AIO_LIBS) $(LIBS)
 # Extra libraries always linked with static binaries
 STATIC_LIBS = $(PTHREAD_LIBS)
 DEFS += @DEFS@
@@ -82,12 +82,12 @@ CPG_CFLAGS = @CPG_CFLAGS@
 CPG_LIBS = @CPG_LIBS@
 EDITLINE_CFLAGS = @EDITLINE_CFLAGS@
 EDITLINE_LIBS = @EDITLINE_LIBS@
+LIBSYSTEMD_CFLAGS = @LIBSYSTEMD_CFLAGS@
+LIBSYSTEMD_LIBS = @LIBSYSTEMD_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_CFLAGS = @READLINE_CFLAGS@
 READLINE_LIBS = @READLINE_LIBS@
 SELINUX_LIBS = @SELINUX_LIBS@
-SYSTEMD_CFLAGS = @SYSTEMD_CFLAGS@
-SYSTEMD_LIBS = @SYSTEMD_LIBS@
 UDEV_CFLAGS = @UDEV_CFLAGS@
 UDEV_LIBS = @UDEV_LIBS@
 VALGRIND_CFLAGS = @VALGRIND_CFLAGS@


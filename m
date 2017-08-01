From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 12:34:35 -0400
Subject: master - configure: tune BUILD_DMEVENTD
Message-ID: <201708011634.v71GYZuB018015@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=95dd5bc7fb7dc818116ee367aaa3079f410e2cf7
Commit:        95dd5bc7fb7dc818116ee367aaa3079f410e2cf7
Parent:        92b53a80772a5a7f18c95ac4f3154a3cd4b1ce43
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 1 18:17:06 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 18:17:06 2017 +0200

configure: tune  BUILD_DMEVENTD

Drop 'DMEVENT' make variable and use  BUILD_DMEVENTD like with other daemons.
NOTE: by default we do not build dmeventd - maybe time to change
as lot of build targets basically do need dmeventd...

Switch to use SYSTEMD_LIBS and avoid linking systemd library with
every linked tool when dbus notification are enabled.
(TODO  add missing testing for lib presence)
---
 configure           |   17 ++++++++---------
 configure.in        |   14 ++++++--------
 make.tmpl.in        |    5 +++--
 man/Makefile.in     |    2 +-
 scripts/Makefile.in |    2 +-
 5 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/configure b/configure
index 6c649cf..2afbe6e 100755
--- a/configure
+++ b/configure
@@ -704,7 +704,6 @@ FSADM
 ELDFLAGS
 DM_LIB_PATCHLEVEL
 DMEVENTD_PATH
-DMEVENTD
 DL_LIBS
 DEVMAPPER
 DEFAULT_USE_LVMLOCKD
@@ -12238,7 +12237,7 @@ if test "$NOTIFYDBUS_SUPPORT" = yes; then
 
 $as_echo "#define NOTIFYDBUS_SUPPORT 1" >>confdefs.h
 
-	LIBS="-lsystemd $LIBS"
+	SYSTEMD_LIBS="-lsystemd"
 fi
 
 ################################################################################
@@ -13917,15 +13916,15 @@ $as_echo "$BLKDEACTIVATE" >&6; }
 $as_echo_n "checking whether to use dmeventd... " >&6; }
 # Check whether --enable-dmeventd was given.
 if test "${enable_dmeventd+set}" = set; then :
-  enableval=$enable_dmeventd; DMEVENTD=$enableval
+  enableval=$enable_dmeventd; BUILD_DMEVENTD=$enableval
+else
+  BUILD_DMEVENTD=no
 fi
 
-{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $DMEVENTD" >&5
-$as_echo "$DMEVENTD" >&6; }
-
-BUILD_DMEVENTD=$DMEVENTD
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BUILD_DMEVENTD" >&5
+$as_echo "$BUILD_DMEVENTD" >&6; }
 
-if test "$DMEVENTD" = yes; then
+if test "$BUILD_DMEVENTD" = yes; then
    if test "$MIRRORS" != internal; then
       as_fn_error $? "--enable-dmeventd currently requires --with-mirrors=internal" "$LINENO" 5
    fi
@@ -15218,7 +15217,7 @@ done
 
 fi
 
-if test "$DMEVENTD" = yes; then
+if test "$BUILD_DMEVENTD" = yes; then
 	for ac_header in arpa/inet.h
 do :
   ac_fn_c_check_header_mongrel "$LINENO" "arpa/inet.h" "ac_cv_header_arpa_inet_h" "$ac_includes_default"
diff --git a/configure.in b/configure.in
index a76f914..43e8652 100644
--- a/configure.in
+++ b/configure.in
@@ -1302,7 +1302,7 @@ AC_MSG_RESULT($NOTIFYDBUS_SUPPORT)
 
 if test "$NOTIFYDBUS_SUPPORT" = yes; then
 	AC_DEFINE([NOTIFYDBUS_SUPPORT], 1, [Define to 1 to include code that uses dbus notification.])
-	LIBS="-lsystemd $LIBS"
+	SYSTEMD_LIBS="-lsystemd"
 fi
 
 ################################################################################
@@ -1581,13 +1581,11 @@ dnl -- enable dmeventd handling
 AC_MSG_CHECKING(whether to use dmeventd)
 AC_ARG_ENABLE(dmeventd, AC_HELP_STRING([--enable-dmeventd],
 				       [enable the device-mapper event daemon]),
-	      DMEVENTD=$enableval)
-AC_MSG_RESULT($DMEVENTD)
-
-BUILD_DMEVENTD=$DMEVENTD
+	      BUILD_DMEVENTD=$enableval, BUILD_DMEVENTD=no)
+AC_MSG_RESULT($BUILD_DMEVENTD)
 
 dnl -- dmeventd currently requires internal mirror support
-if test "$DMEVENTD" = yes; then
+if test "$BUILD_DMEVENTD" = yes; then
    if test "$MIRRORS" != internal; then
       AC_MSG_ERROR([--enable-dmeventd currently requires --with-mirrors=internal])
    fi
@@ -1860,7 +1858,7 @@ if test "$CLUSTER" != none; then
 	AC_CHECK_FUNCS(socket,,hard_bailout)
 fi
 
-if test "$DMEVENTD" = yes; then
+if test "$BUILD_DMEVENTD" = yes; then
 	AC_CHECK_HEADERS(arpa/inet.h,,hard_bailout)
 fi
 
@@ -2072,7 +2070,6 @@ AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
 AC_SUBST(DLM_LIBS)
 AC_SUBST(DL_LIBS)
-AC_SUBST(DMEVENTD)
 AC_SUBST(DMEVENTD_PATH)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(ELDFLAGS)
@@ -2131,6 +2128,7 @@ AC_SUBST(SALCK_CFLAGS)
 AC_SUBST(SALCK_LIBS)
 AC_SUBST(SELINUX_LIBS)
 AC_SUBST(SELINUX_PC)
+AC_SUBST(SYSTEMD_LIBS)
 AC_SUBST(SNAPSHOTS)
 AC_SUBST(STATICDIR)
 AC_SUBST(STATIC_LINK)
diff --git a/make.tmpl.in b/make.tmpl.in
index 20041f9..17276c3 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -62,7 +62,7 @@ CLDFLAGS += @CLDFLAGS@
 ELDFLAGS += @ELDFLAGS@
 LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
-LVMINTERNAL_LIBS = -llvm-internal $(DMEVENT_LIBS) $(DAEMON_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
+LVMINTERNAL_LIBS = -llvm-internal $(DMEVENT_LIBS) $(DAEMON_LIBS) $(SYSTEMD_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
 RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
@@ -73,6 +73,7 @@ UDEV_CFLAGS = @UDEV_CFLAGS@
 UDEV_LIBS = @UDEV_LIBS@
 BLKID_CFLAGS = @BLKID_CFLAGS@
 BLKID_LIBS = @BLKID_LIBS@
+SYSTEMD_LIBS = @SYSTEMD_LIBS@
 VALGRIND_CFLAGS = @VALGRIND_CFLAGS@
 TESTING = @TESTING@
 
@@ -267,7 +268,7 @@ DAEMON_LIBS = -ldaemonclient
 LDFLAGS += -L$(top_builddir)/libdaemon/client
 CLDFLAGS += -L$(top_builddir)/libdaemon/client
 
-ifeq ("@DMEVENTD@", "yes")
+ifeq ("@BUILD_DMEVENTD@", "yes")
   DMEVENT_LIBS = -ldevmapper-event
   LDFLAGS += -L$(top_builddir)/daemons/dmeventd
   CLDFLAGS += -L$(top_builddir)/daemons/dmeventd
diff --git a/man/Makefile.in b/man/Makefile.in
index 219b2b9..b8f3aeb 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -85,7 +85,7 @@ else
     MAN8DM+=$(BLKDEACTIVATEMAN)
   endif
 
-  ifeq ("@DMEVENTD@", "yes")
+  ifeq ("@BUILD_DMEVENTD@", "yes")
     MAN8DM+=$(DMEVENTDMAN)
   endif
 
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 9c28956..b0d72c6 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -25,7 +25,7 @@ include $(top_builddir)/make.tmpl
 ifeq ("@APPLIB@", "yes")
 	DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
 	LDFLAGS += -L$(top_builddir)/liblvm
-ifeq ("@DMEVENTD@", "yes")
+ifeq ("@BUILD_DMEVENTD@", "yes")
 	LDFLAGS += -Wl,-rpath-link,$(top_builddir)/daemons/dmeventd
 endif
 	LVMLIBS = @LVM2APP_LIB@ -ldevmapper



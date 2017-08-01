From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 08:29:37 -0400
Subject: master - configure: improve test for realtime clock
Message-ID: <201708011229.v71CTbW2006113@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=92b53a80772a5a7f18c95ac4f3154a3cd4b1ce43
Commit:        92b53a80772a5a7f18c95ac4f3154a3cd4b1ce43
Parent:        a60fd5723645a56b677281007e6d5ed2493945cf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 1 12:41:45 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 14:03:54 2017 +0200

configure: improve test for realtime clock

Check first if we need to even link -lrt  - since clock functions
are normally emebeded with recent  glibc (>=2.17)
Use standard  RT_LIBS name.
Avoid duplicate test for realtime clock with lvmlockd
Show better error message when realtime clock support is missing or
disabled.
Link  RT_LIBS explicitely with lvmlockd and lvmetad.
---
 configure                    |   38 +++++++++++++++++++++++++++-----------
 configure.in                 |   13 +++++++++----
 daemons/lvmetad/Makefile.in  |    2 +-
 daemons/lvmlockd/Makefile.in |    2 +-
 libdm/Makefile.in            |    2 +-
 make.tmpl.in                 |    1 +
 6 files changed, 40 insertions(+), 18 deletions(-)

diff --git a/configure b/configure
index 8396e3e..6c649cf 100755
--- a/configure
+++ b/configure
@@ -660,7 +660,7 @@ SELINUX_PC
 SELINUX_LIBS
 REPLICATORS
 READLINE_LIBS
-RT_LIB
+RT_LIBS
 RAID
 PYTHON3DIR
 PYTHON2DIR
@@ -14316,8 +14316,24 @@ fi
 fi
 
 ################################################################################
+RT_LIBS=
+HAVE_REALTIME=no
 if test "$REALTIME" = yes; then
-	{ $as_echo "$as_me:${as_lineno-$LINENO}: checking for clock_gettime in -lrt" >&5
+	for ac_func in clock_gettime
+do :
+  ac_fn_c_check_func "$LINENO" "clock_gettime" "ac_cv_func_clock_gettime"
+if test "x$ac_cv_func_clock_gettime" = xyes; then :
+  cat >>confdefs.h <<_ACEOF
+#define HAVE_CLOCK_GETTIME 1
+_ACEOF
+ HAVE_REALTIME=yes
+fi
+done
+
+
+	if test "$HAVE_REALTIME" != yes; then :
+   # try again with -lrt
+	      { $as_echo "$as_me:${as_lineno-$LINENO}: checking for clock_gettime in -lrt" >&5
 $as_echo_n "checking for clock_gettime in -lrt... " >&6; }
 if ${ac_cv_lib_rt_clock_gettime+:} false; then :
   $as_echo_n "(cached) " >&6
@@ -14354,17 +14370,15 @@ fi
 { $as_echo "$as_me:${as_lineno-$LINENO}: result: $ac_cv_lib_rt_clock_gettime" >&5
 $as_echo "$ac_cv_lib_rt_clock_gettime" >&6; }
 if test "x$ac_cv_lib_rt_clock_gettime" = xyes; then :
-  HAVE_REALTIME=yes
-else
-  HAVE_REALTIME=no
+  RT_LIBS="-lrt"; HAVE_REALTIME=yes
 fi
 
+fi
 
 	if test "$HAVE_REALTIME" = yes; then
 
 $as_echo "#define HAVE_REALTIME 1" >>confdefs.h
 
-		RT_LIB="-lrt"
 	else
 		{ $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Disabling realtime clock" >&5
 $as_echo "$as_me: WARNING: Disabling realtime clock" >&2;}
@@ -14876,13 +14890,15 @@ done
 fi
 
 if test "$BUILD_LVMLOCKD" = yes; then
-	for ac_func in clock_gettime strtoull
+	if test "$HAVE_REALTIME" != yes; then :
+  as_fn_error $? "Realtime clock support is mandatory for lvmlockd." "$LINENO" 5
+fi
+	for ac_func in strtoull
 do :
-  as_ac_var=`$as_echo "ac_cv_func_$ac_func" | $as_tr_sh`
-ac_fn_c_check_func "$LINENO" "$ac_func" "$as_ac_var"
-if eval test \"x\$"$as_ac_var"\" = x"yes"; then :
+  ac_fn_c_check_func "$LINENO" "strtoull" "ac_cv_func_strtoull"
+if test "x$ac_cv_func_strtoull" = xyes; then :
   cat >>confdefs.h <<_ACEOF
-#define `$as_echo "HAVE_$ac_func" | $as_tr_cpp` 1
+#define HAVE_STRTOULL 1
 _ACEOF
 
 else
diff --git a/configure.in b/configure.in
index 4e13679..a76f914 100644
--- a/configure.in
+++ b/configure.in
@@ -1671,12 +1671,16 @@ fi
 
 ################################################################################
 dnl -- Check for realtime clock support
+RT_LIBS=
+HAVE_REALTIME=no
 if test "$REALTIME" = yes; then
-	AC_CHECK_LIB(rt, clock_gettime, HAVE_REALTIME=yes, HAVE_REALTIME=no)
+	AC_CHECK_FUNCS([clock_gettime], HAVE_REALTIME=yes)
+
+	AS_IF([test "$HAVE_REALTIME" != yes], [ # try again with -lrt
+	      AC_CHECK_LIB([rt], [clock_gettime], RT_LIBS="-lrt"; HAVE_REALTIME=yes)])
 
 	if test "$HAVE_REALTIME" = yes; then
 		AC_DEFINE([HAVE_REALTIME], 1, [Define to 1 to include support for realtime clock.])
-		RT_LIB="-lrt"
 	else
 		AC_MSG_WARN(Disabling realtime clock)
 	fi
@@ -1835,7 +1839,8 @@ if test "$BUILD_CMIRRORD" = yes; then
 fi
 
 if test "$BUILD_LVMLOCKD" = yes; then
-	AC_CHECK_FUNCS(clock_gettime strtoull,,hard_bailout)
+	AS_IF([test "$HAVE_REALTIME" != yes], [AC_MSG_ERROR([Realtime clock support is mandatory for lvmlockd.])])
+	AC_CHECK_FUNCS(strtoull,,hard_bailout)
 fi
 
 if test "$BUILD_LVMPOLLD" = yes; then
@@ -2117,7 +2122,7 @@ AC_SUBST(PYTHON3DIR)
 AC_SUBST(QUORUM_CFLAGS)
 AC_SUBST(QUORUM_LIBS)
 AC_SUBST(RAID)
-AC_SUBST(RT_LIB)
+AC_SUBST(RT_LIBS)
 AC_SUBST(READLINE_LIBS)
 AC_SUBST(REPLICATORS)
 AC_SUBST(SACKPT_CFLAGS)
diff --git a/daemons/lvmetad/Makefile.in b/daemons/lvmetad/Makefile.in
index 44e10fa..1d901aa 100644
--- a/daemons/lvmetad/Makefile.in
+++ b/daemons/lvmetad/Makefile.in
@@ -32,7 +32,7 @@ CFLAGS_lvmetactl.o += $(EXTRA_EXEC_CFLAGS)
 CFLAGS_lvmetad-core.o += $(EXTRA_EXEC_CFLAGS)
 INCLUDES += -I$(top_srcdir)/libdaemon/server
 LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
-LIBS += $(DAEMON_LIBS) -ldevmapper $(PTHREAD_LIBS)
+LIBS += $(RT_LIBS) $(DAEMON_LIBS) -ldevmapper $(PTHREAD_LIBS)
 
 lvmetad: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
diff --git a/daemons/lvmlockd/Makefile.in b/daemons/lvmlockd/Makefile.in
index 33038ec..8f16d06 100644
--- a/daemons/lvmlockd/Makefile.in
+++ b/daemons/lvmlockd/Makefile.in
@@ -36,7 +36,7 @@ include $(top_builddir)/make.tmpl
 CFLAGS += $(EXTRA_EXEC_CFLAGS)
 INCLUDES += -I$(top_srcdir)/libdaemon/server
 LDFLAGS += -L$(top_builddir)/libdaemon/server $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS)
-LIBS +=  $(DAEMON_LIBS) -ldevmapper $(PTHREAD_LIBS)
+LIBS += $(RT_LIBS) $(DAEMON_LIBS) -ldevmapper $(PTHREAD_LIBS)
 
 lvmlockd: $(OBJECTS) $(top_builddir)/libdaemon/client/libdaemonclient.a \
 		    $(top_builddir)/libdaemon/server/libdaemonserver.a
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index 7396cdc..66ec395 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -56,7 +56,7 @@ include $(top_builddir)/make.tmpl
 
 PROGS_CFLAGS = $(UDEV_CFLAGS)
 
-LIBS += $(RT_LIB) $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS) $(M_LIBS)
+LIBS += $(RT_LIBS) $(SELINUX_LIBS) $(UDEV_LIBS) $(PTHREAD_LIBS) $(M_LIBS)
 
 device-mapper: all
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 3a09a10..20041f9 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -64,6 +64,7 @@ LDDEPS += @LDDEPS@
 LIB_SUFFIX = @LIB_SUFFIX@
 LVMINTERNAL_LIBS = -llvm-internal $(DMEVENT_LIBS) $(DAEMON_LIBS) $(UDEV_LIBS) $(DL_LIBS) $(BLKID_LIBS)
 DL_LIBS = @DL_LIBS@
+RT_LIBS = @RT_LIBS@
 M_LIBS = @M_LIBS@
 PTHREAD_LIBS = @PTHREAD_LIBS@
 READLINE_LIBS = @READLINE_LIBS@



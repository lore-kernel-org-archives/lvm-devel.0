From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 9 Jul 2008 09:59:43 -0000
Subject: LVM2 ./WHATS_NEW ./configure ./configure.in dm ...
Message-ID: <20080709095943.17766.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-07-09 09:59:42

Modified files:
	.              : WHATS_NEW configure configure.in 
	dmeventd/mirror: Makefile.in 
	dmeventd/snapshot: Makefile.in 

Log message:
	Fix dmeventd regression where mirror and snapshot monitoring libraries
	failed to link against liblvm2cmd.
	
	Dmeventd DSOs *require* lvm2cmd to be linked in.
	
	For the future:
	1) AC_SUBST does not create Makefile variables, only @foo at -style substitutions
	2) When using `test', whitespace around `=' is essential:
	test a=b is true, as is test a=a

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.925&r2=1.926
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.73&r2=1.74
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2008/06/27 22:35:22	1.925
+++ LVM2/WHATS_NEW	2008/07/09 09:59:41	1.926
@@ -1,5 +1,7 @@
 Version 2.02.40 - 
 ================================
+  Fix dmeventd regression where mirror and snapshot monitoring libraries
+  failed to link against liblvm2cmd.
 
 Version 2.02.39 - 27th June 2008
 ================================
--- LVM2/configure	2008/06/27 19:57:27	1.73
+++ LVM2/configure	2008/07/09 09:59:41	1.74
@@ -8726,10 +8726,11 @@
 { echo "$as_me:$LINENO: result: $CMDLIB" >&5
 echo "${ECHO_T}$CMDLIB" >&6; }
 
-test $CMDLIB=yes \
+test x$CMDLIB = xyes \
   && LVM2CMD_LIB=-llvm2cmd \
   || LVM2CMD_LIB=
 
+
 ################################################################################
 { echo "$as_me:$LINENO: checking whether to install fsadm" >&5
 echo $ECHO_N "checking whether to install fsadm... $ECHO_C" >&6; }
@@ -8752,12 +8753,21 @@
 { echo "$as_me:$LINENO: result: $DMEVENTD" >&5
 echo "${ECHO_T}$DMEVENTD" >&6; }
 
-if test x$DMEVENTD = xyes && test x$MIRRORS != xinternal; then
-{ { echo "$as_me:$LINENO: error: --enable-dmeventd currently requires --with-mirrors=internal
-" >&5
+if test x$DMEVENTD = xyes; then
+   if test x$MIRRORS != xinternal; then
+      { { echo "$as_me:$LINENO: error: --enable-dmeventd currently requires --with-mirrors=internal
+      " >&5
 echo "$as_me: error: --enable-dmeventd currently requires --with-mirrors=internal
-" >&2;}
+      " >&2;}
+   { (exit 1); exit 1; }; }
+   fi
+   if test x$CMDLIB = xno; then
+      { { echo "$as_me:$LINENO: error: --enable-dmeventd requires --enable-cmdlib to be used as well
+      " >&5
+echo "$as_me: error: --enable-dmeventd requires --enable-cmdlib to be used as well
+      " >&2;}
    { (exit 1); exit 1; }; }
+   fi
 fi
 
 if test x$DMEVENTD = xyes; then
@@ -10260,7 +10270,7 @@
   ac_cv_func_getmntent=yes
 
 cat >>confdefs.h <<\_ACEOF
-#define HAVE_GETMNTENT
+#define HAVE_GETMNTENT 1
 _ACEOF
 
 else
--- LVM2/configure.in	2008/06/27 19:57:27	1.74
+++ LVM2/configure.in	2008/07/09 09:59:42	1.75
@@ -366,10 +366,11 @@
 CMDLIB=$enableval, CMDLIB=no)
 AC_MSG_RESULT($CMDLIB)
 AC_SUBST([LVM2CMD_LIB])
-test $CMDLIB=yes \
+test x$CMDLIB = xyes \
   && LVM2CMD_LIB=-llvm2cmd \
   || LVM2CMD_LIB=
 
+
 ################################################################################
 dnl -- Enable fsadm
 AC_MSG_CHECKING(whether to install fsadm)
@@ -385,10 +386,17 @@
 AC_MSG_RESULT($DMEVENTD)
 
 dnl -- dmeventd currently requires internal mirror support
-if test x$DMEVENTD = xyes && test x$MIRRORS != xinternal; then
-AC_MSG_ERROR(
---enable-dmeventd currently requires --with-mirrors=internal
-)
+if test x$DMEVENTD = xyes; then
+   if test x$MIRRORS != xinternal; then
+      AC_MSG_ERROR(
+	--enable-dmeventd currently requires --with-mirrors=internal
+      )
+   fi
+   if test x$CMDLIB = xno; then
+      AC_MSG_ERROR(
+        --enable-dmeventd requires --enable-cmdlib to be used as well
+      )
+   fi
 fi
 
 if test x$DMEVENTD = xyes; then
--- LVM2/dmeventd/mirror/Makefile.in	2008/06/23 09:25:07	1.6
+++ LVM2/dmeventd/mirror/Makefile.in	2008/07/09 09:59:42	1.7
@@ -17,7 +17,7 @@
 VPATH = @srcdir@
 
 INCLUDES += -I${top_srcdir}/tools
-CLDFLAGS += -L${top_srcdir}/tools -ldevmapper $(LVM2CMD_LIB)
+CLDFLAGS += -L${top_srcdir}/tools -ldevmapper @LVM2CMD_LIB@
 
 SOURCES = dmeventd_mirror.c
 
--- LVM2/dmeventd/snapshot/Makefile.in	2008/06/23 09:25:08	1.2
+++ LVM2/dmeventd/snapshot/Makefile.in	2008/07/09 09:59:42	1.3
@@ -17,7 +17,7 @@
 VPATH = @srcdir@
 
 INCLUDES += -I${top_srcdir}/tools
-CLDFLAGS += -L${top_srcdir}/tools -ldevmapper $(LVM2CMD_LIB)
+CLDFLAGS += -L${top_srcdir}/tools -ldevmapper @LVM2CMD_LIB@
 
 SOURCES = dmeventd_snapshot.c
 



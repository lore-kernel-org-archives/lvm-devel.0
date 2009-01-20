From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 20 Jan 2009 17:07:54 -0000
Subject: LVM2 ./configure ./configure.in tools/lvm-static.c
Message-ID: <20090120170754.30736.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-01-20 17:07:53

Modified files:
	.              : configure configure.in 
	tools          : lvm-static.c 

Log message:
	Fix problems with static build
	
	- compiler warning (missing header)
	
	- configure should set static flag early to be able
	use STATIC_LINK flag during configure script

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm-static.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/configure	2008/12/07 19:37:07	1.88
+++ LVM2/configure	2009/01/20 17:07:53	1.89
@@ -1323,6 +1323,8 @@
 Optional Features:
   --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
+  --enable-static_link    Use this to link the tools to their libraries
+                          statically.  Default is dynamic linking
   --enable-lvm1_fallback  Use this to fall back and use LVM1 binaries if
                           device-mapper is missing from the kernel
   --disable-readline      Disable readline support
@@ -1337,8 +1339,6 @@
   --enable-pkgconfig      Install pkgconfig support
   --enable-fsadm          Enable fsadm
   --enable-dmeventd       Enable the device-mapper event daemon
-  --enable-static_link    Use this to link the tools to their libraries
-                          statically.  Default is dynamic linking
   --disable-selinux       Disable selinux support
   --enable-nls            Enable Native Language Support
 
@@ -8398,6 +8398,19 @@
 
 
 ################################################################################
+{ echo "$as_me:$LINENO: checking whether to use static linking" >&5
+echo $ECHO_N "checking whether to use static linking... $ECHO_C" >&6; }
+# Check whether --enable-static_link was given.
+if test "${enable_static_link+set}" = set; then
+  enableval=$enable_static_link; STATIC_LINK=$enableval
+else
+  STATIC_LINK=no
+fi
+
+{ echo "$as_me:$LINENO: result: $STATIC_LINK" >&5
+echo "${ECHO_T}$STATIC_LINK" >&6; }
+
+################################################################################
 
 
 ################################################################################
@@ -9308,19 +9321,6 @@
 fi
 
 ################################################################################
-{ echo "$as_me:$LINENO: checking whether to use static linking" >&5
-echo $ECHO_N "checking whether to use static linking... $ECHO_C" >&6; }
-# Check whether --enable-static_link was given.
-if test "${enable_static_link+set}" = set; then
-  enableval=$enable_static_link; STATIC_LINK=$enableval
-else
-  STATIC_LINK=no
-fi
-
-{ echo "$as_me:$LINENO: result: $STATIC_LINK" >&5
-echo "${ECHO_T}$STATIC_LINK" >&6; }
-
-################################################################################
 { echo "$as_me:$LINENO: checking whether to enable selinux support" >&5
 echo $ECHO_N "checking whether to enable selinux support... $ECHO_C" >&6; }
 # Check whether --enable-selinux was given.
@@ -10609,7 +10609,7 @@
   ac_cv_func_getmntent=yes
 
 cat >>confdefs.h <<\_ACEOF
-#define HAVE_GETMNTENT
+#define HAVE_GETMNTENT 1
 _ACEOF
 
 else
--- LVM2/configure.in	2008/12/07 19:37:07	1.92
+++ LVM2/configure.in	2009/01/20 17:07:53	1.93
@@ -129,6 +129,15 @@
 AC_FUNC_VPRINTF
 
 ################################################################################
+dnl -- Enables statically-linked tools
+AC_MSG_CHECKING(whether to use static linking)
+AC_ARG_ENABLE(static_link,
+  [  --enable-static_link    Use this to link the tools to their libraries
+                          statically.  Default is dynamic linking],
+  STATIC_LINK=$enableval, STATIC_LINK=no)
+AC_MSG_RESULT($STATIC_LINK)
+
+################################################################################
 dnl -- Prefix is /usr by default, the exec_prefix default is setup later
 AC_PREFIX_DEFAULT(/usr)
 
@@ -509,15 +518,6 @@
 fi
 
 ################################################################################
-dnl -- Enables statically-linked tools
-AC_MSG_CHECKING(whether to use static linking)
-AC_ARG_ENABLE(static_link,
-  [  --enable-static_link    Use this to link the tools to their libraries
-                          statically.  Default is dynamic linking],
-  STATIC_LINK=$enableval, STATIC_LINK=no)
-AC_MSG_RESULT($STATIC_LINK)
-
-################################################################################
 dnl -- Disable selinux
 AC_MSG_CHECKING(whether to enable selinux support)
 AC_ARG_ENABLE(selinux, [  --disable-selinux       Disable selinux support],
--- LVM2/tools/lvm-static.c	2008/12/18 05:27:18	1.6
+++ LVM2/tools/lvm-static.c	2009/01/20 17:07:53	1.7
@@ -14,6 +14,7 @@
  */
 
 #include "lvm2cmdline.h"
+#include "lib.h"
 
 int main(int argc, char **argv)
 {



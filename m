From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Mar 2010 14:44:43 -0000
Subject: LVM2 ./configure lib/misc/configure.h.in
Message-ID: <20100323144443.2870.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-03-23 14:44:43

Modified files:
	.              : configure 
	lib/misc       : configure.h.in 

Log message:
	Autoreconf.
	
	(Strictly require libudev if udev_sync is used)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/configure.h.in.diff?cvsroot=lvm2&r1=1.18&r2=1.19

--- LVM2/configure	2010/03/18 13:24:35	1.122
+++ LVM2/configure	2010/03/23 14:44:42	1.123
@@ -12209,28 +12209,6 @@
 $as_echo "$UDEV_SYNC" >&6; }
 
 if test x$UDEV_SYNC = xyes; then
-
-cat >>confdefs.h <<\_ACEOF
-#define UDEV_SYNC_SUPPORT 1
-_ACEOF
-
-fi
-
-{ $as_echo "$as_me:$LINENO: checking whether to enable installation of udev rules required for synchronisation" >&5
-$as_echo_n "checking whether to enable installation of udev rules required for synchronisation... " >&6; }
-# Check whether --enable-udev_rules was given.
-if test "${enable_udev_rules+set}" = set; then
-  enableval=$enable_udev_rules; UDEV_RULES=$enableval
-else
-  UDEV_RULES=$UDEV_SYNC
-fi
-
-{ $as_echo "$as_me:$LINENO: result: $UDEV_RULES" >&5
-$as_echo "$UDEV_RULES" >&6; }
-
-################################################################################
-
-if test x$UDEV_SYNC = xyes; then
 	{ $as_echo "$as_me:$LINENO: checking for udev_queue_get_udev_is_active in -ludev" >&5
 $as_echo_n "checking for udev_queue_get_udev_is_active in -ludev... " >&6; }
 if test "${ac_cv_lib_udev_udev_queue_get_udev_is_active+set}" = set; then
@@ -12297,26 +12275,32 @@
 { $as_echo "$as_me:$LINENO: result: $ac_cv_lib_udev_udev_queue_get_udev_is_active" >&5
 $as_echo "$ac_cv_lib_udev_udev_queue_get_udev_is_active" >&6; }
 if test "x$ac_cv_lib_udev_udev_queue_get_udev_is_active" = x""yes; then
-  HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE=yes
+  UDEV_LIBS="-ludev"
 else
-  HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE=no
+  { { $as_echo "$as_me:$LINENO: error: bailing out... libudev library is required" >&5
+$as_echo "$as_me: error: bailing out... libudev library is required" >&2;}
+   { (exit 1); exit 1; }; }
 fi
 
 
-		if test x$HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE = xyes; then
-
 cat >>confdefs.h <<\_ACEOF
-#define HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE 1
+#define UDEV_SYNC_SUPPORT 1
 _ACEOF
 
-			UDEV_LIBS="-ludev"
-		else
-			UDEV_LIBS=
-			{ $as_echo "$as_me:$LINENO: WARNING: It won't be possible to get udev state. We will assume that udev is not running." >&5
-$as_echo "$as_me: WARNING: It won't be possible to get udev state. We will assume that udev is not running." >&2;}
-		fi
 fi
 
+{ $as_echo "$as_me:$LINENO: checking whether to enable installation of udev rules required for synchronisation" >&5
+$as_echo_n "checking whether to enable installation of udev rules required for synchronisation... " >&6; }
+# Check whether --enable-udev_rules was given.
+if test "${enable_udev_rules+set}" = set; then
+  enableval=$enable_udev_rules; UDEV_RULES=$enableval
+else
+  UDEV_RULES=$UDEV_SYNC
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $UDEV_RULES" >&5
+$as_echo "$UDEV_RULES" >&6; }
+
 ################################################################################
 # Check whether --enable-compat was given.
 if test "${enable_compat+set}" = set; then
--- LVM2/lib/misc/configure.h.in	2010/03/18 13:24:36	1.18
+++ LVM2/lib/misc/configure.h.in	2010/03/23 14:44:42	1.19
@@ -347,10 +347,6 @@
 /* Define to 1 if you have the <time.h> header file. */
 #undef HAVE_TIME_H
 
-/* Define to 1 if libudev's udev_queue_get_udev_is_active function is
-   available. */
-#undef HAVE_UDEV_QUEUE_GET_UDEV_IS_ACTIVE
-
 /* Define to 1 if you have the `uname' function. */
 #undef HAVE_UNAME
 



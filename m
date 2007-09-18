From: meyering@sourceware.org <meyering@sourceware.org>
Date: 18 Sep 2007 14:01:09 -0000
Subject: LVM2 configure configure.in
Message-ID: <20070918140109.4801.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-18 14:01:08

Modified files:
	.              : configure configure.in 

Log message:
	Allow relative dir name in: --with-dmdir=../device-mapper
	
	* configure.in: Convert a relative dmdir directory name to the required
	absolute form, e.g. in ./configure --with-dmdir=../device-mapper
	Suggestion from Jun'ichi Nomura.
	* configure: Regenerate.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/configure	2007/09/18 14:00:41	1.62
+++ LVM2/configure	2007/09/18 14:01:08	1.63
@@ -9627,6 +9627,12 @@
 fi
 
 
+# Convert a relative dir name to absolute.
+case $DMDIR in
+  /*) ;;
+  *) DMDIR="`pwd`/$DMDIR" ;;
+esac
+
 ################################################################################
 if test x$READLINE = xyes; then
 
@@ -11591,7 +11597,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile test/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile test/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12195,6 +12201,7 @@
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
     "lib/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES lib/mirror/Makefile" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
+    "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
@@ -12206,7 +12213,6 @@
     "test/format1/Makefile") CONFIG_FILES="$CONFIG_FILES test/format1/Makefile" ;;
     "test/regex/Makefile") CONFIG_FILES="$CONFIG_FILES test/regex/Makefile" ;;
     "test/filters/Makefile") CONFIG_FILES="$CONFIG_FILES test/filters/Makefile" ;;
-    "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
 
   *) { { $as_echo "$as_me:$LINENO: error: invalid argument: $ac_config_target" >&5
 $as_echo "$as_me: error: invalid argument: $ac_config_target" >&2;}
--- LVM2/configure.in	2007/09/18 14:00:41	1.60
+++ LVM2/configure.in	2007/09/18 14:01:08	1.61
@@ -538,6 +538,12 @@
   	    [ DMDIR="$withval" CPPFLAGS="$CPPFLAGS -I$DMDIR/include"],
 	    [ DMDIR= ])
 
+# Convert a relative dir name to absolute.
+case $DMDIR in
+  /*) ;;
+  *) DMDIR="`pwd`/$DMDIR" ;;
+esac
+
 ################################################################################
 dnl -- Ensure additional headers required
 if test x$READLINE = xyes; then



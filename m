From: meyering@sourceware.org <meyering@sourceware.org>
Date: 18 Sep 2007 18:26:32 -0000
Subject: LVM2 configure configure.in
Message-ID: <20070918182632.22650.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-18 18:26:32

Modified files:
	.              : configure configure.in 

Log message:
	* configure.in (AC_CONFIG_FILES): Remove the test/*/Makefile names
	corresponding to the recently-removed directories.
	* configure: Regenerate.
	Reported by Dave Wysochanski.
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/configure	2007/09/18 14:01:08	1.63
+++ LVM2/configure	2007/09/18 18:26:32	1.64
@@ -11597,7 +11597,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile test/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile test/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12208,11 +12208,6 @@
     "tools/Makefile") CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
     "tools/version.h") CONFIG_FILES="$CONFIG_FILES tools/version.h" ;;
     "tools/fsadm/Makefile") CONFIG_FILES="$CONFIG_FILES tools/fsadm/Makefile" ;;
-    "test/mm/Makefile") CONFIG_FILES="$CONFIG_FILES test/mm/Makefile" ;;
-    "test/device/Makefile") CONFIG_FILES="$CONFIG_FILES test/device/Makefile" ;;
-    "test/format1/Makefile") CONFIG_FILES="$CONFIG_FILES test/format1/Makefile" ;;
-    "test/regex/Makefile") CONFIG_FILES="$CONFIG_FILES test/regex/Makefile" ;;
-    "test/filters/Makefile") CONFIG_FILES="$CONFIG_FILES test/filters/Makefile" ;;
 
   *) { { $as_echo "$as_me:$LINENO: error: invalid argument: $ac_config_target" >&5
 $as_echo "$as_me: error: invalid argument: $ac_config_target" >&2;}
--- LVM2/configure.in	2007/09/18 14:01:08	1.61
+++ LVM2/configure.in	2007/09/18 18:26:32	1.62
@@ -24,7 +24,7 @@
 
 ################################################################################
 dnl -- Setup the directory where autoconf has auxilary files
-AC_CONFIG_AUX_DIR(autoconf) 
+AC_CONFIG_AUX_DIR(autoconf)
 
 ################################################################################
 dnl -- Get system type
@@ -638,35 +638,30 @@
 AC_SUBST([LIB_PTHREAD])
 
 ################################################################################
-dnl -- First and last lines should not contain files to generate in order to 
+dnl -- First and last lines should not contain files to generate in order to
 dnl -- keep utility scripts running properly
-AC_CONFIG_FILES([\
-Makefile								\
-make.tmpl								\
-daemons/Makefile							\
-daemons/clvmd/Makefile							\
-dmeventd/Makefile							\
-dmeventd/mirror/Makefile						\
-doc/Makefile								\
-include/Makefile						 	\
-lib/Makefile							 	\
-lib/format1/Makefile						 	\
-lib/format_pool/Makefile						\
-lib/locking/Makefile							\
-lib/mirror/Makefile							\
-lib/snapshot/Makefile							\
-test/Makefile                                                           \
-man/Makefile							 	\
-po/Makefile								\
-scripts/Makefile								\
-tools/Makefile							 	\
-tools/version.h								\
-tools/fsadm/Makefile							\
-test/mm/Makefile							\
-test/device/Makefile							\
-test/format1/Makefile							\
-test/regex/Makefile                                                     \
-test/filters/Makefile                                                   \
+AC_CONFIG_FILES([
+Makefile
+make.tmpl
+daemons/Makefile
+daemons/clvmd/Makefile
+dmeventd/Makefile
+dmeventd/mirror/Makefile
+doc/Makefile
+include/Makefile
+lib/Makefile
+lib/format1/Makefile
+lib/format_pool/Makefile
+lib/locking/Makefile
+lib/mirror/Makefile
+lib/snapshot/Makefile
+test/Makefile
+man/Makefile
+po/Makefile
+scripts/Makefile
+tools/Makefile
+tools/version.h
+tools/fsadm/Makefile
 ])
 AC_OUTPUT
 



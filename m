From: meyering@sourceware.org <meyering@sourceware.org>
Date: 12 Sep 2007 18:23:03 -0000
Subject: LVM2 configure
Message-ID: <20070912182303.24883.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-12 18:23:02

Modified files:
	.              : configure 

Log message:
	configure: regenerate, to remove vestige of an upcoming patch

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/configure	2007/09/12 16:54:23	1.60
+++ LVM2/configure	2007/09/12 18:23:02	1.61
@@ -11591,7 +11591,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile t/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile dmeventd/Makefile dmeventd/mirror/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile man/Makefile po/Makefile scripts/Makefile tools/Makefile tools/version.h tools/fsadm/Makefile test/mm/Makefile test/device/Makefile test/format1/Makefile test/regex/Makefile test/filters/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12206,7 +12206,6 @@
     "test/format1/Makefile") CONFIG_FILES="$CONFIG_FILES test/format1/Makefile" ;;
     "test/regex/Makefile") CONFIG_FILES="$CONFIG_FILES test/regex/Makefile" ;;
     "test/filters/Makefile") CONFIG_FILES="$CONFIG_FILES test/filters/Makefile" ;;
-    "t/Makefile") CONFIG_FILES="$CONFIG_FILES t/Makefile" ;;
 
   *) { { $as_echo "$as_me:$LINENO: error: invalid argument: $ac_config_target" >&5
 $as_echo "$as_me: error: invalid argument: $ac_config_target" >&2;}



From: agk@sourceware.org <agk@sourceware.org>
Date: 22 Jul 2009 20:01:30 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW ./configure ./confi ...
Message-ID: <20090722200130.12404.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-22 20:01:29

Modified files:
	.              : VERSION WHATS_NEW configure configure.in 
	                 make.tmpl.in 
	lib/misc       : lvm-version.h.in 

Log message:
	Add an API version number, LVM_LIBAPI, to the VERSION string.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.202&r2=1.203
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1195&r2=1.1196
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.99&r2=1.100
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-version.h.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/VERSION	2009/07/15 15:38:41	1.202
+++ LVM2/VERSION	2009/07/22 20:01:28	1.203
@@ -1 +1 @@
-2.02.50-cvs (2009-07-15)
+2.02.50(1)-cvs (2009-07-22)
--- LVM2/WHATS_NEW	2009/07/21 20:00:02	1.1195
+++ LVM2/WHATS_NEW	2009/07/22 20:01:28	1.1196
@@ -1,5 +1,6 @@
 Version 2.02.50 - 
 ================================
+  Add an API version number, LVM_LIBAPI, to the VERSION string for liblvm.
   Pass a pointer to struct cmd_context to init_multiple_segtypes
   Return EINVALID_CMD_LINE not success when invalid VG name format is used.
   Remove unnecessary messages after vgcreate/vgsplit refactor (2.02.49).
--- LVM2/configure	2009/05/22 14:44:59	1.94
+++ LVM2/configure	2009/07/22 20:01:28	1.95
@@ -657,6 +657,7 @@
 LVM_PATCHLEVEL
 LVM_MINOR
 LVM_MAJOR
+LVM_LIBAPI
 LVM_VERSION
 LVM1_FALLBACK
 LVM1
@@ -12606,13 +12607,14 @@
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 VER=`cat VERSION`
-LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.*(//;s/).*//'`\""
+LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.* (//;s/).*//'`\""
 VER=`echo "$VER" | $AWK '{print $1}'`
 LVM_RELEASE="\"`echo "$VER" | $AWK -F '-' '{print $2}'`\""
 VER=`echo "$VER" | $AWK -F '-' '{print $1}'`
 LVM_MAJOR=`echo "$VER" | $AWK -F '.' '{print $1}'`
 LVM_MINOR=`echo "$VER" | $AWK -F '.' '{print $2}'`
-LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '.' '{print $3}'`
+LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '[(.]' '{print $3}'`
+LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 ################################################################################
 
@@ -12681,6 +12683,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
 
--- LVM2/configure.in	2009/05/22 14:44:59	1.99
+++ LVM2/configure.in	2009/07/22 20:01:29	1.100
@@ -750,13 +750,14 @@
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 VER=`cat VERSION`
-LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.*(//;s/).*//'`\""
+LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.* (//;s/).*//'`\""
 VER=`echo "$VER" | $AWK '{print $1}'`
 LVM_RELEASE="\"`echo "$VER" | $AWK -F '-' '{print $2}'`\""
 VER=`echo "$VER" | $AWK -F '-' '{print $1}'`
 LVM_MAJOR=`echo "$VER" | $AWK -F '.' '{print $1}'`
 LVM_MINOR=`echo "$VER" | $AWK -F '.' '{print $2}'`
-LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '.' '{print $3}'`
+LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '[[(.]]' '{print $3}'`
+LVM_LIBAPI=`echo "$VER" | $AWK -F '[[()]]' '{print $2}'`
 
 ################################################################################
 AC_SUBST(APPLIB)
@@ -801,6 +802,7 @@
 AC_SUBST(LVM1)
 AC_SUBST(LVM1_FALLBACK)
 AC_SUBST(LVM_VERSION)
+AC_SUBST(LVM_LIBAPI)
 AC_SUBST(LVM_MAJOR)
 AC_SUBST(LVM_MINOR)
 AC_SUBST(LVM_PATCHLEVEL)
--- LVM2/make.tmpl.in	2009/05/11 10:28:45	1.67
+++ LVM2/make.tmpl.in	2009/07/22 20:01:29	1.68
@@ -116,6 +116,9 @@
 LIB_VERSION_DM := $(shell cat $(top_srcdir)/VERSION_DM | \
 		    awk -F '.' '{printf "%s.%s",$$1,$$2}')
 
+LIB_VERSION_APP := $(shell cat $(top_srcdir)/VERSION | \
+		     awk -F '[(). ]' '{printf "%s.%s",$$1,$$4}')
+
 INCLUDES += -I. -I$(top_srcdir)/include
 
 INC_LNS = $(top_srcdir)/include/.symlinks_created
--- LVM2/lib/misc/lvm-version.h.in	2009/02/22 22:11:58	1.1
+++ LVM2/lib/misc/lvm-version.h.in	2009/07/22 20:01:29	1.2
@@ -17,13 +17,14 @@
 /**
  * The LVM version number
  *
- * LVM_MAJOR.LVM_MINOR.LVM_PATCHLEVEL[-LVM_RELEASE]
+ * LVM_MAJOR.LVM_MINOR.LVM_PATCHLEVEL(LVM_LIBAPI)[-LVM_RELEASE]
  */
 
 #define LVM_VERSION @LVM_VERSION@
 #define LVM_MAJOR @LVM_MAJOR@
 #define LVM_MINOR @LVM_MINOR@
 #define LVM_PATCHLEVEL @LVM_PATCHLEVEL@
+#define LVM_LIBAPI @LVM_LIBAPI@
 #define LVM_RELEASE @LVM_RELEASE@
 #define LVM_RELEASE_DATE @LVM_RELEASE_DATE@
 #endif



From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Nov 2008 20:48:51 -0000
Subject: LVM2 configure
Message-ID: <20081101204851.20656.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-01 20:48:51

Modified files:
	.              : configure 

Log message:
	autoreconf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/configure	2008/11/01 02:20:06	1.82
+++ LVM2/configure	2008/11/01 20:48:50	1.83
@@ -708,6 +708,7 @@
 DM_DEVICE_UID
 DM_IOCTLS
 DM_LIB_VERSION
+DM_LIB_PATCHLEVEL
 FSADM
 GROUP
 HAVE_LIBDL
@@ -11804,6 +11805,8 @@
 _ACEOF
 
 
+DM_LIB_PATCHLEVEL=`cat VERSION_LIB | awk -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
+
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 ################################################################################
@@ -11860,6 +11863,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/Makefile test/Makefile tools/Makefile tools/version.h"
 
@@ -12598,9 +12602,9 @@
 DM_DEVICE_UID!$DM_DEVICE_UID$ac_delim
 DM_IOCTLS!$DM_IOCTLS$ac_delim
 DM_LIB_VERSION!$DM_LIB_VERSION$ac_delim
+DM_LIB_PATCHLEVEL!$DM_LIB_PATCHLEVEL$ac_delim
 FSADM!$FSADM$ac_delim
 GROUP!$GROUP$ac_delim
-HAVE_LIBDL!$HAVE_LIBDL$ac_delim
 _ACEOF
 
   if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 97; then
@@ -12642,6 +12646,7 @@
 ac_delim='%!_!# '
 for ac_last_try in false false false false false :; do
   cat >conf$$subs.sed <<_ACEOF
+HAVE_LIBDL!$HAVE_LIBDL$ac_delim
 HAVE_REALTIME!$HAVE_REALTIME$ac_delim
 HAVE_SELINUX!$HAVE_SELINUX$ac_delim
 INTL!$INTL$ac_delim
@@ -12672,7 +12677,7 @@
 LTLIBOBJS!$LTLIBOBJS$ac_delim
 _ACEOF
 
-  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 28; then
+  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 29; then
     break
   elif $ac_last_try; then
     { { echo "$as_me:$LINENO: error: could not make $CONFIG_STATUS" >&5



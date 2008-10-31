From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Oct 2008 22:34:42 -0000
Subject: LVM2 configure
Message-ID: <20081031223442.2487.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-10-31 22:34:42

Modified files:
	.              : configure 

Log message:
	autoreconf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/configure	2008/10/31 22:12:55	1.80
+++ LVM2/configure	2008/10/31 22:34:42	1.81
@@ -701,7 +701,6 @@
 COPTIMISE_FLAG
 DEBUG
 DEVMAPPER
-DMDIR
 DMEVENTD
 DM_COMPAT
 DM_DEVICE_GID
@@ -1364,7 +1363,6 @@
   --with-localedir=DIR    Translation files in DIR [PREFIX/share/locale]
   --with-confdir=DIR      Configuration files in DIR /etc
   --with-staticdir=DIR    Static binary in DIR EXEC_PREFIX/sbin
-  --with-dmdir=DIR        Build against device-mapper source tree in DIR
   --with-usrlibdir=DIR
   --with-usrsbindir=DIR
   --with-dmeventd-pidfile=PATH    dmeventd pidfile [/var/run/dmeventd.pid]
@@ -10071,21 +10069,6 @@
 
 
 
-# Check whether --with-dmdir was given.
-if test "${with_dmdir+set}" = set; then
-  withval=$with_dmdir;  DMDIR="$withval" CPPFLAGS="$CPPFLAGS -I$DMDIR/include"
-else
-   DMDIR=
-fi
-
-
-# Convert a relative dir name to absolute.
-case $DMDIR in
-  /*) ;;
-  *) DMDIR="`pwd`/$DMDIR" ;;
-esac
-
-
 # Check whether --with-usrlibdir was given.
 if test "${with_usrlibdir+set}" = set; then
   withval=$with_usrlibdir;  usrlibdir="$withval"
@@ -11839,9 +11822,8 @@
 
 
 
-
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/Makefile test/Makefile tools/Makefile tools/version.h"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/Makefile test/Makefile tools/Makefile tools/version.h"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12404,6 +12386,7 @@
     "daemons/clvmd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/clvmd/Makefile" ;;
     "daemons/dmeventd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/Makefile" ;;
     "daemons/dmeventd/libdevmapper-event.pc") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/libdevmapper-event.pc" ;;
+    "daemons/dmeventd/plugins/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/Makefile" ;;
     "daemons/dmeventd/plugins/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/mirror/Makefile" ;;
     "daemons/dmeventd/plugins/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/snapshot/Makefile" ;;
     "doc/Makefile") CONFIG_FILES="$CONFIG_FILES doc/Makefile" ;;
@@ -12570,7 +12553,6 @@
 COPTIMISE_FLAG!$COPTIMISE_FLAG$ac_delim
 DEBUG!$DEBUG$ac_delim
 DEVMAPPER!$DEVMAPPER$ac_delim
-DMDIR!$DMDIR$ac_delim
 DMEVENTD!$DMEVENTD$ac_delim
 DM_COMPAT!$DM_COMPAT$ac_delim
 DM_DEVICE_GID!$DM_DEVICE_GID$ac_delim
@@ -12580,6 +12562,7 @@
 DM_LIB_VERSION!$DM_LIB_VERSION$ac_delim
 FSADM!$FSADM$ac_delim
 GROUP!$GROUP$ac_delim
+HAVE_LIBDL!$HAVE_LIBDL$ac_delim
 _ACEOF
 
   if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 97; then
@@ -12621,7 +12604,6 @@
 ac_delim='%!_!# '
 for ac_last_try in false false false false false :; do
   cat >conf$$subs.sed <<_ACEOF
-HAVE_LIBDL!$HAVE_LIBDL$ac_delim
 HAVE_REALTIME!$HAVE_REALTIME$ac_delim
 HAVE_SELINUX!$HAVE_SELINUX$ac_delim
 INTL!$INTL$ac_delim
@@ -12652,7 +12634,7 @@
 LTLIBOBJS!$LTLIBOBJS$ac_delim
 _ACEOF
 
-  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 29; then
+  if test `sed -n "s/.*$ac_delim\$/X/p" conf$$subs.sed | grep -c X` = 28; then
     break
   elif $ac_last_try; then
     { { echo "$as_me:$LINENO: error: could not make $CONFIG_STATUS" >&5



From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Sep 2009 19:32:38 -0000
Subject: LVM2 configure configure.in
Message-ID: <20090902193238.4352.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-02 19:32:37

Modified files:
	.              : configure configure.in 

Log message:
	clogd->cmirrord

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.103&r2=1.104
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.110&r2=1.111

--- LVM2/configure	2009/09/01 19:11:45	1.103
+++ LVM2/configure	2009/09/02 19:32:37	1.104
@@ -15155,7 +15155,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/clogd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -15758,7 +15758,7 @@
     "make.tmpl") CONFIG_FILES="$CONFIG_FILES make.tmpl" ;;
     "daemons/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/Makefile" ;;
     "daemons/clvmd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/clvmd/Makefile" ;;
-    "daemons/clogd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/clogd/Makefile" ;;
+    "daemons/cmirrord/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/cmirrord/Makefile" ;;
     "daemons/dmeventd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/Makefile" ;;
     "daemons/dmeventd/libdevmapper-event.pc") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/libdevmapper-event.pc" ;;
     "daemons/dmeventd/plugins/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/Makefile" ;;
--- LVM2/configure.in	2009/09/01 19:11:46	1.110
+++ LVM2/configure.in	2009/09/02 19:32:37	1.111
@@ -1112,7 +1112,7 @@
 make.tmpl
 daemons/Makefile
 daemons/clvmd/Makefile
-daemons/clogd/Makefile
+daemons/cmirrord/Makefile
 daemons/dmeventd/Makefile
 daemons/dmeventd/libdevmapper-event.pc
 daemons/dmeventd/plugins/Makefile



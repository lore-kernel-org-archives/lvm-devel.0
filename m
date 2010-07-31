From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2010 00:43:42 -0000
Subject: LVM2 WHATS_NEW configure configure.in
Message-ID: <20100731004342.789.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-31 00:43:42

Modified files:
	.              : WHATS_NEW configure configure.in 

Log message:
	Fix configure to supply DEFAULT_RUN_DIR to Makefiles.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1678&r2=1.1679
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.150&r2=1.151

--- LVM2/WHATS_NEW	2010/07/30 17:50:15	1.1678
+++ LVM2/WHATS_NEW	2010/07/31 00:43:41	1.1679
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Fix configure to supply DEFAULT_RUN_DIR to Makefiles.
   Fix wrong number of mirror log at allocate policy
 
 Version 2.02.72 - 28th July 2010  [CVE-2010-2526]
--- LVM2/configure	2010/07/28 13:55:42	1.137
+++ LVM2/configure	2010/07/31 00:43:41	1.138
@@ -691,6 +691,7 @@
 DMEVENTD
 DL_LIBS
 DEVMAPPER
+DEFAULT_RUN_DIR
 DEFAULT_LOCK_DIR
 DEFAULT_CACHE_SUBDIR
 DEFAULT_BACKUP_SUBDIR
@@ -18043,6 +18044,7 @@
 
 
 
+
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile"
 
--- LVM2/configure.in	2010/07/28 13:55:42	1.150
+++ LVM2/configure.in	2010/07/31 00:43:42	1.151
@@ -1232,6 +1232,7 @@
 AC_SUBST(DEFAULT_BACKUP_SUBDIR)
 AC_SUBST(DEFAULT_CACHE_SUBDIR)
 AC_SUBST(DEFAULT_LOCK_DIR)
+AC_SUBST(DEFAULT_RUN_DIR)
 AC_SUBST(DEVMAPPER)
 AC_SUBST(DLM_CFLAGS)
 AC_SUBST(DLM_LIBS)



From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Aug 2011 01:52:20 -0000
Subject: LVM2 ./configure ./configure.in daemons/clvmd/ ...
Message-ID: <20110812015220.4731.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-12 01:52:19

Modified files:
	.              : configure configure.in 
	daemons/clvmd  : Makefile.in 

Log message:
	Drop CCS* variables no longer used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.154&r2=1.155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.168&r2=1.169
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/configure	2011/08/11 19:18:18	1.154
+++ LVM2/configure	2011/08/12 01:52:16	1.155
@@ -669,8 +669,6 @@
 CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
-CCS_LIBS
-CCS_CFLAGS
 BUILD_DMEVENTD
 BUILD_CMIRRORD
 APPLIB
@@ -10162,8 +10160,6 @@
 
 
 
-
-
 ################################################################################
 ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makef!
 ile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
--- LVM2/configure.in	2011/08/11 19:18:18	1.168
+++ LVM2/configure.in	2011/08/12 01:52:17	1.169
@@ -1271,8 +1271,6 @@
 AC_SUBST(AWK)
 AC_SUBST(BUILD_CMIRRORD)
 AC_SUBST(BUILD_DMEVENTD)
-AC_SUBST(CCS_CFLAGS)
-AC_SUBST(CCS_LIBS)
 AC_SUBST(CFLAGS)
 AC_SUBST(CFLOW_CMD)
 AC_SUBST(CLDFLAGS)
--- LVM2/daemons/clvmd/Makefile.in	2011/08/09 18:11:00	1.41
+++ LVM2/daemons/clvmd/Makefile.in	2011/08/12 01:52:19	1.42
@@ -15,8 +15,6 @@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-CCS_LIBS = @CCS_LIBS@
-CCS_CFLAGS = @CCS_CFLAGS@
 CMAN_LIBS = @CMAN_LIBS@
 CMAN_CFLAGS = @CMAN_CFLAGS@
 CONFDB_LIBS = @CONFDB_LIBS@



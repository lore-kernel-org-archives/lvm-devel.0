From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Jul 2011 12:59:58 -0000
Subject: LVM2 configure
Message-ID: <20110728125958.14206.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-07-28 12:59:44

Modified files:
	.              : configure 

Log message:
	autoreconf

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.148&r2=1.149

--- LVM2/configure	2011/04/28 16:54:32	1.148
+++ LVM2/configure	2011/07/28 12:59:44	1.149
@@ -603,6 +603,7 @@
 missingkernel
 kerneldir
 interface
+DMEVENTD_PIDFILE
 WRITE_INSTALL
 UDEV_SYNC
 UDEV_RULES
@@ -10380,8 +10381,9 @@
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makef!
 ile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11102,6 +11104,8 @@
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
     "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
+    "scripts/dm_event_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/dm_event_systemd_red_hat.service" ;;
+    "scripts/lvm2_monitoring_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_systemd_red_hat.service" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
     "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;



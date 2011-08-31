From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 31 Aug 2011 11:39:32 -0000
Subject: LVM2 configure
Message-ID: <20110831113932.29917.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-08-31 11:39:32

Modified files:
	.              : configure 

Log message:
	Autoreconf for lvmetad patch

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.156&r2=1.157

--- LVM2/configure	2011/08/24 08:27:49	1.156
+++ LVM2/configure	2011/08/31 11:39:32	1.157
@@ -670,6 +670,7 @@
 CLDWHOLEARCHIVE
 CLDNOWHOLEARCHIVE
 CLDFLAGS
+BUILD_LVMETAD
 BUILD_DMEVENTD
 BUILD_CMIRRORD
 APPLIB
@@ -812,6 +813,7 @@
 enable_testing
 enable_valgrind_pool
 enable_devmapper
+enable_lvmetad
 enable_udev_sync
 enable_udev_rules
 enable_compat
@@ -1503,6 +1505,7 @@
   --enable-testing        enable testing targets in the makefile
   --enable-valgrind-pool  enable valgrind awareness of pools
   --disable-devmapper     disable LVM2 device-mapper interaction
+  --disable-lvmetad       disable the LVM Metadata Daemon
   --enable-udev_sync      enable synchronisation with udev processing
   --enable-udev_rules     install rule files needed for udev synchronisation
   --enable-compat         enable support for old device-mapper versions
@@ -2808,6 +2811,7 @@
 		LDFLAGS="$LDFLAGS -Wl,--export-dynamic"
 		LIB_SUFFIX=so
 		DEVMAPPER=yes
+		LVMETAD=no
 		ODIRECT=yes
 		DM_IOCTLS=yes
 		SELINUX=yes
@@ -8554,6 +8558,19 @@
 fi
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to build LVMetaD" >&5
+$as_echo_n "checking whether to build LVMetaD... " >&6; }
+# Check whether --enable-lvmetad was given.
+if test "${enable_lvmetad+set}" = set; then :
+  enableval=$enable_lvmetad; LVMETAD=$enableval
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $LVMETAD" >&5
+$as_echo "$LVMETAD" >&6; }
+
+BUILD_LVMETAD=$LVMETAD
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to enable synchronisation with udev processing" >&5
 $as_echo_n "checking whether to enable synchronisation with udev processing... " >&6; }
 # Check whether --enable-udev_sync was given.
@@ -10187,8 +10204,9 @@
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile test/api/Makefile tools/M!
 akefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/Makefile test/Makefile !
 test/api/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -10889,6 +10907,7 @@
     "daemons/dmeventd/plugins/raid/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/raid/Makefile" ;;
     "daemons/dmeventd/plugins/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/mirror/Makefile" ;;
     "daemons/dmeventd/plugins/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/snapshot/Makefile" ;;
+    "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
     "doc/Makefile") CONFIG_FILES="$CONFIG_FILES doc/Makefile" ;;
     "doc/example.conf") CONFIG_FILES="$CONFIG_FILES doc/example.conf" ;;
     "include/.symlinks") CONFIG_FILES="$CONFIG_FILES include/.symlinks" ;;



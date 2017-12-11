From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 11 Dec 2017 07:11:55 -0500
Subject: master - lvmdbusd: Fix path to python3
Message-ID: <201712111211.vBBCBtuH026307@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2aedc98242cefd29a5eccabb600be6f37e756fda
Commit:        2aedc98242cefd29a5eccabb600be6f37e756fda
Parent:        6a6c8d7b81703205a283528da5b7b8630e32d0d0
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Dec 11 12:36:54 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Dec 11 12:36:54 2017 +0100

lvmdbusd: Fix path to python3

lvmdbusd executable script must use python3 interpreter detected by
configure script, as site-packages directory used for library is only
used by that interpreter.
---
 WHATS_NEW                    |    1 +
 configure                    |    3 ++-
 configure.in                 |    1 +
 daemons/lvmdbusd/.gitignore  |    1 +
 daemons/lvmdbusd/lvmdbusd    |   16 ----------------
 daemons/lvmdbusd/lvmdbusd.in |   16 ++++++++++++++++
 6 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index db256b0..6f13fe3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Fix python3 path in lvmdbusd to use value detected by configure.
   Reduce checks for active LVs in vgchange before background polling.
   Ensure _node_send_message always uses clean status of thin pool.
   Fix lvmlockd to use pool lock when accessing _tmeta volume.
diff --git a/configure b/configure
index fc0a27a..903ad6e 100755
--- a/configure
+++ b/configure
@@ -15778,7 +15778,7 @@ _ACEOF
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaem
 on/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_
 red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/dmfilemapd/Makefile daemons/lvmdbusd/Makefile daemons/lvmdbusd/lvmdbusd daemons/lvmdbusd/path.py daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile include/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaem
 on/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/com.redhat.lvmdbus1.service scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmdbusd_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service script
 s/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/lvmdump.sh scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16488,6 +16488,7 @@ do
     "daemons/dmeventd/plugins/thin/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmeventd/plugins/thin/Makefile" ;;
     "daemons/dmfilemapd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/dmfilemapd/Makefile" ;;
     "daemons/lvmdbusd/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/Makefile" ;;
+    "daemons/lvmdbusd/lvmdbusd") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/lvmdbusd" ;;
     "daemons/lvmdbusd/path.py") CONFIG_FILES="$CONFIG_FILES daemons/lvmdbusd/path.py" ;;
     "daemons/lvmetad/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmetad/Makefile" ;;
     "daemons/lvmpolld/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/lvmpolld/Makefile" ;;
diff --git a/configure.in b/configure.in
index a0a47cd..85ddce0 100644
--- a/configure.in
+++ b/configure.in
@@ -2186,6 +2186,7 @@ daemons/dmeventd/plugins/snapshot/Makefile
 daemons/dmeventd/plugins/thin/Makefile
 daemons/dmfilemapd/Makefile
 daemons/lvmdbusd/Makefile
+daemons/lvmdbusd/lvmdbusd
 daemons/lvmdbusd/path.py
 daemons/lvmetad/Makefile
 daemons/lvmpolld/Makefile
diff --git a/daemons/lvmdbusd/.gitignore b/daemons/lvmdbusd/.gitignore
index 09375e7..c0f6b4e 100644
--- a/daemons/lvmdbusd/.gitignore
+++ b/daemons/lvmdbusd/.gitignore
@@ -1 +1,2 @@
 path.py
+lvmdbusd
diff --git a/daemons/lvmdbusd/lvmdbusd b/daemons/lvmdbusd/lvmdbusd
deleted file mode 100755
index 73d0f13..0000000
--- a/daemons/lvmdbusd/lvmdbusd
+++ /dev/null
@@ -1,16 +0,0 @@
-#!/usr/bin/env python3
-
-# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
-#
-# This copyrighted material is made available to anyone wishing to use,
-# modify, copy, or redistribute it subject to the terms and conditions
-# of the GNU General Public License v.2.
-#
-# You should have received a copy of the GNU General Public License
-# along with this program. If not, see <http://www.gnu.org/licenses/>.
-
-import sys
-from lvmdbusd import main
-
-if __name__ == '__main__':
-	sys.exit(main())
diff --git a/daemons/lvmdbusd/lvmdbusd.in b/daemons/lvmdbusd/lvmdbusd.in
new file mode 100755
index 0000000..bd84cd8
--- /dev/null
+++ b/daemons/lvmdbusd/lvmdbusd.in
@@ -0,0 +1,16 @@
+#!@PYTHON3@
+
+# Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program. If not, see <http://www.gnu.org/licenses/>.
+
+import sys
+from lvmdbusd import main
+
+if __name__ == '__main__':
+	sys.exit(main())



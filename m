From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Oct 2012 12:46:32 +0000 (UTC)
Subject: master - configure: autoreconf
Message-ID: <20121012124632.1DC92A0D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a70d6b350f98bd6e9068ce723a275f31e9f27b7e
Commit:        a70d6b350f98bd6e9068ce723a275f31e9f27b7e
Parent:        c698ee14bbb1310cf2383c8977d14a8e29139f8c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 12 14:45:26 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 12 14:45:26 2012 +0200

configure: autoreconf

---
 configure |   22 +++++++++++++++++++++-
 1 files changed, 21 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index add489a..b58c52d 100755
--- a/configure
+++ b/configure
@@ -651,6 +651,7 @@ INTL_PACKAGE
 INTL
 HAVE_REALTIME
 HAVE_LIBDL
+BLKDEACTIVATE
 FSADM
 ELDFLAGS
 DM_LIB_PATCHLEVEL
@@ -854,6 +855,7 @@ enable_python_bindings
 enable_pkgconfig
 enable_write_install
 enable_fsadm
+enable_blkdeactivate
 enable_dmeventd
 enable_selinux
 enable_nls
@@ -1558,6 +1560,7 @@ Optional Features:
   --enable-pkgconfig      install pkgconfig support
   --enable-write_install  install user writable files
   --disable-fsadm         disable fsadm
+  --disable-blkdeactivate disable blkdeactivate
   --enable-dmeventd       enable the device-mapper event daemon
   --disable-selinux       disable selinux support
   --enable-nls            enable Native Language Support
@@ -2883,6 +2886,7 @@ case "$host_os" in
 		SELINUX=yes
 		CLUSTER=internal
 		FSADM=yes
+		BLKDEACTIVATE=yes
 		;;
 	darwin*)
 		CFLAGS="$CFLAGS -no-cpp-precomp -fno-common"
@@ -2898,6 +2902,7 @@ case "$host_os" in
 		SELINUX=no
 		CLUSTER=none
 		FSADM=no
+		BLKDEACTIVATE=no
 		;;
 esac
 
@@ -9340,6 +9345,17 @@ fi
 $as_echo "$FSADM" >&6; }
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to install blkdeactivate" >&5
+$as_echo_n "checking whether to install blkdeactivate... " >&6; }
+# Check whether --enable-blkdeactivate was given.
+if test "${enable_blkdeactivate+set}" = set; then :
+  enableval=$enable_blkdeactivate; BLKDEACTIVATE=$enableval
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $BLKDEACTIVATE" >&5
+$as_echo "$BLKDEACTIVATE" >&6; }
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use dmeventd" >&5
 $as_echo_n "checking whether to use dmeventd... " >&6; }
 # Check whether --enable-dmeventd was given.
@@ -10770,8 +10786,9 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvm
 etad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile doc/Makefile doc/example.conf include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/bl
 k_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/dm_event_systemd_red_hat.socket scripts/dm_event_systemd_red_hat.service scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -11499,6 +11516,9 @@ do
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "python/Makefile") CONFIG_FILES="$CONFIG_FILES python/Makefile" ;;
     "python/setup.py") CONFIG_FILES="$CONFIG_FILES python/setup.py" ;;
+    "scripts/blkdeactivate.sh") CONFIG_FILES="$CONFIG_FILES scripts/blkdeactivate.sh" ;;
+    "scripts/blk_availability_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_init_red_hat" ;;
+    "scripts/blk_availability_systemd_red_hat.service") CONFIG_FILES="$CONFIG_FILES scripts/blk_availability_systemd_red_hat.service" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
     "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
     "scripts/lvm2_lvmetad_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_lvmetad_init_red_hat" ;;



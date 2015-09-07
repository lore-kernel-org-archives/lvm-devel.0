From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  7 Sep 2015 15:45:21 +0000 (UTC)
Subject: master - configure: regenerate
Message-ID: <20150907154521.E0ED960A75@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d62448cb456170bab17b2af24e11df964666e1c6
Commit:        d62448cb456170bab17b2af24e11df964666e1c6
Parent:        1999e368f16cf7537c553be573809713213fdacd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 7 14:02:25 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 7 17:43:27 2015 +0200

configure: regenerate

---
 configure |   34 +++++++++++++++++++++++++---------
 1 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/configure b/configure
index c7b7dd5..ea44878 100755
--- a/configure
+++ b/configure
@@ -643,6 +643,7 @@ LVMETAD_PIDFILE
 DMEVENTD_PIDFILE
 WRITE_INSTALL
 VALGRIND_POOL
+USE_TRACKING
 UDEV_HAS_BUILTIN_BLKID
 UDEV_RULE_EXEC_DETECTION
 UDEV_SYSTEMD_BACKGROUND_JOBS
@@ -693,7 +694,6 @@ BLKDEACTIVATE
 FSADM
 ELDFLAGS
 DM_LIB_PATCHLEVEL
-DM_LIB_VERSION
 DMEVENTD_PATH
 DMEVENTD
 DL_LIBS
@@ -876,6 +876,7 @@ SHELL'
 ac_subst_files=''
 ac_user_opts='
 enable_option_checking
+enable_dependency_tracking
 enable_static_link
 with_user
 with_group
@@ -1634,6 +1635,8 @@ Optional Features:
   --disable-option-checking  ignore unrecognized --enable/--with options
   --disable-FEATURE       do not include FEATURE (same as --enable-FEATURE=no)
   --enable-FEATURE[=ARG]  include FEATURE [ARG=yes]
+  --disable-dependency-tracking
+                          speeds up one-time build.
   --enable-static_link    use this to link the tools to their libraries
                           statically (default is dynamic linking
   --enable-lvm1_fallback  use this to fall back and use LVM1 binaries if
@@ -2966,7 +2969,7 @@ ac_compiler_gnu=$ac_cv_c_compiler_gnu
 
 
 
-ac_config_headers="$ac_config_headers lib/misc/configure.h"
+ac_config_headers="$ac_config_headers conf/configure.h"
 
 
 ################################################################################
@@ -7633,6 +7636,19 @@ done
 
 
 ################################################################################
+{ $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to disable dependency tracking" >&5
+$as_echo_n "checking whether to disable dependency tracking... " >&6; }
+# Check whether --enable-dependency-tracking was given.
+if test "${enable_dependency_tracking+set}" = set; then :
+  enableval=$enable_dependency_tracking; USE_TRACKING=$enableval
+else
+  USE_TRACKING=yes
+fi
+
+{ $as_echo "$as_me:${as_lineno-$LINENO}: result: $USE_TRACKING" >&5
+$as_echo "$USE_TRACKING" >&6; }
+
+################################################################################
 { $as_echo "$as_me:${as_lineno-$LINENO}: checking whether to use static linking" >&5
 $as_echo_n "checking whether to use static linking... " >&6; }
 # Check whether --enable-static_link was given.
@@ -14026,18 +14042,18 @@ test "$interface" != ioctl && as_fn_error $? "--with-interface=ioctl required. f
 $as_echo "$interface" >&6; }
 
 ################################################################################
-DM_LIB_VERSION="\"`cat "$srcdir"/VERSION_DM 2>/dev/null || echo Unknown`\""
+read DM_LIB_VERSION < "$srcdir"/VERSION_DM 2>/dev/null || DM_LIB_VERSION=Unknown
 
 cat >>confdefs.h <<_ACEOF
-#define DM_LIB_VERSION $DM_LIB_VERSION
+#define DM_LIB_VERSION "$DM_LIB_VERSION"
 _ACEOF
 
 
 DM_LIB_PATCHLEVEL=`cat "$srcdir"/VERSION_DM | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3}'`
 
-LVM_VERSION="\"`cat "$srcdir"/VERSION 2>/dev/null || echo Unknown`\""
+read VER < "$srcdir"/VERSION 2>/dev/null || VER=Unknown
 
-VER=`cat "$srcdir"/VERSION`
+LVM_VERSION=\"$VER\"
 LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.* (//;s/).*//'`\""
 VER=`echo "$VER" | $AWK '{print $1}'`
 LVM_RELEASE="\"`echo "$VER" | $AWK -F '-' '{print $2}'`\""
@@ -14196,7 +14212,7 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdev
 mapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan
 _systemd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/raid/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile daemons/dmeventd/plugins/thin/Makefile daemons/lvmetad/Makefile daemons/lvmpolld/Makefile daemons/lvmlockd/Makefile conf/Makefile conf/example.conf conf/lvmlocal.conf conf/command_profile_template.profile conf/metadata_profile_template.profile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile conf/lvm-version.h lib/raid/Makefile lib/snapshot/Makefile lib/thin/Makefile lib/cache_segtype/Makefile libdaemon/Makefile libdaemon/client/Makefile libdaemon/server/Makefile libdm/Makefile libdm/libdevmapp
 er.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile python/Makefile python/setup.py scripts/blkdeactivate.sh scripts/blk_availability_init_red_hat scripts/blk_availability_systemd_red_hat.service scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/dm_event_systemd_red_hat.service scripts/dm_event_systemd_red_hat.socket scripts/lvm2_cluster_activation_red_hat.sh scripts/lvm2_cluster_activation_systemd_red_hat.service scripts/lvm2_clvmd_systemd_red_hat.service scripts/lvm2_cmirrord_systemd_red_hat.service scripts/lvm2_lvmetad_init_red_hat scripts/lvm2_lvmetad_systemd_red_hat.service scripts/lvm2_lvmetad_systemd_red_hat.socket scripts/lvm2_lvmpolld_init_red_hat scripts/lvm2_lvmpolld_systemd_red_hat.service scripts/lvm2_lvmpolld_systemd_red_hat.socket scripts/lvm2_lvmlockd_systemd_red_hat.service scripts/lvm2_lvmlocking_systemd_red_hat.service scripts/lvm2_monitoring_init_red_hat scripts/lvm2_monitoring_systemd_red_hat.service scripts/lvm2_pvscan_sys
 temd_red_hat at .service scripts/lvm2_tmpfiles_red_hat.conf scripts/Makefile test/Makefile test/api/Makefile test/unit/Makefile tools/Makefile udev/Makefile unit-tests/datastruct/Makefile unit-tests/regex/Makefile unit-tests/mm/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -14890,7 +14906,7 @@ cat >>$CONFIG_STATUS <<\_ACEOF || ac_write_fail=1
 for ac_config_target in $ac_config_targets
 do
   case $ac_config_target in
-    "lib/misc/configure.h") CONFIG_HEADERS="$CONFIG_HEADERS lib/misc/configure.h" ;;
+    "conf/configure.h") CONFIG_HEADERS="$CONFIG_HEADERS conf/configure.h" ;;
     "Makefile") CONFIG_FILES="$CONFIG_FILES Makefile" ;;
     "make.tmpl") CONFIG_FILES="$CONFIG_FILES make.tmpl" ;;
     "daemons/Makefile") CONFIG_FILES="$CONFIG_FILES daemons/Makefile" ;;
@@ -14920,7 +14936,7 @@ do
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
     "lib/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES lib/mirror/Makefile" ;;
     "lib/replicator/Makefile") CONFIG_FILES="$CONFIG_FILES lib/replicator/Makefile" ;;
-    "lib/misc/lvm-version.h") CONFIG_FILES="$CONFIG_FILES lib/misc/lvm-version.h" ;;
+    "conf/lvm-version.h") CONFIG_FILES="$CONFIG_FILES conf/lvm-version.h" ;;
     "lib/raid/Makefile") CONFIG_FILES="$CONFIG_FILES lib/raid/Makefile" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "lib/thin/Makefile") CONFIG_FILES="$CONFIG_FILES lib/thin/Makefile" ;;



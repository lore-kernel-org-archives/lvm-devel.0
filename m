From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Mar 2010 14:47:18 +0100
Subject: [PATCH 25/25] Replicator: update generated configure.in
In-Reply-To: <cover.1268833246.git.zkabelac@redhat.com>
References: <cover.1268833246.git.zkabelac@redhat.com>
Message-ID: <4f2afb7bb74d8e96c7dbce00a93cb5cb397bd721.1268833246.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure |   33 ++++++++++++++++++++++++++++++++-
 1 files changed, 32 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index 2d8d969..7fe7ad0 100755
--- a/configure
+++ b/configure
@@ -658,6 +658,7 @@ PTHREAD_LIBS
 POOL
 PKGCONFIG
 OWNER
+REPLICATORS
 MIRRORS
 LVM_RELEASE_DATE
 LVM_RELEASE
@@ -817,6 +818,7 @@ with_pool
 with_cluster
 with_snapshots
 with_mirrors
+with_replicators
 enable_readline
 enable_realtime
 with_clvmd
@@ -1549,6 +1551,7 @@ Optional Packages:
                           TYPE=internal
   --with-mirrors=TYPE     Mirror support: internal/shared/none
                           TYPE=internal
+  --with-replicators=TYPE Replicator support: internal/shared/none TYPE=none
   --with-clvmd=TYPE       Build cluster LVM Daemon.
                           The following cluster manager combinations are valid:
                            * cman,gulm             (RHEL4 or equivalent)
@@ -9328,6 +9331,32 @@ _ACEOF
 fi
 
 ################################################################################
+{ $as_echo "$as_me:$LINENO: checking whether to include replicators" >&5
+$as_echo_n "checking whether to include replicators... " >&6; }
+
+# Check whether --with-replicators was given.
+if test "${with_replicators+set}" = set; then
+  withval=$with_replicators; REPLICATORS=$withval
+else
+  REPLICATORS="none"
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $REPLICATORS" >&5
+$as_echo "$REPLICATORS" >&6; }
+
+case "$REPLICATORS" in
+  none|shared) ;;
+  internal)
+cat >>confdefs.h <<\_ACEOF
+#define REPLICATOR_INTERNAL 1
+_ACEOF
+ ;;
+  *) { { $as_echo "$as_me:$LINENO: error: --with-replicators parameter invalid ($REPLICATORS)" >&5
+$as_echo "$as_me: error: --with-replicators parameter invalid ($REPLICATORS)" >&2;}
+   { (exit 1); exit 1; }; } ;;
+esac
+
+################################################################################
 { $as_echo "$as_me:$LINENO: checking whether to enable readline" >&5
 $as_echo_n "checking whether to enable readline... " >&6; }
 # Check whether --enable-readline was given.
@@ -15564,8 +15593,9 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/lvm2/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16183,6 +16213,7 @@ do
     "lib/format_pool/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format_pool/Makefile" ;;
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
     "lib/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES lib/mirror/Makefile" ;;
+    "lib/replicator/Makefile") CONFIG_FILES="$CONFIG_FILES lib/replicator/Makefile" ;;
     "lib/misc/lvm-version.h") CONFIG_FILES="$CONFIG_FILES lib/misc/lvm-version.h" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
-- 
1.7.0.1



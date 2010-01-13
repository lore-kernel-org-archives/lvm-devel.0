From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 13 Jan 2010 14:42:22 +0100
Subject: [PATCH 18/18] Replicator: update of generated configure file
In-Reply-To: <cover.1263389894.git.zkabelac@redhat.com>
References: <cover.1263389894.git.zkabelac@redhat.com>
Message-ID: <9bb6faf74bb533a36f31ff7b958e7381280b9a49.1263389894.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 configure |   34 +++++++++++++++++++++++++++++++++-
 1 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index 85d0730..0afd574 100755
--- a/configure
+++ b/configure
@@ -656,6 +656,7 @@ SELINUX_LIBS
 POOL
 PKGCONFIG
 OWNER
+REPLICATOR
 MIRRORS
 LVM_RELEASE_DATE
 LVM_RELEASE
@@ -815,6 +816,7 @@ with_pool
 with_cluster
 with_snapshots
 with_mirrors
+with_replicator
 enable_readline
 enable_realtime
 with_clvmd
@@ -1547,6 +1549,8 @@ Optional Packages:
                           TYPE=internal
   --with-mirrors=TYPE     Mirror support: internal/shared/none
                           TYPE=internal
+  --with-replicator=TYPE  Replicator support: internal/shared/none
+                          [TYPE=none]
   --with-clvmd=TYPE       Build cluster LVM Daemon.
                           The following cluster manager combinations are valid:
                            * cman,gulm             (RHEL4 or equivalent)
@@ -9326,6 +9330,32 @@ _ACEOF
 fi
 
 ################################################################################
+{ $as_echo "$as_me:$LINENO: checking whether to include replicator" >&5
+$as_echo_n "checking whether to include replicator... " >&6; }
+
+# Check whether --with-replicator was given.
+if test "${with_replicator+set}" = set; then
+  withval=$with_replicator;  REPLICATOR="$withval"
+else
+   REPLICATOR="none"
+fi
+
+{ $as_echo "$as_me:$LINENO: result: $REPLICATOR" >&5
+$as_echo "$REPLICATOR" >&6; }
+
+case "$REPLICATOR" in
+ none|shared) ;;
+ internal)
+cat >>confdefs.h <<\_ACEOF
+#define REPLICATOR_INTERNAL 1
+_ACEOF
+ ;;
+ *) { { $as_echo "$as_me:$LINENO: error: --with-replicator parameter invalid ($REPLICATOR)" >&5
+$as_echo "$as_me: error: --with-replicator parameter invalid ($REPLICATOR)" >&2;}
+   { (exit 1); exit 1; }; } ;;
+esac
+
+################################################################################
 { $as_echo "$as_me:$LINENO: checking whether to enable readline" >&5
 $as_echo_n "checking whether to enable readline... " >&6; }
 # Check whether --enable-readline was given.
@@ -15530,8 +15560,9 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16148,6 +16179,7 @@ do
     "lib/format_pool/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format_pool/Makefile" ;;
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
     "lib/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES lib/mirror/Makefile" ;;
+    "lib/replicator/Makefile") CONFIG_FILES="$CONFIG_FILES lib/replicator/Makefile" ;;
     "lib/misc/lvm-version.h") CONFIG_FILES="$CONFIG_FILES lib/misc/lvm-version.h" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
-- 
1.6.6



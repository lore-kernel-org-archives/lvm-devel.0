From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 30 Nov 2009 12:37:23 +0100
Subject: [PATCH 23/23] Replicator: update of generated configure file
In-Reply-To: <1259581043-15308-23-git-send-email-zkabelac@redhat.com>
References: <1259581043-15308-1-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-2-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-3-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-4-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-5-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-6-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-7-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-8-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-9-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-10-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-11-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-12-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-13-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-14-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-15-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-16-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-17-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-18-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-19-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-20-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-21-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-22-git-send-email-zkabelac@redhat.com>
	<1259581043-15308-23-git-send-email-zkabelac@redhat.com>
Message-ID: <1259581043-15308-24-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 configure |   34 +++++++++++++++++++++++++++++++++-
 1 files changed, 33 insertions(+), 1 deletions(-)

diff --git a/configure b/configure
index 7da2d3c..d01d867 100755
--- a/configure
+++ b/configure
@@ -655,6 +655,7 @@ SELINUX_LIBS
 POOL
 PKGCONFIG
 OWNER
+REPLICATOR
 MIRRORS
 LVM_RELEASE_DATE
 LVM_RELEASE
@@ -814,6 +815,7 @@ with_pool
 with_cluster
 with_snapshots
 with_mirrors
+with_replicator
 enable_readline
 enable_realtime
 with_clvmd
@@ -1546,6 +1548,8 @@ Optional Packages:
                           TYPE=internal
   --with-mirrors=TYPE     Mirror support: internal/shared/none
                           TYPE=internal
+  --with-replicator=TYPE  Replicator support: internal/shared/none
+                          [TYPE=none]
   --with-clvmd=TYPE       Build cluster LVM Daemon.
                           The following cluster manager combinations are valid:
                            * cman,gulm             (RHEL4 or equivalent)
@@ -9325,6 +9329,32 @@ _ACEOF
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
@@ -15525,8 +15555,9 @@ LVM_LIBAPI=`echo "$VER" | $AWK -F '[()]' '{print $2}'`
 
 
 
+
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/replicator/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16143,6 +16174,7 @@ do
     "lib/format_pool/Makefile") CONFIG_FILES="$CONFIG_FILES lib/format_pool/Makefile" ;;
     "lib/locking/Makefile") CONFIG_FILES="$CONFIG_FILES lib/locking/Makefile" ;;
     "lib/mirror/Makefile") CONFIG_FILES="$CONFIG_FILES lib/mirror/Makefile" ;;
+    "lib/replicator/Makefile") CONFIG_FILES="$CONFIG_FILES lib/replicator/Makefile" ;;
     "lib/misc/lvm-version.h") CONFIG_FILES="$CONFIG_FILES lib/misc/lvm-version.h" ;;
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
-- 
1.6.5.3



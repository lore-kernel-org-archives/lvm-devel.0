From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 24 Jan 2011 11:50:33 +0100
Subject: [PATCH 09/15] Testing: Add udev_wait for sfdisk
In-Reply-To: <cover.1295865933.git.zkabelac@redhat.com>
References: <cover.1295865933.git.zkabelac@redhat.com>
Message-ID: <583c86e1e7ace2ea99ba4ed7d44c4e65b6d8e373.1295865933.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

sfdisk needs to wait for device creation by udev
(when /dev is mounted on tmpfs)

mdadm --stop seems to exit before actual node is
deleted on  /dev mounted on  devtmpfs.

-o pipefile produces  exit code 141 (128 + SIGPIPE) when
pipe from dmsetup table | egrep -q  is closed after egrep exit.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 test/api/percent.sh             |    2 +-
 test/lib/aux.sh                 |   10 ++++++++++
 test/lib/check.sh               |    4 +++-
 test/t-pvcreate-operation-md.sh |    8 +++++++-
 4 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/test/api/percent.sh b/test/api/percent.sh
index 52cc799..e93e4cc 100644
--- a/test/api/percent.sh
+++ b/test/api/percent.sh
@@ -23,5 +23,5 @@ lvcreate -s -n snap $vg/foo -l 2 -c 4k
 lvcreate -s -n snap2 $vg/foo -l 6 -c 4k
 dd if=/dev/urandom of=$DM_DEV_DIR/$vg/snap2 count=1 bs=1024
 lvcreate -m 1 -n mirr $vg -l 1 --mirrorlog core
-lvs
+lvs $vg
 aux apitest percent $vg
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 04367ea..89f3bca 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -71,6 +71,7 @@ teardown_devs() {
 
 	}
 
+	udev_wait
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
 	if test -f SCSI_DEBUG_DEV; then
@@ -367,6 +368,15 @@ api() {
 	$abs_top_builddir/test/api/wrapper "$@"
 }
 
+udev_wait() {
+	pgrep udev >/dev/null || return
+        if test -n "$1" ; then
+		udevadm settle --exit-if-exists=$1
+        else
+		udevadm settle --timeout=5 
+        fi
+}
+
 test -f DEVICES && devs=$(cat DEVICES)
 test -f LOOP && LOOP=$(cat LOOP)
 
diff --git a/test/lib/check.sh b/test/lib/check.sh
index 23b6970..ab8ba9e 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -23,7 +23,9 @@
 
 # ...
 
-set -e -o pipefail
+set -e 
+# pipefail doesn't work with breaking pipe output from the larger dmsetup table
+#-o pipefail
 
 trim()
 {
diff --git a/test/t-pvcreate-operation-md.sh b/test/t-pvcreate-operation-md.sh
index a844e32..5085ce1 100644
--- a/test/t-pvcreate-operation-md.sh
+++ b/test/t-pvcreate-operation-md.sh
@@ -34,8 +34,9 @@ mdadm_maj=$(mdadm --version 2>&1 | perl -pi -e 's|.* v(\d+).*|\1|')
 cleanup_md() {
     # sleeps offer hack to defeat: 'md: md127 still in use'
     # see: https://bugzilla.redhat.com/show_bug.cgi?id=509908#c25
-    sleep 2
+    aux udev_wait
     mdadm --stop $mddev || true
+    aux udev_wait
     if [ -b "$mddev" ]; then
         # mdadm doesn't always cleanup the device node
 	sleep 2
@@ -102,6 +103,11 @@ EOF
     base_mddev_p=`basename $mddev_p_sysfs_name`
     mddev_p=/dev/${base_mddev_p}
 
+    # in case the system is running without devtmpfs /dev
+    # wait here for created device node on tmpfs
+    aux udev_wait $mddev_p
+    test -b $mddev_p || exit 200
+
     # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
     # but reliable alignment_offset support requires kernel.org Linux >= 2.6.33
     sysfs_alignment_offset=/sys/dev/block/${mddev_maj_min}/${base_mddev_p}/alignment_offset
-- 
1.7.3.5



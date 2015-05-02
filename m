From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  2 May 2015 22:43:51 +0000 (UTC)
Subject: master - tests: use odirect
Message-ID: <20150502224351.8536060CFD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f6660db7df704d8ba5d855b369b6dfdff4eed1c
Commit:        4f6660db7df704d8ba5d855b369b6dfdff4eed1c
Parent:        74a81a4577ac3934952b3c731f699ef9a789592e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat May 2 21:14:45 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun May 3 00:43:15 2015 +0200

tests: use odirect

Fill snaphot with odirect so we know data hits disk
before we test how full the snapshot is.
---
 test/api/percent.sh                        |    4 ++--
 test/shell/lvextend-snapshot-dmeventd.sh   |    3 +--
 test/shell/snapshot-autoumount-dmeventd.sh |    4 ++--
 test/shell/snapshot-maxsize.sh             |    2 +-
 4 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/test/api/percent.sh b/test/api/percent.sh
index e099497..0031a67 100644
--- a/test/api/percent.sh
+++ b/test/api/percent.sh
@@ -21,9 +21,9 @@ vgcreate -s 4k $vg $(cat DEVICES)
 lvcreate -aey -l 5 -n foo $vg
 lvcreate -s -n snap $vg/foo -l 3 -c 4k
 lvcreate -s -n snap2 $vg/foo -l 6 -c 4k
-dd if=/dev/urandom of="$DM_DEV_DIR/$vg/snap2" count=1 bs=1024
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/snap2" count=1 bs=1024 oflag=direct
 lvcreate -aey --type mirror -m 1 -n mirr $vg -l 1 --mirrorlog core
-lvs $vg
+lvs -a $vg
 aux apitest percent $vg
 
 vgremove -ff $vg
diff --git a/test/shell/lvextend-snapshot-dmeventd.sh b/test/shell/lvextend-snapshot-dmeventd.sh
index c944322..f073a81 100644
--- a/test/shell/lvextend-snapshot-dmeventd.sh
+++ b/test/shell/lvextend-snapshot-dmeventd.sh
@@ -16,8 +16,7 @@ extend() {
 }
 
 write_() {
-	dd if=/dev/zero of="$DM_DEV_DIR/$vg/snap" bs=1k count=$2 seek=$1
-	sync
+	dd if=/dev/zero of="$DM_DEV_DIR/$vg/snap" bs=1k count=$2 seek=$1 oflag=direct
 }
 
 percent_() {
diff --git a/test/shell/snapshot-autoumount-dmeventd.sh b/test/shell/snapshot-autoumount-dmeventd.sh
index 9d5b8c5..db4062e 100644
--- a/test/shell/snapshot-autoumount-dmeventd.sh
+++ b/test/shell/snapshot-autoumount-dmeventd.sh
@@ -32,8 +32,8 @@ mkdir "$mntdir"
 mount "$DM_DEV_DIR/mapper/$vg-snap" "$mntdir"
 mount
 cat /proc/mounts | grep "$mntdir"
-dd if=/dev/zero of="$mntdir/file$1" bs=1M count=5
-sync
+dd if=/dev/zero of="$mntdir/file$1" bs=1M count=5 oflag=direct
+
 #dmeventd only checks every 10 seconds :(
 for i in {1..10}; do
 	cat /proc/mounts | grep "$mntdir" || break
diff --git a/test/shell/snapshot-maxsize.sh b/test/shell/snapshot-maxsize.sh
index f5be5a5..3949f19 100644
--- a/test/shell/snapshot-maxsize.sh
+++ b/test/shell/snapshot-maxsize.sh
@@ -22,7 +22,7 @@ lvcreate -aey -L1 -n $lv1 $vg
 # Snapshot should be large enough to handle any writes
 lvcreate -L2 -s $vg/$lv1 -n $lv2
 
-dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1
+dd if=/dev/zero of="$DM_DEV_DIR/$vg/$lv2" bs=1M count=1 oflag=direct
 
 # Snapshot must not be 'I'nvalid here
 check lv_attr_bit state $vg/$lv2 "a"



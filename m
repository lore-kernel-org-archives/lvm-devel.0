From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Jun 2014 13:24:48 +0000 (UTC)
Subject: master - tests: check new snapshot skills
Message-ID: <20140617132448.3A16361207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=378fa9d1585941a8492830d866377e5f29dff29c
Commit:        378fa9d1585941a8492830d866377e5f29dff29c
Parent:        8403bbd4adabb6718f45f67e5a4a98f6de26dbb6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 17 13:35:40 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 17 13:43:05 2014 +0200

tests: check new snapshot skills

---
 test/shell/snapshot-merge.sh |    2 +-
 test/shell/snapshot-usage.sh |   42 ++++++++++++++++++++++++++++++++++++++----
 2 files changed, 39 insertions(+), 5 deletions(-)

diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index bebc9de..0117cdc 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -33,7 +33,7 @@ setup_merge_() {
 
     if [ $NUM_EXTRA_SNAPS -gt 0 ]; then
 	for i in $(seq 1 $NUM_EXTRA_SNAPS); do
-	    lvcreate -s -n ${BASE_SNAP_LV_NAME}_${i} -l 20%FREE ${VG_NAME}/${LV_NAME}
+	    lvcreate -s -n ${BASE_SNAP_LV_NAME}_${i} -l 20%ORIGIN ${VG_NAME}/${LV_NAME}
 	done
     fi
 }
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 3fc40e3..c0a14c6 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -17,7 +17,8 @@ MKFS=mkfs.ext2
 which $MKFS || skip
 
 fill() {
-	dd if=/dev/zero of="$DM_DEV_DIR/$vg1/lvol0" bs=$1 count=1
+	dd if=/dev/zero of="$DM_DEV_DIR/${2:-$vg1/lvol0}" bs=$1 count=1 oflag=direct || \
+		die "Snapshot does not fit $1"
 }
 
 # Wait until device is opened
@@ -39,9 +40,6 @@ cleanup_tail()
 	aux teardown
 }
 
-aux prepare_pvs 1
-vgcreate -s 4M $vg $(cat DEVICES)
-
 TSIZE=15P
 aux can_use_16T || TSIZE=15T
 
@@ -64,6 +62,21 @@ if aux target_at_least dm-snapshot 1 10 0 ; then
 	fi
 fi
 
+aux prepare_pvs 1
+vgcreate -s 4M $vg $(cat DEVICES)
+
+# Play with 1 extent
+lvcreate -aey -l1 -n $lv $vg
+# 100%LV is not supported for snapshot
+fail lvcreate -s -l 100%LV -n snap $vg/$lv |& tee out
+grep 'Please express size as %ORIGIN, %VG, %PVS, or %FREE' out
+# 100%ORIGIN needs to have enough space for all data and needs to round-up
+lvcreate -s -l 100%ORIGIN -n $lv1 $vg/$lv
+# everything needs to fit
+fill 4M $vg/$lv1
+lvremove -f $vg
+
+
 # Automatically activates exclusively in cluster
 lvcreate -s -l 100%FREE -n $lv $vg --virtualsize $TSIZE
 
@@ -76,6 +89,27 @@ pvcreate --setphysicalvolumesize 4T "$DM_DEV_DIR/$vg/$lv"
 trap 'cleanup_tail' EXIT
 vgcreate -s 1K $vg1 "$DM_DEV_DIR/$vg/$lv"
 
+
+# Play with small 1k 128 extents
+lvcreate -aey -L128K -n $lv $vg1
+# 100%ORIGIN needs to have enough space for all data
+lvcreate -s -l 100%ORIGIN -n snap100 $vg1/$lv
+# everything needs to fit
+fill 128k $vg1/snap100
+
+# 50%ORIGIN needs to have enough space for 50% of data
+lvcreate -s -l 50%ORIGIN -n snap50 $vg1/$lv
+fill 64k $vg1/snap50
+
+lvcreate -s -l 25%ORIGIN -n snap25 $vg1/$lv
+fill 32k $vg1/snap25
+
+# Check we do not provide too much extra space
+not fill 33k $vg1/snap25
+
+lvs -a $vg1
+lvremove -f $vg1
+
 # Test virtual snapshot over /dev/zero
 lvcreate -V50 -L10 -n $lv1 -s $vg1
 CHECK_ACTIVE="active"



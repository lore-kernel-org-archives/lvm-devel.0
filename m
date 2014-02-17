From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Feb 2014 21:26:36 +0000 (UTC)
Subject: master - thin: fix merge of old snaphost
Message-ID: <20140217212636.21E3C60F70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25cea92338876f7ed02b05652a2de3f28c9bae1c
Commit:        25cea92338876f7ed02b05652a2de3f28c9bae1c
Parent:        f33a224ef016f2071d7f0f6fdacfe56d98c3c58a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 17 21:48:27 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 17 22:25:53 2014 +0100

thin: fix merge of old snaphost

Fix merging of old snapshot into thinvolume origin.
Add also internal error for the error case when
merging requests activation of merged LV.
---
 WHATS_NEW                     |    1 +
 lib/metadata/snapshot_manip.c |    3 ++-
 lib/thin/thin.c               |   11 ++++++-----
 test/shell/thin-merge.sh      |   15 +++++++++------
 tools/lvconvert.c             |    2 +-
 5 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c02fcae..03a3b8a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix merging of old snapshot into thin volume origin.
   Use --ignoreskippedcluster in lvm2-monitor initscript/systemd unit.
   Do not use VG read/write state for LV read/write state.
   Use --ignoreskippedcluster in activation systemd units if use_lvmetad=0.
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index e563a78..362c805 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -15,6 +15,7 @@
 
 #include "lib.h"
 #include "metadata.h"
+#include "segtype.h"
 #include "locking.h"
 #include "toolcontext.h"
 #include "lv_alloc.h"
@@ -151,7 +152,7 @@ void init_snapshot_merge(struct lv_segment *snap_seg,
 	origin->snapshot = snap_seg;
 	origin->status |= MERGING;
 
-	if (lv_is_thin_volume(origin)) {
+	if (seg_is_thin_volume(snap_seg)) {
 		snap_seg->merge_lv = origin;
 		/* Making thin LV inivisible with regular log */
 		lv_set_hidden(snap_seg->lv);
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 8eaa73d..92767a8 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -542,18 +542,19 @@ static int _thin_add_target_line(struct dev_manager *dm,
 	}
 
 	if (!laopts->no_merging) {
+		if (seg->merge_lv) {
+			log_error(INTERNAL_ERROR "Failed to add merged segment of %s.",
+				  seg->lv->name);
+			return 0;
+		}
 		/*
 		 * merge support for thinp snapshots is implemented by
 		 * simply swapping the thinp device_id of the snapshot
 		 * and origin.
 		 */
-		if (seg->merge_lv) {
-			/* snapshot, use merging lv's device_id */
-			device_id = first_seg(seg->merge_lv)->device_id;
-		} else if (lv_is_merging_origin(seg->lv)) {
+		if (lv_is_merging_origin(seg->lv) && seg_is_thin_volume(find_snapshot(seg->lv)))
 			/* origin, use merging snapshot's device_id */
 			device_id = find_snapshot(seg->lv)->device_id;
-		}
 	}
 
 	if (!dm_tree_node_add_thin_target(node, len, pool_dlid, device_id))
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index 10a81f0..0bb5ee7 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -13,7 +13,8 @@
 
 . lib/test
 
-which mkfs.ext2 || skip
+MKFS=mkfs.ext2
+which $MKFS  || skip
 which fsck || skip
 
 #
@@ -27,13 +28,13 @@ lvcreate -T -L8M $vg/pool -V10M -n $lv1
 lvchange --addtag tagL $vg/$lv1
 
 mkdir mnt
-mkfs.ext2 $DM_DEV_DIR/$vg/$lv1
+$MKFS $DM_DEV_DIR/$vg/$lv1
 mount $DM_DEV_DIR/$vg/$lv1 mnt
 touch mnt/test
 
 lvcreate -K -s -n snap --addtag tagS $vg/$lv1
 mkdir mntsnap
-mkfs.ext2 $DM_DEV_DIR/$vg/snap
+$MKFS $DM_DEV_DIR/$vg/snap
 mount $DM_DEV_DIR/$vg/snap mntsnap
 touch mntsnap/test_snap
 
@@ -82,7 +83,7 @@ lvchange -ay $vg/$lv1
 check lv_exists $vg $lv1
 check lv_field  $vg/$lv1 thin_id "2"
 check lv_field $vg/$lv1 tags "tagL"
-not check lv_exists $vg snap
+check lv_not_exists $vg snap
 
 fsck -n $DM_DEV_DIR/$vg/$lv1
 mount $DM_DEV_DIR/$vg/$lv1 mnt
@@ -97,8 +98,10 @@ lvcreate -s -n snap $vg/$lv1
 # Also add old snapshot to thin origin
 lvcreate -s -L10 -n oldsnapof_${lv1} $vg/$lv1
 not lvconvert --merge $vg/snap
-lvremove -f $vg/oldsnapof_${lv1}
-
+$MKFS $DM_DEV_DIR/$vg/oldsnapof_${lv1}
+lvconvert --merge $vg/oldsnapof_${lv1}
+fsck -n $DM_DEV_DIR/$vg/$lv1
+check lv_not_exists $vg oldsnapof_${lv1}
 # Add old snapshot to thin snapshot
 lvcreate -s -L10 -n oldsnapof_snap $vg/snap
 lvconvert --merge $vg/snap
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index d53b83a..7fc1949 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -897,7 +897,7 @@ int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (lv_is_merging_origin(lv))
 		return poll_daemon(cmd, lv_full_name, uuid, background, 0,
-				   lv_is_thin_volume(lv) ?
+				   seg_is_thin_volume(find_snapshot(lv)) ?
 				   &_lvconvert_thin_merge_fns : &_lvconvert_merge_fns,
 				   "Merged");
 



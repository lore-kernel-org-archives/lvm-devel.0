From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:34:38 +0000 (UTC)
Subject: master - raid: fix raid1 to mirror conversion
Message-ID: <20161211223438.CDD2F60C4A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c8369099bc6105f39982b3e36dd9a53c347b07a
Commit:        0c8369099bc6105f39982b3e36dd9a53c347b07a
Parent:        31564834db7610b37f52040fbba89f4c71de4c34
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 10 20:01:05 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:17:22 2016 +0100

raid: fix raid1 to mirror conversion

Fix order of operation when converting raid1 into old mirror.
Before any later metadata modification are initiated prepare
mirror_log device with all clearing.
Then directly convert  raid1 into mirror with mirror_log.
This convertion now properly see as precommitted metadata
new 'mirror' and committed old 'raid' and is able to
preload all LVs.
---
 WHATS_NEW                 |    1 +
 lib/metadata/raid_manip.c |   13 +++++++------
 2 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 274430f..74627ba 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Fix lvconvert raid1 to mirror table reload order.
   Add internal function for separate mirror log preparation.
   Fix segfault in lvmetad from missing NULL in daemon_reply_simple.
   Simplify internal _info_run() and use _setup_task_run() for mknod.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 7c4ce61..5cbd819 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2207,6 +2207,7 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 				    int update_and_reload,
 				    struct dm_list *removal_lvs)
 {
+	struct logical_volume *log_lv;
 	struct lv_segment *seg = first_seg(lv);
 
 	if (!seg_is_raid1(seg)) {
@@ -2227,7 +2228,10 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 		return 0;
 	}
 
-	init_mirror_in_sync(new_image_count > seg->area_count ? 0 : 1);
+	if (!(log_lv = prepare_mirror_log(lv, (new_image_count <= seg->area_count) /* in sync */,
+					  new_region_size,
+					  allocate_pvs, lv->vg->alloc)))
+		return_0; /* TODO remove log_lv on error path */
 
 	/* Change image pair count to requested # of images */
 	if (new_image_count != seg->area_count) {
@@ -2255,11 +2259,8 @@ static int _convert_raid1_to_mirror(struct logical_volume *lv,
 	seg->status &= ~RAID;
 	lv->status |= (MIRROR | MIRRORED);
 
-	/* Add mirror_log LV (should happen in wih image allocation */
-	if (!add_mirror_log(lv->vg->cmd, lv, 1, seg->region_size, allocate_pvs, lv->vg->alloc)) {
-		log_error("Unable to add mirror log to %s.", display_lvname(lv));
-		return 0;
-	}
+	if (!attach_mirror_log(first_seg(lv), log_lv))
+		return_0;
 
 	return update_and_reload ? _lv_update_reload_fns_reset_eliminate_lvs(lv, removal_lvs) : 1;
 }



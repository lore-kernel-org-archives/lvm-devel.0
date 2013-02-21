From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 21 Feb 2013 13:11:37 +0000 (UTC)
Subject: master - RAID: Make 'vgreduce --removemissing' work with RAID LVs
Message-ID: <20130221131137.9D4511465@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=845852d6b4b486075f3ed866890f79b278a990ce
Commit:        845852d6b4b486075f3ed866890f79b278a990ce
Parent:        0e4ffd9d3b9cc8bf88662e3a0d023602360c6993
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Feb 20 14:52:46 2013 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Feb 20 14:52:46 2013 -0600

RAID: Make 'vgreduce --removemissing' work with RAID LVs

Currently it is impossible to remove a failed PV which has a RAID LV
on it.  This patch fixes the issue by replacing the failed PV with an
'error' segment within the affected sub-LVs.  Once there is no longer
a RAID LV using the PV, it can be removed.

Most often, it is better to replace a failed RAID device with a spare.
(You can use 'lvconvert --repair <vg>/<LV>' to accomplish that.)
However, if there are no spares in the volume group and none will be
added, it is useful to be able to removed the failed device.

Following patches address the ability to perform 'lvconvert' operations
on RAID LVs that contain sub-LVs composed of 'error' segments.
---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/raid_manip.c        |   64 ++++++++++++++++++++++++++++++++++++++
 tools/vgreduce.c                 |    6 +++
 4 files changed, 72 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f827508..d237386 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Make 'vgreduce --removemissing' able to handle RAID LVs with missing PVs.
   Rename lvm.conf setting 'mirror_region_size' to 'raid_region_size'.
   Fix pvs -o pv_free reporting for PVs with zero PE count.
   Fix missing cleanup of flags when the LV is detached from pool.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 406491c..890aa18 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -808,6 +808,7 @@ int lv_raid_reshape(struct logical_volume *lv,
 		    const struct segment_type *new_segtype);
 int lv_raid_replace(struct logical_volume *lv, struct dm_list *remove_pvs,
 		    struct dm_list *allocate_pvs);
+int lv_raid_remove_missing(struct logical_volume *lv);
 
 /* --  metadata/raid_manip.c */
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 896ad42..74bb80a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1853,3 +1853,67 @@ try_again:
 
 	return 1;
 }
+
+int lv_raid_remove_missing(struct logical_volume *lv)
+{
+	uint32_t s, lvl_idx;
+	struct lv_segment *seg = first_seg(lv);
+	struct cmd_context *cmd = lv->vg->cmd;
+
+	if (!(lv->status & PARTIAL_LV)) {
+		log_error(INTERNAL_ERROR "%s/%s is not a partial LV",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	log_debug("Attempting to remove missing devices from %s LV, %s",
+		  seg->segtype->ops->name(seg), lv->name);
+
+	/*
+	 * FIXME: Make sure # of compromised components will not affect RAID
+	 */
+
+	for (s = 0, lvl_idx = 0; s < seg->area_count; s++) {
+		if (!(seg_lv(seg, s)->status & PARTIAL_LV) &&
+		    !(seg_metalv(seg, s)->status & PARTIAL_LV))
+			continue;
+
+		log_debug("Replacing %s and %s segments with error target",
+			  seg_lv(seg, s)->name, seg_metalv(seg, s)->name);
+		if (!replace_lv_with_error_segment(seg_lv(seg, s))) {
+			log_error("Failed to replace %s/%s's extents"
+				  " with error target", lv->vg->name,
+				  seg_lv(seg, s)->name);
+			return 0;
+		}
+		if (!replace_lv_with_error_segment(seg_metalv(seg, s))) {
+			log_error("Failed to replace %s/%s's extents"
+				  " with error target", lv->vg->name,
+				  seg_metalv(seg, s)->name);
+			return 0;
+		}
+	}
+
+	if (!vg_write(lv->vg)) {
+		log_error("Failed to write changes to %s in %s",
+			  lv->name, lv->vg->name);
+		return 0;
+	}
+
+	if (!suspend_lv(cmd, lv)) {
+		log_error("Failed to suspend %s/%s before committing changes",
+			  lv->vg->name, lv->name);
+		return 0;
+	}
+
+	if (!vg_commit(lv->vg)) {
+		log_error("Failed to commit changes to %s in %s",
+			  lv->name, lv->vg->name);
+		return 0;
+	}
+
+	if (!resume_lv(cmd, lv))
+		return_0;
+
+	return 1;
+}
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 1b04a49..c068b26 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -89,6 +89,12 @@ static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 
 		/* Are any segments of this LV on missing PVs? */
 		if (lv->status & PARTIAL_LV) {
+			if (seg_is_raid(first_seg(lv))) {
+				if (!lv_raid_remove_missing(lv))
+					return_0;
+				goto restart;
+			}
+
 			if (lv->status & MIRRORED) {
 				if (!mirror_remove_missing(cmd, lv, 1))
 					return_0;



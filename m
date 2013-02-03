From: Jonathan Brassow <jbrassow@redhat.com>
Date: Sun, 03 Feb 2013 02:29:53 -0600
Subject: [PATCH 1 of 3] Make 'vgreduce --removemissing' work with RAID LVs
In-Reply-To: <1359880051.15387.8.camel@f16>
References: <1359880051.15387.8.camel@f16>
Message-ID: <1359880193.15387.10.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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


Index: lvm2/lib/metadata/metadata-exported.h
===================================================================
--- lvm2.orig/lib/metadata/metadata-exported.h
+++ lvm2/lib/metadata/metadata-exported.h
@@ -807,6 +807,7 @@ int lv_raid_reshape(struct logical_volum
 		    const struct segment_type *new_segtype);
 int lv_raid_replace(struct logical_volume *lv, struct dm_list *remove_pvs,
 		    struct dm_list *allocate_pvs);
+int lv_raid_remove_missing(struct logical_volume *lv);
 
 /* --  metadata/raid_manip.c */
 
Index: lvm2/tools/vgreduce.c
===================================================================
--- lvm2.orig/tools/vgreduce.c
+++ lvm2/tools/vgreduce.c
@@ -89,6 +89,12 @@ static int _make_vg_consistent(struct cm
 
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
Index: lvm2/lib/metadata/raid_manip.c
===================================================================
--- lvm2.orig/lib/metadata/raid_manip.c
+++ lvm2/lib/metadata/raid_manip.c
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




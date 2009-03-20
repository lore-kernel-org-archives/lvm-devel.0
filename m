From: Milan Broz <mbroz@redhat.com>
Date: Fri, 20 Mar 2009 18:44:30 +0100
Subject: [PATCH] fix following problems if max_lv is set
Message-ID: <49C3D5FE.6090001@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix the last fix for max_lv....

The vg->lv_count is now confusing:
during the metadata parsing it counts all volumes, later
it contains only user visible ones.

Unfortunately change that is too risky, so for now use this workaround:

When checking for max_lv violation:
	- ignore the check if adding snapshot (import = 1 is set)
	(the check applies before when creating COW)
	- on other places, check max_lv against actual count
	of visible LVs (including snapshots)

Temporarily disable the vg_validate check, mirror conversion
violates max LV # (during downconversion it removes mirror image
flag and sets visible flag for all removed images, activates VG,
and later removes these "orphan" LVs...)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c       |    2 +-
 lib/metadata/metadata.c       |   20 +++++++++++++++++---
 lib/metadata/metadata.h       |    2 ++
 lib/metadata/snapshot_manip.c |    9 ++++-----
 test/t-lvcreate-usage.sh      |    4 ++++
 tools/vgchange.c              |    5 +++--
 6 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2661e0c..687a88b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1832,7 +1832,7 @@ struct logical_volume *lv_create_empty(const char *name,
 	struct logical_volume *lv;
 	char dname[NAME_LEN];
 
-	if (vg->max_lv && (vg->max_lv == vg->lv_count)) {
+	if (!import && vg->max_lv && (vg->max_lv == visible_lvs_in_vg(vg))) {
 		log_error("Maximum number of logical volumes (%u) reached "
 			  "in volume group %s", vg->max_lv, vg->name);
 		return NULL;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7848d82..c6991ab 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1124,6 +1124,18 @@ unsigned displayable_lvs_in_vg(const struct volume_group *vg)
 	return lv_count;
 }
 
+unsigned visible_lvs_in_vg(const struct volume_group *vg)
+{
+	struct lv_list *lvl;
+	unsigned lv_count = 0;
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		if (lvl->lv->status & VISIBLE_LV)
+			lv_count++;
+
+	return lv_count;
+}
+
 /*
  * Determine whether two vgs are compatible for merging.
  */
@@ -1158,7 +1170,7 @@ int vgs_are_compatible(struct cmd_context *cmd __attribute((unused)),
 	}
 
 	if (vg_to->max_lv &&
-	    (vg_to->max_lv < vg_to->lv_count + vg_from->lv_count)) {
+	    (vg_to->max_lv < visible_lvs_in_vg(vg_to) + visible_lvs_in_vg(vg_from))) {
 		log_error("Maximum number of logical volumes (%d) exceeded "
 			  " for \"%s\" and \"%s\"", vg_to->max_lv, vg_to->name,
 			  vg_from->name);
@@ -1461,12 +1473,14 @@ int vg_validate(struct volume_group *vg)
 		r = 0;
 	}
 
-	if (vg->max_lv && (vg->max_lv < vg->lv_count)) {
+	/* FIXME: mirror conversion violates this temporarily
+	if (vg->max_lv && (vg->max_lv < visible_lvs_in_vg(vg))) {
 		log_error("Internal error: Volume group %s contains %u volumes"
 			  " but the limit is set to %u.",
-			  vg->name, vg->lv_count, vg->max_lv);
+			  vg->name, visible_lvs_in_vg(vg), vg->max_lv);
 		r = 0;
 	}
+	*/
 
 	return r;
 }
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index fbcf82b..11e9fe7 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -339,8 +339,10 @@ struct lv_segment *get_only_segment_using_this_lv(struct logical_volume *lv);
 
 /*
  * Count LVs that are visible from user's perspective.
+ * FIXME: confusing, displayable doesn't count snapshots
  */
 unsigned displayable_lvs_in_vg(const struct volume_group *vg);
+unsigned visible_lvs_in_vg(const struct volume_group *vg);
 
 /*
  * For internal metadata caching.
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 3955382..d4441db 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -77,15 +77,15 @@ int vg_add_snapshot(const char *name, struct logical_volume *origin,
 	}
 
 	/*
-	 * Set origin lv count in advance to prevent fail because
+	 * Hide origin lv in advance to prevent fail because
 	 * of temporary violation of LV limits.
 	 */
-	origin->vg->lv_count--;
+	cow->status &= ~VISIBLE_LV;
 
 	if (!(snap = lv_create_empty(name ? name : "snapshot%d",
 				     lvid, LVM_READ | LVM_WRITE | VISIBLE_LV,
 				     ALLOC_INHERIT, 1, origin->vg))) {
-		origin->vg->lv_count++;
+		cow->status |= VISIBLE_LV;
 		return_0;
 	}
 
@@ -99,12 +99,11 @@ int vg_add_snapshot(const char *name, struct logical_volume *origin,
 	seg->cow = cow;
 	seg->lv->status |= SNAPSHOT;
 
+	origin->vg->lv_count--;
 	origin->origin_count++;
 	origin->vg->snapshot_count++;
 	cow->snapshot = seg;
 
-	cow->status &= ~VISIBLE_LV;
-
 	dm_list_add(&origin->snapshot_segs, &seg->origin_list);
 
 	return 1;
diff --git a/test/t-lvcreate-usage.sh b/test/t-lvcreate-usage.sh
index 13abbdf..cd3e3c7 100755
--- a/test/t-lvcreate-usage.sh
+++ b/test/t-lvcreate-usage.sh
@@ -65,5 +65,9 @@ lvcreate -l1 -s -n $lv2 $vg/$lv1
 lvcreate -l1 -n $lv3 $vg
 not lvcreate -l1 -n $lv4 $vg
 vgs $vg
+lvremove -ff $vg/$lv3
+lvcreate -l1 -s -n $lv3 $vg/$lv1
+not lvcreate -l1 -s -n $lv4 $vg/$lv1
+# FIXME add mirror & lvconvert tests
 lvremove -ff $vg
 vgchange -l 0 $vg
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 8831a23..27335c6 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -14,6 +14,7 @@
  */
 
 #include "tools.h"
+#include "metadata.h"
 
 static int _monitor_lvs_in_vg(struct cmd_context *cmd,
 			       struct volume_group *vg, int reg)
@@ -308,9 +309,9 @@ static int _vgchange_logicalvolume(struct cmd_context *cmd,
 		}
 	}
 
-	if (max_lv && max_lv < vg->lv_count) {
+	if (max_lv && max_lv < visible_lvs_in_vg(vg)) {
 		log_error("MaxLogicalVolume is less than the current number "
-			  "%d of LVs for \"%s\"", vg->lv_count,
+			  "%d of LVs for \"%s\"", visible_lvs_in_vg(vg),
 			  vg->name);
 		return ECMD_FAILED;
 	}




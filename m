From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Fri, 23 Aug 2013 14:10:52 +0000 (UTC)
Subject: master - pvmove: Add support for RAID, mirror, and thin
Message-ID: <20130823141052.903BA60D31@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c59167ec132071d6ab53f928b0775c36a704fe7c
Commit:        c59167ec132071d6ab53f928b0775c36a704fe7c
Parent:        e5c021316843a3b08e4f6d12ec27f06c20ded7da
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Aug 23 08:57:16 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Aug 23 08:57:16 2013 -0500

pvmove: Add support for RAID, mirror, and thin

This patch allows pvmove to operate on RAID, mirror and thin LVs.
The key component is the ability to avoid moving a RAID or mirror
sub-LV onto a PV that already has another RAID sub-LV on it.
(e.g. Avoid placing both images of a RAID1 LV on the same PV.)

Top-level LVs are processed to determine which PVs to avoid for
the sake of redundancy, while bottom-level LVs are processed
to determine which segments/extents to move.

This approach does have some drawbacks.  By eliminating whole PVs
from the allocation list, we might miss the opportunity to perform
pvmove in some senarios.  For example, if we have 3 devices and
a linear uses half of the first, a RAID1 uses half of the first and
half of the second, and a linear uses half of the third (FIGURE 1);
we should be able to pvmove the first device (FIGURE 2).
	FIGURE 1:
        [ linear ] [ -RAID- ] [ linear ]
        [ -RAID- ] [        ] [        ]

	FIGURE 2:
        [  moved ] [ -RAID- ] [ linear ]
        [  moved ] [ linear ] [ -RAID- ]
However, the approach we are using would eliminate the second
device from consideration and would leave us with too little space
for allocation.  In these situations, the user does have the ability
to specify LVs and move them one at a time.
---
 WHATS_NEW       |    1 +
 man/pvmove.8.in |    5 +-
 tools/pvmove.c  |  124 ++++++++++++++++++++++++++++++++++++++++++------------
 3 files changed, 100 insertions(+), 30 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 76c2ebb..3ea8786 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Add ability to pvmove RAID, mirror, and thin volumes.
   Make lvm2-activation-generator silent unless it's in error state.
   Remove "mpath major is not dm major" msg for mpath component scan (2.02.94).
   Prevent cluster mirror logs from being corrupted by redundant checkpoints.
diff --git a/man/pvmove.8.in b/man/pvmove.8.in
index de20abb..ba6ea1e 100644
--- a/man/pvmove.8.in
+++ b/man/pvmove.8.in
@@ -75,7 +75,8 @@ is updated so that the Logical Volumes reflect the new data locations.
 Note that this new process cannot support the original LVM1
 type of on-disk metadata.  Metadata can be converted using \fBvgconvert\fP(8).
 
-N.B. The moving of mirrors, snapshots and their origins is not yet supported.
+N.B. The moving of non-thinly provisioned snapshots and their
+origins is not supported.
 
 .SH OPTIONS
 See \fBlvm\fP(8) for common options.
@@ -109,7 +110,7 @@ To move all Physical Extents that are used by simple Logical Volumes on
 .sp
 .B pvmove /dev/sdb1
 .P
-Any mirrors, snapshots and their origins are left unchanged.
+Any non-thinly provisioned snapshots and their origins are left unchanged.
 .P
 Additionally, a specific destination device /dev/sdc1
 can be specified like this:
diff --git a/tools/pvmove.c b/tools/pvmove.c
index cb5c9ec..34adc6d 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -135,6 +135,47 @@ static struct dm_list *_get_allocatable_pvs(struct cmd_context *cmd, int argc,
 }
 
 /*
+ * _trim_allocatable_pvs
+ * @alloc_list
+ * @trim_list
+ *
+ * Remove PVs in 'trim_list' from 'alloc_list'.
+ *
+ * Returns: 1 on success, 0 on error
+ */
+static int _trim_allocatable_pvs(struct dm_list *alloc_list,
+				 struct dm_list *trim_list,
+				 alloc_policy_t alloc)
+{
+	struct dm_list *pvht, *pvh, *trim_pvh;
+	struct pv_list *pvl, *trim_pvl;
+
+	if (!alloc_list) {
+		log_error(INTERNAL_ERROR "alloc_list is NULL");
+		return 0;
+	}
+
+	if (!trim_list || dm_list_empty(trim_list))
+		return 1; /* alloc_list stays the same */
+
+	dm_list_iterate_safe(pvh, pvht, alloc_list) {
+		pvl = dm_list_item(pvh, struct pv_list);
+
+		dm_list_iterate(trim_pvh, trim_list) {
+			trim_pvl = dm_list_item(trim_pvh, struct pv_list);
+
+			/* Don't allocate onto a trim PV */
+			if ((alloc != ALLOC_ANYWHERE) &&
+			    (pvl->pv == trim_pvl->pv)) {
+				dm_list_del(&pvl->list);
+				break;  /* goto next in alloc_list */
+			}
+		}
+	}
+	return 1;
+}
+
+/*
  * Replace any LV segments on given PV with temporary mirror.
  * Returns list of LVs changed.
  */
@@ -181,6 +222,7 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 	struct logical_volume *lv_mirr, *lv;
 	struct lv_segment *seg;
 	struct lv_list *lvl;
+	struct dm_list trim_list;
 	uint32_t log_count = 0;
 	int lv_found = 0;
 	int lv_skipped = 0;
@@ -204,7 +246,50 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 
 	dm_list_init(*lvs_changed);
 
-	/* Find segments to be moved and set up mirrors */
+	/*
+	 * First,
+	 * use top-level RAID and mirror LVs to build a list of PVs
+	 * that must be avoided during allocation.  This is necessary
+	 * to maintain redundancy of those targets, but it is also
+	 * sub-optimal.  Avoiding entire PVs in this way limits our
+	 * ability to find space for other segment types.  In the
+	 * majority of cases, however, this method will suffice and
+	 * in the cases where it does not, the user can issue the
+	 * pvmove on a per-LV basis.
+	 *
+	 * FIXME: Eliminating entire PVs places too many restrictions
+	 *        on allocation.
+	 */
+	dm_list_iterate_items(lvl, &vg->lvs) {
+		lv = lvl->lv;
+		if (lv == lv_mirr)
+			continue;
+
+		if (lv_name && strcmp(lv->name, lv_name))
+			continue;
+
+		if (!lv_is_on_pvs(lv, source_pvl))
+			continue;
+
+		if (seg_is_raid(first_seg(lv)) ||
+		    seg_is_mirrored(first_seg(lv))) {
+			dm_list_init(&trim_list);
+
+			if (!get_pv_list_for_lv(lv->vg->cmd->mem,
+						lv, &trim_list))
+				return_NULL;
+
+			if (!_trim_allocatable_pvs(allocatable_pvs,
+						   &trim_list, alloc))
+				return_NULL;
+		}
+	}
+
+	/*
+	 * Second,
+	 * use bottom-level LVs (like *_mimage_*, *_mlog, *_rmeta_*, etc)
+	 * to find segments to be moved and then set up mirrors.
+	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 		if (lv == lv_mirr)
@@ -214,38 +299,21 @@ static struct logical_volume *_set_up_pvmove_lv(struct cmd_context *cmd,
 				continue;
 			lv_found = 1;
 		}
+
+		if (!lv_is_on_pvs(lv, source_pvl))
+			continue;
+
 		if (lv_is_origin(lv) || lv_is_cow(lv)) {
 			lv_skipped = 1;
 			log_print_unless_silent("Skipping snapshot-related LV %s", lv->name);
 			continue;
 		}
-		if (lv_is_raid_type(lv)) {
-			seg = first_seg(lv);
-			if (seg_is_raid(seg)) {
-				lv_skipped = 1;
-				log_print_unless_silent("Skipping %s LV %s",
-							seg->segtype->ops->name(seg),
-							lv->name);
-				continue;
-			}
-			lv_skipped = 1;
-			log_print_unless_silent("Skipping RAID sub-LV %s",
-						lv->name);
-			continue;
-		}
-		if (lv->status & MIRRORED) {
-			lv_skipped = 1;
-			log_print_unless_silent("Skipping mirror LV %s", lv->name);
-			continue;
-		}
-		if (lv->status & MIRROR_LOG) {
-			lv_skipped = 1;
-			log_print_unless_silent("Skipping mirror log LV %s", lv->name);
-			continue;
-		}
-		if (lv->status & MIRROR_IMAGE) {
-			lv_skipped = 1;
-			log_print_unless_silent("Skipping mirror image LV %s", lv->name);
+		seg = first_seg(lv);
+		if (seg_is_raid(seg) || seg_is_mirrored(seg)) {
+			/*
+			 * Pass over top-level LVs - they were handled.
+			 * Allow sub-LVs to proceed.
+			 */
 			continue;
 		}
 		if (lv_is_thin_volume(lv) || lv_is_thin_pool(lv)) {



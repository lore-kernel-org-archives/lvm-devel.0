From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 24 Mar 2015 07:43:32 +0000 (UTC)
Subject: master - metadata: vg: add removed_lvs field to collect LVs which have been removed
Message-ID: <20150324074332.39BA361171@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8759f7d755cec7286d1bccda3a323b12481d5738
Commit:        8759f7d755cec7286d1bccda3a323b12481d5738
Parent:        c9f021de0b4d2c873ef5b97d17c602d0380359fd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Mar 23 13:32:00 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 24 08:43:08 2015 +0100

metadata: vg: add removed_lvs field to collect LVs which have been removed

Do not keep dangling LVs if they're removed from the vg->lvs list and
move them to vg->removed_lvs instead (this is actually similar to already
existing vg->removed_pvs list, just it's for LVs now).

Once we have this vg->removed_lvs list indexed so it's possible to
do lookups for LVs quickly, we can remove the LV_REMOVED flag as
that one won't be needed anymore - instead of checking the flag,
we can directly check the vg->removed_lvs list if the LV is present
there or not and to say if the LV is removed or not then. For now,
we don't have this index, but it may be implemented in the future.
---
 lib/metadata/lv_manip.c          |    2 +-
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/metadata.c          |   14 ++++++++++++++
 lib/metadata/vg.c                |    1 +
 lib/metadata/vg.h                |    5 +++++
 tools/toollib.c                  |    5 +++++
 6 files changed, 28 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b9cd056..99fb91f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5350,7 +5350,7 @@ int unlink_lv_from_vg(struct logical_volume *lv)
 	if (!(lvl = find_lv_in_vg(lv->vg, lv->name)))
 		return_0;
 
-	dm_list_del(&lvl->list);
+	dm_list_move(&lv->vg->removed_lvs, &lvl->list);
 	lv->status |= LV_REMOVED;
 
 	return 1;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 75cd94f..47fb9ae 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -125,6 +125,8 @@
 								   be referenced on internal lists of LVs.
 								   Any remaining references should check for
 								   this flag and ignore the LV is set.
+								   FIXME: Remove this flag once we have indexed
+									  vg->removed_lvs for quick lookup.
 								*/
 #define LV_ERROR_WHEN_FULL	UINT64_C(0x0008000000000000)    /* LV - error when full */
 #define PV_ALLOCATION_PROHIBITED	UINT64_C(0x0010000000000000)	/* PV - internal use only - allocation prohibited
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 33ce370..a1a31eb 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2568,12 +2568,26 @@ int vg_validate(struct volume_group *vg)
 		r = 0;
 	}
 
+	dm_list_iterate_items(lvl, &vg->removed_lvs) {
+		if (!(lvl->lv->status & LV_REMOVED)) {
+			log_error(INTERNAL_ERROR "LV %s is not marked as removed while it's part "
+				  "of removed LV list for VG %s", lvl->lv->name, vg->name);
+			r = 0;
+		}
+	}
+
 	/*
 	 * Count all non-snapshot invisible LVs
 	 */
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv_count++;
 
+		if (lvl->lv->status & LV_REMOVED) {
+			log_error(INTERNAL_ERROR "LV %s is marked as removed while it's "
+				  "still part of the VG %s", lvl->lv->name, vg->name);
+			r = 0;
+		}
+
 		if (lvl->lv->status & LVM_WRITE_LOCKED) {
 			log_error(INTERNAL_ERROR "LV %s has external flag LVM_WRITE_LOCKED set internally.",
 				  lvl->lv->name);
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 404cc6f..c9a7e9e 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -63,6 +63,7 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 	dm_list_init(&vg->pvs_to_create);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	dm_list_init(&vg->removed_lvs);
 	dm_list_init(&vg->removed_pvs);
 
 	log_debug_mem("Allocated VG %s at %p.", vg->name, vg);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 67a04a0..b0ab122 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -113,6 +113,11 @@ struct volume_group {
 	 */
 
 	/*
+	 * List of removed logical volumes by _lv_reduce.
+	 */
+	struct dm_list removed_lvs;
+
+	/*
 	 * List of removed physical volumes by pvreduce.
 	 * They have to get cleared on vg_commit.
 	 */
diff --git a/tools/toollib.c b/tools/toollib.c
index be89450..142ff33 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2061,6 +2061,11 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	dm_list_iterate_items(lvl, &final_lvs) {
+		/*
+		 *  FIXME: Once we have index over vg->removed_lvs, check directly
+		 *         LV presence there and remove LV_REMOVE flag/lv_is_removed fn
+		 *         as they won't be needed anymore.
+		 */
 		if (lv_is_removed(lvl->lv))
 			continue;
 



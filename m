From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 22 Apr 2013 11:08:31 +0200
Subject: [PATCH 2/2] snapshot: rework creation and removal of snapshots
In-Reply-To: <cover.1366621483.git.zkabelac@redhat.com>
References: <cover.1366621483.git.zkabelac@redhat.com>
Message-ID: <ed82c4d6f0be41857b015685a38f4ad079176653.1366621483.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Support for exclusive activation of snapshot revealed some problems.

When snapshot is created, COW LV is activated first (for clearing) and
then it's been transformed into snapshot's LV, but it has left lock for
such LV active and this lock could not have been removed from dlm,
unless snapshot has been removed within same dlm session.

If the snapshot was removed after rebooting node, the lock is missing,
and COW LV cannot be detached.

Patch modifes the approach in this way:

Always deactivate COW LV after clearing (so it's activated again via
imlicit snapshot activation rule when snapshot is activated).

When snapshot is removed, activate COW LV as independend LV, so the lock
will exist for such LV, but only in case, the snapshot is active.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/lv_manip.c       | 15 +++++----------
 lib/metadata/snapshot_manip.c | 33 ++++++++++++++++++++++++---------
 2 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7580464..bc57ecb 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4393,7 +4393,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 	struct logical_volume *lv, *org = NULL;
 	struct logical_volume *pool_lv;
 	struct lv_list *lvl;
-	int origin_active = 0;
 	const char *thin_name = NULL;
 
 	if (new_lv_name && find_lv_in_vg(vg, new_lv_name)) {
@@ -4480,9 +4479,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		/* Must zero cow */
 		status |= LVM_WRITE;
 
-		if (lp->voriginsize)
-			origin_active = 1;
-		else {
+		if (!lp->voriginsize) {
 
 			if (!(org = find_lv(vg, lp->origin))) {
 				log_error("Couldn't find origin volume '%s'.",
@@ -4526,8 +4523,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 				log_warn("WARNING: See global/mirror_segtype_default in lvm.conf.");
 			}
 
-			if ((origin_active = lv_is_active(org)) &&
-			    vg_is_clustered(vg) &&
+			if (vg_is_clustered(vg) && lv_is_active(org) &&
 			    !lv_is_active_exclusive_locally(org)) {
 				log_error("%s must be active exclusively to"
 					  " create snapshot", org->name);
@@ -4821,8 +4817,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		if (!(lp->permission & LVM_WRITE))
 			lv->status &= ~LVM_WRITE;
 
-		/* COW area must be deactivated if origin is not active */
-		if (!origin_active && !deactivate_lv(cmd, lv)) {
+		/* COW area must be deactivated (no lock) */
+		if (!deactivate_lv(cmd, lv)) {
 			log_error("Aborting. Couldn't deactivate snapshot "
 				  "COW area. Manual intervention required.");
 			return NULL;
@@ -4841,8 +4837,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 			goto deactivate_and_revert_new_lv;
 		}
 
-		/* cow LV remains active and becomes snapshot LV */
-
+		/* COW LV is inactive here and becomes snapshot LV */
 		if (!vg_add_snapshot(org, lv, NULL,
 				     org->le_count, lp->chunk_size)) {
 			log_error("Couldn't create snapshot.");
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 5766d0b..d481fe8 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -176,6 +176,7 @@ int vg_remove_snapshot(struct logical_volume *cow)
 {
 	int merging_snapshot = 0;
 	struct logical_volume *origin = origin_from_cow(cow);
+	int is_origin_active = lv_is_active(origin);
 
 	dm_list_del(&cow->snapshot->origin_list);
 	origin->origin_count--;
@@ -209,25 +210,39 @@ int vg_remove_snapshot(struct logical_volume *cow)
 	lv_set_visible(cow);
 
 	/* format1 must do the change in one step, with the commit last. */
-	if (!(origin->vg->fid->fmt->features & FMT_MDAS))
+	if (!(origin->vg->fid->fmt->features & FMT_MDAS)) {
+		/* Get the lock for COW volume */
+		if (is_origin_active && !activate_lv(cow->vg->cmd, cow)) {
+			log_error("Unable to activate logical volume \"%s\"",
+				  cow->name);
+			return 0;
+		}
 		return 1;
+	}
 
 	if (!vg_write(origin->vg))
 		return_0;
-	if (!suspend_lv(origin->vg->cmd, origin)) {
+
+	/* Skip call suspend, if device is not active */
+	if (is_origin_active && !suspend_lv(origin->vg->cmd, origin)) {
 		log_error("Failed to refresh %s without snapshot.",
 			  origin->name);
 		return 0;
 	}
 	if (!vg_commit(origin->vg))
 		return_0;
-	if (!merging_snapshot && !resume_lv(origin->vg->cmd, cow)) {
-		log_error("Failed to resume %s.", cow->name);
-		return 0;
-	}
-	if (!resume_lv(origin->vg->cmd, origin)) {
-		log_error("Failed to resume %s.", origin->name);
-		return 0;
+
+	if (is_origin_active) {
+		/* Takes LV lock on cluster */
+		if (!merging_snapshot && !activate_lv(cow->vg->cmd, cow)) {
+			log_error("Failed to activate %s.", cow->name);
+			return 0;
+		}
+
+		if (!resume_lv(origin->vg->cmd, origin)) {
+			log_error("Failed to resume %s.", origin->name);
+			return 0;
+		}
 	}
 
 	return 1;
-- 
1.8.2



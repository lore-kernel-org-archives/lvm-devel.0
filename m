From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:02:34 +0000 (UTC)
Subject: dev-mornfall-lvmcache - snapshot: rework cluster creation and removal
Message-ID: <20130605120234.6CB9A613BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f84f12a6a3edaac5220699dd9c6937139429d852
Commit:        f84f12a6a3edaac5220699dd9c6937139429d852
Parent:        d51b7e54044518ed8e20ce3ea617a28d2313730d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 21 10:37:52 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 25 17:33:24 2013 +0200

snapshot: rework cluster creation and removal

Support for exclusive activation of snapshots revealed some problems.

When snapshot is created, COW LV is activated first (for clearing) and
then it's transformed into snapshot's COW LV, but it has left the lock
for such LV active in cluster and this lock could not have been removed
from dlm, unless snapshot has been removed within same dlm session.

If the user tried to remove snapshot after rebooting node, the lock was
missing, and COW LV could not have been detached.

Patch modifes the approach in this way:

Always deactivate COW LV for clustered vg  after clearing (so it's
activated again via imlicit snapshot activation rule when snapshot is activated).

When snapshot is removed, activate COW LV as independend LV, so the lock
will exist for such LV, but only when the snapshot is active.

Also add test case for testing snapshot removal after cluster reboot.
---
 WHATS_NEW                     |    1 +
 lib/metadata/lv_manip.c       |   24 ++++++++++++++----------
 lib/metadata/snapshot_manip.c |   37 ++++++++++++++++++++++++++++---------
 test/shell/clvmd-restart.sh   |   12 +++++++++++-
 4 files changed, 54 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ceaed00..5c97eff 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix creation and removal of clustered snapshot.
   Fix clvmd caching of metadata when suspending inactive volumes.
   Find newest timestamp of merged config files.
   Fix assignment order for vg fid for lvm1 and pool format.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7580464..42e0fab 100644
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
@@ -4821,8 +4817,14 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 		if (!(lp->permission & LVM_WRITE))
 			lv->status &= ~LVM_WRITE;
 
-		/* COW area must be deactivated if origin is not active */
-		if (!origin_active && !deactivate_lv(cmd, lv)) {
+		/*
+		 * For clustered VG deactivate zeroed COW to not keep
+		 * the LV lock. For non-clustered VG, deactivate
+		 * if origin is real (not virtual) inactive device.
+		 */
+		if ((vg_is_clustered(vg) ||
+		     (!lp->voriginsize && !lv_is_active(org))) &&
+		    !deactivate_lv(cmd, lv)) {
 			log_error("Aborting. Couldn't deactivate snapshot "
 				  "COW area. Manual intervention required.");
 			return NULL;
@@ -4841,8 +4843,10 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 			goto deactivate_and_revert_new_lv;
 		}
 
-		/* cow LV remains active and becomes snapshot LV */
-
+		/*
+		 * COW LV is activated via implicit activation of origin LV
+		 * Only the snapshot origin holds the LV lock in cluster
+		 */
 		if (!vg_add_snapshot(org, lv, NULL,
 				     org->le_count, lp->chunk_size)) {
 			log_error("Couldn't create snapshot.");
diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
index 5766d0b..0c10104 100644
--- a/lib/metadata/snapshot_manip.c
+++ b/lib/metadata/snapshot_manip.c
@@ -176,6 +176,7 @@ int vg_remove_snapshot(struct logical_volume *cow)
 {
 	int merging_snapshot = 0;
 	struct logical_volume *origin = origin_from_cow(cow);
+	int is_origin_active = lv_is_active(origin);
 
 	dm_list_del(&cow->snapshot->origin_list);
 	origin->origin_count--;
@@ -209,25 +210,43 @@ int vg_remove_snapshot(struct logical_volume *cow)
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
+		/*
+		 * If the snapshot was active and the COW LV is taken away
+		 * the LV lock on cluster has to be grabbed, so use
+		 * activate_lv() which resumes suspend cow device.
+		 */
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
diff --git a/test/shell/clvmd-restart.sh b/test/shell/clvmd-restart.sh
index 2b341e5..e88e187 100644
--- a/test/shell/clvmd-restart.sh
+++ b/test/shell/clvmd-restart.sh
@@ -46,8 +46,18 @@ test "$LOCAL_CLVMD" -eq "$NEW_LOCAL_CLVMD"
 
 # FIXME: Hmm - how could we test exclusivity is preserved in singlenode ?
 lvchange -an $vg/$lv1
-lvchange -ay $vg/$lv1
+lvchange -aey $vg/$lv1
+lvcreate -s -l3 -n snap $vg/$lv1
 
 "$LVM_CLVMD_BINARY" -R
 
+vgchange -an $vg
+
+# Test what happens after 'reboot'
+kill "$LOCAL_CLVMD"
+aux prepare_clvmd
+
+vgchange -ay $vg
+lvremove -f $vg/snap
+
 vgremove -ff $vg



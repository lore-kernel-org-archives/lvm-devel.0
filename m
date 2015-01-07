From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  7 Jan 2015 10:19:35 +0000 (UTC)
Subject: master - mirror: do not try to reactivate inactive mirror when removing its LVs which have missing PVs
Message-ID: <20150107101935.E580460FB1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff1eca3b6f1b40158fa5a5877b1ad6de72e4ed1e
Commit:        ff1eca3b6f1b40158fa5a5877b1ad6de72e4ed1e
Parent:        e97023804a8aa94d723025506fa23cf4a5c323e9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 7 10:52:38 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 7 11:16:19 2015 +0100

mirror: do not try to reactivate inactive mirror when removing its LVs which have missing PVs

When mirror has missing PVs and there are mirror images on those missing
PVs, we delete the images and during this delete operation, we also
reactivate the LV. But if we're trying to reactivate the LV in cluster
which is not active and at the same time cmirrord is not running (which
is OK since we may have created the mirror LV as inactive), we end up
with:
  "Error locking on node <node_name>: Shared cluster mirrors are not available."

That is because we're trying to activate the mirror LV without cmirrord.
However, there's no need to do this reactivation if the mirror LV (and
hence it's sub LVs) were not activated before.

This issue caused failure in mirror-vgreduce-removemissing.sh test
recently with this sequence (excerpt from the test script):

  prepare_lvs_
  lvcreate -an -Zn -l2 --type mirror -m1 --nosync -n $lv1 $vg "$dev1" $dev2" "$dev3":$BLOCKS
  mimages_are_on_ $lv1 "$dev1" "$dev2"
  mirrorlog_is_on_ $lv1 "$dev3"
  aux disable_dev "$dev2"
  vgreduce --removemissing --force $vg

The important thing about that test is that we're not running cmirrord,
we're activating the mirror with "-an" so it's inactive and then
vgreduce --removemissing tries to reactivate the mirror images
as part of the _delete_lv function call inside and since cmirrord
is not running, we end up with the "Shared cluster mirrors are not
available." error.
---
 lib/metadata/mirror.c |   32 +++++++++++++++++++-------------
 1 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index bac1ffb..edbf7d4 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -420,7 +420,8 @@ static int _activate_lv_like_model(struct logical_volume *model,
 /*
  * Delete independent/orphan LV, it must acquire lock.
  */
-static int _delete_lv(struct logical_volume *mirror_lv, struct logical_volume *lv)
+static int _delete_lv(struct logical_volume *mirror_lv, struct logical_volume *lv,
+		      int reactivate)
 {
 	struct cmd_context *cmd = mirror_lv->vg->cmd;
 	struct dm_str_list *sl;
@@ -440,15 +441,17 @@ static int _delete_lv(struct logical_volume *mirror_lv, struct logical_volume *l
 		}
 	}
 
-	/* FIXME: the 'model' should be 'mirror_lv' not 'lv', I think. */
-	if (!_activate_lv_like_model(lv, lv))
-		return_0;
+	if (reactivate) {
+		/* FIXME: the 'model' should be 'mirror_lv' not 'lv', I think. */
+		if (!_activate_lv_like_model(lv, lv))
+			return_0;
 
-	/* FIXME Is this superfluous now? */
-	sync_local_dev_names(cmd);
+		/* FIXME Is this superfluous now? */
+		sync_local_dev_names(cmd);
 
-	if (!deactivate_lv(cmd, lv))
-		return_0;
+		if (!deactivate_lv(cmd, lv))
+			return_0;
+	}
 
 	if (!lv_remove(lv))
 		return_0;
@@ -799,11 +802,11 @@ static int _split_mirror_images(struct logical_volume *lv,
 	}
 
 	/* Remove original mirror layer if it has been converted to linear */
-	if (sub_lv && !_delete_lv(lv, sub_lv))
+	if (sub_lv && !_delete_lv(lv, sub_lv, 1))
 		return_0;
 
 	/* Remove the log if it has been converted to linear */
-	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))
+	if (detached_log_lv && !_delete_lv(lv, detached_log_lv, 1))
 		return_0;
 
 	return 1;
@@ -852,6 +855,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	struct lv_list *lvl;
 	struct dm_list tmp_orphan_lvs;
 	uint32_t orig_removed = num_removed;
+	int reactivate;
 
 	if (removed)
 		*removed = 0;
@@ -864,6 +868,7 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	if (collapse && (old_area_count - num_removed != 1)) {
 		log_error("Incompatible parameters to _remove_mirror_images");
 		return 0;
+
 	}
 
 	num_removed = 0;
@@ -1093,16 +1098,17 @@ static int _remove_mirror_images(struct logical_volume *lv,
 	}
 
 	/* Save or delete the 'orphan' LVs */
+	reactivate = lv_is_active(lv_lock_holder(lv));
 	if (!collapse) {
 		dm_list_iterate_items(lvl, &tmp_orphan_lvs)
-			if (!_delete_lv(lv, lvl->lv))
+			if (!_delete_lv(lv, lvl->lv, reactivate))
 				return_0;
 	}
 
-	if (temp_layer_lv && !_delete_lv(lv, temp_layer_lv))
+	if (temp_layer_lv && !_delete_lv(lv, temp_layer_lv, reactivate))
 		return_0;
 
-	if (detached_log_lv && !_delete_lv(lv, detached_log_lv))
+	if (detached_log_lv && !_delete_lv(lv, detached_log_lv, reactivate))
 		return_0;
 
 	/* Mirror with only 1 area is 'in sync'. */



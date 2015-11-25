From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 25 Nov 2015 10:44:16 +0000 (UTC)
Subject: master - cleanup: rename vg_ondisk to vg_committed
Message-ID: <20151125104416.92334602C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d9faf859871e0e862ded3cc08638847c9aaa6f1a
Commit:        d9faf859871e0e862ded3cc08638847c9aaa6f1a
Parent:        0285066e10d0c4a37bc4938eeed2139299600b3e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 24 23:29:18 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 25 11:11:21 2015 +0100

cleanup: rename vg_ondisk to vg_committed

Unifying terminology.

Since all the metadata in-use are ALWAYS on disk - switch
to terminology  committed and precommitted.

Patch has no functional change inside.
---
 lib/metadata/metadata.c |   16 ++++++++--------
 lib/metadata/vg.c       |    2 +-
 lib/metadata/vg.h       |   10 +++++-----
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b1ddb34..52d76c3 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -936,18 +936,18 @@ static int _vg_update_vg_precommitted(struct volume_group *vg)
 	return 1;
 }
 
-static int _vg_update_vg_ondisk(struct volume_group *vg)
+static int _vg_update_vg_committed(struct volume_group *vg)
 {
 	if (dm_pool_locked(vg->vgmem))
 		return 1;
 
-	if (vg->vg_ondisk || is_orphan_vg(vg->name)) /* we already have it */
+	if (vg->vg_committed || is_orphan_vg(vg->name)) /* we already have it */
 		return 1;
 
 	if (!_vg_update_vg_precommitted(vg))
 		return_0;
 
-	vg->vg_ondisk = vg->vg_precommitted;
+	vg->vg_committed = vg->vg_precommitted;
 	vg->vg_precommitted = NULL;
 	if (vg->cft_precommitted) {
 		dm_config_destroy(vg->cft_precommitted);
@@ -978,7 +978,7 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 	if (vg->read_status != failure)
 		vg->read_status = failure;
 
-	if (vg->fid && !_vg_update_vg_ondisk(vg))
+	if (vg->fid && !_vg_update_vg_committed(vg))
 		vg->read_status |= FAILED_ALLOCATION;
 
 	return vg;
@@ -3206,8 +3206,8 @@ int vg_commit(struct volume_group *vg)
 		vg->old_name = NULL;
 
 		/* This *is* the original now that it's commited. */
-		release_vg(vg->vg_ondisk);
-		vg->vg_ondisk = vg->vg_precommitted;
+		release_vg(vg->vg_committed);
+		vg->vg_committed = vg->vg_precommitted;
 		vg->vg_precommitted = NULL;
 		if (vg->cft_precommitted) {
 			dm_config_destroy(vg->cft_precommitted);
@@ -5539,10 +5539,10 @@ const struct logical_volume *lv_ondisk(const struct logical_volume *lv)
 	if (!lv)
 		return NULL;
 
-	if (!lv->vg->vg_ondisk)
+	if (!lv->vg->vg_committed)
 		return lv;
 
-	vg = lv->vg->vg_ondisk;
+	vg = lv->vg->vg_committed;
 
 	if (!(found_lv = find_lv_in_vg_by_lvid(vg, &lv->lvid))) {
 		log_error(INTERNAL_ERROR "LV %s (UUID %s) not found in ondisk metadata.",
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index ca2bf96..992cf2a 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -98,7 +98,7 @@ void release_vg(struct volume_group *vg)
 	    !lvmcache_vginfo_holders_dec_and_test_for_zero(vg->vginfo))
 		return;
 
-	release_vg(vg->vg_ondisk);
+	release_vg(vg->vg_committed);
 	release_vg(vg->vg_precommitted);
 	if (vg->cft_precommitted)
 		dm_config_destroy(vg->cft_precommitted);
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index a21af8b..df660a7 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -52,13 +52,13 @@ struct volume_group {
 	unsigned skip_validate_lock_args : 1;
 
 	/*
-	 * The parsed on-disk copy of this VG; is NULL if this is the on-disk
-	 * version (i.e. vg_ondisk == NULL *implies* this is the on-disk copy,
-	 * there is no guarantee that if this VG is the same as the on-disk one
+	 * The parsed committed (on-disk) copy of this VG; is NULL if this VG is committed
+	 * version (i.e. vg_committed == NULL *implies* this is the committed copy,
+	 * there is no guarantee that if this VG is the same as the committed one
 	 * this will be NULL). The pointer is maintained by calls to
-	 * _vg_update_vg_ondisk.
+	 * _vg_update_vg_committed.
 	 */
-	struct volume_group *vg_ondisk;
+	struct volume_group *vg_committed;
 	struct dm_config_tree *cft_precommitted; /* Precommitted metadata */
 	struct volume_group *vg_precommitted; /* Parsed from cft */
 



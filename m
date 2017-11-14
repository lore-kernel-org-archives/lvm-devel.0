From: Alasdair Kergon <agk@sourceware.org>
Date: Tue, 14 Nov 2017 10:40:43 -0500
Subject: master - metadata: Eliminate redundant nested VG metadata
Message-ID: <201711141540.vAEFehQO020175@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b5f62a143dcc83bcc12910400b177620a8f49b7c
Commit:        b5f62a143dcc83bcc12910400b177620a8f49b7c
Parent:        7a5728fb4c748b911f829c5cda0768c6289a4512
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Nov 14 15:38:55 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Nov 14 15:38:55 2017 +0000

metadata: Eliminate redundant nested VG metadata

Only lv_committed() now uses vg->vg_committed and it appears redundant
if its contents match the enclosing VG so don't waste cycles creating it
when that's known to be true when no write lock is held so the struct
won't get modified.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   64 ++++++++++++++++++++++-------------------------
 2 files changed, 31 insertions(+), 34 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1c8838c..04229da 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.177 -
 ====================================
+  Eliminate redundant nested VG metadata in VG struct.
   Avoid importing persistent filter in vgscan/pvscan/vgrename.
   Fix memleak of string buffer when vgcfgbackup runs in secure mode.
   Do not print error when clvmd cannot find running clvmd.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 56c11e6..a14dfa6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -897,46 +897,41 @@ int vgcreate_params_validate(struct cmd_context *cmd,
 	return 1;
 }
 
+static void _vg_wipe_cached_precommitted(struct volume_group *vg)
+{
+	release_vg(vg->vg_precommitted);
+	vg->vg_precommitted = NULL;
+}
+
+static void _vg_move_cached_precommitted_to_committed(struct volume_group *vg)
+{
+	release_vg(vg->vg_committed);
+	vg->vg_committed = vg->vg_precommitted;
+	vg->vg_precommitted = NULL;
+}
+
 /*
  * Update content of precommitted VG
  *
  * TODO: Optimize in the future, since lvmetad needs similar
  *       config tree processing in lvmetad_vg_update().
  */
-static int _vg_update_vg_precommitted(struct volume_group *vg)
+static int _vg_update_embedded_copy(struct volume_group *vg, struct volume_group **vg_embedded)
 {
-	struct dm_config_tree *cft_precommitted;
+	struct dm_config_tree *cft;
 
-	release_vg(vg->vg_precommitted);
-	vg->vg_precommitted = NULL;
+	_vg_wipe_cached_precommitted(vg);
 
 	/* Copy the VG using an export followed by import */
-	if (!(cft_precommitted = export_vg_to_config_tree(vg)))
+	if (!(cft = export_vg_to_config_tree(vg)))
 		return_0;
 
-	if (!(vg->vg_precommitted = import_vg_from_config_tree(cft_precommitted, vg->fid))) {
-		dm_config_destroy(cft_precommitted);
+	if (!(*vg_embedded = import_vg_from_config_tree(cft, vg->fid))) {
+		dm_config_destroy(cft);
 		return_0;
 	}
 
-	dm_config_destroy(cft_precommitted);
-
-	return 1;
-}
-
-static int _vg_update_vg_committed(struct volume_group *vg)
-{
-	if (dm_pool_locked(vg->vgmem))
-		return 1;
-
-	if (vg->vg_committed || is_orphan_vg(vg->name)) /* we already have it */
-		return 1;
-
-	if (!_vg_update_vg_precommitted(vg))
-		return_0;
-
-	vg->vg_committed = vg->vg_precommitted;
-	vg->vg_precommitted = NULL;
+	dm_config_destroy(cft);
 
 	return 1;
 }
@@ -949,7 +944,6 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 					    struct volume_group *vg,
 					    uint32_t failure)
 {
-
 	/* Never return a cached VG structure for a failure */
 	if (vg && vg->vginfo && failure != SUCCESS) {
 		release_vg(vg);
@@ -961,8 +955,13 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 
 	vg->read_status = failure;
 
-	if (vg->fid && !_vg_update_vg_committed(vg))
-		vg->read_status |= FAILED_ALLOCATION;
+	/*
+	 * If we hold a write lock and might be changing the VG contents, embed a pristine 
+	 * copy of the VG metadata for the activation code to use later
+	 */
+	if (vg->fid && !dm_pool_locked(vg->vgmem) && !vg->vg_committed && !is_orphan_vg(vg->name))
+		if (vg_write_lock_held() && !_vg_update_embedded_copy(vg, &vg->vg_committed))
+			vg->read_status |= FAILED_ALLOCATION;
 
 	return vg;
 }
@@ -3092,7 +3091,7 @@ int vg_write(struct volume_group *vg)
 		}
 	}
 
-	if (!_vg_update_vg_precommitted(vg)) /* prepare precommited */
+	if (!_vg_update_embedded_copy(vg, &vg->vg_precommitted)) /* prepare precommited */
 		return_0;
 
 	lockd_vg_update(vg);
@@ -3177,9 +3176,7 @@ int vg_commit(struct volume_group *vg)
 			pvl->pv->status &= ~PV_MOVED_VG;
 
 		/* This *is* the original now that it's commited. */
-		release_vg(vg->vg_committed);
-		vg->vg_committed = vg->vg_precommitted;
-		vg->vg_precommitted = NULL;
+		_vg_move_cached_precommitted_to_committed(vg);
 	}
 
 	/* If update failed, remove any cached precommitted metadata. */
@@ -3212,8 +3209,7 @@ void vg_revert(struct volume_group *vg)
 		}
 	}
 
-	release_vg(vg->vg_precommitted);  /* VG is no longer needed */
-	vg->vg_precommitted = NULL;
+	_vg_wipe_cached_precommitted(vg); /* VG is no longer needed */
 
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (mda->ops->vg_revert &&



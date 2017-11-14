From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 13 Nov 2017 21:35:11 -0500
Subject: master - metadata: Eliminate redundant nested VG metadata
Message-ID: <201711140235.vAE2ZBvC007168@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=762606a8c4070db7b3719c492bd9319d36ec271d
Commit:        762606a8c4070db7b3719c492bd9319d36ec271d
Parent:        00acae12a4295075f1b93786f60327e5d3c26e70
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Nov 14 01:57:14 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Nov 14 01:57:14 2017 +0000

metadata: Eliminate redundant nested VG metadata

Only lv_committed() now uses vg->vg_committed and it appears redundant
if its contents match the enclosing VG so don't waste cycles creating it
when that's known to be true.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   44 ++++++++++++++++++--------------------------
 2 files changed, 19 insertions(+), 26 deletions(-)

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
index 56c11e6..9c4c24d 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -897,6 +897,19 @@ int vgcreate_params_validate(struct cmd_context *cmd,
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
@@ -907,8 +920,7 @@ static int _vg_update_vg_precommitted(struct volume_group *vg)
 {
 	struct dm_config_tree *cft_precommitted;
 
-	release_vg(vg->vg_precommitted);
-	vg->vg_precommitted = NULL;
+	_vg_wipe_cached_precommitted(vg);
 
 	/* Copy the VG using an export followed by import */
 	if (!(cft_precommitted = export_vg_to_config_tree(vg)))
@@ -924,23 +936,6 @@ static int _vg_update_vg_precommitted(struct volume_group *vg)
 	return 1;
 }
 
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
-
-	return 1;
-}
-
 /*
  * Create a (struct volume_group) volume group handle from a struct volume_group pointer and a
  * possible failure code or zero for success.
@@ -961,8 +956,8 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 
 	vg->read_status = failure;
 
-	if (vg->fid && !_vg_update_vg_committed(vg))
-		vg->read_status |= FAILED_ALLOCATION;
+	if (vg->fid && !dm_pool_locked(vg->vgmem))
+		_vg_wipe_cached_precommitted(vg);
 
 	return vg;
 }
@@ -3177,9 +3172,7 @@ int vg_commit(struct volume_group *vg)
 			pvl->pv->status &= ~PV_MOVED_VG;
 
 		/* This *is* the original now that it's commited. */
-		release_vg(vg->vg_committed);
-		vg->vg_committed = vg->vg_precommitted;
-		vg->vg_precommitted = NULL;
+		_vg_move_cached_precommitted_to_committed(vg);
 	}
 
 	/* If update failed, remove any cached precommitted metadata. */
@@ -3212,8 +3205,7 @@ void vg_revert(struct volume_group *vg)
 		}
 	}
 
-	release_vg(vg->vg_precommitted);  /* VG is no longer needed */
-	vg->vg_precommitted = NULL;
+	_vg_wipe_cached_precommitted(vg);	/* VG is no longer needed */
 
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (mda->ops->vg_revert &&



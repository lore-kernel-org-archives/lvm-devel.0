From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 13 Nov 2017 21:35:07 -0500
Subject: master - metadata: Remove unused vg.cft_precommitted
Message-ID: <201711140235.vAE2Z7GR007157@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=00acae12a4295075f1b93786f60327e5d3c26e70
Commit:        00acae12a4295075f1b93786f60327e5d3c26e70
Parent:        6bf0f04ae2cb4e2c33a9836125a41e9e6b21e4d7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Nov 14 01:09:58 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Nov 14 01:22:09 2017 +0000

metadata: Remove unused vg.cft_precommitted

The precommitted metadata config_tree is now only referenced from a
single function so just use a local variable instead.
---
 lib/metadata/metadata.c |   29 ++++++++---------------------
 lib/metadata/vg.c       |    2 --
 lib/metadata/vg.h       |    3 +--
 3 files changed, 9 insertions(+), 25 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d823ef2..56c11e6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -905,23 +905,22 @@ int vgcreate_params_validate(struct cmd_context *cmd,
  */
 static int _vg_update_vg_precommitted(struct volume_group *vg)
 {
+	struct dm_config_tree *cft_precommitted;
+
 	release_vg(vg->vg_precommitted);
 	vg->vg_precommitted = NULL;
 
-	if (vg->cft_precommitted) {
-		dm_config_destroy(vg->cft_precommitted);
-		vg->cft_precommitted = NULL;
-	}
-
-	if (!(vg->cft_precommitted = export_vg_to_config_tree(vg)))
+	/* Copy the VG using an export followed by import */
+	if (!(cft_precommitted = export_vg_to_config_tree(vg)))
 		return_0;
 
-	if (!(vg->vg_precommitted = import_vg_from_config_tree(vg->cft_precommitted, vg->fid))) {
-		dm_config_destroy(vg->cft_precommitted);
-		vg->cft_precommitted = NULL;
+	if (!(vg->vg_precommitted = import_vg_from_config_tree(cft_precommitted, vg->fid))) {
+		dm_config_destroy(cft_precommitted);
 		return_0;
 	}
 
+	dm_config_destroy(cft_precommitted);
+
 	return 1;
 }
 
@@ -938,10 +937,6 @@ static int _vg_update_vg_committed(struct volume_group *vg)
 
 	vg->vg_committed = vg->vg_precommitted;
 	vg->vg_precommitted = NULL;
-	if (vg->cft_precommitted) {
-		dm_config_destroy(vg->cft_precommitted);
-		vg->cft_precommitted = NULL;
-	}
 
 	return 1;
 }
@@ -3185,10 +3180,6 @@ int vg_commit(struct volume_group *vg)
 		release_vg(vg->vg_committed);
 		vg->vg_committed = vg->vg_precommitted;
 		vg->vg_precommitted = NULL;
-		if (vg->cft_precommitted) {
-			dm_config_destroy(vg->cft_precommitted);
-			vg->cft_precommitted = NULL;
-		}
 	}
 
 	/* If update failed, remove any cached precommitted metadata. */
@@ -3223,10 +3214,6 @@ void vg_revert(struct volume_group *vg)
 
 	release_vg(vg->vg_precommitted);  /* VG is no longer needed */
 	vg->vg_precommitted = NULL;
-	if (vg->cft_precommitted) {
-		dm_config_destroy(vg->cft_precommitted);
-		vg->cft_precommitted = NULL;
-	}
 
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (mda->ops->vg_revert &&
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index f90ac82..4c808da 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -104,8 +104,6 @@ void release_vg(struct volume_group *vg)
 
 	release_vg(vg->vg_committed);
 	release_vg(vg->vg_precommitted);
-	if (vg->cft_precommitted)
-		dm_config_destroy(vg->cft_precommitted);
 	_free_vg(vg);
 }
 
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index bc2c2dd..086a42c 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -59,8 +59,7 @@ struct volume_group {
 	 * _vg_update_vg_committed.
 	 */
 	struct volume_group *vg_committed;
-	struct dm_config_tree *cft_precommitted; /* Precommitted metadata */
-	struct volume_group *vg_precommitted; /* Parsed from cft */
+	struct volume_group *vg_precommitted;
 
 	alloc_policy_t alloc;
 	struct profile *profile;



From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  1 Mar 2014 13:24:46 +0000 (UTC)
Subject: master - lvmetad: more reuse precommit buffer
Message-ID: <20140301132446.B6C4B60C85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=090e81281fbf88bf27ee6930dfaf03cd48aade88
Commit:        090e81281fbf88bf27ee6930dfaf03cd48aade88
Parent:        bda98c4b8dcd17d27c582fe6e2bc2d3c2742d4d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 28 22:40:00 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 1 14:08:58 2014 +0100

lvmetad: more reuse precommit buffer

This patch moves more allocation to vg_write
(as started in 8c878438f5a75310d09a1ee035d9caf8e2b9e50b)
TODO: relocate also communication.
(in-release update)
---
 lib/cache/lvmetad.c     |   10 +++++-----
 lib/metadata/metadata.c |   38 +++++++++++++++++++++++++++-----------
 lib/metadata/vg.c       |    2 ++
 lib/metadata/vg.h       |    3 ++-
 4 files changed, 36 insertions(+), 17 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index c994874..600fc19 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -468,7 +468,6 @@ int lvmetad_vg_update(struct volume_group *vg)
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
 	struct _fixup_baton baton;
-	struct dm_config_tree *vgmeta;
 
 	if (!vg)
 		return 0;
@@ -476,13 +475,14 @@ int lvmetad_vg_update(struct volume_group *vg)
 	if (!lvmetad_active() || test_mode())
 		return 1; /* fake it */
 
-	if (!(vgmeta = export_vg_to_config_tree(vg)))
-		return_0;
+	if (!vg->cft_precommitted) {
+		log_error(INTERNAL_ERROR "VG update without precommited");
+		return 0;
+	}
 
 	log_debug_lvmetad("Sending lvmetad updated metadata for VG %s (seqno %" PRIu32 ")", vg->name, vg->seqno);
 	reply = _lvmetad_send("vg_update", "vgname = %s", vg->name,
-			      "metadata = %t", vgmeta, NULL);
-	dm_config_destroy(vgmeta);
+			      "metadata = %t", vg->cft_precommitted, NULL);
 
 	if (!_lvmetad_handle_reply(reply, "update VG", vg->name, NULL)) {
 		daemon_reply_destroy(reply);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8643b75..278b519 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -864,20 +864,24 @@ int vgcreate_params_validate(struct cmd_context *cmd,
  */
 static int _vg_update_vg_precommitted(struct volume_group *vg)
 {
-	struct dm_config_tree *cft;
-
 	release_vg(vg->vg_precommitted);
 	vg->vg_precommitted = NULL;
 
-	if (!(cft = export_vg_to_config_tree(vg)))
-		return_0;
+	if (vg->cft_precommitted) {
+		dm_config_destroy(vg->cft_precommitted);
+		vg->cft_precommitted = NULL;
+	}
 
-	if (!(vg->vg_precommitted = import_vg_from_config_tree(cft, vg->fid)))
-		stack;
+	if (!(vg->cft_precommitted = export_vg_to_config_tree(vg)))
+		return_0;
 
-	dm_config_destroy(cft);
+	if (!(vg->vg_precommitted = import_vg_from_config_tree(vg->cft_precommitted, vg->fid))) {
+		dm_config_destroy(vg->cft_precommitted);
+		vg->cft_precommitted = NULL;
+		return_0;
+	}
 
-	return vg->vg_precommitted ? 1 : 0;
+	return 1;
 }
 
 static int _vg_update_vg_ondisk(struct volume_group *vg)
@@ -893,6 +897,10 @@ static int _vg_update_vg_ondisk(struct volume_group *vg)
 
 	vg->vg_ondisk = vg->vg_precommitted;
 	vg->vg_precommitted = NULL;
+	if (vg->cft_precommitted) {
+		dm_config_destroy(vg->cft_precommitted);
+		vg->cft_precommitted = NULL;
+	}
 
 	return 1;
 }
@@ -2695,6 +2703,9 @@ int vg_write(struct volume_group *vg)
 		}
 	}
 
+	if (!_vg_update_vg_precommitted(vg)) /* prepare precommited */
+		return_0;
+
 	/*
 	 * If precommit is not supported, changes take effect immediately.
 	 * FIXME Replace with a more-accurate FMT_COMMIT flag.
@@ -2702,9 +2713,6 @@ int vg_write(struct volume_group *vg)
 	if (!(vg->fid->fmt->features & FMT_PRECOMMIT) && !lvmetad_vg_update(vg))
 		return_0;
 
-	if (!_vg_update_vg_precommitted(vg)) /* prepare precommited */
-		return_0;
-
 	return 1;
 }
 
@@ -2773,6 +2781,10 @@ int vg_commit(struct volume_group *vg)
 		release_vg(vg->vg_ondisk);
 		vg->vg_ondisk = vg->vg_precommitted;
 		vg->vg_precommitted = NULL;
+		if (vg->cft_precommitted) {
+			dm_config_destroy(vg->cft_precommitted);
+			vg->cft_precommitted = NULL;
+		}
 	}
 
 	/* If update failed, remove any cached precommitted metadata. */
@@ -2791,6 +2803,10 @@ void vg_revert(struct volume_group *vg)
 
 	release_vg(vg->vg_precommitted);  /* VG is no longer needed */
 	vg->vg_precommitted = NULL;
+	if (vg->cft_precommitted) {
+		dm_config_destroy(vg->cft_precommitted);
+		vg->cft_precommitted = NULL;
+	}
 
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (mda->ops->vg_revert &&
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 8f23d56..8ebec99 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -90,6 +90,8 @@ void release_vg(struct volume_group *vg)
 
 	release_vg(vg->vg_ondisk);
 	release_vg(vg->vg_precommitted);
+	if (vg->cft_precommitted)
+		dm_config_destroy(vg->cft_precommitted);
 	_free_vg(vg);
 }
 
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 028471b..b3b7e93 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -57,7 +57,8 @@ struct volume_group {
 	 * _vg_update_vg_ondisk.
 	 */
 	struct volume_group *vg_ondisk;
-	struct volume_group *vg_precommitted; /* Parsed from precommitted */
+	struct dm_config_tree *cft_precommitted; /* Precommitted metadata */
+	struct volume_group *vg_precommitted; /* Parsed from cft */
 
 	alloc_policy_t alloc;
 	struct profile *profile;



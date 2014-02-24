From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:04 +0000 (UTC)
Subject: master - metadata: move vg parsing to vg_write
Message-ID: <20140224201704.1B51660D5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c878438f5a75310d09a1ee035d9caf8e2b9e50b
Commit:        8c878438f5a75310d09a1ee035d9caf8e2b9e50b
Parent:        203affffc70622e1b0db4734bc631cd7caf22442
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 22 01:44:21 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:08:53 2014 +0100

metadata: move vg parsing to vg_write

Parsing vg structure during  supend/commit/resume may require a lot of
memory - so move this into vg_write.

FIXME: there are now multiple cache layers which our doing some thing
multiple times at different levels. Moreover there is now different
caching path with and without lvmetad - this should be unified
and both path should use same mechanism.
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   52 ++++++++++++++++++++++++++++++++--------------
 lib/metadata/vg.c       |    1 +
 lib/metadata/vg.h       |    1 +
 4 files changed, 39 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 23f7424..05f5042 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Move parsing of VG metadata from vg_commit() back to vg_write() (2.02.99)
   Avoid a PV label scan while in a critical section.
   Remove (always 0) skip argument from lv_activation_skip().
   Create /dev/disk/by-id/lvm-pv-uuid-<PV_UUID> symlink for each PV via udev.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 74f23b0..8643b75 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -856,30 +856,45 @@ int vgcreate_params_validate(struct cmd_context *cmd,
 	return 1;
 }
 
-static int _vg_update_vg_ondisk(struct volume_group *vg)
+/*
+ * Update content of precommitted VG
+ *
+ * TODO: Optimize in the future, since lvmetad needs similar
+ *       config tree processing in lvmetad_vg_update().
+ */
+static int _vg_update_vg_precommitted(struct volume_group *vg)
 {
 	struct dm_config_tree *cft;
-	int pool_locked;
 
-	if (vg->vg_ondisk || is_orphan_vg(vg->name)) /* we already have it */
-		return 1;
+	release_vg(vg->vg_precommitted);
+	vg->vg_precommitted = NULL;
 
-	pool_locked = dm_pool_locked(vg->vgmem);
-	if (pool_locked && !dm_pool_unlock(vg->vgmem, 0))
+	if (!(cft = export_vg_to_config_tree(vg)))
 		return_0;
 
-	cft = export_vg_to_config_tree(vg);
-	if (!cft)
-		return 0;
+	if (!(vg->vg_precommitted = import_vg_from_config_tree(cft, vg->fid)))
+		stack;
 
-	vg->vg_ondisk = import_vg_from_config_tree(cft, vg->fid);
 	dm_config_destroy(cft);
 
-	/* recompute the pool crc */
-	if (pool_locked && !dm_pool_lock(vg->vgmem, 1))
+	return vg->vg_precommitted ? 1 : 0;
+}
+
+static int _vg_update_vg_ondisk(struct volume_group *vg)
+{
+	if (dm_pool_locked(vg->vgmem))
+		return 1;
+
+	if (vg->vg_ondisk || is_orphan_vg(vg->name)) /* we already have it */
+		return 1;
+
+	if (!_vg_update_vg_precommitted(vg))
 		return_0;
 
-	return vg->vg_ondisk ? 1 : 0;
+	vg->vg_ondisk = vg->vg_precommitted;
+	vg->vg_precommitted = NULL;
+
+	return 1;
 }
 
 /*
@@ -2687,6 +2702,9 @@ int vg_write(struct volume_group *vg)
 	if (!(vg->fid->fmt->features & FMT_PRECOMMIT) && !lvmetad_vg_update(vg))
 		return_0;
 
+	if (!_vg_update_vg_precommitted(vg)) /* prepare precommited */
+		return_0;
+
 	return 1;
 }
 
@@ -2753,9 +2771,8 @@ int vg_commit(struct volume_group *vg)
 
 		/* This *is* the original now that it's commited. */
 		release_vg(vg->vg_ondisk);
-		vg->vg_ondisk = NULL;
-		if (!_vg_update_vg_ondisk(vg)) /* make a new one for future edits */
-			return_0;
+		vg->vg_ondisk = vg->vg_precommitted;
+		vg->vg_precommitted = NULL;
 	}
 
 	/* If update failed, remove any cached precommitted metadata. */
@@ -2772,6 +2789,9 @@ void vg_revert(struct volume_group *vg)
 {
 	struct metadata_area *mda;
 
+	release_vg(vg->vg_precommitted);  /* VG is no longer needed */
+	vg->vg_precommitted = NULL;
+
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (mda->ops->vg_revert &&
 		    !mda->ops->vg_revert(vg->fid, vg, mda)) {
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 877371e..8f23d56 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -89,6 +89,7 @@ void release_vg(struct volume_group *vg)
 		return;
 
 	release_vg(vg->vg_ondisk);
+	release_vg(vg->vg_precommitted);
 	_free_vg(vg);
 }
 
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 43d27bf..028471b 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -57,6 +57,7 @@ struct volume_group {
 	 * _vg_update_vg_ondisk.
 	 */
 	struct volume_group *vg_ondisk;
+	struct volume_group *vg_precommitted; /* Parsed from precommitted */
 
 	alloc_policy_t alloc;
 	struct profile *profile;



From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 08 Aug 2011 17:58:42 +0200
Subject: [PATCH] Fix format instance handling in _vg_read
Message-ID: <4E4007B2.40901@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The _vg_read fn uses a global format_instance (the "fid") and then it tries to
call vg_read iteratively with the fid as a parameter (and so assigning it to
the vg struct), calling free_vg if the vg was found incorrect.

The problem is that free_vg would also free any fid it has assigned, so we need
to handle this somehow. To be sure that such situation does not happen, let's
increase the fid's ref_count before the iteration where we call vg_read and
decrement it afterwards. That way we can be sure that the fid is not destroyed
prematurely within the free_vg call in the iteration.

Since we create the fid manually and handle it manually in _vg_read fn, we need
to destroy it manually as well by calling the _destroy_fid fn directly if it's
not done withing the free_vg call.

This patch also adds a few missing free_vg calls.

Bad luck the vg_read is a bit complex, but we need this patch to avoid memory
leaks and premature destruction of the fid. This is the only place where we need
to do this magic. The _vg_read fn likes using the fid globally and fiddle with
it in an obscure way, so here's a small obscure fix :)

Peter

---

 lib/metadata/metadata.c |   45 +++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 41 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c8442d8..5f59021 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2768,6 +2768,14 @@ static void _free_pv_list(struct dm_list *all_pvs)
 		pvl->pv->fid->fmt->ops->destroy_instance(pvl->pv->fid);
 }
 
+static void _destroy_fid(struct format_instance **fid)
+{
+	if (*fid) {
+		(*fid)->fmt->ops->destroy_instance(*fid);
+		fid = NULL;
+	}
+}
+
 int vg_missing_pv_count(const struct volume_group *vg)
 {
 	int ret = 0;
@@ -2826,7 +2834,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				     int warnings, 
 				     int *consistent, unsigned precommitted)
 {
-	struct format_instance *fid;
+	struct format_instance *fid = NULL;
 	struct format_instance_ctx fic;
 	const struct format_type *fmt;
 	struct volume_group *vg, *correct_vg = NULL;
@@ -2904,12 +2912,20 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	}
 
 	/* Store pvids for later so we can check if any are missing */
-	if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid)))
+	if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid))) {
+		_destroy_fid(&fid);
 		return_NULL;
+	}
 
+	/*
+	 * We use the fid globally here so prevent the free_vg
+	 * call to destroy the fid - we may want to reuse it!
+	 */
+	fid->ref_count++;
 	/* Ensure contents of all metadata areas match - else do recovery */
 	inconsistent_mda_count=0;
 	dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
+
 		if ((use_precommitted &&
 		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda))) ||
 		    (!use_precommitted &&
@@ -2945,6 +2961,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		if (vg != correct_vg)
 			free_vg(vg);
 	}
+	fid->ref_count--;
 
 	/* Ensure every PV in the VG was in the cache */
 	if (correct_vg) {
@@ -2976,8 +2993,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				}
 				if (dm_list_size(&info->mdas)) {
 					if (!fid_add_mdas(fid, &info->mdas,
-							  info->dev->pvid, ID_LEN))
+							  info->dev->pvid, ID_LEN)) {
+						free_vg(correct_vg);
 						return_NULL;
+					}
 					 
 					log_debug("Empty mda found for VG %s.", vgname);
 
@@ -3006,8 +3025,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				 */
 				lvmcache_update_vg(correct_vg, correct_vg->status & PRECOMMITTED);
 
-				if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid)))
+				if (!(pvids = lvmcache_get_pvids(cmd, vgname, vgid))) {
+					free_vg(correct_vg);
 					return_NULL;
+				}
 			}
 		}
 
@@ -3044,6 +3065,13 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 	/* Failed to find VG where we expected it - full scan and retry */
 	if (!correct_vg) {
+		/*
+		 * Free outstanding format instance that remained unassigned
+		 * from previous step where we tried to get the "correct_vg",
+		 * but we failed to do so (so there's a dangling fid now).
+		 */
+		_destroy_fid(&fid);
+
 		inconsistent = 0;
 
 		/* Independent MDAs aren't supported under low memory */
@@ -3065,6 +3093,11 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			return NULL;
 		}
 
+		/*
+		 * We use the fid globally here so prevent the free_vg
+		 * call to destroy the fid - we may want to reuse it!
+		*/
+		fid->ref_count++;
 		/* Ensure contents of all metadata areas match - else recover */
 		inconsistent_mda_count=0;
 		dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
@@ -3080,6 +3113,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 				correct_vg = vg;
 				if (!_update_pv_list(cmd->mem, &all_pvs, correct_vg)) {
 					_free_pv_list(&all_pvs);
+					fid->ref_count--;
 					free_vg(vg);
 					return_NULL;
 				}
@@ -3103,6 +3137,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 
 				if (!_update_pv_list(cmd->mem, &all_pvs, vg)) {
 					_free_pv_list(&all_pvs);
+					fid->ref_count--;
 					free_vg(vg);
 					free_vg(correct_vg);
 					return_NULL;
@@ -3119,10 +3154,12 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 			if (vg != correct_vg)
 				free_vg(vg);
 		}
+		fid->ref_count--;
 
 		/* Give up looking */
 		if (!correct_vg) {
 			_free_pv_list(&all_pvs);
+			_destroy_fid(&fid);
 			return_NULL;
 		}
 	}



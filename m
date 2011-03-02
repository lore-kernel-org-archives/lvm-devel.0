From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  2 Mar 2011 19:20:26 +0100
Subject: [PATCH 4/4] Use alloc_vg for forma1_vg_read
In-Reply-To: <cover.1299089601.git.zkabelac@redhat.com>
References: <cover.1299089601.git.zkabelac@redhat.com>
Message-ID: <19fdc99a5c030080e78405b1e6faafc3c7a0cc4f.1299089601.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update code to use alloc_vg.
Move remainder of the _build_vg to _format1_vg_read

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format1/format1.c |   72 +++++++++++++++---------------------------------
 1 files changed, 23 insertions(+), 49 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 9011982..98c1916 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -177,84 +177,58 @@ out:
 	return 0;
 }
 
-static struct volume_group *_build_vg(struct format_instance *fid,
-				      struct dm_list *pvs,
-				      struct dm_pool *mem)
+static struct volume_group *_format1_vg_read(struct format_instance *fid,
+				     const char *vg_name,
+				     struct metadata_area *mda __attribute__((unused)))
 {
-	struct volume_group *vg = dm_pool_zalloc(mem, sizeof(*vg));
+	struct volume_group *vg;
 	struct disk_list *dl;
+	DM_LIST_INIT(pvs);
+
+	/* Strip dev_dir if present */
+	vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
+
+	if (!(vg = alloc_vg("format1_vg_read", fid->fmt->cmd, NULL)))
+		return_NULL;
 
-	if (!vg)
+	if (!read_pvs_in_vg(fid->fmt, vg_name, fid->fmt->cmd->filter,
+			    vg->vgmem, &pvs))
 		goto_bad;
 
 	if (dm_list_empty(pvs))
 		goto_bad;
 
-	vg->cmd = fid->fmt->cmd;
-	vg->vgmem = mem;
 	vg->fid = fid;
-	vg->seqno = 0;
-	dm_list_init(&vg->pvs);
-	dm_list_init(&vg->lvs);
-	dm_list_init(&vg->tags);
-	dm_list_init(&vg->removed_pvs);
 
-	if (!_check_vgs(pvs, vg))
+	if (!_check_vgs(&pvs, vg))
 		goto_bad;
 
-	dl = dm_list_item(pvs->n, struct disk_list);
+	dl = dm_list_item(pvs.n, struct disk_list);
 
-	if (!import_vg(mem, vg, dl))
+	if (!import_vg(vg->vgmem, vg, dl))
 		goto_bad;
 
-	if (!import_pvs(fid->fmt, mem, vg, pvs))
+	if (!import_pvs(fid->fmt, vg->vgmem, vg, &pvs))
 		goto_bad;
 
-	if (!import_lvs(mem, vg, pvs))
+	if (!import_lvs(vg->vgmem, vg, &pvs))
 		goto_bad;
 
-	if (!import_extents(fid->fmt->cmd, vg, pvs))
+	if (!import_extents(fid->fmt->cmd, vg, &pvs))
 		goto_bad;
 
-	if (!import_snapshots(mem, vg, pvs))
+	if (!import_snapshots(vg->vgmem, vg, &pvs))
 		goto_bad;
 
 	/* Fix extents counts by adding missing PV if partial VG */
-	if ((vg->status & PARTIAL_VG) && !_fix_partial_vg(vg, pvs))
+	if ((vg->status & PARTIAL_VG) && !_fix_partial_vg(vg, &pvs))
 		goto_bad;
 
 	return vg;
 
-      bad:
-	dm_pool_free(mem, vg);
-	return NULL;
-}
-
-static struct volume_group *_format1_vg_read(struct format_instance *fid,
-				     const char *vg_name,
-				     struct metadata_area *mda __attribute__((unused)))
-{
-	struct dm_pool *mem = dm_pool_create("lvm1 vg_read", VG_MEMPOOL_CHUNK);
-	struct dm_list pvs;
-	struct volume_group *vg = NULL;
-	dm_list_init(&pvs);
-
-	if (!mem)
-		return_NULL;
-
-	/* Strip dev_dir if present */
-	vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
-
-	if (!read_pvs_in_vg
-	    (fid->fmt, vg_name, fid->fmt->cmd->filter, mem, &pvs))
-		goto_bad;
-
-	if (!(vg = _build_vg(fid, &pvs, mem)))
-		goto_bad;
-
-	return vg;
 bad:
-	dm_pool_destroy(mem);
+	free(vg);
+
 	return NULL;
 }
 
-- 
1.7.4.1



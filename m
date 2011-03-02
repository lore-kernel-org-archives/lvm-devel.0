From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  2 Mar 2011 19:20:24 +0100
Subject: [PATCH 2/4] Use alloc_vg for _pool_vg_read
In-Reply-To: <cover.1299089601.git.zkabelac@redhat.com>
References: <cover.1299089601.git.zkabelac@redhat.com>
Message-ID: <2707ac5b260a4ee390ba6e570e5bd7a32eac81c5.1299089601.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For simplier review.

Move remainder of _build_vg_from_pds  to _pool_vg_read.
Use  vg memory pool for import functions.
(it's been using smem -> fid mempool -> cmd mempool)

CHECKME: Why is here seqno == 1 ?
It's seems like every other alloc_vg is happy with seqno == 0.
Or all the others are wrond and count should start with 1 ?
Seems to be there from import day.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_pool/format_pool.c |   96 ++++++++++++++---------------------------
 1 files changed, 33 insertions(+), 63 deletions(-)

diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 4252dad..f37e1e3 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -98,93 +98,63 @@ static int _check_usp(const char *vgname, struct user_subpool *usp, int sp_count
 	return 1;
 }
 
-static struct volume_group *_build_vg_from_pds(struct format_instance
-					       *fid, struct dm_pool *mem,
-					       struct dm_list *pds)
+static struct volume_group *_pool_vg_read(struct format_instance *fid,
+					  const char *vg_name,
+					  struct metadata_area *mda __attribute__((unused)))
 {
-	struct dm_pool *smem = fid->fmt->cmd->mem;
-	struct volume_group *vg = NULL;
-	struct user_subpool *usp = NULL;
+	struct volume_group *vg;
+	struct user_subpool *usp;
 	int sp_count;
+	DM_LIST_INIT(pds);
 
-	if (!(vg = dm_pool_zalloc(smem, sizeof(*vg)))) {
-		log_error("Unable to allocate volume group structure");
-		return NULL;
-	}
+	/* We can safely ignore the mda passed in */
 
-	vg->cmd = fid->fmt->cmd;
-	vg->vgmem = mem;
-	vg->fid = fid;
-	vg->name = NULL;
-	vg->status = 0;
-	vg->extent_count = 0;
-	vg->pv_count = 0;
-	vg->seqno = 1;
-	vg->system_id = NULL;
-	dm_list_init(&vg->pvs);
-	dm_list_init(&vg->lvs);
-	dm_list_init(&vg->tags);
-	dm_list_init(&vg->removed_pvs);
-
-	if (!import_pool_vg(vg, smem, pds))
-		return_NULL;
+	/* Strip dev_dir if present */
+	vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
 
-	if (!import_pool_pvs(fid->fmt, vg, smem, pds))
+	/* Set vg_name through read_pool_pds() (SIMPLIFY in alloc_vg) */
+	if (!(vg = alloc_vg("pool_vg_read", fid->fmt->cmd, NULL)))
 		return_NULL;
 
-	if (!import_pool_lvs(vg, smem, pds))
-		return_NULL;
+	/* Read all the pvs in the vg */
+	if (!read_pool_pds(fid->fmt, vg_name, vg->vgmem, &pds))
+		goto_bad;
+
+	vg->fid = fid;
+	vg->seqno = 1; /* FIXME: Why is used 1 here? */
+
+	if (!import_pool_vg(vg, vg->vgmem, &pds))
+		goto_bad;
+
+	if (!import_pool_pvs(fid->fmt, vg, vg->vgmem, &pds))
+		goto_bad;
+
+	if (!import_pool_lvs(vg, vg->vgmem, &pds))
+		goto_bad;
 
 	/*
 	 * I need an intermediate subpool structure that contains all the
 	 * relevant info for this.  Then i can iterate through the subpool
 	 * structures for checking, and create the segments
 	 */
-	if (!(usp = _build_usp(pds, mem, &sp_count)))
-		return_NULL;
+	if (!(usp = _build_usp(&pds, vg->vgmem, &sp_count)))
+		goto_bad;
 
 	/*
 	 * check the subpool structures - we can't handle partial VGs in
 	 * the pool format, so this will error out if we're missing PVs
 	 */
 	if (!_check_usp(vg->name, usp, sp_count))
-		return_NULL;
+		goto_bad;
 
-	if (!import_pool_segments(&vg->lvs, smem, usp, sp_count))
-		return_NULL;
+	if (!import_pool_segments(&vg->lvs, vg->vgmem, usp, sp_count))
+		goto_bad;
 
 	return vg;
-}
 
-static struct volume_group *_pool_vg_read(struct format_instance *fid,
-				     const char *vg_name,
-				     struct metadata_area *mda __attribute__((unused)))
-{
-	struct dm_pool *mem = dm_pool_create("pool vg_read", VG_MEMPOOL_CHUNK);
-	struct dm_list pds;
-	struct volume_group *vg = NULL;
-
-	dm_list_init(&pds);
-
-	/* We can safely ignore the mda passed in */
-
-	if (!mem)
-		return_NULL;
-
-	/* Strip dev_dir if present */
-	vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
-
-	/* Read all the pvs in the vg */
-	if (!read_pool_pds(fid->fmt, vg_name, mem, &pds))
-		goto_out;
+bad:
+	free_vg(vg);
 
-	/* Do the rest of the vg stuff */
-	if (!(vg = _build_vg_from_pds(fid, mem, &pds)))
-		goto_out;
-
-	return vg;
-out:
-	dm_pool_destroy(mem);
 	return NULL;
 }
 
-- 
1.7.4.1



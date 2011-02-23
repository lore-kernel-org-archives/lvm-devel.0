From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 23 Feb 2011 14:52:15 +0100
Subject: [PATCH 1/3] Refactor vg allocation code
In-Reply-To: <cover.1298466569.git.zkabelac@redhat.com>
References: <cover.1298466569.git.zkabelac@redhat.com>
Message-ID: <95e375249a799ab7c5cb4d2f8ebf63e446c5364a.1298466569.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Create new function to allocate VG structure.

Usure about naming strategy - we use  i.e. alloc_lv,
but most the new function have now operation prefix.

Also the location after Dave's refactoring patches is unclear.

I'd suppose we should move all 'vg' related code to vg.c,
but for now lot's of stuff is still spread across metadata.c and
other files (i.e.  free_vg).

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/import_vsn1.c |   33 ++++++++++-----------------------
 lib/metadata/metadata.c       |   35 +++++------------------------------
 lib/metadata/vg.c             |   25 +++++++++++++++++++++++++
 lib/metadata/vg.h             |    2 ++
 4 files changed, 42 insertions(+), 53 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 0ffe334..bc63f36 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -652,35 +652,28 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	const struct config_node *vgn, *cn;
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL, *lv_hash = NULL;
-	struct dm_pool *mem = dm_pool_create("lvm2 vg_read", VG_MEMPOOL_CHUNK);
 	unsigned scan_done_once = use_cached_pvs;
 
-	if (!mem)
-		return_NULL;
-
 	/* skip any top-level values */
 	for (vgn = cft->root; (vgn && vgn->v); vgn = vgn->sib)
 		;
 
 	if (!vgn) {
 		log_error("Couldn't find volume group in file.");
-		goto bad;
+		return NULL;
 	}
 
-	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
-		goto_bad;
-
-	vg->vgmem = mem;
-	vg->cmd = fid->fmt->cmd;
+	if (!(vg = alloc_vg(fid->fmt->cmd)))
+		return_NULL;
 
 	/* FIXME Determine format type from file contents */
 	/* eg Set to instance of fmt1 here if reading a format1 backup? */
 	vg->fid = fid;
 
-	if (!(vg->name = dm_pool_strdup(mem, vgn->key)))
+	if (!(vg->name = dm_pool_strdup(vg->vgmem, vgn->key)))
 		goto_bad;
 
-	if (!(vg->system_id = dm_pool_zalloc(mem, NAME_LEN)))
+	if (!(vg->system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN)))
 		goto_bad;
 
 	vgn = vgn->child;
@@ -733,7 +726,6 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	vg->alloc = ALLOC_NORMAL;
 	if ((cn = find_config_node(vgn, "allocation_policy"))) {
 		const struct config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
@@ -761,21 +753,16 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	dm_list_init(&vg->pvs);
-	if (!_read_sections(fid, "physical_volumes", _read_pv, mem, vg,
+	if (!_read_sections(fid, "physical_volumes", _read_pv, vg->vgmem, vg,
 			    vgn, pv_hash, lv_hash, 0, &scan_done_once)) {
 		log_error("Couldn't find all physical volumes for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
-	dm_list_init(&vg->lvs);
-	dm_list_init(&vg->tags);
-	dm_list_init(&vg->removed_pvs);
-
 	/* Optional tags */
 	if ((cn = find_config_node(vgn, "tags")) &&
-	    !(read_tags(mem, &vg->tags, cn->v))) {
+	    !(read_tags(vg->vgmem, &vg->tags, cn->v))) {
 		log_error("Couldn't read tags for volume group %s.", vg->name);
 		goto bad;
 	}
@@ -789,14 +776,14 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	if (!_read_sections(fid, "logical_volumes", _read_lvnames, mem, vg,
+	if (!_read_sections(fid, "logical_volumes", _read_lvnames, vg->vgmem, vg,
 			    vgn, pv_hash, lv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volume names for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
-	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, mem, vg,
+	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, vg->vgmem, vg,
 			    vgn, pv_hash, lv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volumes for "
 			  "volume group %s.", vg->name);
@@ -824,7 +811,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	if (lv_hash)
 		dm_hash_destroy(lv_hash);
 
-	dm_pool_destroy(mem);
+	free_vg(vg);
 	return NULL;
 }
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6a29d24..d75a1cf 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -942,18 +942,8 @@ static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
 			     struct volume_group *vg,
 			     uint32_t failure)
 {
-	struct dm_pool *vgmem;
-
-	if (!vg) {
-		if (!(vgmem = dm_pool_create("lvm2 vg_handle", VG_MEMPOOL_CHUNK)) ||
-		    !(vg = dm_pool_zalloc(vgmem, sizeof(*vg)))) {
-			log_error("Error allocating vg handle.");
-			if (vgmem)
-				dm_pool_destroy(vgmem);
-			return_NULL;
-		}
-		vg->vgmem = vgmem;
-	}
+	if (!vg && !(vg = alloc_vg(cmd)))
+		return_NULL;
 
 	vg->read_status = failure;
 
@@ -994,7 +984,6 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 	struct volume_group *vg;
 	struct format_instance_ctx fic;
 	int consistent = 0;
-	struct dm_pool *mem;
 	uint32_t rc;
 
 	if (!validate_name(vg_name)) {
@@ -1017,10 +1006,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
 	}
 
-	if (!(mem = dm_pool_create("lvm2 vg_create", VG_MEMPOOL_CHUNK)))
-		goto_bad;
-
-	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
+        if (!(vg = alloc_vg(cmd)))
 		goto_bad;
 
 	if (!id_create(&vg->id)) {
@@ -1032,16 +1018,13 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 	/* Strip dev_dir if present */
 	vg_name = strip_dir(vg_name, cmd->dev_dir);
 
-	vg->vgmem = mem;
-	vg->cmd = cmd;
-
-	if (!(vg->name = dm_pool_strdup(mem, vg_name)))
+	if (!(vg->name = dm_pool_strdup(vg->vgmem, vg_name)))
 		goto_bad;
 
 	vg->seqno = 0;
 
 	vg->status = (RESIZEABLE_VG | LVM_READ | LVM_WRITE);
-	if (!(vg->system_id = dm_pool_alloc(mem, NAME_LEN)))
+	if (!(vg->system_id = dm_pool_alloc(vg->vgmem, NAME_LEN)))
 		goto_bad;
 
 	*vg->system_id = '\0';
@@ -1057,14 +1040,6 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 	vg->mda_copies = DEFAULT_VGMETADATACOPIES;
 
 	vg->pv_count = 0;
-	dm_list_init(&vg->pvs);
-
-	dm_list_init(&vg->lvs);
-
-	dm_list_init(&vg->tags);
-
-	/* initialize removed_pvs list */
-	dm_list_init(&vg->removed_pvs);
 
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vg_name;
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 9d0d5dd..392d23c 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -18,6 +18,31 @@
 #include "display.h"
 #include "activate.h"
 
+struct volume_group *alloc_vg(struct cmd_context *cmd)
+{
+	struct dm_pool *vgmem;
+	struct volume_group *vg;
+
+	if (!(vgmem = dm_pool_create("lvm2 vg_handle", VG_MEMPOOL_CHUNK)) ||
+	    !(vg = dm_pool_zalloc(vgmem, sizeof(*vg)))) {
+		log_error("Error allocating VG structure.");
+		if (vgmem)
+			dm_pool_destroy(vgmem);
+		return NULL;
+	}
+
+	vg->cmd = cmd;
+	vg->vgmem = vgmem;
+	vg->alloc = ALLOC_NORMAL;
+
+	dm_list_init(&vg->pvs);
+	dm_list_init(&vg->lvs);
+	dm_list_init(&vg->tags);
+	dm_list_init(&vg->removed_pvs);
+
+	return vg;
+}
+
 char *vg_fmt_dup(const struct volume_group *vg)
 {
 	if (!vg->fid || !vg->fid->fmt)
diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index 448dcfe..c00fb74 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -95,6 +95,8 @@ struct volume_group {
 	uint32_t mda_copies; /* target number of mdas for this VG */
 };
 
+struct volume_group *alloc_vg(struct cmd_context *cmd);
+
 char *vg_fmt_dup(const struct volume_group *vg);
 char *vg_name_dup(const struct volume_group *vg);
 char *vg_system_id_dup(const struct volume_group *vg);
-- 
1.7.4.1



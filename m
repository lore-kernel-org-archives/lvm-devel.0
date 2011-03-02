From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  2 Mar 2011 19:20:23 +0100
Subject: [PATCH 1/4] Refactor vg allocation code
In-Reply-To: <cover.1299089601.git.zkabelac@redhat.com>
References: <cover.1299089601.git.zkabelac@redhat.com>
Message-ID: <5d8c872e6031f8aa61255e75ea65d935a38dd5a8.1299089601.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Create new function to allocate VG structure.

Currently it takes pool_name (for easier debugging).
And also take vg_name to futher simplify code.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/format_text/import_vsn1.c |   38 ++++++---------------
 lib/metadata/metadata.c       |   75 ++++++++--------------------------------
 lib/metadata/vg.c             |   32 +++++++++++++++++
 lib/metadata/vg.h             |    3 ++
 4 files changed, 61 insertions(+), 87 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 0ffe334..d75e7af 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -652,35 +652,25 @@ static struct volume_group *_read_vg(struct format_instance *fid,
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
+	if (!(vg = alloc_vg("read_vg", fid->fmt->cmd, vgn->key)))
+		return_NULL;
 
 	/* FIXME Determine format type from file contents */
 	/* eg Set to instance of fmt1 here if reading a format1 backup? */
 	vg->fid = fid;
 
-	if (!(vg->name = dm_pool_strdup(mem, vgn->key)))
-		goto_bad;
-
-	if (!(vg->system_id = dm_pool_zalloc(mem, NAME_LEN)))
+	if (!(vg->system_id = dm_pool_zalloc(vg->vgmem, NAME_LEN)))
 		goto_bad;
 
 	vgn = vgn->child;
@@ -733,7 +723,6 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	vg->alloc = ALLOC_NORMAL;
 	if ((cn = find_config_node(vgn, "allocation_policy"))) {
 		const struct config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
@@ -761,21 +750,16 @@ static struct volume_group *_read_vg(struct format_instance *fid,
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
@@ -789,15 +773,15 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 		goto bad;
 	}
 
-	if (!_read_sections(fid, "logical_volumes", _read_lvnames, mem, vg,
-			    vgn, pv_hash, lv_hash, 1, NULL)) {
+	if (!_read_sections(fid, "logical_volumes", _read_lvnames, vg->vgmem,
+			    vg, vgn, pv_hash, lv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volume names for volume "
 			  "group %s.", vg->name);
 		goto bad;
 	}
 
-	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, mem, vg,
-			    vgn, pv_hash, lv_hash, 1, NULL)) {
+	if (!_read_sections(fid, "logical_volumes", _read_lvsegs, vg->vgmem,
+			    vg, vgn, pv_hash, lv_hash, 1, NULL)) {
 		log_error("Couldn't read all logical volumes for "
 			  "volume group %s.", vg->name);
 		goto bad;
@@ -824,7 +808,7 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	if (lv_hash)
 		dm_hash_destroy(lv_hash);
 
-	dm_pool_destroy(mem);
+	free_vg(vg);
 	return NULL;
 }
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ff61cbb..f50ab2a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -836,25 +836,16 @@ int vgcreate_params_validate(struct cmd_context *cmd,
  * possible failure code or zero for success.
  */
 static struct volume_group *_vg_make_handle(struct cmd_context *cmd,
-			     struct volume_group *vg,
-			     uint32_t failure)
+					    struct volume_group *vg,
+					    uint32_t failure)
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
+	if (!vg && !(vg = alloc_vg("vg_make_handle", cmd, NULL)))
+		return_NULL;
 
-	vg->read_status = failure;
+	if (vg->read_status != failure)
+		vg->read_status = failure;
 
-	return (struct volume_group *)vg;
+	return vg;
 }
 
 int lv_has_unknown_segments(const struct logical_volume *lv)
@@ -891,7 +882,6 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 	struct volume_group *vg;
 	struct format_instance_ctx fic;
 	int consistent = 0;
-	struct dm_pool *mem;
 	uint32_t rc;
 
 	if (!validate_name(vg_name)) {
@@ -914,10 +904,10 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 		return _vg_make_handle(cmd, NULL, FAILED_EXIST);
 	}
 
-	if (!(mem = dm_pool_create("lvm2 vg_create", VG_MEMPOOL_CHUNK)))
-		goto_bad;
+	/* Strip dev_dir if present */
+	vg_name = strip_dir(vg_name, cmd->dev_dir);
 
-	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
+	if (!(vg = alloc_vg("vg_create", cmd, vg_name)))
 		goto_bad;
 
 	if (!id_create(&vg->id)) {
@@ -926,19 +916,8 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 		goto bad;
 	}
 
-	/* Strip dev_dir if present */
-	vg_name = strip_dir(vg_name, cmd->dev_dir);
-
-	vg->vgmem = mem;
-	vg->cmd = cmd;
-
-	if (!(vg->name = dm_pool_strdup(mem, vg_name)))
-		goto_bad;
-
-	vg->seqno = 0;
-
 	vg->status = (RESIZEABLE_VG | LVM_READ | LVM_WRITE);
-	if (!(vg->system_id = dm_pool_alloc(mem, NAME_LEN)))
+	if (!(vg->system_id = dm_pool_alloc(vg->vgmem, NAME_LEN)))
 		goto_bad;
 
 	*vg->system_id = '\0';
@@ -954,14 +933,6 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
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
@@ -2614,31 +2585,15 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	struct pv_list *pvl;
 	struct volume_group *vg;
 	struct physical_volume *pv;
-	struct dm_pool *mem;
 
 	lvmcache_label_scan(cmd, 0);
 
 	if (!(vginfo = vginfo_from_vgname(orphan_vgname, NULL)))
 		return_NULL;
 
-	if (!(mem = dm_pool_create("vg_read orphan", VG_MEMPOOL_CHUNK)))
+	if (!(vg = alloc_vg("vg_read_orphans", cmd, orphan_vgname)))
 		return_NULL;
 
-	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg)))) {
-		log_error("vg allocation failed");
-		goto bad;
-	}
-	dm_list_init(&vg->pvs);
-	dm_list_init(&vg->lvs);
-	dm_list_init(&vg->tags);
-	dm_list_init(&vg->removed_pvs);
-	vg->vgmem = mem;
-	vg->cmd = cmd;
-	if (!(vg->name = dm_pool_strdup(mem, orphan_vgname))) {
-		log_error("vg name allocation failed");
-		goto bad;
-	}
-
 	/* create format instance with appropriate metadata area */
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = orphan_vgname;
@@ -2649,11 +2604,11 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	}
 
 	dm_list_iterate_items(info, &vginfo->infos) {
-		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev),
+		if (!(pv = _pv_read(cmd, vg->vgmem, dev_name(info->dev),
 				    vg->fid, NULL, warnings, 0))) {
 			continue;
 		}
-		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
+		if (!(pvl = dm_pool_zalloc(vg->vgmem, sizeof(*pvl)))) {
 			log_error("pv_list allocation failed");
 			goto bad;
 		}
@@ -2663,7 +2618,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 
 	return vg;
 bad:
-	dm_pool_destroy(mem);
+	free_vg(vg);
 	return NULL;
 }
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 9d0d5dd..5bd00ae 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -18,6 +18,38 @@
 #include "display.h"
 #include "activate.h"
 
+struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
+			      const char *vg_name)
+{
+	struct dm_pool *vgmem;
+	struct volume_group *vg;
+
+	if (!(vgmem = dm_pool_create(pool_name, VG_MEMPOOL_CHUNK)) ||
+	    !(vg = dm_pool_zalloc(vgmem, sizeof(*vg)))) {
+		log_error("Failed to allocate volume group structure");
+		if (vgmem)
+			dm_pool_destroy(vgmem);
+		return NULL;
+	}
+
+	if (vg_name && !(vg->name = dm_pool_strdup(vgmem, vg_name))) {
+		log_error("Failed to allocate VG name.");
+		dm_pool_destroy(vgmem);
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
index 448dcfe..2cc6047 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -95,6 +95,9 @@ struct volume_group {
 	uint32_t mda_copies; /* target number of mdas for this VG */
 };
 
+struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
+			      const char *vg_name);
+
 char *vg_fmt_dup(const struct volume_group *vg);
 char *vg_name_dup(const struct volume_group *vg);
 char *vg_system_id_dup(const struct volume_group *vg);
-- 
1.7.4.1



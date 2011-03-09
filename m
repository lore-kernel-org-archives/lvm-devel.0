From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed,  9 Mar 2011 13:22:35 +0100
Subject: [PATCH 3/7] Use vg_set_fid and new pv_set_fid throughout.
In-Reply-To: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
References: <1299673359-6784-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1299673359-6784-4-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Let's define a strict rule that each fid assignment to a PV/VG will be
done via pv_set_fid/vg_set_fid fn. This is needed for proper reference
counting.

(Even a NULL fid should be assigned using these fns to decrement
ref_count for any currently assigned fid)

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/format1/format1.c         |    2 +-
 lib/format_pool/format_pool.c |    2 +-
 lib/format_text/format-text.c |    6 +----
 lib/format_text/import_vsn1.c |    8 +++---
 lib/metadata/metadata.c       |   52 +++++++++++++++++++++++++++++++++++-----
 lib/metadata/metadata.h       |    1 +
 6 files changed, 53 insertions(+), 18 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index a024d99..3961b67 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -192,12 +192,12 @@ static struct volume_group *_build_vg(struct format_instance *fid,
 
 	vg->cmd = fid->fmt->cmd;
 	vg->vgmem = mem;
-	vg->fid = fid;
 	vg->seqno = 0;
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
+	vg_set_fid(vg, fid);
 
 	if (!_check_vgs(pvs, vg))
 		goto_bad;
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 24c21c2..53b4171 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -114,7 +114,6 @@ static struct volume_group *_build_vg_from_pds(struct format_instance
 
 	vg->cmd = fid->fmt->cmd;
 	vg->vgmem = mem;
-	vg->fid = fid;
 	vg->name = NULL;
 	vg->status = 0;
 	vg->extent_count = 0;
@@ -125,6 +124,7 @@ static struct volume_group *_build_vg_from_pds(struct format_instance
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
+	vg_set_fid(vg, fid);
 
 	if (!import_pool_vg(vg, smem, pds))
 		return_NULL;
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 166c8cc..789c984 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1690,12 +1690,8 @@ static int _text_pv_setup(const struct format_type *fmt,
 	    (pv_mdac = pv_mda->metadata_locn))
 		size_reduction = pv_mdac->area.size >> SECTOR_SHIFT;
 
-	/* Destroy old PV-based format instance if it exists. */
-	if (!(pv->fid->type & FMT_INSTANCE_VG))
-		pv->fmt->ops->destroy_instance(pv->fid);
-
 	/* From now on, VG format instance will be used. */
-	pv->fid = vg->fid;
+	pv_set_fid(pv, vg->fid);
 
 	/* FIXME Cope with genuine pe_count 0 */
 
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 0ffe334..d71f1ec 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -673,10 +673,6 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	vg->vgmem = mem;
 	vg->cmd = fid->fmt->cmd;
 
-	/* FIXME Determine format type from file contents */
-	/* eg Set to instance of fmt1 here if reading a format1 backup? */
-	vg->fid = fid;
-
 	if (!(vg->name = dm_pool_strdup(mem, vgn->key)))
 		goto_bad;
 
@@ -812,6 +808,10 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	dm_hash_destroy(pv_hash);
 	dm_hash_destroy(lv_hash);
 
+	/* FIXME Determine format type from file contents */
+	/* eg Set to instance of fmt1 here if reading a format1 backup? */
+	vg_set_fid(vg, fid);
+
 	/*
 	 * Finished.
 	 */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5fba636..cfbc1b7 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -166,14 +166,24 @@ void add_pvl_to_vgs(struct volume_group *vg, struct pv_list *pvl)
 	dm_list_add(&vg->pvs, &pvl->list);
 	vg->pv_count++;
 	pvl->pv->vg = vg;
-	pvl->pv->fid = vg->fid;
+	pv_set_fid(pvl->pv, vg->fid);
 }
 
 void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
 {
+	struct format_instance_ctx fic;
+	struct format_instance *fid;
+
 	vg->pv_count--;
 	dm_list_del(&pvl->list);
 	pvl->pv->vg = NULL; /* orphan */
+
+	/* Use a new PV-based format instance since the PV is orphan now. */
+	fic.type = FMT_INSTANCE_PV | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
+	fic.context.pv_id = (const char *) &pvl->pv->id;
+	fid = pvl->pv->fid->fmt->ops->create_instance(pvl->pv->fid->fmt, &fic);
+
+	pv_set_fid(pvl->pv, fid);
 }
 
 
@@ -288,6 +298,10 @@ static int _copy_pv(struct dm_pool *pvmem,
 {
 	memcpy(pv_to, pv_from, sizeof(*pv_to));
 
+	/* We must use pv_set_fid here to update the reference counter! */
+	pv_to->fid = NULL;
+	pv_set_fid(pv_to, pv_from->fid);
+
 	if (!(pv_to->vg_name = dm_pool_strdup(pvmem, pv_from->vg_name)))
 		return_0;
 
@@ -890,6 +904,7 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 {
 	struct volume_group *vg;
 	struct format_instance_ctx fic;
+	struct format_instance *fid;
 	int consistent = 0;
 	struct dm_pool *mem;
 	uint32_t rc;
@@ -966,10 +981,11 @@ struct volume_group *vg_create(struct cmd_context *cmd, const char *vg_name)
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = vg_name;
 	fic.context.vg_ref.vg_id = NULL;
-	if (!(vg->fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
+	if (!(fid = cmd->fmt->ops->create_instance(cmd->fmt, &fic))) {
 		log_error("Failed to create format instance");
 		goto bad;
 	}
+	vg_set_fid(vg, fid);
 
 	if (vg->fid->fmt->ops->vg_setup &&
 	    !vg->fid->fmt->ops->vg_setup(vg->fid, vg)) {
@@ -1536,7 +1552,7 @@ static struct physical_volume *_alloc_pv(struct dm_pool *mem, struct device *dev
 	if (!pv)
 		return_NULL;
 
-	pv->fid = NULL;
+	pv_set_fid(pv, NULL);
 	pv->pe_size = 0;
 	pv->pe_start = 0;
 	pv->pe_count = 0;
@@ -1591,6 +1607,7 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 {
 	const struct format_type *fmt = cmd->fmt;
 	struct format_instance_ctx fic;
+	struct format_instance *fid;
 	struct dm_pool *mem = fmt->cmd->mem;
 	struct physical_volume *pv = _alloc_pv(mem, dev);
 	unsigned mda_index;
@@ -1634,10 +1651,11 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 
 	fic.type = FMT_INSTANCE_PV;
 	fic.context.pv_id = (const char *) &pv->id;
-	if (!(pv->fid = fmt->ops->create_instance(fmt, &fic))) {
+	if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
 		log_error("Couldn't create format instance for PV %s.", pv_dev_name(pv));
 		goto bad;
 	}
+	pv_set_fid(pv, fid);
 
 	pv->fmt = fmt;
 	pv->vg_name = fmt->orphan_vg_name;
@@ -2609,6 +2627,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 					     const char *orphan_vgname)
 {
 	struct format_instance_ctx fic;
+	struct format_instance *fid;
 	struct lvmcache_vginfo *vginfo;
 	struct lvmcache_info *info;
 	struct pv_list *pvl;
@@ -2643,10 +2662,11 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
 	fic.context.vg_ref.vg_name = orphan_vgname;
 	fic.context.vg_ref.vg_id = NULL;
-	if (!(vg->fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic))) {
+	if (!(fid = vginfo->fmt->ops->create_instance(vginfo->fmt, &fic))) {
 		log_error("Failed to create format instance");
 		goto bad;
 	}
+	vg_set_fid(vg, fid);
 
 	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!(pv = _pv_read(cmd, mem, dev_name(info->dev),
@@ -3425,11 +3445,12 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 	else {
 		fic.type = FMT_INSTANCE_PV | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
 		fic.context.pv_id = (const char *) &pv->id;
-		if (!(pv->fid = pv->fmt->ops->create_instance(pv->fmt, &fic))) {
+		if (!(fid = pv->fmt->ops->create_instance(pv->fmt, &fic))) {
 			log_error("_pv_read: Couldn't create format instance "
 				  "for PV %s", pv_name);
 			goto bad;
 		}
+		pv_set_fid(pv, fid);
 	}
 
 	return pv;
@@ -3980,14 +4001,31 @@ bad:
 	return NULL;
 }
 
+void pv_set_fid(struct physical_volume *pv,
+		struct format_instance *fid)
+{
+	if (pv->fid)
+		pv->fid->fmt->ops->destroy_instance(pv->fid);
+
+	pv->fid = fid;
+	if (fid)
+		fid->ref_count++;
+}
+
 void vg_set_fid(struct volume_group *vg,
 		 struct format_instance *fid)
 {
 	struct pv_list *pvl;
 
+	if (vg->fid)
+		vg->fid->fmt->ops->destroy_instance(vg->fid);
+
 	vg->fid = fid;
+	if (fid)
+		fid->ref_count++;
+
 	dm_list_iterate_items(pvl, &vg->pvs)
-		pvl->pv->fid = fid;
+		pv_set_fid(pvl->pv, fid);
 }
 
 static int _convert_key_to_string(const char *key, size_t key_len,
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 8f0a6b1..46311df 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -206,6 +206,7 @@ struct format_instance_ctx {
 
 struct format_instance *alloc_fid(const struct format_type *fmt,
 				  const struct format_instance_ctx *fic);
+void pv_set_fid(struct physical_volume *pv, struct format_instance *fid);
 void vg_set_fid(struct volume_group *vg, struct format_instance *fid);
 /* FIXME: Add generic interface for mda counts based on given key. */
 int fid_add_mda(struct format_instance *fid, struct metadata_area *mda,
-- 
1.7.4



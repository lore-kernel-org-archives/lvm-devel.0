From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Mar 2011 12:43:33 -0000
Subject: LVM2 lib/format1/format1.c lib/format_pool/for ...
Message-ID: <20110310124333.15916.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-10 12:43:30

Modified files:
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: import_vsn1.c 
	lib/metadata   : metadata.c vg.c vg.h 
	.              : WHATS_NEW 

Log message:
	Refactor vg allocation code
	
	Create new function alloc_vg() to allocate VG structure.
	
	It takes pool_name (for easier debugging).
	and also take vg_name to futher simplify code.
	
	Move remainder of _build_vg_from_pds  to _pool_vg_read
	and use vg memory pool for import functions.
	(it's been using smem -> fid mempool -> cmd mempool)
	(FIXME: remove mempool parameter for import functions and use vg).
	
	Move remainder of the _build_vg to _format1_vg_read

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.437&r2=1.438
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1940&r2=1.1941

--- LVM2/lib/format1/format1.c	2011/02/25 14:12:14	1.133
+++ LVM2/lib/format1/format1.c	2011/03/10 12:43:29	1.134
@@ -177,84 +177,58 @@
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
 
-	if (dm_list_empty(pvs))
+	if (dm_list_empty(&pvs))
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
 
--- LVM2/lib/format_pool/format_pool.c	2011/02/21 12:24:16	1.39
+++ LVM2/lib/format_pool/format_pool.c	2011/03/10 12:43:29	1.40
@@ -98,93 +98,65 @@
 	return 1;
 }
 
-static struct volume_group *_build_vg_from_pds(struct format_instance
-					       *fid, struct dm_pool *mem,
-					       struct dm_list *pds)
-{
-	struct dm_pool *smem = fid->fmt->cmd->mem;
-	struct volume_group *vg = NULL;
-	struct user_subpool *usp = NULL;
+static struct volume_group *_pool_vg_read(struct format_instance *fid,
+					  const char *vg_name,
+					  struct metadata_area *mda __attribute__((unused)))
+{
+	struct volume_group *vg;
+	struct user_subpool *usp;
 	int sp_count;
+	DM_LIST_INIT(pds);
 
-	if (!(vg = dm_pool_zalloc(smem, sizeof(*vg)))) {
-		log_error("Unable to allocate volume group structure");
-		return NULL;
-	}
+	/* We can safely ignore the mda passed in */
+
+	/* Strip dev_dir if present */
+	vg_name = strip_dir(vg_name, fid->fmt->cmd->dev_dir);
+
+	/* Set vg_name through read_pool_pds() */
+	if (!(vg = alloc_vg("pool_vg_read", fid->fmt->cmd, NULL)))
+		return_NULL;
+
+	/* Read all the pvs in the vg */
+	if (!read_pool_pds(fid->fmt, vg_name, vg->vgmem, &pds))
+		goto_bad;
 
-	vg->cmd = fid->fmt->cmd;
-	vg->vgmem = mem;
 	vg->fid = fid;
-	vg->name = NULL;
-	vg->status = 0;
-	vg->extent_count = 0;
-	vg->pv_count = 0;
+	/* Setting pool seqno to 1 because the code always did this,
+	 * although we don't think it's needed. */
 	vg->seqno = 1;
-	vg->system_id = NULL;
-	dm_list_init(&vg->pvs);
-	dm_list_init(&vg->lvs);
-	dm_list_init(&vg->tags);
-	dm_list_init(&vg->removed_pvs);
 
-	if (!import_pool_vg(vg, smem, pds))
-		return_NULL;
+	if (!import_pool_vg(vg, vg->vgmem, &pds))
+		goto_bad;
 
-	if (!import_pool_pvs(fid->fmt, vg, smem, pds))
-		return_NULL;
+	if (!import_pool_pvs(fid->fmt, vg, vg->vgmem, &pds))
+		goto_bad;
 
-	if (!import_pool_lvs(vg, smem, pds))
-		return_NULL;
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
 
--- LVM2/lib/format_text/import_vsn1.c	2011/02/03 16:03:13	1.82
+++ LVM2/lib/format_text/import_vsn1.c	2011/03/10 12:43:29	1.83
@@ -652,35 +652,25 @@
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
@@ -733,7 +723,6 @@
 		goto bad;
 	}
 
-	vg->alloc = ALLOC_NORMAL;
 	if ((cn = find_config_node(vgn, "allocation_policy"))) {
 		const struct config_value *cv = cn->v;
 		if (!cv || !cv->v.str) {
@@ -761,21 +750,16 @@
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
@@ -789,15 +773,15 @@
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
@@ -824,7 +808,7 @@
 	if (lv_hash)
 		dm_hash_destroy(lv_hash);
 
-	dm_pool_destroy(mem);
+	free_vg(vg);
 	return NULL;
 }
 
--- LVM2/lib/metadata/metadata.c	2011/02/28 13:19:02	1.437
+++ LVM2/lib/metadata/metadata.c	2011/03/10 12:43:30	1.438
@@ -836,25 +836,16 @@
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
@@ -891,7 +882,6 @@
 	struct volume_group *vg;
 	struct format_instance_ctx fic;
 	int consistent = 0;
-	struct dm_pool *mem;
 	uint32_t rc;
 
 	if (!validate_name(vg_name)) {
@@ -914,10 +904,10 @@
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
@@ -926,19 +916,8 @@
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
@@ -954,14 +933,6 @@
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
@@ -2614,31 +2585,15 @@
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
@@ -2649,11 +2604,11 @@
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
@@ -2663,7 +2618,7 @@
 
 	return vg;
 bad:
-	dm_pool_destroy(mem);
+	free_vg(vg);
 	return NULL;
 }
 
--- LVM2/lib/metadata/vg.c	2010/10/25 13:54:29	1.8
+++ LVM2/lib/metadata/vg.c	2011/03/10 12:43:30	1.9
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
--- LVM2/lib/metadata/vg.h	2010/12/20 13:40:46	1.9
+++ LVM2/lib/metadata/vg.h	2011/03/10 12:43:30	1.10
@@ -95,6 +95,9 @@
 	uint32_t mda_copies; /* target number of mdas for this VG */
 };
 
+struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
+			      const char *vg_name);
+
 char *vg_fmt_dup(const struct volume_group *vg);
 char *vg_name_dup(const struct volume_group *vg);
 char *vg_system_id_dup(const struct volume_group *vg);
--- LVM2/WHATS_NEW	2011/03/10 03:03:03	1.1940
+++ LVM2/WHATS_NEW	2011/03/10 12:43:30	1.1941
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Refactor allocation of VG structure, add alloc_vg().
   Avoid possible endless loop in _free_vginfo when 4 or more VGs have same name.
   Use empty string instead of /dev// for LV path when there's no VG.
   Don't allocate unused VG mempool in _pvsegs_sub_single.



From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Apr 2009 09:59:20 -0000
Subject: LVM2 ./WHATS_NEW lib/format1/format1.c lib/for ...
Message-ID: <20090410095920.19426.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-04-10 09:59:19

Modified files:
	.              : WHATS_NEW 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: import_vsn1.c 
	lib/locking    : locking.h 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 

Log message:
	Introduce memory pool per volume group.
	
	Since now, all code reading volume group is responsible for releasing
	the memory allocated by calling vg_release(vg).
	(For simplicity of use, vg_releae can be called for vg == NULL,
	the same logic like free(NULL)).
	
	Also providing simple macro for unlocking & releasing in one step,
	tools usualy uses this approach.
	
	The global memory pool (cmd->mem) should be used only for global
	physical volume operations.
	
	This patch have to be applied with all subsequent patches to complete
	memory pool per vg logic.
	
	Using separate memory pool has quite bit memory saving impact when
	using large VGs, this is mainly needed when we have to use
	preallocated and locked memory (and should not overflow from that
	memory space).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1085&r2=1.1086
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.63&r2=1.64
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.209&r2=1.210
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.190&r2=1.191

--- LVM2/WHATS_NEW	2009/04/10 09:56:58	1.1085
+++ LVM2/WHATS_NEW	2009/04/10 09:59:18	1.1086
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Introduce memory pools per volume group (to reduce memory for large VGs).
   Add memory pool leaks detection.
   Use copy of PV structure when manipulating with global PV lists.
   Always return exit error status when locking of volume group fails.
--- LVM2/lib/format1/format1.c	2009/02/25 23:29:06	1.111
+++ LVM2/lib/format1/format1.c	2009/04/10 09:59:18	1.112
@@ -111,9 +111,9 @@
 }
 
 static struct volume_group *_build_vg(struct format_instance *fid,
-				      struct dm_list *pvs)
+				      struct dm_list *pvs,
+				      struct dm_pool *mem)
 {
-	struct dm_pool *mem = fid->fmt->cmd->mem;
 	struct volume_group *vg = dm_pool_alloc(mem, sizeof(*vg));
 	struct disk_list *dl;
 
@@ -126,6 +126,7 @@
 	memset(vg, 0, sizeof(*vg));
 
 	vg->cmd = fid->fmt->cmd;
+	vg->vgmem = mem;
 	vg->fid = fid;
 	vg->seqno = 0;
 	dm_list_init(&vg->pvs);
@@ -163,7 +164,7 @@
 				     const char *vg_name,
 				     struct metadata_area *mda __attribute((unused)))
 {
-	struct dm_pool *mem = dm_pool_create("lvm1 vg_read", 1024 * 10);
+	struct dm_pool *mem = dm_pool_create("lvm1 vg_read", VG_MEMPOOL_CHUNK);
 	struct dm_list pvs;
 	struct volume_group *vg = NULL;
 	dm_list_init(&pvs);
@@ -178,12 +179,13 @@
 	    (fid->fmt, vg_name, fid->fmt->cmd->filter, mem, &pvs))
 		goto_bad;
 
-	if (!(vg = _build_vg(fid, &pvs)))
+	if (!(vg = _build_vg(fid, &pvs, mem)))
 		goto_bad;
 
-      bad:
-	dm_pool_destroy(mem);
 	return vg;
+bad:
+	dm_pool_destroy(mem);
+	return NULL;
 }
 
 static struct disk_list *_flatten_pv(struct format_instance *fid,
@@ -240,7 +242,7 @@
 static int _format1_vg_write(struct format_instance *fid, struct volume_group *vg,
 		     struct metadata_area *mda __attribute((unused)))
 {
-	struct dm_pool *mem = dm_pool_create("lvm1 vg_write", 1024 * 10);
+	struct dm_pool *mem = dm_pool_create("lvm1 vg_write", VG_MEMPOOL_CHUNK);
 	struct dm_list pvds;
 	int r = 0;
 
--- LVM2/lib/format_pool/format_pool.c	2009/02/25 23:29:06	1.20
+++ LVM2/lib/format_pool/format_pool.c	2009/04/10 09:59:18	1.21
@@ -113,6 +113,7 @@
 	}
 
 	vg->cmd = fid->fmt->cmd;
+	vg->vgmem = mem;
 	vg->fid = fid;
 	vg->name = NULL;
 	vg->status = 0;
@@ -160,7 +161,7 @@
 				     const char *vg_name,
 				     struct metadata_area *mda __attribute((unused)))
 {
-	struct dm_pool *mem = dm_pool_create("pool vg_read", 1024);
+	struct dm_pool *mem = dm_pool_create("pool vg_read", VG_MEMPOOL_CHUNK);
 	struct dm_list pds;
 	struct volume_group *vg = NULL;
 
@@ -182,9 +183,10 @@
 	if (!(vg = _build_vg_from_pds(fid, mem, &pds)))
 		goto_out;
 
-      out:
-	dm_pool_destroy(mem);
 	return vg;
+out:
+	dm_pool_destroy(mem);
+	return NULL;
 }
 
 static int _pool_pv_setup(const struct format_type *fmt __attribute((unused)),
--- LVM2/lib/format_text/import_vsn1.c	2009/04/02 21:34:41	1.57
+++ LVM2/lib/format_text/import_vsn1.c	2009/04/10 09:59:19	1.58
@@ -662,18 +662,23 @@
 	struct config_node *vgn, *cn;
 	struct volume_group *vg;
 	struct dm_hash_table *pv_hash = NULL;
-	struct dm_pool *mem = fid->fmt->cmd->mem;
+	struct dm_pool *mem = dm_pool_create("lvm2 vg_read", VG_MEMPOOL_CHUNK);
+
+	if (!mem)
+		return_NULL;
 
 	/* skip any top-level values */
 	for (vgn = cft->root; (vgn && vgn->v); vgn = vgn->sib) ;
 
 	if (!vgn) {
 		log_error("Couldn't find volume group in file.");
-		return NULL;
+		goto bad;
 	}
 
 	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
-		return_NULL;
+		goto_bad;
+
+	vg->vgmem = mem;
 	vg->cmd = fid->fmt->cmd;
 
 	/* FIXME Determine format type from file contents */
@@ -807,7 +812,7 @@
 	if (pv_hash)
 		dm_hash_destroy(pv_hash);
 
-	dm_pool_free(mem, vg);
+	dm_pool_destroy(mem);
 	return NULL;
 }
 
--- LVM2/lib/locking/locking.h	2008/11/03 22:14:29	1.43
+++ LVM2/lib/locking/locking.h	2009/04/10 09:59:19	1.44
@@ -115,6 +115,9 @@
 	lock_vol(cmd, (lv)->lvid.s, flags | LCK_LV_CLUSTERED(lv))
 
 #define unlock_vg(cmd, vol)	lock_vol(cmd, vol, LCK_VG_UNLOCK)
+#define unlock_release_vg(cmd, vg, vol) do { unlock_vg(cmd, vol); \
+					     vg_release(vg); \
+					} while (0)
 
 #define resume_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_RESUME)
 #define suspend_lv(cmd, lv)	lock_lv_vol(cmd, lv, LCK_LV_SUSPEND | LCK_HOLD)
--- LVM2/lib/metadata/metadata-exported.h	2009/02/25 23:29:06	1.63
+++ LVM2/lib/metadata/metadata-exported.h	2009/04/10 09:59:19	1.64
@@ -212,6 +212,7 @@
 
 struct volume_group {
 	struct cmd_context *cmd;
+	struct dm_pool *vgmem;
 	struct format_instance *fid;
 	uint32_t seqno;		/* Metadata sequence number */
 
@@ -437,6 +438,7 @@
 int vg_split_mdas(struct cmd_context *cmd, struct volume_group *vg_from,
 		  struct volume_group *vg_to);
 
+void vg_release(struct volume_group *vg);
 /* Manipulate LVs */
 struct logical_volume *lv_create_empty(const char *name,
 				       union lvid *lvid,
--- LVM2/lib/metadata/metadata.c	2009/04/10 09:56:00	1.209
+++ LVM2/lib/metadata/metadata.c	2009/04/10 09:59:19	1.210
@@ -517,18 +517,22 @@
 			       int pv_count, char **pv_names)
 {
 	struct volume_group *vg;
-	struct dm_pool *mem = cmd->mem;
 	int consistent = 0;
-
-	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
-		return_NULL;
+	struct dm_pool *mem;
 
 	/* is this vg name already in use ? */
-	if (vg_read_internal(cmd, vg_name, NULL, &consistent)) {
+	if ((vg = vg_read_internal(cmd, vg_name, NULL, &consistent))) {
 		log_err("A volume group called '%s' already exists.", vg_name);
-		goto bad;
+		vg_release(vg);
+		return NULL;
 	}
 
+	if (!(mem = dm_pool_create("lvm2 vg_create", VG_MEMPOOL_CHUNK)))
+		return_NULL;
+
+	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
+		goto_bad;
+
 	if (!id_create(&vg->id)) {
 		log_err("Couldn't create uuid for volume group '%s'.", vg_name);
 		goto bad;
@@ -537,6 +541,7 @@
 	/* Strip dev_dir if present */
 	vg_name = strip_dir(vg_name, cmd->dev_dir);
 
+	vg->vgmem = mem;
 	vg->cmd = cmd;
 
 	if (!(vg->name = dm_pool_strdup(mem, vg_name)))
@@ -589,7 +594,7 @@
 	return vg;
 
       bad:
-	dm_pool_free(mem, vg);
+	dm_pool_destroy(mem);
 	return NULL;
 }
 
@@ -1643,23 +1648,28 @@
 	struct pv_list *pvl;
 	struct volume_group *vg;
 	struct physical_volume *pv;
+	struct dm_pool *mem;
 
 	lvmcache_label_scan(cmd, 0);
 
 	if (!(vginfo = vginfo_from_vgname(orphan_vgname, NULL)))
 		return_NULL;
 
-	if (!(vg = dm_pool_zalloc(cmd->mem, sizeof(*vg)))) {
+	if (!(mem = dm_pool_create("vg_read orphan", VG_MEMPOOL_CHUNK)))
+		return_NULL;
+
+	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg)))) {
 		log_error("vg allocation failed");
 		return NULL;
 	}
 	dm_list_init(&vg->pvs);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
+	vg->vgmem = mem;
 	vg->cmd = cmd;
-	if (!(vg->name = dm_pool_strdup(cmd->mem, orphan_vgname))) {
+	if (!(vg->name = dm_pool_strdup(mem, orphan_vgname))) {
 		log_error("vg name allocation failed");
-		return NULL;
+		goto bad;
 	}
 
 	/* create format instance with appropriate metadata area */
@@ -1667,17 +1677,16 @@
 							  orphan_vgname, NULL,
 							  NULL))) {
 		log_error("Failed to create format instance");
-		dm_pool_free(cmd->mem, vg);
-		return NULL;
+		goto bad;
 	}
 
 	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!(pv = _pv_read(cmd, dev_name(info->dev), NULL, NULL, 1, 0))) {
 			continue;
 		}
-		if (!(pvl = dm_pool_zalloc(cmd->mem, sizeof(*pvl)))) {
+		if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
 			log_error("pv_list allocation failed");
-			return NULL;
+			goto bad;
 		}
 		pvl->pv = pv;
 		dm_list_add(&vg->pvs, &pvl->list);
@@ -1685,6 +1694,9 @@
 	}
 
 	return vg;
+bad:
+	dm_pool_destroy(mem);
+	return NULL;
 }
 
 static int _update_pv_list(struct dm_pool *pvmem, struct dm_list *all_pvs, struct volume_group *vg)
@@ -2040,6 +2052,18 @@
 	return vg;
 }
 
+void vg_release(struct volume_group *vg)
+{
+	if (!vg || !vg->vgmem)
+		return;
+
+	if (vg->vgmem == vg->cmd->mem)
+		log_error("Internal error: global memory pool used for VG %s",
+			  vg->name);
+
+	dm_pool_destroy(vg->vgmem);
+}
+
 /* This is only called by lv_from_lvid, which is only called from
  * activate.c so we know the appropriate VG lock is already held and
  * the vg_read_internal is therefore safe.
--- LVM2/lib/metadata/metadata.h	2009/02/25 23:29:06	1.190
+++ LVM2/lib/metadata/metadata.h	2009/04/10 09:59:19	1.191
@@ -35,6 +35,7 @@
 //#define PV_MIN_SIZE ( 512L * 1024L >> SECTOR_SHIFT)	/* 512 KB in sectors */
 //#define MAX_RESTRICTED_LVS 255	/* Used by FMT_RESTRICTED_LVIDS */
 #define MIRROR_LOG_OFFSET	2	/* sectors */
+#define VG_MEMPOOL_CHUNK	10240	/* in bytes, hint only */
 
 /*
  * Ceiling(n / sz)



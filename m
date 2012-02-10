From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Feb 2012 02:53:06 -0000
Subject: LVM2/lib cache/lvmcache.c format1/format1.c fo ...
Message-ID: <20120210025306.11815.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-10 02:53:05

Modified files:
	lib/cache      : lvmcache.c 
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata-exported.h metadata.c vg.c 

Log message:
	Keep a global (per-format) orphan_vg and keep any and all orphan PVs linked to
	it. Avoids the need for FMT_INSTANCE_PV and enables further simplifications. No
	functional change, internal refactor only.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.188&r2=1.189
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.227&r2=1.228
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.477&r2=1.478
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/lib/cache/lvmcache.c	2012/02/10 01:28:27	1.123
+++ LVM2/lib/cache/lvmcache.c	2012/02/10 02:53:03	1.124
@@ -1322,8 +1322,6 @@
 				  const char *vgname, const char *vgid,
 				  uint32_t vgstatus, const char *creation_host)
 {
-        log_error("lvmcache_update_vgname_and_id: %s -> %s", dev_name(info->dev), vgname);
-
 	if (!vgname && !info->vginfo) {
 		log_error(INTERNAL_ERROR "NULL vgname handed to cache");
 		/* FIXME Remove this */
--- LVM2/lib/format1/format1.c	2012/02/10 01:28:28	1.141
+++ LVM2/lib/format1/format1.c	2012/02/10 02:53:04	1.142
@@ -546,6 +546,13 @@
 
 static void _format1_destroy(struct format_type *fmt)
 {
+	/* FIXME out of place, but the main (cmd) pool has been already
+	 * destroyed and touching the fid (also via release_vg) will crash the
+	 * program */
+	dm_hash_destroy(fmt->orphan_vg->hostnames);
+	dm_pool_destroy(fmt->orphan_vg->fid->mem);
+	dm_pool_destroy(fmt->orphan_vg->vgmem);
+
 	dm_free(fmt);
 }
 
@@ -570,6 +577,8 @@
 #endif
 {
 	struct format_type *fmt = dm_malloc(sizeof(*fmt));
+	struct format_instance_ctx fic;
+	struct format_instance *fid;
 
 	if (!fmt)
 		return_NULL;
@@ -596,6 +605,19 @@
 		return NULL;
 	}
 
+	if (!(fmt->orphan_vg = alloc_vg("text_orphan", cmd, fmt->orphan_vg_name))) {
+		log_error("Couldn't create lvm1 orphan VG.");
+		return NULL;
+	}
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = fmt->orphan_vg_name;
+	fic.context.vg_ref.vg_id = NULL;
+	if (!(fid = _format1_create_instance(fmt, &fic))) {
+		log_error("Couldn't create lvm1 orphan VG format instance.");
+		return NULL;
+	}
+	vg_set_fid(fmt->orphan_vg, fid);
+
 	log_very_verbose("Initialised format: %s", fmt->name);
 
 	return fmt;
--- LVM2/lib/format_pool/format_pool.c	2012/02/08 10:49:36	1.46
+++ LVM2/lib/format_pool/format_pool.c	2012/02/10 02:53:04	1.47
@@ -259,6 +259,13 @@
 
 static void _pool_destroy(struct format_type *fmt)
 {
+	/* FIXME out of place, but the main (cmd) pool has been already
+	 * destroyed and touching the fid (also via release_vg) will crash the
+	 * program */
+	dm_hash_destroy(fmt->orphan_vg->hostnames);
+	dm_pool_destroy(fmt->orphan_vg->fid->mem);
+	dm_pool_destroy(fmt->orphan_vg->vgmem);
+
 	dm_free(fmt);
 }
 
@@ -281,6 +288,8 @@
 #endif
 {
 	struct format_type *fmt = dm_malloc(sizeof(*fmt));
+	struct format_instance_ctx fic;
+	struct format_instance *fid;
 
 	if (!fmt) {
 		log_error("Unable to allocate format type structure for pool "
@@ -309,6 +318,19 @@
 		return NULL;
 	}
 
+	if (!(fmt->orphan_vg = alloc_vg("text_orphan", cmd, fmt->orphan_vg_name))) {
+		log_error("Couldn't create lvm1 orphan VG.");
+		return NULL;
+	}
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = fmt->orphan_vg_name;
+	fic.context.vg_ref.vg_id = NULL;
+	if (!(fid = _pool_create_instance(fmt, &fic))) {
+		log_error("Couldn't create lvm1 orphan VG format instance.");
+		return NULL;
+	}
+	vg_set_fid(fmt->orphan_vg, fid);
+
 	log_very_verbose("Initialised format: %s", fmt->name);
 
 	return fmt;
--- LVM2/lib/format_text/format-text.c	2012/02/10 01:28:28	1.188
+++ LVM2/lib/format_text/format-text.c	2012/02/10 02:53:05	1.189
@@ -1513,8 +1513,8 @@
 static void _text_destroy_instance(struct format_instance *fid)
 {
 	if (--fid->ref_count <= 1) {
-		if (fid->type & FMT_INSTANCE_VG && fid->metadata_areas_index.hash)
-			dm_hash_destroy(fid->metadata_areas_index.hash);
+		if (fid->type & FMT_INSTANCE_VG && fid->metadata_areas_index)
+			dm_hash_destroy(fid->metadata_areas_index);
 		dm_pool_destroy(fid->mem);
 	}
 }
@@ -1541,6 +1541,14 @@
 
 static void _text_destroy(struct format_type *fmt)
 {
+	/* FIXME out of place, but the main (cmd) pool has been already
+	 * destroyed and touching the fid (also via release_vg) will crash the
+	 * program */
+	dm_hash_destroy(fmt->orphan_vg->fid->metadata_areas_index);
+	dm_hash_destroy(fmt->orphan_vg->hostnames);
+	dm_pool_destroy(fmt->orphan_vg->fid->mem);
+	dm_pool_destroy(fmt->orphan_vg->vgmem);
+
 	if (fmt->private) {
 		_free_dirs(&((struct mda_lists *) fmt->private)->dirs);
 		_free_raws(&((struct mda_lists *) fmt->private)->raws);
@@ -1666,22 +1674,7 @@
 static int _create_pv_text_instance(struct format_instance *fid,
                                     const struct format_instance_ctx *fic)
 {
-	struct lvmcache_info *info;
-
-	fid->private = NULL;
-
-	if (!(fid->metadata_areas_index.array = dm_pool_zalloc(fid->mem,
-					FMT_TEXT_MAX_MDAS_PER_PV *
-					sizeof(struct metadata_area *)))) {
-		log_error("Couldn't allocate format instance metadata index.");
-		return 0;
-	}
-
-	if (fic->type & FMT_INSTANCE_MDAS &&
-	    (info = lvmcache_info_from_pvid(fic->context.pv_id, 0)))
-		lvmcache_fid_add_mdas_pv(info, fid);
-
-	return 1;
+	return 0; /* just fail */
 }
 
 static void *_create_text_context(struct dm_pool *mem, struct text_context *tc)
@@ -1760,13 +1753,13 @@
 		mda->ops = &_metadata_text_file_backup_ops;
 		mda->metadata_locn = _create_text_context(fid->mem, fic->context.private);
 		mda->status = 0;
-		fid->metadata_areas_index.hash = NULL;
+		fid->metadata_areas_index = NULL;
 		fid_add_mda(fid, mda, NULL, 0, 0);
 	} else {
 		vg_name = fic->context.vg_ref.vg_name;
 		vg_id = fic->context.vg_ref.vg_id;
 
-		if (!(fid->metadata_areas_index.hash = dm_hash_create(128))) {
+		if (!(fid->metadata_areas_index = dm_hash_create(128))) {
 			log_error("Couldn't create metadata index for format "
 				  "instance of VG %s.", vg_name);
 			return 0;
@@ -1872,6 +1865,10 @@
 	return 1;
 }
 
+static int _text_pv_remove_metadata_area(const struct format_type *fmt,
+					 struct physical_volume *pv,
+					 unsigned mda_index);
+
 static int _text_pv_add_metadata_area(const struct format_type *fmt,
 				      struct physical_volume *pv,
 				      int pe_start_locked,
@@ -1908,9 +1905,12 @@
 	mda_size = mda_size << SECTOR_SHIFT;
 
 	if (fid_get_mda_indexed(fid, pvid, ID_LEN, mda_index)) {
-		log_error(INTERNAL_ERROR "metadata area with index %u already "
-			"exists on PV %s.", mda_index, pv_dev_name(pv));
-		return 0;
+		if (!_text_pv_remove_metadata_area(fmt, pv, mda_index)) {
+			log_error(INTERNAL_ERROR "metadata area with index %u already "
+				  "exists on PV %s and removal failed.",
+				  mda_index, pv_dev_name(pv));
+			return 0;
+		}
 	}
 
 	/* First metadata area@the start of the device. */
@@ -2270,6 +2270,8 @@
 
 struct format_type *create_text_format(struct cmd_context *cmd)
 {
+	struct format_instance_ctx fic;
+	struct format_instance *fid;
 	struct format_type *fmt;
 	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
@@ -2335,6 +2337,21 @@
 		}
 	}
 
+	if (!(fmt->orphan_vg = alloc_vg("text_orphan", cmd, fmt->orphan_vg_name))) {
+		dm_free(fmt);
+		return NULL;
+	}
+
+	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
+	fic.context.vg_ref.vg_name = fmt->orphan_vg_name;
+	fic.context.vg_ref.vg_id = NULL;
+	if (!(fid = _text_create_text_instance(fmt, &fic))) {
+		log_error("Failed to create format instance");
+		release_vg(fmt->orphan_vg);
+		goto err;
+	}
+	vg_set_fid(fmt->orphan_vg, fid);
+
 	log_very_verbose("Initialised format: %s", fmt->name);
 
 	return fmt;
--- LVM2/lib/metadata/metadata-exported.h	2012/01/24 00:55:04	1.227
+++ LVM2/lib/metadata/metadata-exported.h	2012/02/10 02:53:05	1.228
@@ -178,6 +178,7 @@
 	const char *name;
 	const char *alias;
 	const char *orphan_vg_name;
+	struct volume_group *orphan_vg; /* Only one ever exists. */
 	uint32_t features;
 	void *library;
 	void *private;
@@ -237,10 +238,7 @@
 	/* FIXME: Try to use the index only. Remove these lists. */
 	struct dm_list metadata_areas_in_use;
 	struct dm_list metadata_areas_ignored;
-	union {
-		struct metadata_area **array;
-		struct dm_hash_table *hash;
-	} metadata_areas_index;
+	struct dm_hash_table *metadata_areas_index;
 
 	void *private;
 };
--- LVM2/lib/metadata/metadata.c	2012/02/10 01:28:28	1.477
+++ LVM2/lib/metadata/metadata.c	2012/02/10 02:53:05	1.478
@@ -170,22 +170,18 @@
 
 void del_pvl_from_vgs(struct volume_group *vg, struct pv_list *pvl)
 {
-	struct format_instance_ctx fic;
-	struct format_instance *fid;
+	struct lvmcache_info *info;
 
 	vg->pv_count--;
 	dm_list_del(&pvl->list);
-	pvl->pv->vg = NULL; /* orphan */
-
-	/* Use a new PV-based format instance since the PV is orphan now. */
-	fic.type = FMT_INSTANCE_PV | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
-	fic.context.pv_id = (const char *) &pvl->pv->id;
-	fid = pvl->pv->fid->fmt->ops->create_instance(pvl->pv->fid->fmt, &fic);
 
-	pv_set_fid(pvl->pv, fid);
+	pvl->pv->vg = vg->fid->fmt->orphan_vg; /* orphan */
+	if ((info = lvmcache_info_from_pvid((const char *) &pvl->pv->id, 0)))
+		lvmcache_fid_add_mdas(info, vg->fid->fmt->orphan_vg->fid,
+				      (const char *) &pvl->pv->id, ID_LEN);
+	pv_set_fid(pvl->pv, vg->fid->fmt->orphan_vg->fid);
 }
 
-
 /**
  * add_pv_to_vg - Add a physical volume to a volume group
  * @vg - volume group to add to
@@ -1663,13 +1659,16 @@
 		goto bad;
 	}
 
-	fic.type = FMT_INSTANCE_PV;
-	fic.context.pv_id = (const char *) &pv->id;
-	if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
-		log_error("Couldn't create format instance for PV %s.", pv_dev_name(pv));
+	struct pv_list *pvl;
+	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl)))) {
+		log_error("pv_list allocation in pv_create failed");
 		goto bad;
 	}
-	pv_set_fid(pv, fid);
+
+	pvl->pv = pv;
+	add_pvl_to_vgs(fmt->orphan_vg, pvl);
+	fmt->orphan_vg->extent_count += pv->pe_count;
+	fmt->orphan_vg->free_count += pv->pe_count;
 
 	pv->fmt = fmt;
 	pv->vg_name = fmt->orphan_vg_name;
@@ -2762,18 +2761,7 @@
 	if (!(fmt = lvmcache_fmt_from_vgname(orphan_vgname, NULL, 0)))
 		return_NULL;
 
-	if (!(vg = alloc_vg("vg_read_orphans", cmd, orphan_vgname)))
-		return_NULL;
-
-	/* create format instance with appropriate metadata area */
-	fic.type = FMT_INSTANCE_VG | FMT_INSTANCE_AUX_MDAS;
-	fic.context.vg_ref.vg_name = orphan_vgname;
-	fic.context.vg_ref.vg_id = NULL;
-	if (!(fid = fmt->ops->create_instance(fmt, &fic))) {
-		log_error("Failed to create format instance");
-		goto bad;
-	}
-	vg_set_fid(vg, fid);
+	vg = fmt->orphan_vg;
 
 	baton.warnings = warnings;
 	baton.vg = vg;
@@ -2781,7 +2769,6 @@
 
 	return vg;
 bad:
-	release_vg(vg);
 	return NULL;
 }
 
@@ -3574,6 +3561,7 @@
 	struct label *label;
 	struct lvmcache_info *info;
 	struct device *dev;
+	const struct format_type *fmt;
 
 	if (!(dev = dev_cache_get(pv_name, cmd->filter)))
 		return_NULL;
@@ -3586,6 +3574,7 @@
 	}
 
 	info = (struct lvmcache_info *) label->info;
+	fmt = lvmcache_fmt(info);
 
 	pv = _alloc_pv(pvmem, dev);
 	if (!pv) {
@@ -3611,14 +3600,8 @@
 	if (fid)
 		lvmcache_fid_add_mdas(info, fid, (const char *) &pv->id, ID_LEN);
 	else {
-		fic.type = FMT_INSTANCE_PV | FMT_INSTANCE_MDAS | FMT_INSTANCE_AUX_MDAS;
-		fic.context.pv_id = (const char *) &pv->id;
-		if (!(fid = pv->fmt->ops->create_instance(pv->fmt, &fic))) {
-			log_error("_pv_read: Couldn't create format instance "
-				  "for PV %s", pv_name);
-			goto bad;
-		}
-		pv_set_fid(pv, fid);
+		lvmcache_fid_add_mdas(info, fmt->orphan_vg->fid, (const char *) &pv->id, ID_LEN);
+		pv_set_fid(pv, fmt->orphan_vg->fid);
 	}
 
 	return pv;
@@ -4236,11 +4219,9 @@
 					    full_key, sizeof(full_key)))
 		return_0;
 
-		dm_hash_insert(fid->metadata_areas_index.hash,
+		dm_hash_insert(fid->metadata_areas_index,
 			       full_key, mda);
 	}
-	else
-		fid->metadata_areas_index.array[sub_key] = mda;
 
 	return 1;
 }
@@ -4275,11 +4256,9 @@
 		if (!_convert_key_to_string(key, key_len, sub_key,
 					    full_key, sizeof(full_key)))
 			return_NULL;
-		mda = (struct metadata_area *) dm_hash_lookup(fid->metadata_areas_index.hash,
+		mda = (struct metadata_area *) dm_hash_lookup(fid->metadata_areas_index,
 							      full_key);
 	}
-	else
-		mda = fid->metadata_areas_index.array[sub_key];
 
 	return mda;
 }
@@ -4311,9 +4290,8 @@
 					    full_key, sizeof(full_key)))
 				return_0;
 
-			dm_hash_remove(fid->metadata_areas_index.hash, full_key);
-		} else
-			fid->metadata_areas_index.array[sub_key] = NULL;
+			dm_hash_remove(fid->metadata_areas_index, full_key);
+		}
 	}
 
 	dm_list_del(&mda->list);
--- LVM2/lib/metadata/vg.c	2012/02/10 01:28:28	1.15
+++ LVM2/lib/metadata/vg.c	2012/02/10 02:53:05	1.16
@@ -79,7 +79,7 @@
 
 void release_vg(struct volume_group *vg)
 {
-	if (!vg)
+	if (!vg || (vg->fid && vg == vg->fid->fmt->orphan_vg))
 		return;
 
 	/* Check if there are any vginfo holders */



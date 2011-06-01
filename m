From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Jun 2011 19:29:44 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/cach ...
Message-ID: <20110601192944.28004.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-01 19:29:34

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c lvmcache.h 
	lib/format1    : format1.c import-export.c 
	lib/format_text: format-text.c import_vsn1.c 
	lib/metadata   : metadata.c metadata.h pv.h vg.c vg.h 
	tools          : pvcreate.c pvremove.c pvresize.c toollib.c 

Log message:
	Defer writing PV labels to vg_write.
	Store label_sector only in struct physical_volume.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2003&r2=1.2004
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.110&r2=1.111
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.h.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.180&r2=1.181
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.456&r2=1.457
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.243&r2=1.244
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.94&r2=1.95
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.226&r2=1.227

--- LVM2/WHATS_NEW	2011/06/01 19:21:04	1.2003
+++ LVM2/WHATS_NEW	2011/06/01 19:29:31	1.2004
@@ -1,5 +1,7 @@
 Version 2.02.86 -  
 =================================
+  Defer writing PV labels to vg_write.
+  Store label_sector only in struct physical_volume.
   Permit --available with lvcreate so non-snapshot LVs need not be activated.
   Report sector containing label in verbose message.
   Clarify error message when unable to convert an LV into a snapshot of an LV.
--- LVM2/lib/cache/lvmcache.c	2011/04/21 13:15:26	1.110
+++ LVM2/lib/cache/lvmcache.c	2011/06/01 19:29:32	1.111
@@ -539,7 +539,7 @@
 	struct lvmcache_info *info;
 	char *vgname;
 
-	if (!device_from_pvid(cmd, (const struct id *)pvid, NULL)) {
+	if (!device_from_pvid(cmd, (const struct id *)pvid, NULL, NULL)) {
 		log_error("Couldn't find device with uuid %s.", pvid);
 		return NULL;
 	}
@@ -769,31 +769,41 @@
 	return pvids;
 }
 
-struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
-				unsigned *scan_done_once)
+static struct device *_device_from_pvid(const struct id *pvid,
+					uint64_t *label_sector)
 {
-	struct label *label;
 	struct lvmcache_info *info;
+	struct label *label;
 
-	/* Already cached ? */
 	if ((info = info_from_pvid((const char *) pvid, 0))) {
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
-			if (id_equal(pvid, (struct id *) &info->dev->pvid))
+			if (id_equal(pvid, (struct id *) &info->dev->pvid)) {
+				if (label_sector)
+					*label_sector = label->sector;
 				return info->dev;
+                        }
 		}
 	}
+	return NULL;
+}
+
+struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
+				unsigned *scan_done_once, uint64_t *label_sector)
+{
+	struct device *dev;
+
+	/* Already cached ? */
+	dev = _device_from_pvid(pvid, label_sector);
+	if (dev)
+		return dev;
 
 	lvmcache_label_scan(cmd, 0);
 
 	/* Try again */
-	if ((info = info_from_pvid((const char *) pvid, 0))) {
-		if (label_read(info->dev, &label, UINT64_C(0))) {
-			info = (struct lvmcache_info *) label->info;
-			if (id_equal(pvid, (struct id *) &info->dev->pvid))
-				return info->dev;
-		}
-	}
+	dev = _device_from_pvid(pvid, label_sector);
+	if (dev)
+		return dev;
 
 	if (critical_section() || (scan_done_once && *scan_done_once))
 		return NULL;
@@ -803,13 +813,9 @@
 		*scan_done_once = 1;
 
 	/* Try again */
-	if ((info = info_from_pvid((const char *) pvid, 0))) {
-		if (label_read(info->dev, &label, UINT64_C(0))) {
-			info = (struct lvmcache_info *) label->info;
-			if (id_equal(pvid, (struct id *) &info->dev->pvid))
-				return info->dev;
-		}
-	}
+	dev = _device_from_pvid(pvid, label_sector);
+	if (dev)
+		return dev;
 
 	return NULL;
 }
--- LVM2/lib/cache/lvmcache.h	2011/03/30 13:14:34	1.38
+++ LVM2/lib/cache/lvmcache.h	2011/06/01 19:29:32	1.39
@@ -99,7 +99,7 @@
 struct lvmcache_info *info_from_pvid(const char *pvid, int valid_only);
 const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
 struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
-				unsigned *scan_done_once);
+				unsigned *scan_done_once, uint64_t *label_sector);
 const char *pvid_from_devname(struct cmd_context *cmd,
 			      const char *dev_name);
 char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid);
--- LVM2/lib/format1/format1.c	2011/03/11 15:10:16	1.138
+++ LVM2/lib/format1/format1.c	2011/06/01 19:29:32	1.139
@@ -406,6 +406,8 @@
 	struct disk_list *dl;
 	struct dm_list pvs;
 	struct lvmcache_info *info;
+	int pe_count, pe_size, pe_start;
+	int r = 1;
 
 	if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
 				  pv->vg_name, NULL, 0)))
@@ -418,6 +420,10 @@
 
 	dm_list_init(&pvs);
 
+	pe_count = pv->pe_count;
+	pe_size = pv->pe_size;
+	pe_start = pv->pe_start;
+
 	/* Ensure any residual PE structure is gone */
 	pv->pe_size = pv->pe_count = 0;
 	pv->pe_start = LVM1_PE_ALIGN;
@@ -430,6 +436,8 @@
 
 	dl->mem = mem;
 	dl->dev = pv->dev;
+	dm_list_init(&dl->uuids);
+	dm_list_init(&dl->lvds);
 
 	if (!export_pv(fmt->cmd, mem, NULL, &dl->pvd, pv))
 		goto_bad;
@@ -444,12 +452,18 @@
 	if (!write_disks(fmt, &pvs))
 		goto_bad;
 
-	dm_pool_destroy(mem);
-	return 1;
+	goto out;
 
       bad:
+	r = 0;
+
+      out:
+	pv->pe_size = pe_size;
+	pv->pe_count = pe_count;
+	pv->pe_start = pe_start;
+
 	dm_pool_destroy(mem);
-	return 0;
+	return r;
 }
 
 static int _format1_vg_setup(struct format_instance *fid, struct volume_group *vg)
--- LVM2/lib/format1/import-export.c	2011/03/13 23:05:48	1.117
+++ LVM2/lib/format1/import-export.c	2011/06/01 19:29:32	1.118
@@ -96,6 +96,8 @@
 	pv->pe_count = pvd->pe_total;
 	pv->pe_alloc_count = 0;
 	pv->pe_align = 0;
+        pv->is_labelled = 0; /* format1 PVs have no label */
+        pv->label_sector = 0;
 
 	/* Fix up pv size if missing or impossibly large */
 	if (!pv->size || pv->size > (1ULL << 62)) {
@@ -149,7 +151,7 @@
 
 	memcpy(pvd->pv_uuid, pv->id.uuid, ID_LEN);
 
-	if (pv->vg_name && !is_orphan(pv)) {
+	if (pv->vg_name && !is_orphan(pv) && !(pv->status & UNLABELLED_PV)) {
 		if (!_check_vg_name(pv->vg_name))
 			return_0;
 		strncpy((char *)pvd->vg_name, pv->vg_name, sizeof(pvd->vg_name));
--- LVM2/lib/format_text/format-text.c	2011/05/28 09:48:15	1.180
+++ LVM2/lib/format_text/format-text.c	2011/06/01 19:29:33	1.181
@@ -45,10 +45,6 @@
 	uint32_t raw_metadata_buf_size;
 };
 
-struct text_fid_pv_context {
-	int64_t label_sector;
-};
-
 struct dir_list {
 	struct dm_list list;
 	char dir[0];
@@ -1252,11 +1248,9 @@
 /* Only for orphans */
 static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv)
 {
-	struct text_fid_pv_context *fid_pv_tc;
 	struct format_instance *fid = pv->fid;
 	const char *pvid = (const char *) (*pv->old_id.uuid ? &pv->old_id : &pv->id);
 	struct label *label;
-	int64_t label_sector;
 	struct lvmcache_info *info;
 	struct mda_context *mdac;
 	struct metadata_area *mda;
@@ -1271,15 +1265,7 @@
 		return_0;
 
 	label = info->label;
-
-	/*
-	 * We can change the label sector for a
-	 * plain PV that is not part of a VG only!
-	 */
-	if (fid && (!fid->type & FMT_INSTANCE_VG) &&
-	    (fid_pv_tc = (struct text_fid_pv_context *) pv->fid->private) &&
-	    ((label_sector = fid_pv_tc->label_sector) != -1))
-		label->sector = label_sector;
+	label->sector = pv->label_sector;
 
 	info->device_size = pv->size << SECTOR_SHIFT;
 	info->fmt = fmt;
@@ -1517,8 +1503,6 @@
 			       unsigned long data_alignment_offset,
 			       struct physical_volume *pv)
 {
-	struct text_fid_pv_context *fid_pv_tc;
-
 	/*
 	 * Try to keep the value of PE start set to a firm value if requested.
 	 * This is usefull when restoring existing PE start value (backups etc.).
@@ -1569,10 +1553,8 @@
 		return 0;
 	}
 
-	if (label_sector != -1) {
-		fid_pv_tc = (struct text_fid_pv_context *) pv->fid->private;
-		fid_pv_tc->label_sector = label_sector;
-	}
+	if (label_sector != -1)
+                pv->label_sector = label_sector;
 
 	return 1;
 }
@@ -1735,16 +1717,9 @@
 static int _create_pv_text_instance(struct format_instance *fid,
                                     const struct format_instance_ctx *fic)
 {
-	struct text_fid_pv_context *fid_pv_tc;
 	struct lvmcache_info *info;
 
-	if (!(fid_pv_tc = (struct text_fid_pv_context *)
-			dm_pool_zalloc(fid->mem, sizeof(*fid_pv_tc)))) {
-		log_error("Couldn't allocate text_fid_pv_context.");
-		return 0;
-	}
-	fid_pv_tc->label_sector = -1;
-	fid->private = (void *) fid_pv_tc;
+	fid->private = NULL;
 
 	if (!(fid->metadata_areas_index.array = dm_pool_zalloc(fid->mem,
 					FMT_TEXT_MAX_MDAS_PER_PV *
@@ -2332,7 +2307,7 @@
 		return 0;
 	}
 
-	if (!(dev_area.dev = device_from_pvid(cmd, &id, NULL))) {
+	if (!(dev_area.dev = device_from_pvid(cmd, &id, NULL, NULL))) {
 		char buffer[64] __attribute__((aligned(8)));
 
 		if (!id_write_format(&id, buffer, sizeof(buffer)))
--- LVM2/lib/format_text/import_vsn1.c	2011/04/29 19:06:17	1.87
+++ LVM2/lib/format_text/import_vsn1.c	2011/06/01 19:29:33	1.88
@@ -190,10 +190,13 @@
 		return 0;
 	}
 
+        pv->is_labelled = 1; /* All format_text PVs are labelled. */
+
 	/*
 	 * Convert the uuid into a device.
 	 */
-	if (!(pv->dev = device_from_pvid(fid->fmt->cmd, &pv->id, scan_done_once))) {
+	if (!(pv->dev = device_from_pvid(fid->fmt->cmd, &pv->id, scan_done_once,
+                                         &pv->label_sector))) {
 		char buffer[64] __attribute__((aligned(8)));
 
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
--- LVM2/lib/metadata/metadata.c	2011/05/07 13:32:05	1.456
+++ LVM2/lib/metadata/metadata.c	2011/06/01 19:29:33	1.457
@@ -38,7 +38,6 @@
 					struct dm_pool *pvmem,
 					const char *pv_name,
 					struct format_instance *fid,
-					uint64_t *label_sector,
 					int warnings, int scan_label_only);
 
 static struct physical_volume *_find_pv_by_name(struct cmd_context *cmd,
@@ -192,6 +191,7 @@
  * @vg - volume group to add to
  * @pv_name - name of the pv (to be removed)
  * @pv - physical volume to add to volume group
+ * @pp - physical volume creation params (OPTIONAL)
  *
  * Returns:
  *  0 - failure
@@ -199,8 +199,9 @@
  * FIXME: remove pv_name - obtain safely from pv
  */
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
-		 struct physical_volume *pv)
+		 struct physical_volume *pv, struct pvcreate_params *pp)
 {
+	struct pv_to_create *pvc;
 	struct pv_list *pvl;
 	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = vg->vgmem;
@@ -289,6 +290,16 @@
 	vg->extent_count += pv->pe_count;
 	vg->free_count += pv->pe_count;
 
+	if (pv->status & UNLABELLED_PV) {
+		if (!(pvc = dm_pool_zalloc(mem, sizeof(*pvc)))) {
+			log_error("pv_to_create allocation for '%s' failed", pv_name);
+			return 0;
+		}
+		pvc->pv = pv;
+		pvc->pp = pp;
+		dm_list_add(&vg->pvs_to_create, &pvc->list);
+	}
+
 	return 1;
 }
 
@@ -640,11 +651,11 @@
 			  "physical volume", pv_name);
 		return 0;
 	} else if (!pv && pp) {
-		pv = pvcreate_single(vg->cmd, pv_name, pp);
+		pv = pvcreate_single(vg->cmd, pv_name, pp, 0);
 		if (!pv)
 			return 0;
 	}
-	if (!add_pv_to_vg(vg, pv_name, pv)) {
+	if (!add_pv_to_vg(vg, pv_name, pv, pp)) {
 		free_pv_fid(pv);
 		return 0;
 	}
@@ -1318,7 +1329,7 @@
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
-	pv = pv_read(cmd, name, NULL, 0, 0);
+	pv = pv_read(cmd, name, 0, 0);
 
 	/*
 	 * If a PV has no MDAs it may appear to be an orphan until the
@@ -1330,7 +1341,7 @@
 		free_pv_fid(pv);
 		if (!scan_vgs_for_pvs(cmd, 0))
 			return_0;
-		pv = pv_read(cmd, name, NULL, 0, 0);
+		pv = pv_read(cmd, name, 0, 0);
 	}
 
 	/* Allow partial & exported VGs to be destroyed. */
@@ -1425,6 +1436,47 @@
 	pp->metadataignore = DEFAULT_PVMETADATAIGNORE;
 }
 
+
+static int _pvcreate_write(struct cmd_context *cmd, struct pv_to_create *pvc)
+{
+	int zero = pvc->pp->zero;
+	struct physical_volume *pv = pvc->pv;
+	struct device *dev = pv->dev;
+	const char *pv_name = dev_name(dev);
+
+	/* Wipe existing label first */
+	if (!label_remove(pv_dev(pv))) {
+		log_error("Failed to wipe existing label on %s", pv_name);
+		return 0;
+	}
+
+	if (zero) {
+		log_verbose("Zeroing start of device %s", pv_name);
+		if (!dev_open_quiet(dev)) {
+			log_error("%s not opened: device not zeroed", pv_name);
+			return 0;
+		}
+
+		if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
+			log_error("%s not wiped: aborting", pv_name);
+			dev_close(dev);
+			return 0;
+		}
+		dev_close(dev);
+	}
+
+	log_error("Writing physical volume data to disk \"%s\"",
+			 pv_name);
+
+	if (!(pv_write(cmd, pv, 1))) {
+		log_error("Failed to write physical volume \"%s\"", pv_name);
+		return 0;
+	}
+
+	log_print("Physical volume \"%s\" successfully created", pv_name);
+	return 1;
+}
+
 /*
  * pvcreate_single() - initialize a device with PV label and metadata area
  *
@@ -1438,7 +1490,8 @@
  */
 struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 					 const char *pv_name,
-					 struct pvcreate_params *pp)
+					 struct pvcreate_params *pp,
+					 int write_now)
 {
 	struct physical_volume *pv = NULL;
 	struct device *dev;
@@ -1451,7 +1504,7 @@
 		pp = &default_pp;
 
 	if (pp->idp) {
-		if ((dev = device_from_pvid(cmd, pp->idp, NULL)) &&
+		if ((dev = device_from_pvid(cmd, pp->idp, NULL, NULL)) &&
 		    (dev != dev_cache_get(pv_name, cmd->filter))) {
 			if (!id_write_format((const struct id*)&pp->idp->uuid,
 			    buffer, sizeof(buffer)))
@@ -1475,6 +1528,7 @@
 	}
 
 	dm_list_init(&mdas);
+
 	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
 			     pp->data_alignment, pp->data_alignment_offset,
 			     pp->pe_start ? pp->pe_start : PV_PE_START_CALC,
@@ -1488,37 +1542,16 @@
 	log_verbose("Set up physical volume for \"%s\" with %" PRIu64
 		    " available sectors", pv_name, pv_size(pv));
 
-	/* Wipe existing label first */
-	if (!label_remove(pv_dev(pv))) {
-		log_error("Failed to wipe existing label on %s", pv_name);
-		goto bad;
-	}
-
-	if (pp->zero) {
-		log_verbose("Zeroing start of device %s", pv_name);
-		if (!dev_open_quiet(dev)) {
-			log_error("%s not opened: device not zeroed", pv_name);
-			goto bad;
-		}
-
-		if (!dev_set(dev, UINT64_C(0), (size_t) 2048, 0)) {
-			log_error("%s not wiped: aborting", pv_name);
-			dev_close(dev);
+	if (write_now) {
+		struct pv_to_create pvc;
+		pvc.pp = pp;
+		pvc.pv = pv;
+		if (!_pvcreate_write(cmd, &pvc))
 			goto bad;
-		}
-		dev_close(dev);
-	}
-
-	log_very_verbose("Writing physical volume data to disk \"%s\"",
-			 pv_name);
-
-	if (!(pv_write(cmd, pv, 0))) {
-		log_error("Failed to write physical volume \"%s\"", pv_name);
-		goto bad;
+	} else {
+		pv->status |= UNLABELLED_PV;
 	}
 
-	log_print("Physical volume \"%s\" successfully created", pv_name);
-
 	return pv;
 
 bad:
@@ -1815,7 +1848,7 @@
 {
 	struct physical_volume *pv;
 
-	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
+	if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, 1, 0))) {
 		log_error("Physical volume %s not found", pv_name);
 		goto bad;
 	}
@@ -1825,7 +1858,7 @@
 		if (!scan_vgs_for_pvs(cmd, 1))
 			goto_bad;
 		free_pv_fid(pv);
-		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0))) {
+		if (!(pv = _pv_read(cmd, cmd->mem, pv_name, NULL, 1, 0))) {
 			log_error("Physical volume %s not found", pv_name);
 			goto bad;
 		}
@@ -2470,6 +2503,7 @@
 int vg_write(struct volume_group *vg)
 {
 	struct dm_list *mdah;
+        struct pv_to_create *pv_to_create;
 	struct metadata_area *mda;
 
 	if (!vg_validate(vg))
@@ -2507,6 +2541,12 @@
 
 	vg->seqno++;
 
+        dm_list_iterate_items(pv_to_create, &vg->pvs_to_create) {
+		if (!_pvcreate_write(vg->cmd, pv_to_create))
+			return 0;
+		pv_to_create->pv->status &= ~UNLABELLED_PV;
+        }
+
 	/* Write to each copy of the metadata area */
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (!mda->ops->vg_write) {
@@ -2676,7 +2716,7 @@
 
 	dm_list_iterate_items(info, &vginfo->infos) {
 		if (!(pv = _pv_read(cmd, vg->vgmem, dev_name(info->dev),
-				    vg->fid, NULL, warnings, 0))) {
+				    vg->fid, warnings, 0))) {
 			continue;
 		}
 		if (!(pvl = dm_pool_zalloc(vg->vgmem, sizeof(*pvl)))) {
@@ -3429,10 +3469,10 @@
  *   FIXME - liblvm todo - make into function that returns handle
  */
 struct physical_volume *pv_read(struct cmd_context *cmd, const char *pv_name,
-				uint64_t *label_sector, int warnings,
+				int warnings,
 				int scan_label_only)
 {
-	return _pv_read(cmd, cmd->mem, pv_name, NULL, label_sector, warnings, scan_label_only);
+	return _pv_read(cmd, cmd->mem, pv_name, NULL, warnings, scan_label_only);
 }
 
 /* FIXME Use label functions instead of PV functions */
@@ -3440,7 +3480,6 @@
 					struct dm_pool *pvmem,
 					const char *pv_name,
 					struct format_instance *fid,
-					uint64_t *label_sector,
 					int warnings, int scan_label_only)
 {
 	struct physical_volume *pv;
@@ -3460,8 +3499,6 @@
 	}
 
 	info = (struct lvmcache_info *) label->info;
-	if (label_sector && *label_sector)
-		*label_sector = label->sector;
 
 	pv = _alloc_pv(pvmem, dev);
 	if (!pv) {
@@ -3469,6 +3506,8 @@
 		return NULL;
 	}
 
+	pv->label_sector = label->sector;
+
 	/* FIXME Move more common code up here */
 	if (!(info->fmt->ops->pv_read(info->fmt, pv_name, pv, scan_label_only))) {
 		log_error("Failed to read existing physical volume '%s'",
@@ -4367,5 +4406,5 @@
  */
 struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name)
 {
-	return _pv_read(cmd, cmd->mem, pv_name, NULL, NULL, 1, 0);
+	return _pv_read(cmd, cmd->mem, pv_name, NULL, 1, 0);
 }
--- LVM2/lib/metadata/metadata.h	2011/05/07 13:32:05	1.243
+++ LVM2/lib/metadata/metadata.h	2011/06/01 19:29:33	1.244
@@ -470,7 +470,8 @@
 
 struct physical_volume *pv_by_path(struct cmd_context *cmd, const char *pv_name);
 int add_pv_to_vg(struct volume_group *vg, const char *pv_name,
-		 struct physical_volume *pv);
+		 struct physical_volume *pv, struct pvcreate_params *pp);
+
 int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 
 uint64_t find_min_mda_size(struct dm_list *mdas);
--- LVM2/lib/metadata/pv.h	2011/02/21 12:31:28	1.10
+++ LVM2/lib/metadata/pv.h	2011/06/01 19:29:33	1.11
@@ -51,6 +51,12 @@
 	unsigned long pe_align;
 	unsigned long pe_align_offset;
 
+        /* This is true whenever the represented PV has a label associated. */
+        uint64_t is_labelled:1;
+
+        /* NB. label_sector is valid whenever is_labelled is true */
+	uint64_t label_sector;
+
 	struct dm_list segments;	/* Ordered pv_segments covering complete PV */
 	struct dm_list tags;
 };
--- LVM2/lib/metadata/vg.c	2011/03/10 12:43:30	1.9
+++ LVM2/lib/metadata/vg.c	2011/06/01 19:29:33	1.10
@@ -43,6 +43,7 @@
 	vg->alloc = ALLOC_NORMAL;
 
 	dm_list_init(&vg->pvs);
+	dm_list_init(&vg->pvs_to_create);
 	dm_list_init(&vg->lvs);
 	dm_list_init(&vg->tags);
 	dm_list_init(&vg->removed_pvs);
--- LVM2/lib/metadata/vg.h	2011/04/29 19:06:17	1.11
+++ LVM2/lib/metadata/vg.h	2011/06/01 19:29:33	1.12
@@ -31,6 +31,12 @@
 	ALLOC_INHERIT
 } alloc_policy_t;
 
+struct pv_to_create {
+	struct dm_list list;
+	struct physical_volume *pv;
+	struct pvcreate_params *pp;
+};
+
 struct volume_group {
 	struct cmd_context *cmd;
 	struct dm_pool *vgmem;
@@ -59,6 +65,13 @@
 	struct dm_list pvs;
 
 	/*
+	 * List of physical volumes that were used in vgextend but do not carry
+	 * a PV label yet. They need to be pvcreate'd at vg_write time.
+	 */
+
+	struct dm_list pvs_to_create;
+
+	/*
 	 * logical volumes
 	 * The following relationship should always hold:
 	 * dm_list_size(lvs) = user visible lv_count + snapshot_count + other invisible LVs
--- LVM2/tools/pvcreate.c	2011/03/11 14:56:56	1.94
+++ LVM2/tools/pvcreate.c	2011/06/01 19:29:34	1.95
@@ -112,7 +112,7 @@
 
 		unescape_colons_and_at_signs(argv[i], NULL, NULL);
 
-		if (!(pv = pvcreate_single(cmd, argv[i], &pp))) {
+		if (!(pv = pvcreate_single(cmd, argv[i], &pp, 1))) {
 			stack;
 			ret = ECMD_FAILED;
 		}
--- LVM2/tools/pvremove.c	2011/03/11 14:56:56	1.34
+++ LVM2/tools/pvremove.c	2011/06/01 19:29:34	1.35
@@ -30,7 +30,7 @@
 
 	/* Is there a pv here already? */
 	/* If not, this is an error unless you used -f. */
-	if (!(pv = pv_read(cmd, name, NULL, 1, 0))) {
+	if (!(pv = pv_read(cmd, name, 1, 0))) {
 		if (arg_count(cmd, force_ARG))
 			return 1;
 		log_error("Physical Volume %s not found", name);
@@ -52,7 +52,7 @@
 			goto bad;
 		}
 		free_pv_fid(pv);
-		if (!(pv = pv_read(cmd, name, NULL, 1, 0))) {
+		if (!(pv = pv_read(cmd, name, 1, 0))) {
 			log_error("Failed to read physical volume %s", name);
 			goto bad;
 		}
--- LVM2/tools/pvresize.c	2011/03/11 14:56:56	1.44
+++ LVM2/tools/pvresize.c	2011/06/01 19:29:34	1.45
@@ -43,7 +43,7 @@
 			return 0;
 		}
 
-		if (!(pv = pv_read(cmd, pv_name, NULL, 1, 0))) {
+		if (!(pv = pv_read(cmd, pv_name, 1, 0))) {
 			unlock_vg(cmd, vg_name);
 			log_error("Unable to read PV \"%s\"", pv_name);
 			return 0;
--- LVM2/tools/toollib.c	2011/05/19 13:59:22	1.226
+++ LVM2/tools/toollib.c	2011/06/01 19:29:34	1.227
@@ -651,7 +651,7 @@
 	}
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!(pv = pv_read(cmd, dev_name(dev), NULL, 0, 0))) {
+		if (!(pv = pv_read(cmd, dev_name(dev), 0, 0))) {
 			memset(&pv_dummy, 0, sizeof(pv_dummy));
 			dm_list_init(&pv_dummy.tags);
 			dm_list_init(&pv_dummy.segments);
@@ -737,7 +737,7 @@
 				}
 				pv = pvl->pv;
 			} else {
-				if (!(pv = pv_read(cmd, argv[opt], NULL,
+				if (!(pv = pv_read(cmd, argv[opt],
 						   1, scan_label_only))) {
 					log_error("Failed to read physical "
 						  "volume \"%s\"", argv[opt]);
@@ -764,7 +764,7 @@
 					scanned = 1;
 					free_pv_fid(pv);
 					if (!(pv = pv_read(cmd, argv[opt],
-							   NULL, 1,
+							   1,
 							   scan_label_only))) {
 						log_error("Failed to read "
 							  "physical volume "



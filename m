From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2007 14:29:36 -0000
Subject: LVM2 ./WHATS_NEW lib/display/display.c lib/for ...
Message-ID: <20071012142936.15353.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-10-12 14:29:32

Modified files:
	.              : WHATS_NEW 
	lib/display    : display.c 
	lib/format1    : import-export.c layout.c 
	lib/format_text: archiver.c export.c format-text.c import_vsn1.c 
	lib/metadata   : lv_manip.c metadata-exported.h metadata.c 
	                 mirror.c pv_manip.c pv_map.c 
	tools          : pvchange.c pvdisplay.c pvscan.c toollib.c 
	                 vgconvert.c vgmerge.c vgreduce.c vgsplit.c 

Log message:
	Add pv_dev_name() to access PV device name.
	
	Patch by Jun'ichi Nomura <j-nomura@ce.jp.nec.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.719&r2=1.720
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/layout.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_map.c.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvdisplay.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvscan.c.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.67&r2=1.68
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37

--- LVM2/WHATS_NEW	2007/10/12 14:08:10	1.719
+++ LVM2/WHATS_NEW	2007/10/12 14:29:31	1.720
@@ -1,5 +1,6 @@
 Version 2.02.29 -
 ==================================
+  Add pv_dev_name() to access PV device name.
   Add const attributes to pv accessor functions.
   Refactor vg_add_snapshot and lv_create_empty.
   Handle new sysfs subsystem/block/devices directory structure.
--- LVM2/lib/display/display.c	2007/08/20 20:55:25	1.78
+++ LVM2/lib/display/display.c	2007/10/12 14:29:31	1.79
@@ -246,7 +246,7 @@
 	}
 
 	log_print("%s:%s:%" PRIu64 ":-1:%u:%u:-1:%" PRIu32 ":%u:%u:%u:%s",
-		  dev_name(pv->dev), pv->vg_name, pv->size,
+		  pv_dev_name(pv), pv->vg_name, pv->size,
 		  /* FIXME pv->pv_number, Derive or remove? */
 		  pv->status,	/* FIXME Support old or new format here? */
 		  pv->status & ALLOCATABLE_PV,	/* FIXME remove? */
@@ -305,7 +305,7 @@
 	}
 
 	log_print("--- %sPhysical volume ---", pv->pe_size ? "" : "NEW ");
-	log_print("PV Name               %s", dev_name(pv->dev));
+	log_print("PV Name               %s", pv_dev_name(pv));
 	log_print("VG Name               %s%s", pv->vg_name,
 		  pv->status & EXPORTED_VG ? " (exported)" : "");
 
@@ -363,7 +363,7 @@
 		return 0;
 	}
 
-	log_print("PV Name               %s     ", dev_name(pv->dev));
+	log_print("PV Name               %s     ", pv_dev_name(pv));
 	/* FIXME  pv->pv_number); */
 	log_print("PV UUID               %s", *uuid ? uuid : "none");
 	log_print("PV Status             %sallocatable",
@@ -515,7 +515,7 @@
 		/* FIXME Re-check the conditions for 'Missing' */
 		log_print("%sPhysical volume\t%s", pre,
 			  seg_pv(seg, s) ?
-			  dev_name(seg_dev(seg, s)) :
+			  pv_dev_name(seg_pv(seg, s)) :
 			    "Missing");
 
 		if (seg_pv(seg, s))
--- LVM2/lib/format1/import-export.c	2007/10/11 18:51:21	1.87
+++ LVM2/lib/format1/import-export.c	2007/10/12 14:29:31	1.88
@@ -74,7 +74,7 @@
 	    strncmp(vg->system_id, (char *)pvd->system_id, sizeof(pvd->system_id)))
 		    log_very_verbose("System ID %s on %s differs from %s for "
 				     "volume group", pvd->system_id,
-				     dev_name(pv->dev), vg->system_id);
+				     pv_dev_name(pv), vg->system_id);
 
 	/*
 	 * If exported, we still need to flag in pv->status too because
@@ -95,19 +95,19 @@
 	/* Fix up pv size if missing */
 	if (!pv->size) {
 		if (!dev_get_size(dev, &pv->size)) {
-			log_error("%s: Couldn't get size.", dev_name(pv->dev));
+			log_error("%s: Couldn't get size.", pv_dev_name(pv));
 			return 0;
 		}
 		log_verbose("Fixing up missing format1 size (%s) "
 			    "for PV %s", display_size(fmt->cmd, pv->size),
-			    dev_name(pv->dev));
+			    pv_dev_name(pv));
 		if (vg) {
 			size = pv->pe_count * (uint64_t) vg->extent_size +
 			       pv->pe_start;
 			if (size > pv->size)
 				log_error("WARNING: Physical Volume %s is too "
 					  "large for underlying device",
-					  dev_name(pv->dev));
+					  pv_dev_name(pv));
 		}
 	}
 
--- LVM2/lib/format1/layout.c	2007/08/20 20:55:25	1.26
+++ LVM2/lib/format1/layout.c	2007/10/12 14:29:31	1.27
@@ -139,7 +139,7 @@
 
 	if (pvd->pe_total < PE_SIZE_PV_SIZE_REL) {
 		log_error("Too few extents on %s.  Try smaller extent size.",
-			  dev_name(pv->dev));
+			  pv_dev_name(pv));
 		dm_free(pvd);
 		return 0;
 	}
@@ -160,7 +160,7 @@
 
 	if (pvd->pe_total > MAX_PE_TOTAL) {
 		log_error("Metadata extent limit (%u) exceeded for %s - "
-			  "%u required", MAX_PE_TOTAL, dev_name(pv->dev),
+			  "%u required", MAX_PE_TOTAL, pv_dev_name(pv),
 			  pvd->pe_total);
 		dm_free(pvd);
 		return 0;
--- LVM2/lib/format_text/archiver.c	2007/08/20 20:55:26	1.9
+++ LVM2/lib/format_text/archiver.c	2007/10/12 14:29:32	1.10
@@ -307,19 +307,19 @@
 		pv = pvl->pv;
 		if (!(info = info_from_pvid(pv->dev->pvid))) {
 			log_error("PV %s missing from cache",
-				  dev_name(pv->dev));
+				  pv_dev_name(pv));
 			return 0;
 		}
 		if (cmd->fmt != info->fmt) {
 			log_error("PV %s is a different format (seqno %s)",
-				  dev_name(pv->dev), info->fmt->name);
+				  pv_dev_name(pv), info->fmt->name);
 			return 0;
 		}
 		if (!vg->fid->fmt->ops->
 		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0,
 			     UINT64_C(0), &vg->fid->metadata_areas, pv, vg)) {
 			log_error("Format-specific setup for %s failed",
-				  dev_name(pv->dev));
+				  pv_dev_name(pv));
 			return 0;
 		}
 	}
--- LVM2/lib/format_text/export.c	2007/08/20 20:55:26	1.56
+++ LVM2/lib/format_text/export.c	2007/10/12 14:29:32	1.57
@@ -360,7 +360,7 @@
 static const char *_get_pv_name(struct formatter *f, struct physical_volume *pv)
 {
 	return (pv) ? (const char *)
-	    dm_hash_lookup(f->pv_names, dev_name(pv->dev)) : "Missing";
+	    dm_hash_lookup(f->pv_names, pv_dev_name(pv)) : "Missing";
 }
 
 static int _print_pvs(struct formatter *f, struct volume_group *vg)
@@ -391,7 +391,7 @@
 		}
 
 		outf(f, "id = \"%s\"", buffer);
-		if (!out_hint(f, "device = \"%s\"", dev_name(pv->dev))) {
+		if (!out_hint(f, "device = \"%s\"", pv_dev_name(pv))) {
 			stack;
 			return 0;
 		}
@@ -636,7 +636,7 @@
 		if (!(name = dm_pool_strdup(f->mem, buffer)))
 			return_0;
 
-		if (!dm_hash_insert(f->pv_names, dev_name(pv->dev), name))
+		if (!dm_hash_insert(f->pv_names, pv_dev_name(pv), name))
 			return_0;
 	}
 
--- LVM2/lib/format_text/format-text.c	2007/08/22 14:38:17	1.82
+++ LVM2/lib/format_text/format-text.c	2007/10/12 14:29:32	1.83
@@ -1183,7 +1183,7 @@
 
 	if (pe_end > disk_size) {
 		log_error("Physical extents end beyond end of device %s!",
-			  dev_name(pv->dev));
+			  pv_dev_name(pv));
 		return 0;
 	}
 
@@ -1204,7 +1204,7 @@
 	/* Ensure it's not going to be bigger than the disk! */
 	if (start1 + mda_size1 > disk_size) {
 		log_warn("WARNING: metadata area fills disk leaving no "
-			 "space for data on %s.", dev_name(pv->dev));
+			 "space for data on %s.", pv_dev_name(pv));
 		/* Leave some free space for rounding */
 		/* Avoid empty data area as could cause tools problems */
 		mda_size1 = disk_size - start1 - alignment * 2;
@@ -1647,7 +1647,7 @@
 				   vg->extent_size;
 			if (pe_count > UINT32_MAX) {
 				log_error("PV %s too large for extent size %s.",
-					  dev_name(pv->dev),
+					  pv_dev_name(pv),
 					  display_size(vg->cmd, (uint64_t) vg->extent_size));
 				return 0;
 			}
--- LVM2/lib/format_text/import_vsn1.c	2007/08/22 14:38:17	1.41
+++ LVM2/lib/format_text/import_vsn1.c	2007/10/12 14:29:32	1.42
@@ -202,7 +202,7 @@
 	if ((cn = find_config_node(pvn, "tags")) &&
 	    !(read_tags(mem, &pv->tags, cn->v))) {
 		log_error("Couldn't read tags for physical volume %s in %s.",
-			  dev_name(pv->dev), vg->name);
+			  pv_dev_name(pv), vg->name);
 		return 0;
 	}
 
@@ -218,19 +218,19 @@
         /* Fix up pv size if missing */
         if (!pv->size && pv->dev) {
                 if (!dev_get_size(pv->dev, &pv->size)) {
-                        log_error("%s: Couldn't get size.", dev_name(pv->dev));
+                        log_error("%s: Couldn't get size.", pv_dev_name(pv));
                         return 0;
                 }
                 log_verbose("Fixing up missing format1 size (%s) "
                             "for PV %s", display_size(fid->fmt->cmd, pv->size),
-                            dev_name(pv->dev));
+                            pv_dev_name(pv));
                 if (vg) {
                         size = pv->pe_count * (uint64_t) vg->extent_size +
                                pv->pe_start;
                         if (size > pv->size)
                                 log_error("WARNING: Physical Volume %s is too "
                                           "large for underlying device",
-                                          dev_name(pv->dev));
+                                          pv_dev_name(pv));
                 }
         }
 
--- LVM2/lib/metadata/lv_manip.c	2007/10/11 19:20:38	1.130
+++ LVM2/lib/metadata/lv_manip.c	2007/10/12 14:29:32	1.131
@@ -526,7 +526,7 @@
 
 	list_iterate_items(spvs, parallel_areas) {
 		list_iterate_items(pvl, &spvs->pvs) {
-			if (!dm_pool_grow_object(mem, dev_name(pvl->pv->dev), strlen(dev_name(pvl->pv->dev)))) {
+			if (!dm_pool_grow_object(mem, pv_dev_name(pvl->pv), strlen(pv_dev_name(pvl->pv)))) {
 				log_error("dm_pool_grow_object failed");
 				dm_pool_abandon_object(mem);
 				return 0;
--- LVM2/lib/metadata/metadata-exported.h	2007/10/12 14:08:10	1.19
+++ LVM2/lib/metadata/metadata-exported.h	2007/10/12 14:29:32	1.20
@@ -470,6 +470,7 @@
 */
 struct device *pv_dev(const pv_t *pv);
 const char *pv_vg_name(const pv_t *pv);
+const char *pv_dev_name(const pv_t *pv);
 uint64_t pv_size(const pv_t *pv);
 uint32_t pv_status(const pv_t *pv);
 uint32_t pv_pe_size(const pv_t *pv);
--- LVM2/lib/metadata/metadata.c	2007/10/12 14:08:10	1.137
+++ LVM2/lib/metadata/metadata.c	2007/10/12 14:29:32	1.138
@@ -241,7 +241,7 @@
 	list_iterate_items(pvl, &vg->pvs) {
 		if (!(pvl->pv->vg_name = dm_pool_strdup(mem, new_name))) {
 			log_error("pv->vg_name allocation failed for '%s'",
-				  dev_name(pvl->pv->dev));
+				  pv_dev_name(pvl->pv));
 			return 0;
 		}
 	}
@@ -313,12 +313,12 @@
 	list_iterate_items(pvl, &vg->pvs) {
 		pv = pvl->pv;
 		log_verbose("Removing physical volume \"%s\" from "
-			    "volume group \"%s\"", dev_name(pv_dev(pv)), vg_name);
+			    "volume group \"%s\"", pv_dev_name(pv), vg_name);
 		pv->vg_name = ORPHAN;
 		pv->status = ALLOCATABLE_PV;
 
 		if (!dev_get_size(pv_dev(pv), &pv->size)) {
-			log_error("%s: Couldn't get size.", dev_name(pv_dev(pv)));
+			log_error("%s: Couldn't get size.", pv_dev_name(pv));
 			ret = 0;
 			continue;
 		}
@@ -327,7 +327,7 @@
 		if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
 			log_error("Failed to remove physical volume \"%s\""
 				  " from volume group \"%s\"",
-				  dev_name(pv_dev(pv)), vg_name);
+				  pv_dev_name(pv), vg_name);
 			ret = 0;
 		}
 	}
@@ -530,13 +530,13 @@
 		pv = pvl->pv;
 
 		pv->pe_size = new_size;
-		if (!_recalc_extents(&pv->pe_count, dev_name(pv->dev), "",
+		if (!_recalc_extents(&pv->pe_count, pv_dev_name(pv), "",
 				     old_size, new_size)) {
 			stack;
 			return 0;
 		}
 
-		if (!_recalc_extents(&pv->pe_alloc_count, dev_name(pv->dev),
+		if (!_recalc_extents(&pv->pe_alloc_count, pv_dev_name(pv),
 				     " allocated space", old_size, new_size)) {
 			stack;
 			return 0;
@@ -547,13 +547,13 @@
 			if (pvseg->lvseg)
 				continue;
 
-			if (!_recalc_extents(&pvseg->pe, dev_name(pv->dev),
+			if (!_recalc_extents(&pvseg->pe, pv_dev_name(pv),
 					     " PV segment start", old_size,
 					     new_size)) {
 				stack;
 				return 0;
 			}
-			if (!_recalc_extents(&pvseg->len, dev_name(pv->dev),
+			if (!_recalc_extents(&pvseg->len, pv_dev_name(pv),
 					     " PV segment length", old_size,
 					     new_size)) {
 				stack;
@@ -742,22 +742,22 @@
 	pv->status = ALLOCATABLE_PV;
 
 	if (!dev_get_size(pv->dev, &pv->size)) {
-		log_error("%s: Couldn't get size.", dev_name(pv->dev));
+		log_error("%s: Couldn't get size.", pv_dev_name(pv));
 		goto bad;
 	}
 
 	if (size) {
 		if (size > pv->size)
 			log_warn("WARNING: %s: Overriding real size. "
-				  "You could lose data.", dev_name(pv->dev));
+				  "You could lose data.", pv_dev_name(pv));
 		log_verbose("%s: Pretending size is %" PRIu64 " sectors.",
-			    dev_name(pv->dev), size);
+			    pv_dev_name(pv), size);
 		pv->size = size;
 	}
 
 	if (pv->size < PV_MIN_SIZE) {
 		log_error("%s: Size must exceed minimum of %ld sectors.",
-			  dev_name(pv->dev), PV_MIN_SIZE);
+			  pv_dev_name(pv), PV_MIN_SIZE);
 		goto bad;
 	}
 
@@ -775,7 +775,7 @@
 				pvmetadatacopies, pvmetadatasize, mdas,
 				pv, NULL)) {
 		log_error("%s: Format-specific setup of physical volume "
-			  "failed.", dev_name(pv->dev));
+			  "failed.", pv_dev_name(pv));
 		goto bad;
 	}
 	return pv;
@@ -988,7 +988,7 @@
 					 stack;
 				log_error("Internal error: Duplicate PV id "
 					  "%s detected for %s in %s.",
-					  uuid, dev_name(pvl->pv->dev),
+					  uuid, pv_dev_name(pvl->pv),
 					  vg->name);
 				r = 0;
 			}
@@ -996,7 +996,7 @@
 
 		if (strcmp(pvl->pv->vg_name, vg->name)) {
 			log_error("Internal error: VG name for PV %s is corrupted",
-				  dev_name(pvl->pv->dev));
+				  pv_dev_name(pvl->pv));
 			r = 0;
 		}
 	}
@@ -1215,7 +1215,7 @@
 		/* PV is not on list so add it.  Note that we don't copy it. */
        		if (!(pvl2 = dm_pool_zalloc(vg->cmd->mem, sizeof(*pvl2)))) {
 			log_error("pv_list allocation for '%s' failed",
-				  dev_name(pvl->pv->dev));
+				  pv_dev_name(pvl->pv));
 			return 0;
 		}
 		pvl2->pv = pvl->pv;
@@ -1454,7 +1454,7 @@
 			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
 				return_NULL;
 			log_error("Removing PV %s (%s) that no longer belongs to VG %s",
-				  dev_name(pvl->pv->dev), uuid, correct_vg->name);
+				  pv_dev_name(pvl->pv), uuid, correct_vg->name);
 			if (!pv_write_orphan(cmd, pvl->pv))
 				return_NULL;
       next_pv:
@@ -1781,14 +1781,14 @@
 	pv->status = ALLOCATABLE_PV;
 
 	if (!dev_get_size(pv->dev, &pv->size)) {
-		log_error("%s: Couldn't get size.", dev_name(pv->dev));
+		log_error("%s: Couldn't get size.", pv_dev_name(pv));
 		return 0;
 	}
 
 	if (!_pv_write(cmd, pv, NULL, INT64_C(-1))) {
 		log_error("Failed to clear metadata from physical "
 			  "volume \"%s\" after removal from \"%s\"",
-			  dev_name(pv->dev), old_vg_name);
+			  pv_dev_name(pv), old_vg_name);
 		return 0;
 	}
 
@@ -1952,6 +1952,11 @@
 	return pv_field(pv, vg_name);
 }
 
+const char *pv_dev_name(const pv_t *pv)
+{
+	return dev_name(pv_dev(pv));
+}
+
 uint64_t pv_size(const pv_t *pv)
 {
 	return pv_field(pv, size);
--- LVM2/lib/metadata/mirror.c	2007/10/11 19:20:38	1.43
+++ LVM2/lib/metadata/mirror.c	2007/10/12 14:29:32	1.44
@@ -651,7 +651,7 @@
 				pv = seg_pv(seg, s);
 				pe = seg_pe(seg, s);
 				log_very_verbose("Moving %s:%u-%u of %s/%s",
-						 dev_name(pvl->pv->dev),
+						 pv_dev_name(pvl->pv),
 						 pe, pe + seg->area_len - 1,
 						 lv->vg->name, lv->name);
 
--- LVM2/lib/metadata/pv_manip.c	2007/09/24 21:30:00	1.14
+++ LVM2/lib/metadata/pv_manip.c	2007/10/12 14:29:32	1.15
@@ -122,7 +122,7 @@
 
 	if (!(peg = find_peg_by_pe(pv, pe))) {
 		log_error("Segment with extent %" PRIu32 " in PV %s not found",
-			  pe, dev_name(pv->dev));
+			  pe, pv_dev_name(pv));
 		return 0;
 	}
 
@@ -162,7 +162,7 @@
 
 	if (!(peg = find_peg_by_pe(pv, pe))) {
 		log_error("Missing PV segment on %s at %u.",
-			  dev_name(pv->dev), pe);
+			  pv_dev_name(pv), pe);
 		return NULL;
 	}
 
@@ -179,7 +179,7 @@
 {
 	if (!peg->lvseg) {
 		log_error("release_pv_segment with unallocated segment: "
-			  "%s PE %" PRIu32, dev_name(peg->pv->dev), peg->pe);
+			  "%s PE %" PRIu32, pv_dev_name(peg->pv), peg->pe);
 		return 0;
 	}
 
@@ -279,7 +279,7 @@
 
 			/* FIXME Remove this next line eventually */
 			log_debug("%s %u: %6u %6u: %s(%u:%u)",
-				  dev_name(pv->dev), segno++, peg->pe, peg->len,
+				  pv_dev_name(pv), segno++, peg->pe, peg->len,
 				  peg->lvseg ? peg->lvseg->lv->name : "NULL",
 				  peg->lvseg ? peg->lvseg->le : 0, s);
 			/* FIXME Add details here on failure instead */
@@ -353,7 +353,7 @@
 	if (new_pe_count < pv->pe_alloc_count) {
 		log_error("%s: cannot resize to %" PRIu32 " extents "
 			  "as %" PRIu32 " are allocated.",
-			  dev_name(pv->dev), new_pe_count,
+			  pv_dev_name(pv), new_pe_count,
 			  pv->pe_alloc_count);
 		return 0;
 	}
@@ -366,7 +366,7 @@
 		if (peg->lvseg) {
 			log_error("%s: cannot resize to %" PRIu32 " extents as "
 				  "later ones are allocated.",
-				  dev_name(pv->dev), new_pe_count);
+				  pv_dev_name(pv), new_pe_count);
 			return 0;
 		}
 	}
@@ -397,7 +397,7 @@
 
 	if ((uint64_t) new_pe_count * pv->pe_size > pv->size ) {
 		log_error("%s: cannot resize to %" PRIu32 " extents as there "
-			  "is only room for %" PRIu64 ".", dev_name(pv->dev),
+			  "is only room for %" PRIu64 ".", pv_dev_name(pv),
 			  new_pe_count, pv->size / pv->pe_size);
 		return 0;
 	}
@@ -426,13 +426,13 @@
 {
 	if ((new_pe_count == pv->pe_count)) {
 		log_verbose("No change to size of physical volume %s.",
-			    dev_name(pv->dev));
+			    pv_dev_name(pv));
 		return 1;
 	}
 
 	log_verbose("Resizing physical volume %s from %" PRIu32
 		    " to %" PRIu32 " extents.",
-		    dev_name(pv->dev), pv->pe_count, new_pe_count);
+		    pv_dev_name(pv), pv->pe_count, new_pe_count);
 
 	if (new_pe_count > pv->pe_count)
 		return _extend_pv(pv, vg, new_pe_count);
@@ -450,7 +450,7 @@
 	uint64_t size = 0;
 	uint32_t new_pe_count = 0;
 	struct list mdas;
-	const char *pv_name = dev_name(pv_dev(pv));
+	const char *pv_name = pv_dev_name(pv);
 	const char *vg_name;
 
 	list_init(&mdas);
--- LVM2/lib/metadata/pv_map.c	2007/08/20 20:55:26	1.28
+++ LVM2/lib/metadata/pv_map.c	2007/10/12 14:29:32	1.29
@@ -46,7 +46,7 @@
 	}
 
 	log_debug("Allowing allocation on %s start PE %" PRIu32 " length %"
-		  PRIu32, dev_name(pvm->pv->dev), start, length);
+		  PRIu32, pv_dev_name(pvm->pv), start, length);
 	pva->map = pvm;
 	pva->start = start;
 	pva->count = length;
--- LVM2/tools/pvchange.c	2007/08/20 20:55:30	1.52
+++ LVM2/tools/pvchange.c	2007/10/12 14:29:32	1.53
@@ -26,7 +26,7 @@
 	uint64_t sector;
 	uint32_t orig_pe_alloc_count;
 
-	const char *pv_name = dev_name(pv_dev(pv));
+	const char *pv_name = pv_dev_name(pv);
 	const char *tag = NULL;
 	const char *orig_vg_name;
 	char uuid[64] __attribute((aligned(8)));
--- LVM2/tools/pvdisplay.c	2007/08/20 20:55:30	1.38
+++ LVM2/tools/pvdisplay.c	2007/10/12 14:29:32	1.39
@@ -24,7 +24,7 @@
 	int ret = ECMD_PROCESSED;
 	uint64_t size;
 
-	const char *pv_name = dev_name(pv_dev(pv));
+	const char *pv_name = pv_dev_name(pv);
 
 	 if (pv_vg_name(pv)) {
 	         if (!lock_vol(cmd, pv_vg_name(pv), LCK_VG_READ)) {
--- LVM2/tools/pvscan.c	2007/08/23 15:02:26	1.42
+++ LVM2/tools/pvscan.c	2007/10/12 14:29:32	1.43
@@ -31,7 +31,7 @@
 
 	/* short listing? */
 	if (arg_count(cmd, short_ARG) > 0) {
-		log_print("%s", dev_name(pv_dev(pv)));
+		log_print("%s", pv_dev_name(pv));
 		return;
 	}
 
@@ -57,9 +57,9 @@
 		}
 
 		sprintf(pv_tmp_name, "%-*s with UUID %s",
-			pv_max_name_len - 2, dev_name(pv_dev(pv)), uuid);
+			pv_max_name_len - 2, pv_dev_name(pv), uuid);
 	} else {
-		sprintf(pv_tmp_name, "%s", dev_name(pv_dev(pv)));
+		sprintf(pv_tmp_name, "%s", pv_dev_name(pv));
 	}
 
 	if (!*pv_vg_name(pv)) {
@@ -173,7 +173,7 @@
 	pv_max_name_len = vg_max_name_len = 0;
 	list_iterate_items(pvl, pvslist) {
 		pv = pvl->pv;
-		len = strlen(dev_name(pv_dev(pv)));
+		len = strlen(pv_dev_name(pv));
 		if (pv_max_name_len < len)
 			pv_max_name_len = len;
 		len = strlen(pv_vg_name(pv));
--- LVM2/tools/toollib.c	2007/10/11 19:20:38	1.107
+++ LVM2/tools/toollib.c	2007/10/12 14:29:32	1.108
@@ -1000,7 +1000,7 @@
 	struct pv_list *new_pvl = NULL, *pvl2;
 	struct list *pe_ranges;
 
-	pvname = dev_name(pvl->pv->dev);
+	pvname = pv_dev_name(pvl->pv);
 	if (allocatable_only && !(pvl->pv->status & ALLOCATABLE_PV)) {
 		log_error("Physical volume %s not allocatable", pvname);
 		return 1;
@@ -1036,7 +1036,7 @@
 	}
 
 	/* Determine selected physical extents */
-	if (!_parse_pes(mem, colon, new_pvl->pe_ranges, dev_name(pvl->pv->dev),
+	if (!_parse_pes(mem, colon, new_pvl->pe_ranges, pv_dev_name(pvl->pv),
 			pvl->pv->pe_count)) {
 		stack;
 		return 0;
--- LVM2/tools/vgconvert.c	2007/08/20 20:55:30	1.24
+++ LVM2/tools/vgconvert.c	2007/10/12 14:29:32	1.25
@@ -118,7 +118,7 @@
 				     pv_pe_size(existing_pv), pvmetadatacopies,
 				     pvmetadatasize, &mdas))) {
 			log_error("Failed to setup physical volume \"%s\"",
-				  dev_name(pv_dev(existing_pv)));
+				  pv_dev_name(existing_pv));
 			if (change_made)
 				log_error("Use pvcreate and vgcfgrestore to "
 					  "repair from archived metadata.");
@@ -129,30 +129,30 @@
 		change_made = 1;
 
 		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
-			    " available sectors", dev_name(pv_dev(pv)), pv_size(pv));
+			    " available sectors", pv_dev_name(pv), pv_size(pv));
 
 		/* Wipe existing label first */
 		if (!label_remove(pv_dev(pv))) {
 			log_error("Failed to wipe existing label on %s",
-				  dev_name(pv_dev(pv)));
+				  pv_dev_name(pv));
 			log_error("Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
 			return ECMD_FAILED;
 		}
 
 		log_very_verbose("Writing physical volume data to disk \"%s\"",
-				 dev_name(pv_dev(pv)));
+				 pv_dev_name(pv));
 		if (!(pv_write(cmd, pv, &mdas,
 			       arg_int64_value(cmd, labelsector_ARG,
 					       DEFAULT_LABELSECTOR)))) {
 			log_error("Failed to write physical volume \"%s\"",
-				  dev_name(pv_dev(pv)));
+				  pv_dev_name(pv));
 			log_error("Use pvcreate and vgcfgrestore to repair "
 				  "from archived metadata.");
 			return ECMD_FAILED;
 		}
 		log_verbose("Physical volume \"%s\" successfully created",
-			    dev_name(pv_dev(pv)));
+			    pv_dev_name(pv));
 
 	}
 
--- LVM2/tools/vgmerge.c	2007/08/20 20:55:30	1.40
+++ LVM2/tools/vgmerge.c	2007/10/12 14:29:32	1.41
@@ -95,7 +95,7 @@
 		if (pv_uses_vg(pvl->pv, vg_from)) {
 			log_error("Physical volume %s might be constructed "
 				  "from same volume group %s.",
-				  dev_name(pvl->pv->dev), vg_from->name);
+				  pv_dev_name(pvl->pv), vg_from->name);
 			goto error;
 		}
 	}
@@ -104,7 +104,7 @@
 		if (pv_uses_vg(pvl->pv, vg_to)) {
 			log_error("Physical volume %s might be constructed "
 				  "from same volume group %s.",
-				  dev_name(pvl->pv->dev), vg_to->name);
+				  pv_dev_name(pvl->pv), vg_to->name);
 			goto error;
 		}
 	}
--- LVM2/tools/vgreduce.c	2007/08/22 14:38:18	1.67
+++ LVM2/tools/vgreduce.c	2007/10/12 14:29:32	1.68
@@ -365,7 +365,7 @@
 			    void *handle __attribute((unused)))
 {
 	struct pv_list *pvl;
-	const char *name = dev_name(pv_dev(pv));
+	const char *name = pv_dev_name(pv);
 
 	if (pv_pe_alloc_count(pv)) {
 		log_error("Physical volume \"%s\" still in use", name);
@@ -392,7 +392,7 @@
 	pv->status = ALLOCATABLE_PV;
 
 	if (!dev_get_size(pv_dev(pv), &pv->size)) {
-		log_error("%s: Couldn't get size.", dev_name(pv_dev(pv)));
+		log_error("%s: Couldn't get size.", pv_dev_name(pv));
 		return ECMD_FAILED;
 	}
 
--- LVM2/tools/vgsplit.c	2007/08/22 14:38:18	1.36
+++ LVM2/tools/vgsplit.c	2007/10/12 14:29:32	1.37
@@ -105,7 +105,7 @@
 					continue;
 				}
 				log_error("Physical Volume %s not found",
-					  dev_name(pv_dev(pv)));
+					  pv_dev_name(pv));
 				return 0;
 			}
 



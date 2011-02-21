From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:24:18 -0000
Subject: LVM2 lib/format1/format1.c lib/format_pool/for ...
Message-ID: <20110221122418.2634.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:24:17

Modified files:
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: archiver.c format-text.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	tools          : vgconvert.c 

Log message:
	Change the code throughout to use new pv_initialise and modified pv_setup fn.
	Change pv_create code to work with these changes together with using new
	pv_add_metadata_area fn to add metadata areas for a PV being created.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.161&r2=1.162
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.178&r2=1.179
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.430&r2=1.431
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.236&r2=1.237
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/lib/format1/format1.c	2011/02/21 12:20:18	1.130
+++ LVM2/lib/format1/format1.c	2011/02/21 12:24:15	1.131
@@ -399,14 +399,6 @@
 }
 
 static int _format1_pv_setup(const struct format_type *fmt,
-			     uint64_t pe_start, uint32_t extent_count,
-			     uint32_t extent_size,
-			     unsigned long data_alignment __attribute__((unused)),
-			     unsigned long data_alignment_offset __attribute__((unused)),
-			     int pvmetadatacopies __attribute__((unused)),
-			     uint64_t pvmetadatasize __attribute__((unused)),
-			     unsigned metadataignore __attribute__((unused)),
-			     struct dm_list *mdas __attribute__((unused)),
 			     struct physical_volume *pv,
 			     struct volume_group *vg __attribute__((unused)))
 {
--- LVM2/lib/format_pool/format_pool.c	2011/02/21 12:20:18	1.38
+++ LVM2/lib/format_pool/format_pool.c	2011/02/21 12:24:16	1.39
@@ -201,15 +201,6 @@
 }
 
 static int _pool_pv_setup(const struct format_type *fmt __attribute__((unused)),
-			  uint64_t pe_start __attribute__((unused)),
-			  uint32_t extent_count __attribute__((unused)),
-			  uint32_t extent_size __attribute__((unused)),
-			  unsigned long data_alignment __attribute__((unused)),
-			  unsigned long data_alignment_offset __attribute__((unused)),
-			  int pvmetadatacopies __attribute__((unused)),
-			  uint64_t pvmetadatasize __attribute__((unused)),
-			  unsigned metadataignore __attribute__((unused)),
-			  struct dm_list *mdas __attribute__((unused)),
 			  struct physical_volume *pv __attribute__((unused)),
 			  struct volume_group *vg __attribute__((unused)))
 {
--- LVM2/lib/format_text/archiver.c	2011/02/21 12:10:58	1.40
+++ LVM2/lib/format_text/archiver.c	2011/02/21 12:24:16	1.41
@@ -333,10 +333,7 @@
 				  pv_dev_name(pv), info->fmt->name);
 			return 0;
 		}
-		if (!vg->fid->fmt->ops->
-		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0, 0UL,
-			     UINT64_C(0), 0,
-			     &vg->fid->metadata_areas_in_use, pv, vg)) {
+		if (!vg->fid->fmt->ops->pv_setup(vg->fid->fmt, pv, vg)) {
 			log_error("Format-specific setup for %s failed",
 				  pv_dev_name(pv));
 			return 0;
--- LVM2/lib/format_text/format-text.c	2011/02/21 12:20:18	1.161
+++ LVM2/lib/format_text/format-text.c	2011/02/21 12:24:17	1.162
@@ -1824,151 +1824,65 @@
 	.mda_locns_match = _mda_locns_match_raw
 };
 
-/* pvmetadatasize in sectors */
-/*
- * pe_start goal: FIXME -- reality of .pv_write complexity undermines this goal
- * - In cases where a pre-existing pe_start is provided (pvcreate --restorefile
- *   and vgconvert): pe_start must not be changed (so pv->pe_start = pe_start).
- * - In cases where pe_start is 0: leave pv->pe_start as 0 and defer the
- *   setting of pv->pe_start to .pv_write
- */
 static int _text_pv_setup(const struct format_type *fmt,
-			  uint64_t pe_start, uint32_t extent_count,
-			  uint32_t extent_size, unsigned long data_alignment,
-			  unsigned long data_alignment_offset,
-			  int pvmetadatacopies, uint64_t pvmetadatasize,
-			  unsigned metadataignore, struct dm_list *mdas,
-			  struct physical_volume *pv, struct volume_group *vg)
-{
-	struct metadata_area *mda, *mda_new, *mda2;
-	struct mda_context *mdac, *mdac2;
-	struct dm_list *pvmdas;
-	struct lvmcache_info *info;
-	int found;
-	uint64_t pe_end = 0;
-	unsigned mda_count = 0;
-	uint64_t mda_size2 = 0;
+			  struct physical_volume *pv,
+			  struct volume_group *vg)
+{
+	struct format_instance *fid = pv->fid;
+	const char *pvid = (const char *) &pv->id;
+	unsigned mda_index;
+	struct metadata_area *pv_mda;
+	struct mda_context *pv_mdac;
 	uint64_t pe_count;
+	uint64_t size_reduction = 0;
 
-	/* FIXME Cope with pvchange */
-	/* FIXME Merge code with _text_create_text_instance */
-
-	/* If new vg, add any further mdas on this PV to the fid's mda list */
-	if (vg) {
-		/* Iterate through all mdas on this PV */
-		if ((info = info_from_pvid(pv->dev->pvid, 0))) {
-			pvmdas = &info->mdas;
-			dm_list_iterate_items(mda, pvmdas) {
-				mda_count++;
-				mdac =
-				    (struct mda_context *) mda->metadata_locn;
-
-				/* FIXME Check it isn't already in use */
-
-				/* Reduce usable device size */
-				if (mda_count > 1)
-					mda_size2 = mdac->area.size >> SECTOR_SHIFT;
-
-				/* Ensure it isn't already on list */
-				found = 0;
-				dm_list_iterate_items(mda2, mdas) {
-					if (mda2->ops !=
-					    &_metadata_text_raw_ops) continue;
-					mdac2 =
-					    (struct mda_context *)
-					    mda2->metadata_locn;
-					if (!memcmp
-					    (&mdac2->area, &mdac->area,
-					     sizeof(mdac->area))) {
-						found = 1;
-						break;
-					}
-				}
-				if (found)
-					continue;
-
-				mda_new = mda_copy(fmt->cmd->mem, mda);
-				if (!mda_new)
-					return_0;
-				dm_list_add(mdas, &mda_new->list);
-				/* FIXME multiple dev_areas inside area */
-			}
-		}
-
-		/* FIXME Cope with genuine pe_count 0 */
-
-		/* If missing, estimate pv->size from file-based metadata */
-		if (!pv->size && pv->pe_count)
-			pv->size = pv->pe_count * (uint64_t) vg->extent_size +
-				   pv->pe_start + mda_size2;
-
-		/* Recalculate number of extents that will fit */
-		if (!pv->pe_count) {
-			pe_count = (pv->size - pv->pe_start - mda_size2) /
-				   vg->extent_size;
-			if (pe_count > UINT32_MAX) {
-				log_error("PV %s too large for extent size %s.",
-					  pv_dev_name(pv),
-					  display_size(vg->cmd, (uint64_t) vg->extent_size));
-				return 0;
-			}
-			pv->pe_count = (uint32_t) pe_count;
-		}
-
-		/* Unlike LVM1, we don't store this outside a VG */
-		/* FIXME Default from config file? vgextend cmdline flag? */
-		pv->status |= ALLOCATABLE_PV;
-	} else {
-		if (pe_start)
-			pv->pe_start = pe_start;
-
-		if (!data_alignment)
-			data_alignment = find_config_tree_int(pv->fmt->cmd,
-						      "devices/data_alignment",
-						      0) * 2;
-
-		if (set_pe_align(pv, data_alignment) != data_alignment &&
-		    data_alignment) {
-			log_error("%s: invalid data alignment of "
-				  "%lu sectors (requested %lu sectors)",
-				  pv_dev_name(pv), pv->pe_align, data_alignment);
-			return 0;
-		}
-
-		if (set_pe_align_offset(pv, data_alignment_offset) != data_alignment_offset &&
-		    data_alignment_offset) {
-			log_error("%s: invalid data alignment offset of "
-				  "%lu sectors (requested %lu sectors)",
-				  pv_dev_name(pv), pv->pe_align_offset, data_alignment_offset);
-			return 0;
-		}
-
-		if (pv->pe_align < pv->pe_align_offset) {
-			log_error("%s: pe_align (%lu sectors) must not be less "
-				  "than pe_align_offset (%lu sectors)",
-				  pv_dev_name(pv), pv->pe_align, pv->pe_align_offset);
+	/* Add any further mdas on this PV to VG's format instance. */
+	for (mda_index = 0; mda_index < FMT_TEXT_MAX_MDAS_PER_PV; mda_index++) {
+		if (!(pv_mda = fid_get_mda_indexed(fid, pvid, ID_LEN, mda_index)))
+			continue;
+
+		/* Be sure it's not already in VG's format instance! */
+		if (!fid_get_mda_indexed(vg->fid, pvid, ID_LEN, mda_index))
+			fid_add_mda(vg->fid, pv_mda, pvid, ID_LEN, mda_index);
+	}
+
+	/* If there's the 2nd mda, we need to reduce
+	 * usable size for further pe_count calculation! */
+	if ((pv_mda = fid_get_mda_indexed(fid, pvid, ID_LEN, 1)) &&
+	    (pv_mdac = pv_mda->metadata_locn))
+		size_reduction = pv_mdac->area.size >> SECTOR_SHIFT;
+
+	/* Destroy old PV-based format instance if it exists. */
+	if (!(pv->fid->type & FMT_INSTANCE_VG))
+		pv->fmt->ops->destroy_instance(pv->fid);
+
+	/* From now on, VG format instance will be used. */
+	pv->fid = vg->fid;
+
+	/* FIXME Cope with genuine pe_count 0 */
+
+	/* If missing, estimate pv->size from file-based metadata */
+	if (!pv->size && pv->pe_count)
+		pv->size = pv->pe_count * (uint64_t) vg->extent_size +
+			   pv->pe_start + size_reduction;
+
+	/* Recalculate number of extents that will fit */
+	if (!pv->pe_count) {
+		pe_count = (pv->size - pv->pe_start - size_reduction) /
+			   vg->extent_size;
+		if (pe_count > UINT32_MAX) {
+			log_error("PV %s too large for extent size %s.",
+				  pv_dev_name(pv),
+				  display_size(vg->cmd, (uint64_t) vg->extent_size));
 			return 0;
 		}
-
-		/*
-		 * This initialization has a side-effect of allowing
-		 * orphaned PVs to be created with the proper alignment.
-		 * Setting pv->pe_start here circumvents .pv_write's
-		 * "pvcreate on PV without prior pvremove" retreival of
-		 * the PV's previous pe_start.
-		 * - Without this you get actual != expected pe_start
-		 *   failures in the testsuite.
-		 */
-		if (!pe_start && pv->pe_start < pv->pe_align)
-			pv->pe_start = pv->pe_align;
-
-		if (extent_count)
-			pe_end = pe_start + extent_count * extent_size - 1;
-		if (!_mda_setup(fmt, pe_start, pe_end, pvmetadatacopies,
-				pvmetadatasize, metadataignore,  mdas, pv, vg))
-			return_0;
+		pv->pe_count = (uint32_t) pe_count;
 	}
 
+	/* Unlike LVM1, we don't store this outside a VG */
+	/* FIXME Default from config file? vgextend cmdline flag? */
+	pv->status |= ALLOCATABLE_PV;
+
 	return 1;
 }
 
--- LVM2/lib/metadata/metadata-exported.h	2011/02/21 12:16:00	1.178
+++ LVM2/lib/metadata/metadata-exported.h	2011/02/21 12:24:17	1.179
@@ -424,9 +424,10 @@
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
-				  int pvmetadatacopies, uint64_t pvmetadatasize,
-				  unsigned metadataignore,
-				  struct dm_list *mdas);
+				  uint64_t label_sector,
+				  int pvmetadatacopies,
+				  uint64_t pvmetadatasize,
+				  unsigned metadataignore);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
              uint32_t new_pe_count);
 int pv_analyze(struct cmd_context *cmd, const char *pv_name,
--- LVM2/lib/metadata/metadata.c	2011/02/21 12:16:00	1.430
+++ LVM2/lib/metadata/metadata.c	2011/02/21 12:24:17	1.431
@@ -195,7 +195,6 @@
 	struct format_instance *fid = vg->fid;
 	struct dm_pool *mem = vg->vgmem;
 	char uuid[64] __attribute__((aligned(8)));
-	struct dm_list *mdas;
 
 	log_verbose("Adding physical volume '%s' to volume group '%s'",
 		    pv_name, vg->name);
@@ -239,24 +238,7 @@
 	 */
 	pv->pe_alloc_count = 0;
 
-	/*
-	 * FIXME: this does not work entirely correctly in the case where a PV
-	 * has 2 mdas and only one is ignored; ideally all non-ignored mdas
-	 * should be placed on metadata_areas list and ignored on the
-	 * metadata_areas_ignored list; however this requires another
-	 * fairly complex refactoring to remove the 'mdas' parameter from both
-	 * pv_setup and pv_write.  For now, we only put ignored mdas on the
-	 * metadata_areas_ignored list if all mdas in the PV are ignored;
-	 * otherwise, we use the non-ignored list.
-	 */
-	if (!pv_mda_used_count(pv))
-		mdas = &fid->metadata_areas_ignored;
-	else
-		mdas = &fid->metadata_areas_in_use;
-
-	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
-				     vg->extent_size, 0, 0, 0UL, UINT64_C(0),
-				     0, mdas, pv, vg)) {
+	if (!fid->fmt->ops->pv_setup(fid->fmt, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
 		return 0;
@@ -1494,9 +1476,10 @@
 	dm_list_init(&mdas);
 	if (!(pv = pv_create(cmd, dev, pp->idp, pp->size,
 			     pp->data_alignment, pp->data_alignment_offset,
-			     pp->pe_start, pp->extent_count, pp->extent_size,
-			     pp->pvmetadatacopies, pp->pvmetadatasize,
-			     pp->metadataignore, &mdas))) {
+			     pp->pe_start ? pp->pe_start : PV_PE_START_CALC,
+			     pp->extent_count, pp->extent_size,
+			     pp->labelsector, pp->pvmetadatacopies,
+			     pp->pvmetadatasize, pp->metadataignore))) {
 		log_error("Failed to setup physical volume \"%s\"", pv_name);
 		goto error;
 	}
@@ -1601,13 +1584,16 @@
 				  uint64_t pe_start,
 				  uint32_t existing_extent_count,
 				  uint32_t existing_extent_size,
-				  int pvmetadatacopies, uint64_t pvmetadatasize,
-				  unsigned metadataignore, struct dm_list *mdas)
+				  uint64_t label_sector,
+				  int pvmetadatacopies,
+				  uint64_t pvmetadatasize,
+				  unsigned metadataignore)
 {
 	const struct format_type *fmt = cmd->fmt;
 	struct format_instance_ctx fic;
 	struct dm_pool *mem = fmt->cmd->mem;
 	struct physical_volume *pv = _alloc_pv(mem, dev);
+	unsigned mda_index;
 
 	if (!pv)
 		return NULL;
@@ -1656,16 +1642,26 @@
 	pv->fmt = fmt;
 	pv->vg_name = fmt->orphan_vg_name;
 
-	if (!fmt->ops->pv_setup(fmt, pe_start, existing_extent_count,
-				existing_extent_size, data_alignment,
-				data_alignment_offset,
-				pvmetadatacopies, pvmetadatasize,
-				metadataignore, mdas, pv, NULL)) {
-		log_error("%s: Format-specific setup of physical volume "
-			  "failed.", pv_dev_name(pv));
+	if (!fmt->ops->pv_initialise(fmt, label_sector, pe_start,
+				     existing_extent_count, existing_extent_size,
+				     data_alignment, data_alignment_offset, pv)) {
+		log_error("Format-specific initialisation of physical "
+			  "volume %s failed.", pv_dev_name(pv));
 		goto bad;
 	}
 
+	for (mda_index = 0; mda_index < pvmetadatacopies; mda_index++) {
+		if (pv->fmt->ops->pv_add_metadata_area &&
+		    !pv->fmt->ops->pv_add_metadata_area(pv->fmt, pv,
+					pe_start != PV_PE_START_CALC,
+					mda_index, pvmetadatasize,
+					metadataignore)) {
+			log_error("Failed to add metadata area for "
+				  "new physical volume %s", pv_dev_name(pv));
+			goto bad;
+		}
+	}
+
 	return pv;
 
       bad:
--- LVM2/lib/metadata/metadata.h	2011/02/21 12:20:19	1.236
+++ LVM2/lib/metadata/metadata.h	2011/02/21 12:24:17	1.237
@@ -272,12 +272,8 @@
 	 * vg.  eg. pe_count is format specific.
 	 */
 	int (*pv_setup) (const struct format_type * fmt,
-			 uint64_t pe_start, uint32_t extent_count,
-			 uint32_t extent_size, unsigned long data_alignment,
-			 unsigned long data_alignment_offset,
-			 int pvmetadatacopies, uint64_t pvmetadatasize,
-			 unsigned metadataignore, struct dm_list * mdas,
-			 struct physical_volume * pv, struct volume_group * vg);
+			 struct physical_volume * pv,
+			 struct volume_group * vg);
 
 	/*
 	 * Add metadata area to a PV. Changes will take effect on pv_write.
--- LVM2/tools/vgconvert.c	2011/02/18 16:17:57	1.45
+++ LVM2/tools/vgconvert.c	2011/02/21 12:24:17	1.46
@@ -125,8 +125,10 @@
 		if (!(pv = pv_create(cmd, pv_dev(existing_pv),
 				     &existing_pv->id, size, 0, 0,
 				     pe_start, pv_pe_count(existing_pv),
-				     pv_pe_size(existing_pv), pvmetadatacopies,
-				     pvmetadatasize, 0, &mdas))) {
+				     pv_pe_size(existing_pv),
+				     arg_int64_value(cmd, labelsector_ARG,
+						     DEFAULT_LABELSECTOR),
+				     pvmetadatacopies, pvmetadatasize, 0))) {
 			log_error("Failed to setup physical volume \"%s\"",
 				  pv_dev_name(existing_pv));
 			if (change_made)



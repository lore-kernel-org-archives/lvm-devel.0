From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 26 Jan 2009 23:03:49 +0100
Subject: [PATCH] Fix pvresize to handle the second metadata area properly
Message-ID: <497E3345.9010809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is a patch for pvresize that solves the problem of second metadata copy not
beeing written to new position at the end of PV when the PV is resized.

Some code from _pv_resize_single function (pvresize.c) is now placed in pv_resize
(pv_manip.c) and new format handler function called _text_pv_resize is added.
This way we can call format specific recalculation of metadata area offsets,
sizes and alignment, which is useful for resizing the PV and moving the second
metadata copy to new position properly. If the PV contains a VG, the VG is reduced
or extended and finally the _text_pv_write is called to write new metadata headers
(_text_pv_write was modified so it can handle the PV with a VG now).

Peter


diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 428b5e2..c487a6d 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1294,7 +1294,35 @@ static int _mda_setup(const struct format_type *fmt,
  	return 1;
  }

-/* Only for orphans */
+static void _pv_get_mdacs(struct physical_volume *pv, struct dm_list *mdas,
+		 		struct mda_context **mdac1, struct mda_context **mdac2)
+{
+	struct metadata_area *mda;
+	struct mda_context *mdac;
+
+	*mdac1 = NULL;
+	*mdac2 = NULL;
+
+	dm_list_iterate_items(mda, mdas) {
+		mdac = (struct mda_context *) mda->metadata_locn;
+
+		if (mdac->area.dev != pv->dev)
+			continue;
+		
+		if (*mdac1)
+			*mdac2 = mdac;
+		else
+			*mdac1 = mdac;
+	}
+
+	if ((*mdac1 != NULL) && (*mdac2 != NULL))
+		if ((*mdac1)->area.start > (*mdac2)->area.start) {
+			mdac = *mdac1;
+			*mdac1 = *mdac2;
+			*mdac2 = mdac;
+		}	
+}
+
  /* Set label_sector to -1 if rewriting existing label into same sector */
  static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv,
  		     struct dm_list *mdas, int64_t label_sector)
@@ -1305,13 +1333,21 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
  	struct metadata_area *mda;
  	char buf[MDA_HEADER_SIZE] __attribute((aligned(8)));
  	struct mda_header *mdah = (struct mda_header *) buf;
+	struct mda_context *mdac1 = NULL, *mdac2 = NULL;
  	uint64_t adjustment;

  	/* FIXME Test mode don't update cache? */

-	if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
-				  FMT_TEXT_ORPHAN_VG_NAME, NULL, 0)))
-		return_0;
+	if (is_orphan_vg(pv_vg_name(pv))) {		
+		if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
+					  FMT_TEXT_ORPHAN_VG_NAME, NULL, 0)))
+			return_0;
+	}
+	else {
+		if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
+						pv_vg_name(pv), (char *) pv->vgid.uuid, 0)))
+			return_0;
+	}
  	label = info->label;

  	if (label_sector != -1)
@@ -1370,12 +1406,31 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
  	if (!dev_open(pv->dev))
  		return_0;

-	dm_list_iterate_items(mda, &info->mdas) {
-		mdac = mda->metadata_locn;
+	_pv_get_mdacs(pv, &info->mdas, &mdac1, &mdac2);
+
+	/* If PV contains VG, we keep the pointer to current metadata in
+	   circular buffer so the old metadata records won't be overwritten.
+	   We can do this for the first metadata area only, the other ones
+	   could be moved and the pointer information lost. */
+
+	/* first metadata area header */
+	if (mdac1 && is_orphan_vg(pv_vg_name(pv))) {
  		memset(&buf, 0, sizeof(buf));
-		mdah->size = mdac->area.size;
-		if (!_raw_write_mda_header(fmt, mdac->area.dev,
-					   mdac->area.start, mdah)) {
+		mdah->size = mdac1->area.size;
+		if (!_raw_write_mda_header(fmt, mdac1->area.dev,
+					mdac1->area.start, mdah)) {
+			if (!dev_close(pv->dev))
+				stack;
+			return_0;
+		}
+	}
+
+	/* second metadata area header */
+	if (mdac2) {
+		memset(&buf, 0, sizeof(buf));
+		mdah->size = mdac2->area.size;
+		if (!_raw_write_mda_header(fmt, mdac2->area.dev,
+					mdac2->area.start, mdah)) {
  			if (!dev_close(pv->dev))
  				stack;
  			return_0;
@@ -1393,6 +1448,53 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
  	return 1;
  }

+static int _text_pv_resize(const struct format_type *fmt, struct physical_volume *pv,
+				struct volume_group *vg, struct dm_list *mdas, uint64_t new_size)
+{
+	const char *pv_name = pv_dev_name(pv);
+	struct mda_context *mdac1, *mdac2;
+	uint64_t mda_start2 = 0, mda_size2 = 0;
+	uint64_t mda_adjustment, disk_size;
+
+	pv->size = new_size;
+	disk_size = pv->size << SECTOR_SHIFT;
+
+	if (pv->size < pv->pe_start) {
+		log_error("%s: Size must exceed physical extent start of "
+				"%" PRIu64 " sectors.", pv_name, pv->pe_start);
+		return 0;
+	}
+
+	_pv_get_mdacs(pv, mdas, &mdac1, &mdac2);
+
+	if (!mdac1)
+		return 0;
+
+	if (mdac2) {
+		mda_size2 = mdac1->area.size;
+		mda_adjustment = (disk_size - mda_size2) % (pe_align(pv) << SECTOR_SHIFT);	
+		if (mda_adjustment)
+			mda_size2 += mda_adjustment;
+
+		mda_start2 = disk_size - mda_size2;
+
+		if ((mda_start2 >> SECTOR_SHIFT) < pv->pe_start) {
+			log_error("%s: Size must leave space for second "
+					"metadata copy of %" PRIu64 " sectors.",
+					pv_name, mda_size2 >> SECTOR_SHIFT);
+			return 0;
+		}
+
+		mdac2->area.start = mda_start2;
+		mdac2->area.size = mda_size2;
+	}
+
+	if (vg)
+		pv->size -= pv->pe_start + (mda_size2 >> SECTOR_SHIFT);
+
+	return 1;
+}
+
  static int _add_raw(struct dm_list *raw_list, struct device_area *dev_area)
  {
  	struct raw_list *rl;
@@ -1829,6 +1931,7 @@ static struct format_handler _text_handler = {
  	.pv_read = _text_pv_read,
  	.pv_setup = _text_pv_setup,
  	.pv_write = _text_pv_write,
+	.pv_resize = _text_pv_resize,
  	.vg_setup = _text_vg_setup,
  	.lv_setup = _text_lv_setup,
  	.create_instance = _text_create_text_instance,
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 40ece6f..d85c4d3 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -364,10 +364,10 @@ pv_t *pv_create(const struct cmd_context *cmd,
  		      uint32_t existing_extent_size,
  		      int pvmetadatacopies,
  		      uint64_t pvmetadatasize, struct dm_list *mdas);
-int pv_resize(struct physical_volume *pv, struct volume_group *vg,
-             uint32_t new_pe_count);
  int pv_analyze(struct cmd_context *cmd, const char *pv_name,
  	       uint64_t label_sector);
+int pv_resize(struct physical_volume *pv, struct volume_group *vg,
+				 struct dm_list *mdas, uint64_t new_size);

  /* FIXME: move internal to library */
  uint32_t pv_list_extents_free(const struct dm_list *pvh);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index eb6ed45..7285b5b 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -223,6 +223,15 @@ struct format_handler {
  			 int64_t label_sector);

  	/*
+	 * Recalculate existing metadata offsets and sizes if new
+	 * PV size is set. If the PV contains a VG, the PV size is
+	 * decreased by the size of metadata areas.
+	 */
+	int (*pv_resize) (const struct format_type * fmt,
+			 struct physical_volume * pv, struct volume_group * vg,
+			 struct dm_list * mdas, uint64_t new_size);
+
+	/*
  	 * Tweak an already filled out a lv eg, check there
  	 * aren't too many extents.
  	 */
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 1b0a457..d73e204 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -406,22 +406,76 @@ static int _extend_pv(struct physical_volume *pv, struct volume_group *vg,
   * Resize a PV in a VG, adding or removing segments as needed.
   * New size must fit within pv->size.
   */
-int pv_resize(struct physical_volume *pv,
-	      struct volume_group *vg,
-	      uint32_t new_pe_count)
+int pv_resize(struct physical_volume *pv, struct volume_group *vg,
+				struct dm_list *mdas, uint64_t new_size)
  {
-	if ((new_pe_count == pv->pe_count)) {
-		log_verbose("No change to size of physical volume %s.",
-			    pv_dev_name(pv));
-		return 1;
+	const char *pv_name = pv_dev_name(pv);
+	uint32_t new_pe_count = 0;
+
+	if (!pv->fmt->ops->pv_write) {
+		log_error("Format does not support writing physical volumes");
+		return 0;
  	}

-	log_verbose("Resizing physical volume %s from %" PRIu32
-		    " to %" PRIu32 " extents.",
-		    pv_dev_name(pv), pv->pe_count, new_pe_count);
+	if (!pv->fmt->ops->pv_resize) {
+		log_error("Format does not support resizing physical volumes");
+		return 0;
+	}
+
+	if (!pv->fmt->ops->pv_resize(pv->fmt, pv, vg, mdas, new_size)) {
+		log_error("Failed to change physical volume size.");
+		return 0;
+	}
+
+	if (vg) {
+		new_pe_count = pv->size / vg->extent_size;
+		
+		if (!new_pe_count) {
+			log_error("%s: Size must leave space for at "
+					"least one physical extent of "
+					"%" PRIu32 " sectors.", pv_name, pv_pe_size(pv));
+			return 0;
+		}
+
+		if ((new_pe_count == pv->pe_count)) {
+			log_verbose("No change to size of physical volume %s.",
+					pv_dev_name(pv));
+			return 1;
+		}
+
+		log_verbose("Resizing physical volume %s from %" PRIu32
+					" to %" PRIu32 " extents.",
+					pv_dev_name(pv), pv->pe_count, new_pe_count);
+
+		if (new_pe_count > pv->pe_count) {
+			if (!_extend_pv(pv, vg, new_pe_count))
+				return 0;
+		}
+		else {
+			if (!_reduce_pv(pv, vg, new_pe_count))
+				return 0;
+		}
+	}
+
+	if (!pv->fmt->ops->pv_write(pv->fmt, pv, mdas, INT64_C(-1))) {
+		log_error("Failed to write physical volume.");
+		return 0;
+	}	
+
+	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
+				pv_name, pv_size(pv));
+
+	log_verbose("Updating physical volume \"%s\"", pv_name);
+
+	if (vg) {
+		if (!vg_write(vg) || !vg_commit(vg)) {
+			log_error("Failed to store physical volume \"%s\" in "
+					"volume group \"%s\"", pv_name, vg->name);
+			return 0;
+		}
+		backup(vg);
+	}
+
+	return 1;

-	if (new_pe_count > pv->pe_count)
-		return _extend_pv(pv, vg, new_pe_count);
-	else
-		return _reduce_pv(pv, vg, new_pe_count);
  }
diff --git a/tools/pvresize.c b/tools/pvresize.c
index c9665b2..3a1cf0c 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -31,12 +31,9 @@ static int _pv_resize_single(struct cmd_context *cmd,
  	struct pv_list *pvl;
  	int consistent = 1;
  	uint64_t size = 0;
-	uint32_t new_pe_count = 0;
  	struct dm_list mdas;
  	const char *pv_name = pv_dev_name(pv);
  	const char *vg_name;
-	struct lvmcache_info *info;
-	int mda_count = 0;

  	dm_list_init(&mdas);

@@ -52,8 +49,6 @@ static int _pv_resize_single(struct cmd_context *cmd,
  			log_error("Unable to read PV \"%s\"", pv_name);
  			return 0;
  		}
-
-		mda_count = dm_list_size(&mdas);
  	} else {
  		vg_name = pv_vg_name(pv);

@@ -83,26 +78,10 @@ static int _pv_resize_single(struct cmd_context *cmd,

  		pv = pvl->pv;

-		if (!(info = info_from_pvid(pv->dev->pvid, 0))) {
-			unlock_vg(cmd, vg_name);
-			log_error("Can't get info for PV %s in volume group %s",
-				  pv_name, vg->name);
-			return 0;
-		}
-
-		mda_count = dm_list_size(&info->mdas);
-
  		if (!archive(vg))
  			return 0;
  	}

-	/* FIXME Create function to test compatibility properly */
-	if (mda_count > 1) {
-		log_error("%s: too many metadata areas for pvresize", pv_name);
-		unlock_vg(cmd, vg_name);
-		return 0;
-	}
-
  	if (!(pv->fmt->features & FMT_RESIZE_PV)) {
  		log_error("Physical volume %s format does not support resizing.",
  			  pv_name);
@@ -133,58 +112,23 @@ static int _pv_resize_single(struct cmd_context *cmd,
  		return 0;
  	}

-	if (size < pv_pe_start(pv)) {
-		log_error("%s: Size must exceed physical extent start of "
-			  "%" PRIu64 " sectors.", pv_name, pv_pe_start(pv));
-		unlock_vg(cmd, vg_name);
-		return 0;
-	}
-
-	pv->size = size;
-
-	if (vg) {
-		pv->size -= pv_pe_start(pv);
-		new_pe_count = pv_size(pv) / vg->extent_size;
-		
- 		if (!new_pe_count) {
-			log_error("%s: Size must leave space for at "
-				  "least one physical extent of "
-				  "%" PRIu32 " sectors.", pv_name,
-				  pv_pe_size(pv));
+	if (is_orphan_vg(pv_vg_name(pv))) {
+		if (!pv_resize(pv, NULL, &mdas, size)) {
  			unlock_vg(cmd, vg_name);
  			return 0;
  		}
-
-		if (!pv_resize(pv, vg, new_pe_count)) {
-			unlock_vg(cmd, vg_name);
-			return_0;
-		}
  	}
-
-	log_verbose("Resizing volume \"%s\" to %" PRIu64 " sectors.",
-		    pv_name, pv_size(pv));
-
-	log_verbose("Updating physical volume \"%s\"", pv_name);
-	if (!is_orphan_vg(pv_vg_name(pv))) {
-		if (!vg_write(vg) || !vg_commit(vg)) {
-			unlock_vg(cmd, pv_vg_name(pv));
-			log_error("Failed to store physical volume \"%s\" in "
-				  "volume group \"%s\"", pv_name, vg->name);
-			return 0;
-		}
-		backup(vg);
-		unlock_vg(cmd, vg_name);
-	} else {
-		if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
-			unlock_vg(cmd, VG_ORPHANS);
-			log_error("Failed to store physical volume \"%s\"",
-				  pv_name);
+	else {
+		if (!pv_resize(pv, vg, &vg->fid->metadata_areas, size)) {
+			unlock_vg(cmd, vg_name);
  			return 0;
  		}
-		unlock_vg(cmd, vg_name);
  	}

+	unlock_vg(cmd, vg_name);
+
  	log_print("Physical volume \"%s\" changed", pv_name);
+
  	return 1;
  }



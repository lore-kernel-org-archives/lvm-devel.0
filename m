From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 18 Nov 2010 22:32:22 +0100
Subject: [PATCH 08/11] Cleanup pv_write to use recent changes in metadata handling interface.
In-Reply-To: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
References: <1290115945-27419-1-git-send-email-prajnoha@redhat.com>
Message-ID: <1290115945-27419-9-git-send-email-prajnoha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Well, pv_write is now quite short and clean when using all the changes
and I hope (maybe 'pray' is a better word :)) I haven't removed anything
important. Also, I hope that everything that should be calculated was
calculated in the code before and eveything is in its place.

Please, double-check me, triple-check me, ... :)

Signed-off-by: Peter Rajnoha <prajnoha@redhat.com>
---
 lib/format1/format1.c            |   14 +----
 lib/format_text/format-text.c    |  114 +------------------------------------
 lib/metadata/metadata-exported.h |    3 +-
 lib/metadata/metadata.c          |   11 ++--
 lib/metadata/metadata.h          |    3 +-
 tools/pvchange.c                 |    4 +-
 tools/pvresize.c                 |    2 +-
 tools/vgconvert.c                |    4 +-
 tools/vgreduce.c                 |    2 +-
 9 files changed, 17 insertions(+), 140 deletions(-)

diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index b2e4aaf..e8b15fe 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -451,23 +451,11 @@ static int _format1_lv_setup(struct format_instance *fid, struct logical_volume
 	return 1;
 }
 
-static int _format1_pv_write(const struct format_type *fmt, struct physical_volume *pv,
-		     struct dm_list *mdas __attribute__((unused)), int64_t sector __attribute__((unused)))
+static int _format1_pv_write(const struct format_type *fmt, struct physical_volume *pv)
 {
 	struct dm_pool *mem;
 	struct disk_list *dl;
 	struct dm_list pvs;
-	struct label *label;
-	struct lvmcache_info *info;
-
-	if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
-				  pv->vg_name, NULL, 0)))
-		return_0;
-	label = info->label;
-	info->device_size = pv->size << SECTOR_SHIFT;
-	info->fmt = fmt;
-
-	dm_list_init(&info->mdas);
 
 	dm_list_init(&pvs);
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index c7f5d5a..7481d80 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1247,129 +1247,23 @@ static int _text_scan(const struct format_type *fmt)
 }
 
 /* Only for orphans */
-/* Set label_sector to -1 if rewriting existing label into same sector */
-/* If mdas is supplied it overwrites existing mdas e.g. used with pvcreate */
-static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv,
-		     struct dm_list *mdas, int64_t label_sector)
+static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv)
 {
-	struct label *label;
 	struct lvmcache_info *info;
 	struct mda_context *mdac;
 	struct metadata_area *mda;
 	char buf[MDA_HEADER_SIZE] __attribute__((aligned(8)));
 	struct mda_header *mdah = (struct mda_header *) buf;
-	uint64_t adjustment;
-	struct data_area_list *da;
 
-	/* FIXME Test mode don't update cache? */
-
-	if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
-				  FMT_TEXT_ORPHAN_VG_NAME, NULL, 0)))
+	if (!(info = info_from_pvid((char *) &pv->id, 0)))
 		return_0;
-	label = info->label;
-
-	if (label_sector != -1)
-		label->sector = label_sector;
-
-	info->device_size = pv->size << SECTOR_SHIFT;
-	info->fmt = fmt;
-
-	/* If mdas supplied, use them regardless of existing ones, */
-	/* otherwise retain existing ones */
-	if (mdas) {
-		if (info->mdas.n)
-			del_mdas(&info->mdas);
-		else
-			dm_list_init(&info->mdas);
-		dm_list_iterate_items(mda, mdas) {
-			mdac = mda->metadata_locn;
-			log_debug("Creating metadata area on %s at sector %"
-				  PRIu64 " size %" PRIu64 " sectors",
-				  dev_name(mdac->area.dev),
-				  mdac->area.start >> SECTOR_SHIFT,
-				  mdac->area.size >> SECTOR_SHIFT);
-			add_mda(fmt, NULL, &info->mdas, mdac->area.dev,
-				mdac->area.start, mdac->area.size, mda_is_ignored(mda));
-		}
-		/* FIXME Temporary until mda creation supported by tools */
-	} else if (!info->mdas.n) {
-		dm_list_init(&info->mdas);
-	}
 
-	/*
-	 * If no pe_start supplied but PV already exists,
-	 * get existing value; use-cases include:
-	 * - pvcreate on PV without prior pvremove
-	 * - vgremove on VG with PV(s) that have pe_start=0 (hacked cfg)
-	 */
 	if (info->das.n) {
-		if (!pv->pe_start)
-			dm_list_iterate_items(da, &info->das)
-				pv->pe_start = da->disk_locn.offset >> SECTOR_SHIFT;
 		del_das(&info->das);
 	} else
 		dm_list_init(&info->das);
 
-#if 0
-	/*
-	 * FIXME: ideally a pre-existing pe_start seen in .pv_write
-	 * would always be preserved BUT 'pvcreate on PV without prior pvremove'
-	 * could easily cause the pe_start to overlap with the first mda!
-	 */
-	if (pv->pe_start) {
-		log_very_verbose("%s: preserving pe_start=%lu",
-				 pv_dev_name(pv), pv->pe_start);
-		goto preserve_pe_start;
-	}
-#endif
-
-	/*
-	 * If pe_start is still unset, set it to first aligned
-	 * sector after any metadata areas that begin before pe_start.
-	 */
-	if (!pv->pe_start) {
-		pv->pe_start = pv->pe_align;
-		if (pv->pe_align_offset)
-			pv->pe_start += pv->pe_align_offset;
-	}
-	dm_list_iterate_items(mda, &info->mdas) {
-		mdac = (struct mda_context *) mda->metadata_locn;
-		if (pv->dev == mdac->area.dev &&
-		    ((mdac->area.start <= (pv->pe_start << SECTOR_SHIFT)) ||
-		    (mdac->area.start <= lvm_getpagesize() &&
-		     pv->pe_start < (lvm_getpagesize() >> SECTOR_SHIFT))) &&
-		    (mdac->area.start + mdac->area.size >
-		     (pv->pe_start << SECTOR_SHIFT))) {
-			pv->pe_start = (mdac->area.start + mdac->area.size)
-			    >> SECTOR_SHIFT;
-			/* Adjust pe_start to: (N * pe_align) + pe_align_offset */
-			if (pv->pe_align) {
-				adjustment =
-				(pv->pe_start - pv->pe_align_offset) % pv->pe_align;
-				if (adjustment)
-					pv->pe_start += (pv->pe_align - adjustment);
-
-				log_very_verbose("%s: setting pe_start=%" PRIu64
-					 " (orig_pe_start=%" PRIu64 ", "
-					 "pe_align=%lu, pe_align_offset=%lu, "
-					 "adjustment=%" PRIu64 ")",
-					 pv_dev_name(pv), pv->pe_start,
-					 (adjustment ?
-					  pv->pe_start - (pv->pe_align - adjustment) :
-					  pv->pe_start),
-					 pv->pe_align, pv->pe_align_offset, adjustment);
-			}
-		}
-	}
-	if (pv->pe_start >= pv->size) {
-		log_error("Data area is beyond end of device %s!",
-			  pv_dev_name(pv));
-		return 0;
-	}
-
-	/* FIXME: preserve_pe_start: */
-	if (!add_da
-	    (NULL, &info->das, pv->pe_start << SECTOR_SHIFT, UINT64_C(0)))
+	if (!add_da(NULL, &info->das, pv->pe_start << SECTOR_SHIFT, UINT64_C(0)))
 		return_0;
 
 	if (!dev_open(pv->dev))
@@ -1388,7 +1282,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 		}
 	}
 
-	if (!label_write(pv->dev, label)) {
+	if (!label_write(pv->dev, info->label)) {
 		dev_close(pv->dev);
 		return_0;
 	}
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index dab953d..850a4ca 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -359,8 +359,7 @@ struct dm_list *get_vgnames(struct cmd_context *cmd, int include_internal);
 struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal);
 int scan_vgs_for_pvs(struct cmd_context *cmd);
 
-int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
-	     struct dm_list *mdas, int64_t label_sector);
+int pv_write(struct cmd_context *cmd, struct physical_volume *pv);
 int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 	    const char *pv_name);
 int move_pvs_used_by_lv(struct volume_group *vg_from,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 30b79f8..be1e7c5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -585,7 +585,7 @@ int vg_remove(struct volume_group *vg)
 		}
 
 		/* FIXME Write to same sector label was read from */
-		if (!pv_write(vg->cmd, pv, NULL, INT64_C(-1))) {
+		if (!pv_write(vg->cmd, pv)) {
 			log_error("Failed to remove physical volume \"%s\""
 				  " from volume group \"%s\"",
 				  pv_dev_name(pv), vg->name);
@@ -1503,7 +1503,7 @@ struct physical_volume * pvcreate_single(struct cmd_context *cmd,
 	log_very_verbose("Writing physical volume data to disk \"%s\"",
 			 pv_name);
 
-	if (!(pv_write(cmd, pv, &mdas, pp->labelsector))) {
+	if (!(pv_write(cmd, pv))) {
 		log_error("Failed to write physical volume \"%s\"", pv_name);
 		goto error;
 	}
@@ -3403,8 +3403,7 @@ int scan_vgs_for_pvs(struct cmd_context *cmd)
 }
 
 int pv_write(struct cmd_context *cmd __attribute__((unused)),
-	     struct physical_volume *pv,
-	     struct dm_list *mdas, int64_t label_sector)
+	     struct physical_volume *pv)
 {
 	if (!pv->fmt->ops->pv_write) {
 		log_error("Format does not support writing physical volumes");
@@ -3417,7 +3416,7 @@ int pv_write(struct cmd_context *cmd __attribute__((unused)),
 		return 0;
 	}
 
-	if (!pv->fmt->ops->pv_write(pv->fmt, pv, mdas, label_sector))
+	if (!pv->fmt->ops->pv_write(pv->fmt, pv))
 		return_0;
 
 	return 1;
@@ -3436,7 +3435,7 @@ int pv_write_orphan(struct cmd_context *cmd, struct physical_volume *pv)
 		return 0;
 	}
 
-	if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
+	if (!pv_write(cmd, pv)) {
 		log_error("Failed to clear metadata from physical "
 			  "volume \"%s\" after removal from \"%s\"",
 			  pv_dev_name(pv), old_vg_name);
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 6e01b17..5962b38 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -279,8 +279,7 @@ struct format_handler {
 	 * pv->vg_name must be a valid orphan VG name
 	 */
 	int (*pv_write) (const struct format_type * fmt,
-			 struct physical_volume * pv, struct dm_list * mdas,
-			 int64_t label_sector);
+			 struct physical_volume * pv);
 
 	/*
 	 * Tweak an already filled out a lv eg, check there
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 02d3510..2633da2 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -160,7 +160,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 
 			pv->vg_name = pv->fmt->orphan_vg_name;
 			pv->pe_alloc_count = 0;
-			if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
+			if (!(pv_write(cmd, pv))) {
 				log_error("pv_write with new uuid failed "
 					  "for %s.", pv_name);
 				goto out;
@@ -182,7 +182,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 			goto out;
 		}
 		backup(vg);
-	} else if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
+	} else if (!(pv_write(cmd, pv))) {
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
 		goto out;
diff --git a/tools/pvresize.c b/tools/pvresize.c
index af499e5..b39f94c 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -152,7 +152,7 @@ static int _pv_resize_single(struct cmd_context *cmd,
 			goto out;
 		}
 		backup(vg);
-	} else if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
+	} else if (!(pv_write(cmd, pv))) {
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
 		goto out;
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index db28710..2043500 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -155,9 +155,7 @@ static int vgconvert_single(struct cmd_context *cmd, const char *vg_name,
 
 		log_very_verbose("Writing physical volume data to disk \"%s\"",
 				 pv_dev_name(pv));
-		if (!(pv_write(cmd, pv, &mdas,
-			       arg_int64_value(cmd, labelsector_ARG,
-					       DEFAULT_LABELSECTOR)))) {
+		if (!(pv_write(cmd, pv))) {
 			log_error("Failed to write physical volume \"%s\"",
 				  pv_dev_name(pv));
 			log_error("Use pvcreate and vgcfgrestore to repair "
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index eceafcd..7e1380a 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -438,7 +438,7 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 		goto bad;
 	}
 
-	if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
+	if (!pv_write(cmd, pv)) {
 		log_error("Failed to clear metadata from physical "
 			  "volume \"%s\" "
 			  "after removal from \"%s\"", name, vg->name);
-- 
1.7.3.2



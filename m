From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 12:26:29 -0000
Subject: LVM2 lib/format1/format1.c lib/format_text/for ...
Message-ID: <20110221122629.4340.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 12:26:28

Modified files:
	lib/format1    : format1.c 
	lib/format_text: format-text.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	tools          : pvchange.c pvresize.c vgconvert.c vgreduce.c 

Log message:
	Change pv_write code to work with the changes in metadata handling interface
	and changes in format_instance.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.131&r2=1.132
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.163&r2=1.164
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.179&r2=1.180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.431&r2=1.432
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.237&r2=1.238
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvresize.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgconvert.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107

--- LVM2/lib/format1/format1.c	2011/02/21 12:24:15	1.131
+++ LVM2/lib/format1/format1.c	2011/02/21 12:26:27	1.132
@@ -426,8 +426,7 @@
 	return 1;
 }
 
-static int _format1_pv_write(const struct format_type *fmt, struct physical_volume *pv,
-		     struct dm_list *mdas __attribute__((unused)), int64_t sector __attribute__((unused)))
+static int _format1_pv_write(const struct format_type *fmt, struct physical_volume *pv)
 {
 	struct dm_pool *mem;
 	struct disk_list *dl;
--- LVM2/lib/format_text/format-text.c	2011/02/21 12:25:16	1.163
+++ LVM2/lib/format_text/format-text.c	2011/02/21 12:26:27	1.164
@@ -1256,60 +1256,81 @@
 }
 
 /* Only for orphans */
-/* Set label_sector to -1 if rewriting existing label into same sector */
-/* If mdas is supplied it overwrites existing mdas e.g. used with pvcreate */
-static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv,
-		     struct dm_list *mdas, int64_t label_sector)
+static int _text_pv_write(const struct format_type *fmt, struct physical_volume *pv)
 {
+	struct text_fid_pv_context *fid_pv_tc;
+	struct format_instance *fid = pv->fid;
 	struct label *label;
+	int64_t label_sector;
 	struct lvmcache_info *info;
 	struct mda_context *mdac;
 	struct metadata_area *mda;
+	unsigned mda_index;
 	char buf[MDA_HEADER_SIZE] __attribute__((aligned(8)));
 	struct mda_header *mdah = (struct mda_header *) buf;
-	uint64_t adjustment;
 	struct data_area_list *da;
 
-	/* FIXME Test mode don't update cache? */
-
-	if (!(info = lvmcache_add(fmt->labeller, (char *) &pv->id, pv->dev,
-				  FMT_TEXT_ORPHAN_VG_NAME, NULL, 0)))
+	/* Add a new cache entry with PV info or update existing one. */
+	if (!(info = lvmcache_add(fmt->labeller, (const char *) &pv->id,
+			pv->dev, FMT_TEXT_ORPHAN_VG_NAME, NULL, 0)))
 		return_0;
+
 	label = info->label;
 
-	if (label_sector != -1)
+	/*
+	 * We can change the label sector for a
+	 * plain PV that is not part of a VG only!
+	 */
+	if (fid && (!fid->type & FMT_INSTANCE_VG) &&
+	    (fid_pv_tc = (struct text_fid_pv_context *) pv->fid->private) &&
+	    ((label_sector = fid_pv_tc->label_sector) != -1))
 		label->sector = label_sector;
 
 	info->device_size = pv->size << SECTOR_SHIFT;
 	info->fmt = fmt;
 
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
+	/* Flush all cached metadata areas, we will reenter new/modified ones. */
+	if (info->mdas.n)
+		del_mdas(&info->mdas);
+	else
 		dm_list_init(&info->mdas);
+
+	/*
+	 * Add all new or modified metadata areas for this PV stored in
+	 * its format instance. If this PV is not part of a VG yet,
+	 * pv->fid will be used. Otherwise pv->vg->fid will be used.
+	 * The fid_get_mda_indexed fn can handle that transparently,
+	 * just pass the right format_instance in.
+	 */
+	for (mda_index = 0; mda_index < FMT_TEXT_MAX_MDAS_PER_PV; mda_index++) {
+		if (!(mda = fid_get_mda_indexed(fid, (const char *) &pv->id,
+							ID_LEN, mda_index)))
+			continue;
+
+		mdac = (struct mda_context *) mda->metadata_locn;
+		log_debug("Creating metadata area on %s at sector %"
+			  PRIu64 " size %" PRIu64 " sectors",
+			  dev_name(mdac->area.dev),
+			  mdac->area.start >> SECTOR_SHIFT,
+			  mdac->area.size >> SECTOR_SHIFT);
+		add_mda(fmt, NULL, &info->mdas, mdac->area.dev,
+			mdac->area.start, mdac->area.size, mda_is_ignored(mda));
 	}
 
 	/*
-	 * If no pe_start supplied but PV already exists,
-	 * get existing value; use-cases include:
-	 * - pvcreate on PV without prior pvremove
-	 * - vgremove on VG with PV(s) that have pe_start=0 (hacked cfg)
+	 * FIXME: Allow writing zero offset/size data area to disk.
+	 *        This requires defining a special value since we can't
+	 *        write offset/size that is 0/0 - this is already reserved
+	 *        as a delimiter in data/metadata area area list in PV header
+	 *        (needs exploring compatibility with older lvm2).
+	 */
+
+	/*
+	 * We can't actually write pe_start = 0 (a data area offset)
+	 * in PV header now. We need to replace this value here. This can
+	 * happen with vgcfgrestore with redefined pe_start or
+	 * pvcreate --restorefile. However, we can can have this value in
+	 * metadata which will override the value in the PV header.
 	 */
 	if (info->das.n) {
 		if (!pv->pe_start)
@@ -1319,66 +1340,7 @@
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
@@ -1397,11 +1359,17 @@
 		}
 	}
 
-	if (!label_write(pv->dev, label)) {
+	if (!label_write(pv->dev, info->label)) {
 		dev_close(pv->dev);
 		return_0;
 	}
 
+	/*
+	 *  FIXME: We should probably use the format instance's metadata
+	 *        areas for label_write and only if it's successful,
+	 *        update the cache afterwards?
+	 */
+
 	if (!dev_close(pv->dev))
 		return_0;
 
--- LVM2/lib/metadata/metadata-exported.h	2011/02/21 12:24:17	1.179
+++ LVM2/lib/metadata/metadata-exported.h	2011/02/21 12:26:27	1.180
@@ -384,8 +384,7 @@
 struct dm_list *get_vgids(struct cmd_context *cmd, int include_internal);
 int scan_vgs_for_pvs(struct cmd_context *cmd, int warnings);
 
-int pv_write(struct cmd_context *cmd, struct physical_volume *pv,
-	     struct dm_list *mdas, int64_t label_sector);
+int pv_write(struct cmd_context *cmd, struct physical_volume *pv);
 int move_pv(struct volume_group *vg_from, struct volume_group *vg_to,
 	    const char *pv_name);
 int move_pvs_used_by_lv(struct volume_group *vg_from,
--- LVM2/lib/metadata/metadata.c	2011/02/21 12:24:17	1.431
+++ LVM2/lib/metadata/metadata.c	2011/02/21 12:26:27	1.432
@@ -586,7 +586,7 @@
 		}
 
 		/* FIXME Write to same sector label was read from */
-		if (!pv_write(vg->cmd, pv, NULL, INT64_C(-1))) {
+		if (!pv_write(vg->cmd, pv)) {
 			log_error("Failed to remove physical volume \"%s\""
 				  " from volume group \"%s\"",
 				  pv_dev_name(pv), vg->name);
@@ -1511,7 +1511,7 @@
 	log_very_verbose("Writing physical volume data to disk \"%s\"",
 			 pv_name);
 
-	if (!(pv_write(cmd, pv, &mdas, pp->labelsector))) {
+	if (!(pv_write(cmd, pv))) {
 		log_error("Failed to write physical volume \"%s\"", pv_name);
 		goto error;
 	}
@@ -3536,8 +3536,7 @@
 }
 
 int pv_write(struct cmd_context *cmd __attribute__((unused)),
-	     struct physical_volume *pv,
-	     struct dm_list *mdas, int64_t label_sector)
+	     struct physical_volume *pv)
 {
 	if (!pv->fmt->ops->pv_write) {
 		log_error("Format does not support writing physical volumes");
@@ -3550,7 +3549,7 @@
 		return 0;
 	}
 
-	if (!pv->fmt->ops->pv_write(pv->fmt, pv, mdas, label_sector))
+	if (!pv->fmt->ops->pv_write(pv->fmt, pv))
 		return_0;
 
 	return 1;
@@ -3569,7 +3568,7 @@
 		return 0;
 	}
 
-	if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
+	if (!pv_write(cmd, pv)) {
 		log_error("Failed to clear metadata from physical "
 			  "volume \"%s\" after removal from \"%s\"",
 			  pv_dev_name(pv), old_vg_name);
--- LVM2/lib/metadata/metadata.h	2011/02/21 12:24:17	1.237
+++ LVM2/lib/metadata/metadata.h	2011/02/21 12:26:27	1.238
@@ -297,8 +297,7 @@
 	 * pv->vg_name must be a valid orphan VG name
 	 */
 	int (*pv_write) (const struct format_type * fmt,
-			 struct physical_volume * pv, struct dm_list * mdas,
-			 int64_t label_sector);
+			 struct physical_volume * pv);
 
 	/*
 	 * Tweak an already filled out a lv eg, check there
--- LVM2/tools/pvchange.c	2011/01/24 13:38:32	1.88
+++ LVM2/tools/pvchange.c	2011/02/21 12:26:28	1.89
@@ -139,7 +139,7 @@
 
 			pv->vg_name = pv->fmt->orphan_vg_name;
 			pv->pe_alloc_count = 0;
-			if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
+			if (!(pv_write(cmd, pv))) {
 				log_error("pv_write with new uuid failed "
 					  "for %s.", pv_name);
 				return 0;
@@ -161,7 +161,7 @@
 			return 0;
 		}
 		backup(vg);
-	} else if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
+	} else if (!(pv_write(cmd, pv))) {
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
 		return 0;
--- LVM2/tools/pvresize.c	2011/02/21 12:16:00	1.39
+++ LVM2/tools/pvresize.c	2011/02/21 12:26:28	1.40
@@ -150,7 +150,7 @@
 			goto out;
 		}
 		backup(vg);
-	} else if (!(pv_write(cmd, pv, NULL, INT64_C(-1)))) {
+	} else if (!(pv_write(cmd, pv))) {
 		log_error("Failed to store physical volume \"%s\"",
 			  pv_name);
 		goto out;
--- LVM2/tools/vgconvert.c	2011/02/21 12:24:17	1.46
+++ LVM2/tools/vgconvert.c	2011/02/21 12:26:28	1.47
@@ -154,9 +154,7 @@
 
 		log_very_verbose("Writing physical volume data to disk \"%s\"",
 				 pv_dev_name(pv));
-		if (!(pv_write(cmd, pv, &mdas,
-			       arg_int64_value(cmd, labelsector_ARG,
-					       DEFAULT_LABELSECTOR)))) {
+		if (!(pv_write(cmd, pv))) {
 			log_error("Failed to write physical volume \"%s\"",
 				  pv_dev_name(pv));
 			log_error("Use pvcreate and vgcfgrestore to repair "
--- LVM2/tools/vgreduce.c	2011/02/18 14:47:31	1.106
+++ LVM2/tools/vgreduce.c	2011/02/21 12:26:28	1.107
@@ -438,7 +438,7 @@
 		goto bad;
 	}
 
-	if (!pv_write(cmd, pv, NULL, INT64_C(-1))) {
+	if (!pv_write(cmd, pv)) {
 		log_error("Failed to clear metadata from physical "
 			  "volume \"%s\" "
 			  "after removal from \"%s\"", name, vg->name);



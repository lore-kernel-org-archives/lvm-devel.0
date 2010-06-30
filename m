From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2010 13:51:15 -0000
Subject: LVM2/lib format_text/format-text.c format_text ...
Message-ID: <20100630135115.10478.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-30 13:51:13

Modified files:
	lib/format_text: format-text.c text_label.c 
	lib/metadata   : metadata.c metadata.h 

Log message:
	Improve various log messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.368&r2=1.369
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.213&r2=1.214

--- LVM2/lib/format_text/format-text.c	2010/06/30 12:17:24	1.137
+++ LVM2/lib/format_text/format-text.c	2010/06/30 13:51:11	1.138
@@ -1642,14 +1642,19 @@
 /*
  * Return a string description of the metadata location.
  */
-static const char * _metadata_locn_desc_raw(void *metadata_locn)
+static const char *_metadata_locn_name_raw(void *metadata_locn)
 {
-	struct mda_context *mdac;
+	struct mda_context *mdac = (struct mda_context *) metadata_locn;
 
-	mdac = (struct mda_context *) metadata_locn;
 	return dev_name(mdac->area.dev);
 }
 
+static uint64_t const _metadata_locn_offset_raw(void *metadata_locn)
+{
+	struct mda_context *mdac = (struct mda_context *) metadata_locn;
+
+	return mdac->area.start;
+}
 
 static int _text_pv_read(const struct format_type *fmt, const char *pv_name,
 		    struct physical_volume *pv, struct dm_list *mdas,
@@ -1743,7 +1748,8 @@
 	.vg_commit = _vg_commit_raw,
 	.vg_revert = _vg_revert_raw,
 	.mda_metadata_locn_copy = _metadata_locn_copy_raw,
-	.mda_metadata_locn_desc = _metadata_locn_desc_raw,
+	.mda_metadata_locn_name = _metadata_locn_name_raw,
+	.mda_metadata_locn_offset = _metadata_locn_offset_raw,
 	.mda_free_sectors = _mda_free_sectors_raw,
 	.mda_total_sectors = _mda_total_sectors_raw,
 	.mda_in_vg = _mda_in_vg_raw,
--- LVM2/lib/format_text/text_label.c	2010/06/30 12:17:24	1.34
+++ LVM2/lib/format_text/text_label.c	2010/06/30 13:51:11	1.35
@@ -314,10 +314,10 @@
 		mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
 		if (mda_is_ignored(mda)) {
-			log_verbose("Skipping mda with ignored flag on "
-				    "device %s at offset %"PRIu64,
-				    dev_name(mdac->area.dev),
-				    mdac->area.start);
+			log_debug("Skipping mda with ignored flag on "
+				  "device %s at offset %"PRIu64,
+				  dev_name(mdac->area.dev),
+				  mdac->area.start);
 			if (!dev_close(mdac->area.dev))
 				stack;
 			continue;
--- LVM2/lib/metadata/metadata.c	2010/06/30 12:17:24	1.368
+++ LVM2/lib/metadata/metadata.c	2010/06/30 13:51:13	1.369
@@ -58,8 +58,6 @@
 static uint32_t _vg_bad_status_bits(const struct volume_group *vg,
 				    uint64_t status);
 
-static int _vg_adjust_ignored_mdas(struct volume_group *vg);
-
 const char _really_init[] =
     "Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ";
 
@@ -1011,10 +1009,13 @@
 {
 	struct metadata_area *mda;
 
-	log_verbose("Setting ignore flag for %"PRIu32" mdas on vg %s",
-		    num_to_ignore, vg->name);
+	log_debug("Adjusting ignored mdas on vg %s: %" PRIu32 " mdas in use "
+		  "but %" PRIu32 " required.  Changing %" PRIu32 " flags.",
+		  vg->name, vg_mda_copies(vg), vg_mda_used_count(vg), num_to_ignore);
+
 	if (!num_to_ignore)
 		return 1;
+
 	/* FIXME: flip bits on random mdas */
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (!mda_is_ignored(mda)) {
@@ -1024,8 +1025,10 @@
 		if (!num_to_ignore)
 			return 1;
 	}
-	log_error("Unable to find %"PRIu32" metadata areas to ignore "
+
+	log_error(INTERNAL_ERROR "Unable to find %"PRIu32" metadata areas to ignore "
 		  "on volume group %s", num_to_ignore, vg->name);
+
 	return 0;
 }
 
@@ -1033,11 +1036,14 @@
 {
 	struct metadata_area *mda, *tmda;
 
-	log_verbose("Clearing ignore flag for %"PRIu32" mdas on vg %s",
-		    num_to_unignore, vg->name);
 	if (!num_to_unignore)
 		return 1;
-	/* FIXME: flip bits on random mdas */
+
+	log_debug("Adjusting ignored mdas on vg %s: %" PRIu32 " mdas in use "
+		  "but %" PRIu32 " required.  Changing %" PRIu32 " flags.",
+		  vg->name, vg_mda_copies(vg), vg_mda_used_count(vg), num_to_unignore);
+
+	/* FIXME: Select mdas to change at random */
 	dm_list_iterate_items_safe(mda, tmda, &vg->fid->metadata_areas_ignored) {
 		if (mda_is_ignored(mda)) {
 			mda_set_ignored(mda, 0);
@@ -1048,6 +1054,7 @@
 		if (!num_to_unignore)
 			return 1;
 	}
+
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (mda_is_ignored(mda)) {
 			mda_set_ignored(mda, 0);
@@ -1056,8 +1063,10 @@
 		if (!num_to_unignore)
 			return 1;
 	}
-	log_error("Unable to find %"PRIu32" metadata areas to un-ignore "
-		  "on volume group %s", num_to_unignore, vg->name);
+
+	log_error(INTERNAL_ERROR "Unable to find %"PRIu32" metadata areas to unignore "
+		 "on volume group %s", num_to_unignore, vg->name);
+
 	return 0;
 }
 
@@ -1067,15 +1076,12 @@
 	int ret = 1;
 
 	mda_copies = vg_mda_used_count(vg);
-	log_verbose("Adjusting ignored mdas on vg %s, vg_mda_used_count=%"
-		    PRIu32", vg_mda_copies=%"PRIu32,
-		    vg->name, mda_copies, vg_mda_copies(vg));
 	if (vg->mda_copies == VGMETADATACOPIES_UNMANAGED)
 		goto skip_adjust;
 
-	if (mda_copies > vg->mda_copies) {
+	if (mda_copies > vg->mda_copies)
 		ret = _vg_ignore_mdas(vg, mda_copies - vg->mda_copies);
-	} else if (mda_copies < vg->mda_copies) {
+	else if (mda_copies < vg->mda_copies) {
 		/* not an error to have vg_mda_count larger than total mdas */
 		if (vg->mda_copies >= vg_mda_count(vg))
 			count = vg_mda_count(vg) - vg_mda_used_count(vg);
@@ -1083,6 +1089,7 @@
 			count = vg->mda_copies - mda_copies;
 		ret = _vg_unignore_mdas(vg, count);
 	}
+
 	/*
 	 * The VGMETADATACOPIES_ALL value will never be written disk.
 	 * It is a special cmdline value that means 2 things:
@@ -1093,7 +1100,7 @@
 		vg->mda_copies = VGMETADATACOPIES_UNMANAGED;
 
 	if (!ret)
-		return ret;
+		return_0;
 
 skip_adjust:
 	/*
@@ -1104,10 +1111,13 @@
 	 * below check and retain correctness.
 	 */
 	if (!dm_list_size(&vg->fid->metadata_areas_in_use) ||
-	    !vg_mda_used_count(vg)) {
+	    !vg_mda_used_count(vg))
 		ret = _vg_unignore_mdas(vg, 1);
-	}
-	return ret;
+
+	if (!ret)
+		return_0;
+
+	return 1;
 }
 
 uint32_t vg_mda_copies(const struct volume_group *vg)
@@ -1115,16 +1125,19 @@
 	return vg->mda_copies;
 }
 
-int vg_set_mda_copies(struct volume_group *vg, uint32_t copies)
+int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies)
 {
 	/* FIXME: add checks, etc, and set the value */
 	/*
 	 * FIXME: Before we set a larger value, we may need to
 	 * enable some mdas on PVS
 	 */
-	vg->mda_copies = copies;
-	log_verbose("Setting mda_copies = %"PRIu32" on vg %s",
-		    copies, vg->name);
+	vg->mda_copies = mda_copies;
+
+	/* FIXME Use log_verbose when this is due to specific cmdline request. */
+	log_debug("Setting mda_copies to %"PRIu32" for VG %s",
+		    mda_copies, vg->name);
+
 	return 1;
 }
 
@@ -2528,7 +2541,8 @@
 		return 0;
 	}
 
-	_vg_adjust_ignored_mdas(vg);
+	if (!_vg_adjust_ignored_mdas(vg))
+		return_0;
 
 	if (dm_list_empty(&vg->fid->metadata_areas_in_use)) {
 		log_error("Aborting vg_write: No metadata areas to write to!");
@@ -4138,22 +4152,19 @@
 void mda_set_ignored(struct metadata_area *mda, unsigned ignored)
 {
 	void *locn = mda->metadata_locn;
+	unsigned old_ignored = mda_is_ignored(mda);
 
-	if (ignored) {
+	if (ignored && !old_ignored)
 		mda->flags |= MDA_IGNORED;
-	} else {
+	else if (!ignored && old_ignored)
 		mda->flags &= ~MDA_IGNORED;
-	}
-	if (mda->ops->mda_metadata_locn_desc)
-		log_verbose("%s mda ignored flag for "
-			    "metadata_locn %s.",
-			    ignored ? "Setting" : "Clearing",
-			    mda->ops->mda_metadata_locn_desc(locn));
 	else
-		log_verbose("%s mda ignored flag for "
-			    "metadata_locn %p.",
-			    ignored ? "Setting" : "Clearing",
-			    locn);
+		return;	/* No change */
+
+	log_debug("%s ignored flag for mda %s at offset %" PRIu64 ".", 
+		  ignored ? "Setting" : "Clearing",
+		  mda->ops->mda_metadata_locn_name ? mda->ops->mda_metadata_locn_name(locn) : "",
+		  mda->ops->mda_metadata_locn_offset ? mda->ops->mda_metadata_locn_offset(locn) : UINT64_C(0));
 }
 
 uint32_t pv_mda_count(const struct physical_volume *pv)
@@ -4201,9 +4212,7 @@
 	 * Do not allow disabling of the the last PV in a VG.
 	 */
 	if (pv_mda_used_count(pv) == vg_mda_used_count(pv->vg)) {
-		log_error("Cannot disable metadata - volume group "
-			  "needs at least one physical volume with "
-			  "metadata areas in use.\n");
+		log_error("Cannot disable all metadata areas in Volume Group.");
 		return 0;
 	}
 
--- LVM2/lib/metadata/metadata.h	2010/06/29 22:37:32	1.213
+++ LVM2/lib/metadata/metadata.h	2010/06/30 13:51:13	1.214
@@ -139,10 +139,12 @@
 	 * Per location copy constructor.
 	 */
 	void *(*mda_metadata_locn_copy) (struct dm_pool *mem, void *metadata_locn);
+
 	/*
-	 * Per location description - useful for logging.
+	 * Per location description for logging.
 	 */
-	const char *(*mda_metadata_locn_desc) (void *metadata_locn);
+	const char *(*mda_metadata_locn_name) (void *metadata_locn);
+	uint64_t const (*mda_metadata_locn_offset) (void *metadata_locn);
 
 	/*
 	 * Returns number of free sectors in given metadata area.



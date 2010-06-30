From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2010 19:28:36 -0000
Subject: LVM2/lib format_text/text_label.c metadata/met ...
Message-ID: <20100630192836.10779.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-30 19:28:35

Modified files:
	lib/format_text: text_label.c 
	lib/metadata   : metadata-exported.h metadata.c 

Log message:
	more mda ignore cleanups

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/text_label.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.162&r2=1.163
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.375&r2=1.376

--- LVM2/lib/format_text/text_label.c	2010/06/30 13:51:11	1.35
+++ LVM2/lib/format_text/text_label.c	2010/06/30 19:28:35	1.36
@@ -314,8 +314,7 @@
 		mda_set_ignored(mda, rlocn_is_ignored(mdah->raw_locns));
 
 		if (mda_is_ignored(mda)) {
-			log_debug("Skipping mda with ignored flag on "
-				  "device %s at offset %"PRIu64,
+			log_debug("Ignoring mda on device %s at offset %"PRIu64,
 				  dev_name(mdac->area.dev),
 				  mdac->area.start);
 			if (!dev_close(mdac->area.dev))
--- LVM2/lib/metadata/metadata-exported.h	2010/06/30 18:03:52	1.162
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/30 19:28:35	1.163
@@ -117,6 +117,9 @@
 #define FAILED_EXIST		0x00000100U
 #define SUCCESS			0x00000000U
 
+#define VGMETADATACOPIES_ALL UINT32_MAX
+#define VGMETADATACOPIES_UNMANAGED 0
+
 /* Ordered list - see lv_manip.c */
 typedef enum {
 	ALLOC_INVALID,
@@ -885,8 +888,6 @@
 uint64_t vg_max_lv(const struct volume_group *vg);
 uint32_t vg_mda_count(const struct volume_group *vg);
 uint32_t vg_mda_used_count(const struct volume_group *vg);
-#define VGMETADATACOPIES_ALL UINT32_MAX
-#define VGMETADATACOPIES_UNMANAGED 0
 uint32_t vg_mda_copies(const struct volume_group *vg);
 int vg_set_mda_copies(struct volume_group *vg, uint32_t copies);
 int vg_check_write_mode(struct volume_group *vg);
--- LVM2/lib/metadata/metadata.c	2010/06/30 18:03:52	1.375
+++ LVM2/lib/metadata/metadata.c	2010/06/30 19:28:35	1.376
@@ -1022,14 +1022,12 @@
 		return 1;
 
 	/* FIXME: flip bits on random mdas */
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use)
 		if (!mda_is_ignored(mda)) {
 			mda_set_ignored(mda, 1);
-			num_to_ignore--;
+			if (!--num_to_ignore)
+				return 1;
 		}
-		if (!num_to_ignore)
-			return 1;
-	}
 
 	log_error(INTERNAL_ERROR "Unable to find %"PRIu32" metadata areas to ignore "
 		  "on volume group %s", num_to_ignore, vg->name);
@@ -1049,25 +1047,21 @@
 		  vg->name, vg_mda_copies(vg), vg_mda_used_count(vg), num_to_unignore);
 
 	/* FIXME: Select mdas to change at random */
-	dm_list_iterate_items_safe(mda, tmda, &vg->fid->metadata_areas_ignored) {
+	dm_list_iterate_items_safe(mda, tmda, &vg->fid->metadata_areas_ignored)
 		if (mda_is_ignored(mda)) {
 			mda_set_ignored(mda, 0);
 			dm_list_move(&vg->fid->metadata_areas_in_use,
 				     &mda->list);
-			num_to_unignore--;
+			if (!--num_to_unignore)
+				return 1;
 		}
-		if (!num_to_unignore)
-			return 1;
-	}
 
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use)
 		if (mda_is_ignored(mda)) {
 			mda_set_ignored(mda, 0);
-			num_to_unignore--;
+			if (!--num_to_unignore)
+				return 1;
 		}
-		if (!num_to_unignore)
-			return 1;
-	}
 
 	log_error(INTERNAL_ERROR "Unable to find %"PRIu32" metadata areas to unignore "
 		 "on volume group %s", num_to_unignore, vg->name);
@@ -1077,24 +1071,30 @@
 
 static int _vg_adjust_ignored_mdas(struct volume_group *vg)
 {
-	uint32_t mda_copies, count;
-	int ret = 1;
+	uint32_t mda_copies_used = vg_mda_used_count(vg);
 
-	mda_copies = vg_mda_used_count(vg);
-	if (vg->mda_copies == VGMETADATACOPIES_UNMANAGED)
-		goto skip_adjust;
-
-	if (mda_copies > vg->mda_copies)
-		ret = _vg_ignore_mdas(vg, mda_copies - vg->mda_copies);
-	else if (mda_copies < vg->mda_copies) {
-		/* not an error to have vg_mda_count larger than total mdas */
-		if (vg->mda_copies >= vg_mda_count(vg))
-			count = vg_mda_count(vg) - vg_mda_used_count(vg);
+	if (vg->mda_copies == VGMETADATACOPIES_UNMANAGED) {
+		/* Ensure at least one mda is in use. */
+		if (!mda_copies_used && vg_mda_count(vg) && !_vg_unignore_mdas(vg, 1))
+			return_0;
 		else
-			count = vg->mda_copies - mda_copies;
-		ret = _vg_unignore_mdas(vg, count);
+			return 1;
 	}
 
+
+	/* Not an error to have vg_mda_count larger than total mdas. */
+	if (vg->mda_copies == VGMETADATACOPIES_ALL ||
+	    vg->mda_copies >= vg_mda_count(vg)) {
+		/* Use all */
+		if (!_vg_unignore_mdas(vg, vg_mda_count(vg) - mda_copies_used))
+			return_0;
+	} else if (mda_copies_used < vg->mda_copies) {
+		if (!_vg_unignore_mdas(vg, vg->mda_copies - mda_copies_used))
+			return_0;
+	} else if (mda_copies_used > vg->mda_copies)
+		if (!_vg_ignore_mdas(vg, mda_copies_used - vg->mda_copies))
+			return_0;
+
 	/*
 	 * The VGMETADATACOPIES_ALL value will never be written disk.
 	 * It is a special cmdline value that means 2 things:
@@ -1104,24 +1104,6 @@
 	if (vg->mda_copies == VGMETADATACOPIES_ALL)
 		vg->mda_copies = VGMETADATACOPIES_UNMANAGED;
 
-	if (!ret)
-		return_0;
-
-skip_adjust:
-	/*
-	 * Ensure at least one mda in use.
-	 * FIXME: check size of fid->metadata_areas_in_use; reason is because
-	 * of how pv_setup works in the case of a pv with 2 mdas, one ignored
-	 * and another not ignored; function needs refactoring to simplify the
-	 * below check and retain correctness.
-	 */
-	if ((!dm_list_size(&vg->fid->metadata_areas_in_use) ||
-	    !vg_mda_used_count(vg)) && vg_mda_count(vg))
-		ret = _vg_unignore_mdas(vg, 1);
-
-	if (!ret)
-		return_0;
-
 	return 1;
 }
 
@@ -2546,10 +2528,10 @@
 		return 0;
 	}
 
-	if (!_vg_adjust_ignored_mdas(vg))
+	if ((vg->fid->fmt->features & FMT_MDAS) && !_vg_adjust_ignored_mdas(vg))
 		return_0;
 
-	if (dm_list_empty(&vg->fid->metadata_areas_in_use)) {
+	if (!vg_mda_used_count(vg)) {
 		log_error("Aborting vg_write: No metadata areas to write to!");
 		return 0;
 	}
@@ -4375,10 +4357,6 @@
 	       if (!mda_is_ignored(mda))
 		       used_count++;
 
-       dm_list_iterate_items(mda, &vg->fid->metadata_areas_ignored)
-	       if (!mda_is_ignored(mda))
-		       used_count++;
-
        return used_count;
 }
 



From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Jun 2010 17:13:09 -0000
Subject: LVM2/lib format_text/format-text.c format_text ...
Message-ID: <20100630171309.5650.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-30 17:13:07

Modified files:
	lib/format_text: format-text.c layout.h 
	lib/metadata   : metadata.c 

Log message:
	more metadataignore message/code cleanup

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/layout.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.373&r2=1.374

--- LVM2/lib/format_text/format-text.c	2010/06/30 13:51:11	1.138
+++ LVM2/lib/format_text/format-text.c	2010/06/30 17:13:05	1.139
@@ -68,9 +68,9 @@
 	return (rlocn->flags & RAW_LOCN_IGNORED ? 1 : 0);
 }
 
-void rlocn_set_ignored(struct raw_locn *rlocn, int value)
+void rlocn_set_ignored(struct raw_locn *rlocn, unsigned mda_ignored)
 {
-	if (value)
+	if (mda_ignored)
 		rlocn->flags |= RAW_LOCN_IGNORED;
 	else
 		rlocn->flags &= ~RAW_LOCN_IGNORED;
--- LVM2/lib/format_text/layout.h	2010/06/28 20:31:01	1.12
+++ LVM2/lib/format_text/layout.h	2010/06/30 17:13:05	1.13
@@ -62,7 +62,7 @@
 } __attribute__ ((packed));
 
 int rlocn_is_ignored(const struct raw_locn *rlocn);
-void rlocn_set_ignored(struct raw_locn *rlocn, int value);
+void rlocn_set_ignored(struct raw_locn *rlocn, unsigned mda_ignored);
 
 /* On disk */
 /* Structure size limited to one sector */
--- LVM2/lib/metadata/metadata.c	2010/06/30 14:54:29	1.373
+++ LVM2/lib/metadata/metadata.c	2010/06/30 17:13:06	1.374
@@ -2615,13 +2615,12 @@
 
 	/* Rearrange the metadata_areas_in_use so ignored mdas come first. */
 	dm_list_init(&ignored);
-	dm_list_iterate_items_safe(mda, tmda, &vg->fid->metadata_areas_in_use) {
+	dm_list_iterate_items_safe(mda, tmda, &vg->fid->metadata_areas_in_use)
 		if (mda_is_ignored(mda))
 			dm_list_move(&ignored, &mda->list);
-	}
-	dm_list_iterate_items_safe(mda, tmda, &ignored) {
+
+	dm_list_iterate_items_safe(mda, tmda, &ignored)
 		dm_list_move(&vg->fid->metadata_areas_in_use, &mda->list);
-	}
 
 	/* Commit to each copy of the metadata area */
 	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
@@ -4067,12 +4066,8 @@
 
 void fid_add_mda(struct format_instance *fid, struct metadata_area *mda)
 {
-	if (mda_is_ignored(mda))
-		dm_list_add(&fid->metadata_areas_ignored,
-			    &mda->list);
-	else
-		dm_list_add(&fid->metadata_areas_in_use,
-			    &mda->list);
+	dm_list_add(mda_is_ignored(mda) ? &fid->metadata_areas_ignored :
+					  &fid->metadata_areas_in_use, &mda->list);
 }
 
 int fid_add_mdas(struct format_instance *fid, struct dm_list *mdas)
@@ -4149,20 +4144,20 @@
 	return (mda->flags & MDA_IGNORED);
 }
 
-void mda_set_ignored(struct metadata_area *mda, unsigned ignored)
+void mda_set_ignored(struct metadata_area *mda, unsigned mda_ignored)
 {
 	void *locn = mda->metadata_locn;
-	unsigned old_ignored = mda_is_ignored(mda);
+	unsigned old_mda_ignored = mda_is_ignored(mda);
 
-	if (ignored && !old_ignored)
+	if (mda_ignored && !old_mda_ignored)
 		mda->flags |= MDA_IGNORED;
-	else if (!ignored && old_ignored)
+	else if (!mda_ignored && old_mda_ignored)
 		mda->flags &= ~MDA_IGNORED;
 	else
 		return;	/* No change */
 
 	log_debug("%s ignored flag for mda %s at offset %" PRIu64 ".", 
-		  ignored ? "Setting" : "Clearing",
+		  mda_ignored ? "Setting" : "Clearing",
 		  mda->ops->mda_metadata_locn_name ? mda->ops->mda_metadata_locn_name(locn) : "",
 		  mda->ops->mda_metadata_locn_offset ? mda->ops->mda_metadata_locn_offset(locn) : UINT64_C(0));
 }
@@ -4191,20 +4186,18 @@
 	return used_count;
 }
 
-unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored)
+unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignored)
 {
 	struct lvmcache_info *info;
 	struct metadata_area *mda, *vg_mda, *tmda;
 	struct dm_list *vg_mdas_in_use, *vg_mdas_ignored;
 
-	info = info_from_pvid((const char *)&pv->id.uuid, 0);
-	if (!info)
+	if (!(info = info_from_pvid((const char *)&pv->id.uuid, 0)))
 		return_0;
 
 	if (is_orphan(pv)) {
-		dm_list_iterate_items(mda, &info->mdas) {
-			mda_set_ignored(mda, ignored);
-		}
+		dm_list_iterate_items(mda, &info->mdas)
+			mda_set_ignored(mda, mda_ignored);
 		return 1;
 	}
 
@@ -4212,7 +4205,8 @@
 	 * Do not allow disabling of the the last PV in a VG.
 	 */
 	if (pv_mda_used_count(pv) == vg_mda_used_count(pv->vg)) {
-		log_error("Cannot disable all metadata areas in Volume Group.");
+		log_error("Cannot disable all metadata areas in volume group %s.",
+			  pv->vg->name);
 		return 0;
 	}
 
@@ -4229,24 +4223,24 @@
 	 */
 	vg_mdas_in_use = &pv->vg->fid->metadata_areas_in_use;
 	vg_mdas_ignored = &pv->vg->fid->metadata_areas_ignored;
+
 	dm_list_iterate_items(mda, &info->mdas) {
-		if (mda_is_ignored(mda) && !ignored) {
+		if (mda_is_ignored(mda) && !mda_ignored)
 			/* Changing an ignored mda to one in_use requires moving it */
-			dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_ignored) {
+			dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_ignored)
 				if (mda_locns_match(mda, vg_mda)) {
-					mda_set_ignored(vg_mda, ignored);
+					mda_set_ignored(vg_mda, mda_ignored);
 					dm_list_move(vg_mdas_in_use, &vg_mda->list);
 				}
-			}
-		}
-		dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_in_use) {
-			if (mda_locns_match(mda, vg_mda)) {
-				mda_set_ignored(vg_mda, ignored);
-				/* don't move mda - needs written to disk */
-			}
-		}
-		mda_set_ignored(mda, ignored);
+
+		dm_list_iterate_items_safe(vg_mda, tmda, vg_mdas_in_use)
+			if (mda_locns_match(mda, vg_mda))
+				/* Don't move mda: needs writing to disk. */
+				mda_set_ignored(vg_mda, mda_ignored);
+
+		mda_set_ignored(mda, mda_ignored);
 	}
+
 	return 1;
 }
 
@@ -4267,31 +4261,30 @@
 {
 	const char *pv_name = pv_dev_name(pv);
 
-	if (mda_ignore && (pv_mda_used_count(pv) == 0)) {
-		log_error("Physical volume \"%s\" metadata already "
-			  "ignored", pv_name);
+	if (mda_ignore && !pv_mda_used_count(pv)) {
+		log_error("Metadata areas on physical volume \"%s\" already "
+			  "ignored.", pv_name);
 		return 0;
 	}
+
 	if (!mda_ignore && (pv_mda_used_count(pv) == pv_mda_count(pv))) {
-		log_error("Physical volume \"%s\" metadata already "
-			  "not ignored", pv_name);
+		log_error("Metadata areas on physical volume \"%s\" already "
+			  "marked as in-use.", pv_name);
 		return 0;
 	}
+
 	if (!pv_mda_count(pv)) {
 		log_error("Physical volume \"%s\" has no metadata "
-			  "areas ", pv_name);
-		return 0;
-	}
-	if (mda_ignore) {
-		log_verbose("Setting physical volume \"%s\" "
-			    "metadata ignored", pv_name);
-	} else {
-		log_verbose("Setting physical volume \"%s\" "
-			    "metadata not ignored", pv_name);
-	}
-	if (!pv_mda_set_ignored(pv, mda_ignore)) {
+			  "areas.", pv_name);
 		return 0;
 	}
+
+	log_verbose("Marking metadata areas on physical volume \"%s\" "
+		    "as %s.", pv_name, mda_ignore ? "ignored" : "in-use");
+
+	if (!pv_mda_set_ignored(pv, mda_ignore))
+		return_0;
+
 	/*
 	 * Update vg_mda_copies based on the mdas in this PV.
 	 * This is most likely what the user would expect - if they
@@ -4301,9 +4294,9 @@
 	 * This does not guarantee this PV's ignore bits will be
 	 * preserved in future operations.
 	 */
-	if (!is_orphan(pv) && vg_mda_copies(pv->vg)) {
+	if (!is_orphan(pv) && vg_mda_copies(pv->vg))
 		vg_set_mda_copies(pv->vg, vg_mda_used_count(pv->vg));
-	}
+
 	return 1;
 }
 
@@ -4373,14 +4366,13 @@
 	 * may have changed from ignored to un-ignored and we need to write
 	 * the state to disk.
 	 */
-       dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+       dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use)
 	       if (!mda_is_ignored(mda))
 		       used_count++;
-       }
-       dm_list_iterate_items(mda, &vg->fid->metadata_areas_ignored) {
+
+       dm_list_iterate_items(mda, &vg->fid->metadata_areas_ignored)
 	       if (!mda_is_ignored(mda))
 		       used_count++;
-       }
 
        return used_count;
 }



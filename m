From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:32:51 -0000
Subject: LVM2 lib/format1/format1.c lib/format_pool/for ...
Message-ID: <20100628203251.15078.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:32:47

Modified files:
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 
	lib/format_text: archiver.c format-text.c 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	lib/report     : report.c 
	tools          : vgmerge.c 

Log message:
	Rename fid->metadata_areas to fid->metadata_areas_in_use.
	
	Rename the metadata_areas list to an 'in_use' list to prepare for
	future 'ignored' list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.152&r2=1.153
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.349&r2=1.350
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.208&r2=1.209
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.66&r2=1.67

--- LVM2/lib/format1/format1.c	2010/04/06 14:04:20	1.116
+++ LVM2/lib/format1/format1.c	2010/06/28 20:32:44	1.117
@@ -463,7 +463,7 @@
 		return_NULL;
 
 	fid->fmt = fmt;
-	dm_list_init(&fid->metadata_areas);
+	dm_list_init(&fid->metadata_areas_in_use);
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda)))) {
@@ -473,7 +473,7 @@
 
 	mda->ops = &_metadata_format1_ops;
 	mda->metadata_locn = NULL;
-	dm_list_add(&fid->metadata_areas, &mda->list);
+	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 
 	return fid;
 }
--- LVM2/lib/format_pool/format_pool.c	2010/04/13 17:25:13	1.27
+++ LVM2/lib/format_pool/format_pool.c	2010/06/28 20:32:46	1.28
@@ -262,7 +262,7 @@
 	}
 
 	fid->fmt = fmt;
-	dm_list_init(&fid->metadata_areas);
+	dm_list_init(&fid->metadata_areas_in_use);
 
 	/* Define a NULL metadata area */
 	if (!(mda = dm_pool_zalloc(fmt->cmd->mem, sizeof(*mda)))) {
@@ -274,7 +274,7 @@
 
 	mda->ops = &_metadata_format_pool_ops;
 	mda->metadata_locn = NULL;
-	dm_list_add(&fid->metadata_areas, &mda->list);
+	dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 
 	return fid;
 }
--- LVM2/lib/format_text/archiver.c	2010/04/14 13:09:16	1.30
+++ LVM2/lib/format_text/archiver.c	2010/06/28 20:32:46	1.31
@@ -277,7 +277,7 @@
 		return NULL;
 	}
 
-	dm_list_iterate_items(mda, &tf->metadata_areas) {
+	dm_list_iterate_items(mda, &tf->metadata_areas_in_use) {
 		if (!(vg = mda->ops->vg_read(tf, vg_name, mda)))
 			stack;
 		break;
@@ -327,7 +327,7 @@
 		}
 		if (!vg->fid->fmt->ops->
 		    pv_setup(vg->fid->fmt, UINT64_C(0), 0, 0, 0, 0, 0UL,
-			     UINT64_C(0), &vg->fid->metadata_areas, pv, vg)) {
+			     UINT64_C(0), &vg->fid->metadata_areas_in_use, pv, vg)) {
 			log_error("Format-specific setup for %s failed",
 				  pv_dev_name(pv));
 			return 0;
@@ -397,7 +397,7 @@
 	}
 
 	/* Write and commit the metadata area */
-	dm_list_iterate_items(mda, &tf->metadata_areas) {
+	dm_list_iterate_items(mda, &tf->metadata_areas_in_use) {
 		if (!(r = mda->ops->vg_write(tf, vg, mda))) {
 			stack;
 			continue;
--- LVM2/lib/format_text/format-text.c	2010/06/28 20:31:59	1.130
+++ LVM2/lib/format_text/format-text.c	2010/06/28 20:32:46	1.131
@@ -1208,7 +1208,7 @@
 	raw_list = &((struct mda_lists *) fmt->private)->raws;
 
 	fid.fmt = fmt;
-	dm_list_init(&fid.metadata_areas);
+	dm_list_init(&fid.metadata_areas_in_use);
 
 	dm_list_iterate_items(rl, raw_list) {
 		/* FIXME We're reading mdah twice here... */
@@ -1914,14 +1914,14 @@
 	fid->private = (void *) fidtc;
 
 	fid->fmt = fmt;
-	dm_list_init(&fid->metadata_areas);
+	dm_list_init(&fid->metadata_areas_in_use);
 
 	if (!vgname) {
 		if (!(mda = dm_pool_alloc(fmt->cmd->mem, sizeof(*mda))))
 			return_NULL;
 		mda->ops = &_metadata_text_file_backup_ops;
 		mda->metadata_locn = context;
-		dm_list_add(&fid->metadata_areas, &mda->list);
+		dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 	} else {
 		dir_list = &((struct mda_lists *) fmt->private)->dirs;
 
@@ -1938,7 +1938,7 @@
 				return_NULL;
 			mda->ops = &_metadata_text_file_ops;
 			mda->metadata_locn = context;
-			dm_list_add(&fid->metadata_areas, &mda->list);
+			dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 		}
 
 		raw_list = &((struct mda_lists *) fmt->private)->raws;
@@ -1958,7 +1958,7 @@
 			memcpy(&mdac->area, &rl->dev_area, sizeof(mdac->area));
 			mda->ops = &_metadata_text_raw_ops;
 			/* FIXME MISTAKE? mda->metadata_locn = context; */
-			dm_list_add(&fid->metadata_areas, &mda->list);
+			dm_list_add(&fid->metadata_areas_in_use, &mda->list);
 		}
 
 		/* Scan PVs in VG for any further MDAs */
@@ -1972,7 +1972,7 @@
 				mda_new = mda_copy(fmt->cmd->mem, mda);
 				if (!mda_new)
 					return_NULL;
-				dm_list_add(&fid->metadata_areas, &mda_new->list);
+				dm_list_add(&fid->metadata_areas_in_use, &mda_new->list);
 			}
 		}
 		/* FIXME Check raw metadata area count - rescan if required */
--- LVM2/lib/metadata/metadata-exported.h	2010/05/24 15:32:20	1.152
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:32:46	1.153
@@ -215,7 +215,7 @@
 
 struct format_instance {
 	const struct format_type *fmt;
-	struct dm_list metadata_areas;	/* e.g. metadata locations */
+	struct dm_list metadata_areas_in_use;	/* e.g. metadata locations */
 	void *private;
 };
 
--- LVM2/lib/metadata/metadata.c	2010/06/28 20:31:59	1.349
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:32:46	1.350
@@ -217,7 +217,7 @@
 
 	if (!fid->fmt->ops->pv_setup(fid->fmt, UINT64_C(0), 0,
 				     vg->extent_size, 0, 0, 0UL, UINT64_C(0),
-				     &fid->metadata_areas, pv, vg)) {
+				     &fid->metadata_areas_in_use, pv, vg)) {
 		log_error("Format-specific setup of physical volume '%s' "
 			  "failed.", pv_name);
 		return 0;
@@ -1255,8 +1255,8 @@
 	struct dm_list *mdas_from, *mdas_to;
 	int common_mda = 0;
 
-	mdas_from = &vg_from->fid->metadata_areas;
-	mdas_to = &vg_to->fid->metadata_areas;
+	mdas_from = &vg_from->fid->metadata_areas_in_use;
+	mdas_to = &vg_to->fid->metadata_areas_in_use;
 
 	dm_list_iterate_items_safe(mda, mda2, mdas_from) {
 		if (!mda->ops->mda_in_vg) {
@@ -1844,7 +1844,7 @@
 
 	/* FIXME Improve recovery situation? */
 	/* Remove each copy of the metadata */
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (mda->ops->vg_remove &&
 		    !mda->ops->vg_remove(vg->fid, vg, mda))
 			return_0;
@@ -2362,7 +2362,7 @@
 	}
 
 
-	if (dm_list_empty(&vg->fid->metadata_areas)) {
+	if (dm_list_empty(&vg->fid->metadata_areas_in_use)) {
 		log_error("Aborting vg_write: No metadata areas to write to!");
 		return 0;
 	}
@@ -2375,12 +2375,12 @@
 	vg->seqno++;
 
 	/* Write to each copy of the metadata area */
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (!mda->ops->vg_write) {
 			log_error("Format does not support writing volume"
 				  "group metadata areas");
 			/* Revert */
-			dm_list_uniterate(mdah, &vg->fid->metadata_areas, &mda->list) {
+			dm_list_uniterate(mdah, &vg->fid->metadata_areas_in_use, &mda->list) {
 				mda = dm_list_item(mdah, struct metadata_area);
 
 				if (mda->ops->vg_revert &&
@@ -2393,7 +2393,7 @@
 		if (!mda->ops->vg_write(vg->fid, vg, mda)) {
 			stack;
 			/* Revert */
-			dm_list_uniterate(mdah, &vg->fid->metadata_areas, &mda->list) {
+			dm_list_uniterate(mdah, &vg->fid->metadata_areas_in_use, &mda->list) {
 				mda = dm_list_item(mdah, struct metadata_area);
 
 				if (mda->ops->vg_revert &&
@@ -2406,12 +2406,12 @@
 	}
 
 	/* Now pre-commit each copy of the new metadata */
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (mda->ops->vg_precommit &&
 		    !mda->ops->vg_precommit(vg->fid, vg, mda)) {
 			stack;
 			/* Revert */
-			dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+			dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 				if (mda->ops->vg_revert &&
 				    !mda->ops->vg_revert(vg->fid, vg, mda)) {
 					stack;
@@ -2438,7 +2438,7 @@
 	}
 
 	/* Commit to each copy of the metadata area */
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		failed = 0;
 		if (mda->ops->vg_commit &&
 		    !mda->ops->vg_commit(vg->fid, vg, mda)) {
@@ -2476,7 +2476,7 @@
 {
 	struct metadata_area *mda;
 
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (mda->ops->vg_revert &&
 		    !mda->ops->vg_revert(vg->fid, vg, mda)) {
 			stack;
@@ -2691,7 +2691,7 @@
 		return_NULL;
 
 	/* Ensure contents of all metadata areas match - else do recovery */
-	dm_list_iterate_items(mda, &fid->metadata_areas) {
+	dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
 		if ((use_precommitted &&
 		     !(vg = mda->ops->vg_read_precommit(fid, vgname, mda))) ||
 		    (!use_precommitted &&
@@ -2809,7 +2809,7 @@
 		}
 
 		/* Ensure contents of all metadata areas match - else recover */
-		dm_list_iterate_items(mda, &fid->metadata_areas) {
+		dm_list_iterate_items(mda, &fid->metadata_areas_in_use) {
 			if ((use_precommitted &&
 			     !(vg = mda->ops->vg_read_precommit(fid, vgname,
 								mda))) ||
@@ -3897,8 +3897,8 @@
  * physical_volume.  The location of the mda depends on whether
  * the PV is in a volume group.  A PV not in a VG has an mda on the
  * 'info->mda' list in lvmcache, while a PV in a VG has an mda on
- * the vg->fid->metadata_areas list.  For further details, see _vg_read(),
- * and the sequence of creating the format_instance with fid->metadata_areas
+ * the vg->fid->metadata_areas_in_use list.  For further details, see _vg_read(),
+ * and the sequence of creating the format_instance with fid->metadata_areas_in_use
  * list, as well as the construction of the VG, with list of PVs (comes
  * after the construction of the fid and list of mdas).
  */
@@ -3984,7 +3984,7 @@
 
 uint32_t vg_mda_count(const struct volume_group *vg)
 {
-	return dm_list_size(&vg->fid->metadata_areas);
+	return dm_list_size(&vg->fid->metadata_areas_in_use);
 }
 
 uint64_t lv_size(const struct logical_volume *lv)
--- LVM2/lib/metadata/metadata.h	2010/06/28 20:31:59	1.208
+++ LVM2/lib/metadata/metadata.h	2010/06/28 20:32:46	1.209
@@ -162,8 +162,8 @@
 			       struct metadata_area *mda);
 
 	/*
-	 * Do these two metadata_areas match with respect to their underlying
-	 * location?
+	 * Do these two metadata_area structures match with respect to
+	 * their underlying location?
 	 */
 	unsigned (*mda_locns_match)(struct metadata_area *mda1,
 				    struct metadata_area *mda2);
--- LVM2/lib/report/report.c	2010/06/23 12:32:08	1.117
+++ LVM2/lib/report/report.c	2010/06/28 20:32:47	1.118
@@ -957,7 +957,7 @@
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint64_t min_mda_size;
 
-	min_mda_size = _find_min_mda_size(&vg->fid->metadata_areas);
+	min_mda_size = _find_min_mda_size(&vg->fid->metadata_areas_in_use);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
@@ -970,7 +970,7 @@
 	uint64_t freespace = UINT64_MAX, mda_free;
 	struct metadata_area *mda;
 
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas) {
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
 		if (!mda->ops->mda_free_sectors)
 			continue;
 		mda_free = mda->ops->mda_free_sectors(mda);
@@ -1126,7 +1126,7 @@
 
 /* necessary for displaying something for PVs not belonging to VG */
 static struct format_instance _dummy_fid = {
-	.metadata_areas = { &(_dummy_fid.metadata_areas), &(_dummy_fid.metadata_areas) },
+	.metadata_areas_in_use = { &(_dummy_fid.metadata_areas_in_use), &(_dummy_fid.metadata_areas_in_use) },
 };
 
 static struct volume_group _dummy_vg = {
--- LVM2/tools/vgmerge.c	2010/04/13 17:26:03	1.66
+++ LVM2/tools/vgmerge.c	2010/06/28 20:32:47	1.67
@@ -120,10 +120,10 @@
 		dm_list_move(&vg_to->lvs, lvh);
 	}
 
-	while (!dm_list_empty(&vg_from->fid->metadata_areas)) {
-		struct dm_list *mdah = vg_from->fid->metadata_areas.n;
+	while (!dm_list_empty(&vg_from->fid->metadata_areas_in_use)) {
+		struct dm_list *mdah = vg_from->fid->metadata_areas_in_use.n;
 
-		dm_list_move(&vg_to->fid->metadata_areas, mdah);
+		dm_list_move(&vg_to->fid->metadata_areas_in_use, mdah);
 	}
 
 	vg_to->extent_count += vg_from->extent_count;



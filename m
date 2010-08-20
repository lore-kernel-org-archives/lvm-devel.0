From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 20 Aug 2010 12:43:51 -0000
Subject: LVM2/lib metadata/metadata.c metadata/metadata ...
Message-ID: <20100820124351.25391.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-08-20 12:43:49

Modified files:
	lib/metadata   : metadata.c metadata.h 
	lib/report     : report.c 

Log message:
	Add vg_mda_size and vg_mda_free functions.
	
	Add supporting functions to get vg_mda_size and vg_mda_free fields.
	Should be no functional change.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.394&r2=1.395
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.216&r2=1.217
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.124&r2=1.125

--- LVM2/lib/metadata/metadata.c	2010/08/19 23:26:32	1.394
+++ LVM2/lib/metadata/metadata.c	2010/08/20 12:43:49	1.395
@@ -1217,6 +1217,48 @@
 	return 1;
 }
 
+uint64_t find_min_mda_size(struct dm_list *mdas)
+{
+	uint64_t min_mda_size = UINT64_MAX, mda_size;
+	struct metadata_area *mda;
+
+	dm_list_iterate_items(mda, mdas) {
+		if (!mda->ops->mda_total_sectors)
+			continue;
+		mda_size = mda->ops->mda_total_sectors(mda);
+		if (mda_size < min_mda_size)
+			min_mda_size = mda_size;
+	}
+
+	if (min_mda_size == UINT64_MAX)
+		min_mda_size = UINT64_C(0);
+
+	return min_mda_size;
+}
+
+uint64_t vg_mda_size(const struct volume_group *vg)
+{
+	return find_min_mda_size(&vg->fid->metadata_areas_in_use);
+}
+
+uint64_t vg_mda_free(const struct volume_group *vg)
+{
+	uint64_t freespace = UINT64_MAX, mda_free;
+	struct metadata_area *mda;
+
+	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
+		if (!mda->ops->mda_free_sectors)
+			continue;
+		mda_free = mda->ops->mda_free_sectors(mda);
+		if (mda_free < freespace)
+			freespace = mda_free;
+	}
+
+	if (freespace == UINT64_MAX)
+		freespace = UINT64_C(0);
+	return freespace;
+}
+
 int vg_set_extent_size(struct volume_group *vg, uint32_t new_size)
 {
 	uint32_t old_size = vg->extent_size;
--- LVM2/lib/metadata/metadata.h	2010/07/08 18:24:30	1.216
+++ LVM2/lib/metadata/metadata.h	2010/08/20 12:43:49	1.217
@@ -416,4 +416,8 @@
 int vg_mark_partial_lvs(struct volume_group *vg);
 int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 
+uint64_t find_min_mda_size(struct dm_list *mdas);
+uint64_t vg_mda_size(const struct volume_group *vg);
+uint64_t vg_mda_free(const struct volume_group *vg);
+
 #endif
--- LVM2/lib/report/report.c	2010/08/17 16:25:35	1.124
+++ LVM2/lib/report/report.c	2010/08/20 12:43:49	1.125
@@ -958,25 +958,6 @@
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
 
-static uint64_t _find_min_mda_size(struct dm_list *mdas)
-{
-	uint64_t min_mda_size = UINT64_MAX, mda_size;
-	struct metadata_area *mda;
-
-	dm_list_iterate_items(mda, mdas) {
-		if (!mda->ops->mda_total_sectors)
-			continue;
-		mda_size = mda->ops->mda_total_sectors(mda);
-		if (mda_size < min_mda_size)
-			min_mda_size = mda_size;
-	}
-
-	if (min_mda_size == UINT64_MAX)
-		min_mda_size = UINT64_C(0);
-
-	return min_mda_size;
-}
-
 static int _pvmdasize_disp(struct dm_report *rh, struct dm_pool *mem,
 			   struct dm_report_field *field,
 			   const void *data, void *private)
@@ -987,7 +968,7 @@
 
 	/* PVs could have 2 mdas of different sizes (rounding effect) */
 	if ((info = info_from_pvid(pvid, 0)))
-		min_mda_size = _find_min_mda_size(&info->mdas);
+		min_mda_size = find_min_mda_size(&info->mdas);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
@@ -999,7 +980,7 @@
 	const struct volume_group *vg = (const struct volume_group *) data;
 	uint64_t min_mda_size;
 
-	min_mda_size = _find_min_mda_size(&vg->fid->metadata_areas_in_use);
+	min_mda_size = vg_mda_size(vg);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }
@@ -1009,19 +990,9 @@
 			   const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	uint64_t freespace = UINT64_MAX, mda_free;
-	struct metadata_area *mda;
-
-	dm_list_iterate_items(mda, &vg->fid->metadata_areas_in_use) {
-		if (!mda->ops->mda_free_sectors)
-			continue;
-		mda_free = mda->ops->mda_free_sectors(mda);
-		if (mda_free < freespace)
-			freespace = mda_free;
-	}
+	uint64_t freespace;
 
-	if (freespace == UINT64_MAX)
-		freespace = UINT64_C(0);
+	freespace = vg_mda_free(vg);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }



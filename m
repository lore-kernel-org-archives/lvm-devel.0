From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 13:53:04 -0000
Subject: LVM2/lib metadata/lv.c metadata/lv.h metadata/ ...
Message-ID: <20100930135304.5268.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 13:52:57

Modified files:
	lib/metadata   : lv.c lv.h metadata.c metadata.h pv.c pv.h vg.c 
	                 vg.h 
	lib/report     : columns.h report.c 

Log message:
	Add {pv|vg|lv}_attr_dup() functions and refactor 'disp' functions.
	
	Move the creating of the 'attr' strings into a common function so
	they can be called from the 'disp' functions as well as the new
	'get' property functions.
	Add "_dup" suffix to indicate memory is allocated.
	Refactor pvstatus_disp to take pv argument and call pv_attr_dup().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.400&r2=1.401
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.219&r2=1.220
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/vg.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.127&r2=1.128

--- LVM2/lib/metadata/lv.c	2010/09/30 13:16:55	1.1
+++ LVM2/lib/metadata/lv.c	2010/09/30 13:52:55	1.2
@@ -14,8 +14,126 @@
 
 #include "lib.h"
 #include "metadata.h"
+#include "activate.h"
 
 uint64_t lv_size(const struct logical_volume *lv)
 {
 	return lv->size;
 }
+
+static int _lv_mimage_in_sync(const struct logical_volume *lv)
+{
+	float percent;
+	percent_range_t percent_range;
+	struct lv_segment *mirror_seg = find_mirror_seg(first_seg(lv));
+
+	if (!(lv->status & MIRROR_IMAGE) || !mirror_seg)
+		return_0;
+
+	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent,
+			       &percent_range, NULL))
+		return_0;
+
+	return (percent_range == PERCENT_100) ? 1 : 0;
+}
+
+char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
+{
+	float snap_percent;
+	percent_range_t percent_range;
+	struct lvinfo info;
+	char *repstr;
+
+	if (!(repstr = dm_pool_zalloc(mem, 7))) {
+		log_error("dm_pool_alloc failed");
+		return 0;
+	}
+
+	/* Blank if this is a "free space" LV. */
+	if (!*lv->name)
+		goto out;
+
+	if (lv->status & PVMOVE)
+		repstr[0] = 'p';
+	else if (lv->status & CONVERTING)
+		repstr[0] = 'c';
+	else if (lv->status & VIRTUAL)
+		repstr[0] = 'v';
+	/* Origin takes precedence over Mirror */
+	else if (lv_is_origin(lv)) {
+		if (lv_is_merging_origin(lv))
+			repstr[0] = 'O';
+		else
+			repstr[0] = 'o';
+	}
+	else if (lv->status & MIRRORED) {
+		if (lv->status & MIRROR_NOTSYNCED)
+			repstr[0] = 'M';
+		else
+			repstr[0] = 'm';
+	}else if (lv->status & MIRROR_IMAGE)
+		if (_lv_mimage_in_sync(lv))
+			repstr[0] = 'i';
+		else
+			repstr[0] = 'I';
+	else if (lv->status & MIRROR_LOG)
+		repstr[0] = 'l';
+	else if (lv_is_cow(lv)) {
+		if (lv_is_merging_cow(lv))
+			repstr[0] = 'S';
+		else
+			repstr[0] = 's';
+	} else
+		repstr[0] = '-';
+
+	if (lv->status & PVMOVE)
+		repstr[1] = '-';
+	else if (lv->status & LVM_WRITE)
+		repstr[1] = 'w';
+	else if (lv->status & LVM_READ)
+		repstr[1] = 'r';
+	else
+		repstr[1] = '-';
+
+	repstr[2] = alloc_policy_char(lv->alloc);
+
+	if (lv->status & LOCKED)
+		repstr[2] = toupper(repstr[2]);
+
+	if (lv->status & FIXED_MINOR)
+		repstr[3] = 'm';	/* Fixed Minor */
+	else
+		repstr[3] = '-';
+
+	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
+		if (info.suspended)
+			repstr[4] = 's';	/* Suspended */
+		else if (info.live_table)
+			repstr[4] = 'a';	/* Active */
+		else if (info.inactive_table)
+			repstr[4] = 'i';	/* Inactive with table */
+		else
+			repstr[4] = 'd';	/* Inactive without table */
+
+		/* Snapshot dropped? */
+		if (info.live_table && lv_is_cow(lv) &&
+		    (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
+		     percent_range == PERCENT_INVALID)) {
+			repstr[0] = toupper(repstr[0]);
+			if (info.suspended)
+				repstr[4] = 'S'; /* Susp Inv snapshot */
+			else
+				repstr[4] = 'I'; /* Invalid snapshot */
+		}
+
+		if (info.open_count)
+			repstr[5] = 'o';	/* Open */
+		else
+			repstr[5] = '-';
+	} else {
+		repstr[4] = '-';
+		repstr[5] = '-';
+	}
+out:
+	return repstr;
+}
--- LVM2/lib/metadata/lv.h	2010/09/30 13:16:55	1.1
+++ LVM2/lib/metadata/lv.h	2010/09/30 13:52:56	1.2
@@ -48,5 +48,6 @@
 };
 
 uint64_t lv_size(const struct logical_volume *lv);
+char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv);
 
 #endif
--- LVM2/lib/metadata/metadata.c	2010/09/30 13:05:45	1.400
+++ LVM2/lib/metadata/metadata.c	2010/09/30 13:52:56	1.401
@@ -3921,6 +3921,22 @@
 	return 1;
 }
 
+char alloc_policy_char(alloc_policy_t alloc)
+{
+	switch (alloc) {
+	case ALLOC_CONTIGUOUS:
+		return 'c';
+	case ALLOC_CLING:
+		return 'l';
+	case ALLOC_NORMAL:
+		return 'n';
+	case ALLOC_ANYWHERE:
+		return 'a';
+	default:
+		return 'i';
+	}
+}
+
 /**
  * pv_by_path - Given a device path return a PV handle if it is a PV
  * @cmd - handle to the LVM command instance
--- LVM2/lib/metadata/metadata.h	2010/09/30 13:04:56	1.219
+++ LVM2/lib/metadata/metadata.h	2010/09/30 13:52:56	1.220
@@ -412,5 +412,6 @@
 int is_mirror_image_removable(struct logical_volume *mimage_lv, void *baton);
 
 uint64_t find_min_mda_size(struct dm_list *mdas);
+char alloc_policy_char(alloc_policy_t alloc);
 
 #endif
--- LVM2/lib/metadata/pv.c	2010/09/30 13:15:42	1.1
+++ LVM2/lib/metadata/pv.c	2010/09/30 13:52:56	1.2
@@ -163,6 +163,27 @@
 	return pv_field(pv, status) & MISSING_PV ? 1 : 0;
 }
 
+char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv)
+{
+	char *repstr;
+
+	if (!(repstr = dm_pool_zalloc(mem, 3))) {
+		log_error("dm_pool_alloc failed");
+		return NULL;
+	}
+
+	if (pv->status & ALLOCATABLE_PV)
+		repstr[0] = 'a';
+	else
+		repstr[0] = '-';
+
+	if (pv->status & EXPORTED_VG)
+		repstr[1] = 'x';
+	else
+		repstr[1] = '-';
+	return repstr;
+}
+
 unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignored)
 {
 	struct lvmcache_info *info;
--- LVM2/lib/metadata/pv.h	2010/09/30 13:15:42	1.1
+++ LVM2/lib/metadata/pv.h	2010/09/30 13:52:56	1.2
@@ -54,6 +54,7 @@
 
 struct device *pv_dev(const struct physical_volume *pv);
 const char *pv_vg_name(const struct physical_volume *pv);
+char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv);
 const char *pv_dev_name(const struct physical_volume *pv);
 uint64_t pv_size(const struct physical_volume *pv);
 uint64_t pv_size_field(const struct physical_volume *pv);
--- LVM2/lib/metadata/vg.c	2010/09/30 13:16:55	1.1
+++ LVM2/lib/metadata/vg.c	2010/09/30 13:52:56	1.2
@@ -434,3 +434,40 @@
 	return 1;
 }
 
+char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg)
+{
+	char *repstr;
+
+	if (!(repstr = dm_pool_zalloc(mem, 7))) {
+		log_error("dm_pool_alloc failed");
+		return NULL;
+	}
+
+	if (vg->status & LVM_WRITE)
+		repstr[0] = 'w';
+	else
+		repstr[0] = 'r';
+
+	if (vg_is_resizeable(vg))
+		repstr[1] = 'z';
+	else
+		repstr[1] = '-';
+
+	if (vg_is_exported(vg))
+		repstr[2] = 'x';
+	else
+		repstr[2] = '-';
+
+	if (vg_missing_pv_count(vg))
+		repstr[3] = 'p';
+	else
+		repstr[3] = '-';
+
+	repstr[4] = alloc_policy_char(vg->alloc);
+
+	if (vg_is_clustered(vg))
+		repstr[5] = 'c';
+	else
+		repstr[5] = '-';
+	return repstr;
+}
--- LVM2/lib/metadata/vg.h	2010/09/30 13:16:55	1.1
+++ LVM2/lib/metadata/vg.h	2010/09/30 13:52:56	1.2
@@ -123,5 +123,6 @@
 
 uint64_t vg_mda_size(const struct volume_group *vg);
 uint64_t vg_mda_free(const struct volume_group *vg);
+char *vg_attr_dup(struct dm_pool *mem, const struct volume_group *vg);
 
 #endif
--- LVM2/lib/report/columns.h	2010/08/20 12:44:17	1.44
+++ LVM2/lib/report/columns.h	2010/09/30 13:52:57	1.45
@@ -93,7 +93,7 @@
 FIELD(PVS, pv, NUM, "PSize", id, 5, pvsize, pv_size, "Size of PV in current units.", 0)
 FIELD(PVS, pv, NUM, "PFree", id, 5, pvfree, pv_free, "Total amount of unallocated space in current units.", 0)
 FIELD(PVS, pv, NUM, "Used", id, 4, pvused, pv_used, "Total amount of allocated space in current units.", 0)
-FIELD(PVS, pv, STR, "Attr", status, 4, pvstatus, pv_attr, "Various attributes - see man page.", 0)
+FIELD(PVS, pv, STR, "Attr", id, 4, pvstatus, pv_attr, "Various attributes - see man page.", 0)
 FIELD(PVS, pv, NUM, "PE", pe_count, 3, uint32, pv_pe_count, "Total number of Physical Extents.", 0)
 FIELD(PVS, pv, NUM, "Alloc", pe_alloc_count, 5, uint32, pv_pe_alloc_count, "Total number of allocated Physical Extents.", 0)
 FIELD(PVS, pv, STR, "PV Tags", tags, 7, tags, pv_tags, "Tags, if any.", 0)
--- LVM2/lib/report/report.c	2010/08/20 12:44:17	1.127
+++ LVM2/lib/report/report.c	2010/09/30 13:52:57	1.128
@@ -34,22 +34,6 @@
 	struct pv_segment *pvseg;
 };
 
-static char _alloc_policy_char(alloc_policy_t alloc)
-{
-	switch (alloc) {
-	case ALLOC_CONTIGUOUS:
-		return 'c';
-	case ALLOC_CLING:
-		return 'l';
-	case ALLOC_NORMAL:
-		return 'n';
-	case ALLOC_ANYWHERE:
-		return 'a';
-	default:
-		return 'i';
-	}
-}
-
 static const uint64_t _minusone64 = UINT64_C(-1);
 static const int32_t _minusone32 = INT32_C(-1);
 
@@ -264,124 +248,16 @@
 	return dm_report_field_int32(rh, field, &_minusone32);
 }
 
-static int _lv_mimage_in_sync(const struct logical_volume *lv)
-{
-	float percent;
-	percent_range_t percent_range;
-	struct lv_segment *mirror_seg = find_mirror_seg(first_seg(lv));
-
-	if (!(lv->status & MIRROR_IMAGE) || !mirror_seg)
-		return_0;
-
-	if (!lv_mirror_percent(lv->vg->cmd, mirror_seg->lv, 0, &percent,
-			       &percent_range, NULL))
-		return_0;
-
-	return (percent_range == PERCENT_100) ? 1 : 0;
-}
-
 static int _lvstatus_disp(struct dm_report *rh __attribute__((unused)), struct dm_pool *mem,
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	struct lvinfo info;
 	char *repstr;
-	float snap_percent;
-	percent_range_t percent_range;
 
-	if (!(repstr = dm_pool_zalloc(mem, 7))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = lv_attr_dup(mem, lv)))
 		return 0;
-	}
-
-	/* Blank if this is a "free space" LV. */
-	if (!*lv->name)
-		goto out;
-
-	if (lv->status & PVMOVE)
-		repstr[0] = 'p';
-	else if (lv->status & CONVERTING)
-		repstr[0] = 'c';
-	else if (lv->status & VIRTUAL)
-		repstr[0] = 'v';
-	/* Origin takes precedence over Mirror */
-	else if (lv_is_origin(lv)) {
-		if (lv_is_merging_origin(lv))
-			repstr[0] = 'O';
-		else
-			repstr[0] = 'o';
-	}
-	else if (lv->status & MIRRORED) {
-		if (lv->status & MIRROR_NOTSYNCED)
-			repstr[0] = 'M';
-		else
-			repstr[0] = 'm';
-	}else if (lv->status & MIRROR_IMAGE)
-		if (_lv_mimage_in_sync(lv))
-			repstr[0] = 'i';
-		else
-			repstr[0] = 'I';
-	else if (lv->status & MIRROR_LOG)
-		repstr[0] = 'l';
-	else if (lv_is_cow(lv)) {
-		if (lv_is_merging_cow(lv))
-			repstr[0] = 'S';
-		else
-			repstr[0] = 's';
-	} else
-		repstr[0] = '-';
-
-	if (lv->status & PVMOVE)
-		repstr[1] = '-';
-	else if (lv->status & LVM_WRITE)
-		repstr[1] = 'w';
-	else if (lv->status & LVM_READ)
-		repstr[1] = 'r';
-	else
-		repstr[1] = '-';
-
-	repstr[2] = _alloc_policy_char(lv->alloc);
-
-	if (lv->status & LOCKED)
-		repstr[2] = toupper(repstr[2]);
-
-	if (lv->status & FIXED_MINOR)
-		repstr[3] = 'm';	/* Fixed Minor */
-	else
-		repstr[3] = '-';
 
-	if (lv_info(lv->vg->cmd, lv, 0, &info, 1, 0) && info.exists) {
-		if (info.suspended)
-			repstr[4] = 's';	/* Suspended */
-		else if (info.live_table)
-			repstr[4] = 'a';	/* Active */
-		else if (info.inactive_table)
-			repstr[4] = 'i';	/* Inactive with table */
-		else
-			repstr[4] = 'd';	/* Inactive without table */
-
-		/* Snapshot dropped? */
-		if (info.live_table && lv_is_cow(lv) &&
-		    (!lv_snapshot_percent(lv, &snap_percent, &percent_range) ||
-		     percent_range == PERCENT_INVALID)) {
-			repstr[0] = toupper(repstr[0]);
-			if (info.suspended)
-				repstr[4] = 'S'; /* Susp Inv snapshot */
-			else
-				repstr[4] = 'I'; /* Invalid snapshot */
-		}
-
-		if (info.open_count)
-			repstr[5] = 'o';	/* Open */
-		else
-			repstr[5] = '-';
-	} else {
-		repstr[4] = '-';
-		repstr[5] = '-';
-	}
-
-out:
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
 }
@@ -390,23 +266,12 @@
 			  struct dm_report_field *field,
 			  const void *data, void *private __attribute__((unused)))
 {
-	const uint32_t status = *(const uint32_t *) data;
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 3))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = pv_attr_dup(mem, pv)))
 		return 0;
-	}
-
-	if (status & ALLOCATABLE_PV)
-		repstr[0] = 'a';
-	else
-		repstr[0] = '-';
-
-	if (status & EXPORTED_VG)
-		repstr[1] = 'x';
-	else
-		repstr[1] = '-';
 
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;
@@ -419,37 +284,8 @@
 	const struct volume_group *vg = (const struct volume_group *) data;
 	char *repstr;
 
-	if (!(repstr = dm_pool_zalloc(mem, 7))) {
-		log_error("dm_pool_alloc failed");
+	if (!(repstr = vg_attr_dup(mem, vg)))
 		return 0;
-	}
-
-	if (vg->status & LVM_WRITE)
-		repstr[0] = 'w';
-	else
-		repstr[0] = 'r';
-
-	if (vg_is_resizeable(vg))
-		repstr[1] = 'z';
-	else
-		repstr[1] = '-';
-
-	if (vg_is_exported(vg))
-		repstr[2] = 'x';
-	else
-		repstr[2] = '-';
-
-	if (vg_missing_pv_count(vg))
-		repstr[3] = 'p';
-	else
-		repstr[3] = '-';
-
-	repstr[4] = _alloc_policy_char(vg->alloc);
-
-	if (vg_is_clustered(vg))
-		repstr[5] = 'c';
-	else
-		repstr[5] = '-';
 
 	dm_report_field_set_value(field, repstr, NULL);
 	return 1;



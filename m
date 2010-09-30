From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Sep 2010 14:09:11 -0000
Subject: LVM2/lib metadata/pv.c metadata/pv.h report/re ...
Message-ID: <20100930140911.18183.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-09-30 14:09:11

Modified files:
	lib/metadata   : pv.c pv.h 
	lib/report     : report.c 

Log message:
	Add pv_mda_size, pv_mda_free, and pv_used functions, call from 'disp' functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv.h.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.130&r2=1.131

--- LVM2/lib/metadata/pv.c	2010/09/30 14:08:20	1.5
+++ LVM2/lib/metadata/pv.c	2010/09/30 14:09:10	1.6
@@ -187,6 +187,50 @@
 	return repstr;
 }
 
+uint64_t pv_mda_size(const struct physical_volume *pv)
+{
+	struct lvmcache_info *info;
+	uint64_t min_mda_size = 0;
+	const char *pvid = (const char *)(&pv->id.uuid);
+
+	/* PVs could have 2 mdas of different sizes (rounding effect) */
+	if ((info = info_from_pvid(pvid, 0)))
+		min_mda_size = find_min_mda_size(&info->mdas);
+	return min_mda_size;
+}
+
+uint64_t pv_mda_free(const struct physical_volume *pv)
+{
+	struct lvmcache_info *info;
+	uint64_t freespace = UINT64_MAX, mda_free;
+	const char *pvid = (const char *)&pv->id.uuid;
+	struct metadata_area *mda;
+
+	if ((info = info_from_pvid(pvid, 0)))
+		dm_list_iterate_items(mda, &info->mdas) {
+			if (!mda->ops->mda_free_sectors)
+				continue;
+			mda_free = mda->ops->mda_free_sectors(mda);
+			if (mda_free < freespace)
+				freespace = mda_free;
+		}
+
+	if (freespace == UINT64_MAX)
+		freespace = UINT64_C(0);
+	return freespace;
+}
+
+uint64_t pv_used(const struct physical_volume *pv)
+{
+	uint64_t used;
+
+	if (!pv->pe_count)
+		used = 0LL;
+	else
+		used = (uint64_t) pv->pe_alloc_count * pv->pe_size;
+	return used;
+}
+
 unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned mda_ignored)
 {
 	struct lvmcache_info *info;
--- LVM2/lib/metadata/pv.h	2010/09/30 14:08:20	1.4
+++ LVM2/lib/metadata/pv.h	2010/09/30 14:09:10	1.5
@@ -67,6 +67,9 @@
 uint64_t pv_pe_start(const struct physical_volume *pv);
 uint32_t pv_pe_count(const struct physical_volume *pv);
 uint32_t pv_pe_alloc_count(const struct physical_volume *pv);
+uint64_t pv_mda_size(const struct physical_volume *pv);
+uint64_t pv_mda_free(const struct physical_volume *pv);
+uint64_t pv_used(const struct physical_volume *pv);
 uint32_t pv_mda_count(const struct physical_volume *pv);
 uint32_t pv_mda_used_count(const struct physical_volume *pv);
 unsigned pv_mda_set_ignored(const struct physical_volume *pv, unsigned ignored);
--- LVM2/lib/report/report.c	2010/09/30 14:08:07	1.130
+++ LVM2/lib/report/report.c	2010/09/30 14:09:10	1.131
@@ -597,10 +597,7 @@
 	    (const struct physical_volume *) data;
 	uint64_t used;
 
-	if (!pv->pe_count)
-		used = 0LL;
-	else
-		used = (uint64_t) pv->pe_alloc_count * pv->pe_size;
+	used = pv_used(pv);
 
 	return _size64_disp(rh, mem, field, &used, private);
 }
@@ -754,22 +751,11 @@
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
-	struct lvmcache_info *info;
-	uint64_t freespace = UINT64_MAX, mda_free;
-	const char *pvid = (const char *)(&((const struct id *) data)->uuid);
-	struct metadata_area *mda;
-
-	if ((info = info_from_pvid(pvid, 0)))
-		dm_list_iterate_items(mda, &info->mdas) {
-			if (!mda->ops->mda_free_sectors)
-				continue;
-			mda_free = mda->ops->mda_free_sectors(mda);
-			if (mda_free < freespace)
-				freespace = mda_free;
-		}
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
+	uint64_t freespace;
 
-	if (freespace == UINT64_MAX)
-		freespace = UINT64_C(0);
+	freespace = pv_mda_free(pv);
 
 	return _size64_disp(rh, mem, field, &freespace, private);
 }
@@ -778,13 +764,11 @@
 			   struct dm_report_field *field,
 			   const void *data, void *private)
 {
-	struct lvmcache_info *info;
-	uint64_t min_mda_size = 0;
-	const char *pvid = (const char *)(&((const struct id *) data)->uuid);
-
-	/* PVs could have 2 mdas of different sizes (rounding effect) */
-	if ((info = info_from_pvid(pvid, 0)))
-		min_mda_size = find_min_mda_size(&info->mdas);
+	const struct physical_volume *pv =
+	    (const struct physical_volume *) data;
+	uint64_t min_mda_size;
+
+	min_mda_size = pv_mda_size(pv);
 
 	return _size64_disp(rh, mem, field, &min_mda_size, private);
 }



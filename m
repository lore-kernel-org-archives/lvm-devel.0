From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Mar 2011 12:14:01 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv.c lib/metadat ...
Message-ID: <20110305121401.18101.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-05 12:14:00

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv.c lv.h 
	lib/report     : properties.c report.c 

Log message:
	Fix reading of released memory
	
	lvseg_segtype_dup used memory pool vg memory pool for strind duplication.
	However this one gets released before reporting happens so the command like:
	
	pvs -o segtype
	
	prints data from already released memory pool. Thanks to the fact there
	is not much allocation happing after the VG is released, the memory
	stays unmodified and correct result is printed.
	
	Fix adds support for mempool passed parameter (like other similar
	query commands) and uses dm_report memory pool for string duplication.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1934&r2=1.1935
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.h.diff?cvsroot=lvm2&r1=1.18&r2=1.19
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/properties.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143

--- LVM2/WHATS_NEW	2011/03/02 23:38:22	1.1934
+++ LVM2/WHATS_NEW	2011/03/05 12:14:00	1.1935
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix reading of released memory for printing segment type.
   Fix syslog initialisation in clvmd to respect lvm.conf setting.
   Fix possible overflow in maximum stripe size and physical extent size.
   Add test for failed allocation from dm_task_set_uuid() in dmeventd.
--- LVM2/lib/metadata/lv.c	2010/11/30 11:53:32	1.20
+++ LVM2/lib/metadata/lv.c	2011/03/05 12:14:00	1.21
@@ -26,13 +26,13 @@
 	return tags_format_and_copy(seg->lv->vg->vgmem, &seg->tags);
 }
 
-char *lvseg_segtype_dup(const struct lv_segment *seg)
+char *lvseg_segtype_dup(struct dm_pool *mem, const struct lv_segment *seg)
 {
 	if (seg->area_count == 1) {
 		return (char *)"linear";
 	}
 
-	return dm_pool_strdup(seg->lv->vg->vgmem, seg->segtype->ops->name(seg));
+	return dm_pool_strdup(mem, seg->segtype->ops->name(seg));
 }
 
 uint64_t lvseg_chunksize(const struct lv_segment *seg)
--- LVM2/lib/metadata/lv.h	2011/02/18 14:47:30	1.18
+++ LVM2/lib/metadata/lv.h	2011/03/05 12:14:00	1.19
@@ -66,7 +66,7 @@
 uint64_t lvseg_start(const struct lv_segment *seg);
 uint64_t lvseg_size(const struct lv_segment *seg);
 uint64_t lvseg_chunksize(const struct lv_segment *seg);
-char *lvseg_segtype_dup(const struct lv_segment *seg);
+char *lvseg_segtype_dup(struct dm_pool *mem, const struct lv_segment *seg);
 char *lvseg_tags_dup(const struct lv_segment *seg);
 
 #endif /* _LVM_LV_H */
--- LVM2/lib/report/properties.c	2011/02/18 14:47:30	1.29
+++ LVM2/lib/report/properties.c	2011/03/05 12:14:00	1.30
@@ -225,7 +225,7 @@
 SET_VG_NUM_PROPERTY_FN(vg_mda_copies, vg_set_mda_copies)
 
 /* LVSEG */
-GET_LVSEG_STR_PROPERTY_FN(segtype, lvseg_segtype_dup(lvseg))
+GET_LVSEG_STR_PROPERTY_FN(segtype, lvseg_segtype_dup(lvseg->lv->vg->vgmem, lvseg))
 #define _segtype_set _not_implemented_set
 GET_LVSEG_NUM_PROPERTY_FN(stripes, lvseg->area_count)
 #define _stripes_set _not_implemented_set
--- LVM2/lib/report/report.c	2011/02/18 14:47:30	1.142
+++ LVM2/lib/report/report.c	2011/03/05 12:14:00	1.143
@@ -278,9 +278,13 @@
 			 const void *data, void *private __attribute__((unused)))
 {
 	const struct lv_segment *seg = (const struct lv_segment *) data;
-
 	char *name;
-	name = lvseg_segtype_dup(seg);
+
+	if (!(name = lvseg_segtype_dup(mem, seg))) {
+		log_error("Failed to get segtype.");
+		return 0;
+	}
+
 	dm_report_field_set_value(field, name, NULL);
 	return 1;
 }



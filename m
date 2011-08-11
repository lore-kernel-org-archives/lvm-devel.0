From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Aug 2011 03:29:52 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c lib/m ...
Message-ID: <20110811032952.25429.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-11 03:29:52

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c metadata-exported.h 

Log message:
	Fix renaming of RAID logical volumes.
	
	The function 'for_each_sub_lv', which rename uses, was not handling the
	RAID metadata areas.  Thus, the metadata LVs were not being renamed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2058&r2=1.2059
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.271&r2=1.272
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.196&r2=1.197

--- LVM2/WHATS_NEW	2011/08/10 20:25:29	1.2058
+++ LVM2/WHATS_NEW	2011/08/11 03:29:51	1.2059
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Fix renaming of RAID logical volumes.
   Replace free_vg with release_vg and move it to vg.c.
   Remove INCONSISTENT_VG flag from the code.
   Remove lock from cache even if unlock fails.
--- LVM2/lib/metadata/lv_manip.c	2011/08/10 16:44:17	1.271
+++ LVM2/lib/metadata/lv_manip.c	2011/08/11 03:29:52	1.272
@@ -2595,6 +2595,19 @@
 			if (!for_each_sub_lv(cmd, seg_lv(seg, s), fn, data))
 				return_0;
 		}
+
+		if (!seg_is_raid(seg))
+			continue;
+
+		/* RAID has meta_areas */
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_metatype(seg, s) != AREA_LV)
+				continue;
+			if (!fn(cmd, seg_metalv(seg, s), data))
+				return_0;
+			if (!for_each_sub_lv(cmd, seg_metalv(seg, s), fn, data))
+				return_0;
+		}
 	}
 
 	return 1;
--- LVM2/lib/metadata/metadata-exported.h	2011/08/10 20:25:30	1.196
+++ LVM2/lib/metadata/metadata-exported.h	2011/08/11 03:29:52	1.197
@@ -330,6 +330,7 @@
 #define seg_pv(seg, s)		(seg)->areas[(s)].u.pv.pvseg->pv
 #define seg_lv(seg, s)		(seg)->areas[(s)].u.lv.lv
 #define seg_metalv(seg, s)	(seg)->meta_areas[(s)].u.lv.lv
+#define seg_metatype(seg, s)	(seg)->meta_areas[(s)].type
 
 struct pe_range {
 	struct dm_list list;



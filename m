From: agk@sourceware.org <agk@sourceware.org>
Date: 28 May 2009 00:29:15 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20090528002915.13084.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-28 00:29:15

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Rename internal vorigin LV to match visible LV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1129&r2=1.1130
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.175&r2=1.176

--- LVM2/WHATS_NEW	2009/05/27 18:19:21	1.1129
+++ LVM2/WHATS_NEW	2009/05/28 00:29:14	1.1130
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Rename internal vorigin LV to match visible LV.
   Suppress 'removed' messages displayed when internal LVs are removed.
   Fix lvchange -a and -p for sparse LVs.
   Fix lvcreate --virtualsize to activate the new device immediately.
--- LVM2/lib/metadata/lv_manip.c	2009/05/27 18:19:21	1.175
+++ LVM2/lib/metadata/lv_manip.c	2009/05/28 00:29:15	1.176
@@ -1700,19 +1700,24 @@
 					void *data),
 			    void *data)
 {
+	struct logical_volume *org;
 	struct lv_segment *seg;
 	uint32_t s;
 
+	if (lv_is_cow(lv) && lv_is_virtual_origin(org = origin_from_cow(lv)))
+		if (!func(cmd, org, data))
+			return_0;
+
 	dm_list_iterate_items(seg, &lv->segments) {
 		if (seg->log_lv && !func(cmd, seg->log_lv, data))
-			return 0;
+			return_0;
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
 			if (!func(cmd, seg_lv(seg, s), data))
-				return 0;
+				return_0;
 			if (!_for_each_sub_lv(cmd, seg_lv(seg, s), func, data))
-				return 0;
+				return_0;
 		}
 	}
 


